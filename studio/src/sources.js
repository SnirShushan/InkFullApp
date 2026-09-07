import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import dotenv from 'dotenv';
import mysql from 'mysql2/promise';
import Database from 'better-sqlite3';
import { importDump, needsImport } from './import-dump.js';
import { TABLE_GROUPS, friendlyName } from './catalog.js';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const DUMP = path.resolve(ROOT, '..', 'data', 'inkisrael_app.sql');
const DB_PATH = path.join(ROOT, 'data', 'inkisrael.sqlite');

dotenv.config({
  path: path.resolve(ROOT, '..', 'app', 'api', '.env'),
});
delete process.env.PORT;

const IDENT = /^[A-Za-z0-9_]+$/;

function groupTables(tables) {
  const grouped = TABLE_GROUPS.map((g) => ({
    ...g,
    tables: g.tables
      .map((name) => tables.find((t) => t.name === name))
      .filter(Boolean),
  })).filter((g) => g.tables.length);
  const extras = tables.filter((t) => !TABLE_GROUPS.some((g) => g.tables.includes(t.name)));
  if (extras.length) grouped.push({ id: 'other', label: 'אחר', tables: extras });
  return grouped;
}

function ensureMuseum() {
  if (!fs.existsSync(DUMP)) {
    throw new Error(`SQL dump not found: ${DUMP}`);
  }
  if (needsImport(DUMP, DB_PATH)) {
    console.log('Importing inkisrael_app.sql into SQLite…');
    importDump(DUMP, DB_PATH);
  } else {
    console.log('SQLite museum cache is up to date.');
  }
  const db = new Database(DB_PATH, { readonly: true, fileMustExist: true });
  db.pragma('query_only = ON');
  return db;
}

function createLivePool() {
  if (!process.env.DB_HOST || !process.env.DB_PASS) return null;
  return mysql.createPool({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME || 'inkisrael_app',
    waitForConnections: true,
    connectionLimit: 4,
    namedPlaceholders: true,
    charset: 'utf8mb4',
  });
}

export function createSources() {
  const sqlite = ensureMuseum();
  const livePool = createLivePool();

  const museum = {
    id: 'museum',
    label: 'Museum dump',
    async listTables() {
      return sqlite
        .prepare(`SELECT name FROM sqlite_master WHERE type='table' AND name != '_meta' ORDER BY name`)
        .all()
        .map((r) => r.name);
    },
    async columns(table) {
      return sqlite.prepare(`PRAGMA table_info("${table}")`).all().map((c) => ({
        name: c.name,
        type: c.type,
      }));
    },
    async count(table, whereSql = '', params = {}) {
      return sqlite.prepare(`SELECT COUNT(*) AS c FROM "${table}" ${whereSql}`).get(params).c;
    },
    async rows(table, { whereSql, params, orderSql, limit, offset }) {
      return sqlite
        .prepare(`SELECT * FROM "${table}" ${whereSql} ${orderSql} LIMIT ${limit} OFFSET ${offset}`)
        .all(params);
    },
    async meta() {
      const rows = sqlite.prepare('SELECT k, v FROM _meta').all();
      return Object.fromEntries(rows.map((r) => [r.k, r.v]));
    },
    async ping() {
      return true;
    },
  };

  const live = {
    id: 'live',
    label: 'Live Railway',
    async listTables() {
      if (!livePool) return [];
      const [rows] = await livePool.query(
        `SELECT table_name AS name FROM information_schema.tables
         WHERE table_schema = DATABASE() AND table_type = 'BASE TABLE'
         ORDER BY table_name`
      );
      return rows.map((r) => r.name);
    },
    async columns(table) {
      const [rows] = await livePool.query(
        `SELECT COLUMN_NAME AS name, DATA_TYPE AS type
         FROM information_schema.columns
         WHERE table_schema = DATABASE() AND table_name = :table
         ORDER BY ORDINAL_POSITION`,
        { table }
      );
      return rows.map((c) => ({ name: c.name, type: String(c.type || '').toUpperCase() }));
    },
    async count(table, whereSql = '', params = {}) {
      const [rows] = await livePool.query(
        `SELECT COUNT(*) AS c FROM \`${table}\` ${whereSql}`,
        params
      );
      return Number(rows[0].c);
    },
    async rows(table, { whereSql, params, orderSql, limit, offset }) {
      const [rows] = await livePool.query(
        `SELECT * FROM \`${table}\` ${whereSql} ${orderSql} LIMIT ${limit} OFFSET ${offset}`,
        params
      );
      return rows;
    },
    async meta() {
      return {
        source: 'live',
        label: 'Railway MySQL',
        database: process.env.DB_NAME || 'inkisrael_app',
      };
    },
    async ping() {
      if (!livePool) return false;
      try {
        const [rows] = await livePool.query('SELECT 1 AS ok');
        return rows?.[0]?.ok === 1;
      } catch (err) {
        console.error('Live DB ping failed:', err.message);
        return false;
      }
    },
  };

  async function overviewFor(source) {
    const names = await source.listTables();
    const tables = [];
    for (const name of names) {
      const cols = await source.columns(name);
      const rows = await source.count(name);
      tables.push({
        name,
        label: friendlyName(name),
        rows,
        columns: cols.length,
      });
    }
    return {
      source: source.id,
      label: source.label,
      meta: await source.meta(),
      liveAvailable: Boolean(livePool) && (await live.ping()),
      totalRows: tables.reduce((s, t) => s + t.rows, 0),
      tableCount: tables.length,
      groups: groupTables(tables),
      tables,
    };
  }

  async function queryTable(source, table, { page, limit, q, sort, dir }) {
    const names = await source.listTables();
    if (!IDENT.test(table) || !names.includes(table)) {
      const err = new Error('Unknown table');
      err.status = 404;
      throw err;
    }
    const cols = await source.columns(table);
    const colNames = cols.map((c) => c.name);
    const safePage = Math.max(1, Number(page) || 1);
    const safeLimit = Math.min(200, Math.max(10, Number(limit) || 50));
    const offset = (safePage - 1) * safeLimit;
    const query = String(q || '').trim();
    const sortCol = IDENT.test(String(sort || '')) ? String(sort) : '';
    const direction = String(dir || 'asc').toLowerCase() === 'desc' ? 'DESC' : 'ASC';

    const params = {};
    let whereSql = '';
    if (query) {
      const likes = colNames.map((c, i) => {
        params[`p${i}`] = `%${query}%`;
        const cast = source.id === 'live' ? `CAST(\`${c}\` AS CHAR)` : `CAST("${c}" AS TEXT)`;
        const ph = source.id === 'live' ? `:p${i}` : `@p${i}`;
        return `${cast} LIKE ${ph}`;
      });
      whereSql = `WHERE ${likes.join(' OR ')}`;
    }

    const quote = source.id === 'live' ? '`' : '"';
    const orderSql = colNames.includes(sortCol)
      ? `ORDER BY ${quote}${sortCol}${quote} ${direction}`
      : colNames.includes('id')
        ? `ORDER BY ${quote}id${quote} DESC`
        : '';

    const total = await source.count(table, whereSql, params);
    const rows = await source.rows(table, { whereSql, params, orderSql, limit: safeLimit, offset });

    return {
      source: source.id,
      name: table,
      label: friendlyName(table),
      columns: cols,
      page: safePage,
      limit: safeLimit,
      total,
      pages: Math.max(1, Math.ceil(total / safeLimit)),
      rows,
    };
  }

  async function compare() {
    const museumNames = await museum.listTables();
    const liveOk = Boolean(livePool) && (await live.ping());
    const liveNames = liveOk ? await live.listTables() : [];
    const names = [...new Set([...museumNames, ...liveNames])].sort();
    const tables = [];
    for (const name of names) {
      const museumRows = museumNames.includes(name) ? await museum.count(name) : null;
      const liveRows = liveOk && liveNames.includes(name) ? await live.count(name) : null;
      tables.push({
        name,
        label: friendlyName(name),
        museum: museumRows,
        live: liveRows,
        delta: museumRows != null && liveRows != null ? liveRows - museumRows : null,
      });
    }
    return {
      liveAvailable: liveOk,
      changed: tables.filter((t) => t.delta !== 0 && t.delta != null || t.museum == null || t.live == null),
      tables,
    };
  }

  function sourceOf(id) {
    if (id === 'live') {
      if (!livePool) {
        const err = new Error('Live Railway database is not configured');
        err.status = 503;
        throw err;
      }
      return live;
    }
    return museum;
  }

  return {
    museum,
    live,
    liveConfigured: Boolean(livePool),
    getLivePool: () => livePool,
    overviewFor,
    queryTable,
    compare,
    sourceOf,
  };
}

export { IDENT };
