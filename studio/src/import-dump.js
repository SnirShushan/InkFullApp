import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import Database from 'better-sqlite3';

const INT_TYPES = /^(tinyint|smallint|mediumint|int|integer|bigint|bit|bool|boolean)$/i;
const REAL_TYPES = /^(float|double|decimal|dec|numeric|real)$/i;
const BLOB_TYPES = /^(blob|tinyblob|mediumblob|longblob|binary|varbinary)$/i;

export function skipSpaceAndComments(sql, i) {
  const n = sql.length;
  while (i < n) {
    const c = sql[i];
    if (c === ' ' || c === '\t' || c === '\n' || c === '\r') {
      i++;
      continue;
    }
    if (c === '-' && sql[i + 1] === '-') {
      i += 2;
      while (i < n && sql[i] !== '\n') i++;
      continue;
    }
    if (c === '/' && sql[i + 1] === '*') {
      i += 2;
      while (i < n && !(sql[i] === '*' && sql[i + 1] === '/')) i++;
      i = Math.min(n, i + 2);
      continue;
    }
    break;
  }
  return i;
}

export function parseSqlString(sql, i) {
  const quote = sql[i];
  if (quote !== "'" && quote !== '"') {
    throw new Error(`Expected quote at ${i}`);
  }
  let out = '';
  i++;
  while (i < sql.length) {
    const c = sql[i];
    if (c === '\\' && i + 1 < sql.length) {
      const n = sql[i + 1];
      const map = {
        n: '\n',
        r: '\r',
        t: '\t',
        b: '\b',
        0: '\0',
        Z: '\x1a',
        "'": "'",
        '"': '"',
        '\\': '\\',
      };
      out += map[n] !== undefined ? map[n] : n;
      i += 2;
      continue;
    }
    if (c === quote && sql[i + 1] === quote) {
      out += quote;
      i += 2;
      continue;
    }
    if (c === quote) {
      return { value: out, next: i + 1 };
    }
    out += c;
    i++;
  }
  throw new Error('Unterminated SQL string');
}

function readStatement(sql, start) {
  let i = start;
  let inQuote = null;
  while (i < sql.length) {
    const c = sql[i];
    if (inQuote) {
      if (c === '\\' && inQuote === "'") {
        i += 2;
        continue;
      }
      if (c === inQuote && sql[i + 1] === inQuote) {
        i += 2;
        continue;
      }
      if (c === inQuote) inQuote = null;
      i++;
      continue;
    }
    if (c === "'" || c === '"') {
      inQuote = c;
      i++;
      continue;
    }
    if (c === '-' && sql[i + 1] === '-') {
      while (i < sql.length && sql[i] !== '\n') i++;
      continue;
    }
    if (c === '/' && sql[i + 1] === '*') {
      i += 2;
      while (i < sql.length && !(sql[i] === '*' && sql[i + 1] === '/')) i++;
      i += 2;
      continue;
    }
    if (c === ';') {
      return { stmt: sql.slice(start, i), next: i + 1 };
    }
    i++;
  }
  return { stmt: sql.slice(start), next: sql.length };
}

function parseValue(sql, i) {
  i = skipSpaceAndComments(sql, i);
  const slice4 = sql.slice(i, i + 4).toUpperCase();
  if (slice4 === 'NULL' && !/[A-Za-z0-9_]/.test(sql[i + 4] || '')) {
    return { value: null, next: i + 4 };
  }
  if (sql[i] === "'" || sql[i] === '"') {
    return parseSqlString(sql, i);
  }
  if (sql[i] === '0' && (sql[i + 1] === 'x' || sql[i + 1] === 'X')) {
    let j = i + 2;
    while (j < sql.length && /[0-9a-fA-F]/.test(sql[j])) j++;
    const hex = sql.slice(i + 2, j);
    let value = hex;
    try {
      const buf = Buffer.from(hex, 'hex');
      const text = buf.toString('utf8');
      if (text && !text.includes('\uFFFD') && /[\x09\x0a\x0d\x20-\x7e\u0080-\uFFFF]/.test(text)) {
        value = text;
      } else {
        value = buf.toString('latin1');
      }
    } catch {
      value = hex;
    }
    return { value, next: j };
  }
  if (sql[i] === '-' || sql[i] === '+' || /[0-9]/.test(sql[i])) {
    let j = i;
    if (sql[j] === '-' || sql[j] === '+') j++;
    while (j < sql.length && /[0-9.]/.test(sql[j])) j++;
    const raw = sql.slice(i, j);
    const num = Number(raw);
    return { value: Number.isFinite(num) && !raw.endsWith('.') ? num : raw, next: j };
  }
  throw new Error(`Unexpected SQL value at ${i}: ${sql.slice(i, i + 40)}`);
}

function parseTuple(sql, i) {
  i = skipSpaceAndComments(sql, i);
  if (sql[i] !== '(') throw new Error(`Expected '(' at ${i}`);
  i++;
  const values = [];
  while (true) {
    i = skipSpaceAndComments(sql, i);
    if (sql[i] === ')') return { values, next: i + 1 };
    const parsed = parseValue(sql, i);
    values.push(parsed.value);
    i = skipSpaceAndComments(sql, parsed.next);
    if (sql[i] === ',') {
      i++;
      continue;
    }
    if (sql[i] === ')') return { values, next: i + 1 };
    throw new Error(`Expected ',' or ')' at ${i}: ${sql.slice(i, i + 30)}`);
  }
}

function splitTopLevel(sql, sep) {
  const parts = [];
  let start = 0;
  let depth = 0;
  let inQuote = null;
  for (let i = 0; i < sql.length; i++) {
    const c = sql[i];
    if (inQuote) {
      if (c === '\\' && inQuote === "'") {
        i++;
        continue;
      }
      if (c === inQuote && sql[i + 1] === inQuote) {
        i++;
        continue;
      }
      if (c === inQuote) inQuote = null;
      continue;
    }
    if (c === "'" || c === '"') {
      inQuote = c;
      continue;
    }
    if (c === '(') depth++;
    else if (c === ')') depth--;
    else if (c === sep && depth === 0) {
      parts.push(sql.slice(start, i));
      start = i + 1;
    }
  }
  parts.push(sql.slice(start));
  return parts;
}

function stripCommentClause(rest) {
  const match = rest.match(/\bCOMMENT\b/i);
  if (!match) return rest.trim();
  const idx = match.index;
  let i = idx + match[0].length;
  while (rest[i] === ' ' || rest[i] === '\t') i++;
  if (rest[i] === "'" || rest[i] === '"') {
    const { next } = parseSqlString(rest, i);
    return (rest.slice(0, idx) + rest.slice(next)).trim();
  }
  return rest.slice(0, idx).trim();
}

export function convertCreateTable(stmt) {
  const nameMatch = stmt.match(/^CREATE TABLE\s+`([^`]+)`\s*\(/i);
  if (!nameMatch) throw new Error('Could not parse CREATE TABLE name');
  const table = nameMatch[1];
  const open = stmt.indexOf('(');
  const close = stmt.lastIndexOf(')');
  const body = stmt.slice(open + 1, close);
  const lines = splitTopLevel(body, ',');
  const cols = [];
  for (const raw of lines) {
    const line = raw.trim();
    if (!line) continue;
    if (/^(PRIMARY|UNIQUE|KEY|INDEX|CONSTRAINT|FULLTEXT|SPATIAL)\b/i.test(line)) continue;
    const colMatch = line.match(/^`([^`]+)`\s+([\s\S]+)$/);
    if (!colMatch) continue;
    const name = colMatch[1];
    let rest = colMatch[2];
    rest = rest.replace(/CHARACTER SET\s+\S+/gi, '');
    rest = rest.replace(/COLLATE\s+\S+/gi, '');
    rest = rest.replace(/\bUNSIGNED\b/gi, '');
    rest = rest.replace(/\bZEROFILL\b/gi, '');
    rest = rest.replace(/\bAUTO_INCREMENT\b/gi, '');
    rest = rest.replace(/\bON UPDATE\s+[A-Za-z0-9_().]+/gi, '');
    rest = stripCommentClause(rest);
    const typeMatch = rest.match(/^(\w+)(\([^)]*\))?(.*)$/s);
    const mysqlType = (typeMatch?.[1] || 'text').toLowerCase();
    let sqliteType = 'TEXT';
    if (INT_TYPES.test(mysqlType)) sqliteType = 'INTEGER';
    else if (REAL_TYPES.test(mysqlType)) sqliteType = 'REAL';
    else if (BLOB_TYPES.test(mysqlType)) sqliteType = 'BLOB';
    let extras = (typeMatch?.[3] || '').replace(/\s+/g, ' ').trim();
    extras = extras.replace(/\bCURRENT_TIMESTAMP\(\)/gi, 'CURRENT_TIMESTAMP');
    cols.push({ name, sqliteType, extras });
  }
  const colSql = cols
    .map((c) => `"${c.name}" ${c.sqliteType}${c.extras ? ` ${c.extras}` : ''}`)
    .join(',\n  ');
  return {
    table,
    columns: cols.map((c) => c.name),
    sql: `CREATE TABLE "${table}" (\n  ${colSql}\n)`,
  };
}

function parseInsert(stmt) {
  const head = stmt.match(
    /^INSERT INTO\s+`([^`]+)`\s*(?:\(([\s\S]*?)\))?\s*VALUES\s*/i
  );
  if (!head) throw new Error('Could not parse INSERT INTO');
  const table = head[1];
  const columns = head[2]
    ? [...head[2].matchAll(/`([^`]+)`/g)].map((m) => m[1])
    : null;
  let i = head[0].length;
  const rows = [];
  while (i < stmt.length) {
    i = skipSpaceAndComments(stmt, i);
    if (i >= stmt.length) break;
    if (stmt[i] === ';') break;
    if (stmt[i] === ',') {
      i++;
      continue;
    }
    if (stmt[i] !== '(') break;
    const tup = parseTuple(stmt, i);
    rows.push(tup.values);
    i = tup.next;
  }
  return { table, columns, rows };
}

export function importDump(dumpPath, dbPath, { onProgress } = {}) {
  const sql = fs.readFileSync(dumpPath, 'utf8');
  fs.mkdirSync(path.dirname(dbPath), { recursive: true });
  if (fs.existsSync(dbPath)) fs.unlinkSync(dbPath);

  const db = new Database(dbPath);
  db.pragma('journal_mode = WAL');
  db.pragma('synchronous = OFF');
  db.pragma('foreign_keys = OFF');

  db.exec(`CREATE TABLE _meta (k TEXT PRIMARY KEY, v TEXT)`);
  const setMeta = db.prepare('INSERT INTO _meta (k, v) VALUES (?, ?)');

  const stat = fs.statSync(dumpPath);
  db.transaction(() => {
    setMeta.run('dump_path', dumpPath);
    setMeta.run('dump_mtime', String(stat.mtimeMs));
    setMeta.run('dump_size', String(stat.size));
    setMeta.run('imported_at', new Date().toISOString());
  })();

  const tables = new Map();
  const insertFns = new Map();
  let i = 0;
  let created = 0;
  let inserted = 0;
  const tx = db.transaction((rows, run) => {
    for (const row of rows) run(row);
  });

  const log = onProgress || ((msg) => console.log(msg));
  log(`Reading dump (${(stat.size / 1024 / 1024).toFixed(1)} MB)…`);

  while (i < sql.length) {
    i = skipSpaceAndComments(sql, i);
    if (i >= sql.length) break;
    const upper = sql.slice(i, i + 12).toUpperCase();
    if (upper.startsWith('CREATE TABLE')) {
      const { stmt, next } = readStatement(sql, i);
      const converted = convertCreateTable(stmt.trim());
      db.exec(`DROP TABLE IF EXISTS "${converted.table}"`);
      db.exec(converted.sql);
      tables.set(converted.table, converted.columns);
      created++;
      log(`Created ${converted.table} (${converted.columns.length} columns)`);
      i = next;
      continue;
    }
    if (upper.startsWith('INSERT INTO')) {
      const { stmt, next } = readStatement(sql, i);
      const parsed = parseInsert(stmt.trim());
      const cols = parsed.columns || tables.get(parsed.table);
      if (!cols) {
        throw new Error(`INSERT for unknown table ${parsed.table}`);
      }
      const key = `${parsed.table}:${cols.join(',')}`;
      if (!insertFns.has(key)) {
        const placeholders = cols.map(() => '?').join(', ');
        const colSql = cols.map((c) => `"${c}"`).join(', ');
        insertFns.set(
          key,
          db.prepare(`INSERT INTO "${parsed.table}" (${colSql}) VALUES (${placeholders})`)
        );
      }
      const run = insertFns.get(key);
      const aligned = parsed.rows.map((row) => {
        if (row.length === cols.length) return row;
        const copy = row.slice(0, cols.length);
        while (copy.length < cols.length) copy.push(null);
        return copy;
      });
      tx(aligned, (row) => run.run(row));
      inserted += aligned.length;
      log(`  + ${aligned.length.toLocaleString()} rows → ${parsed.table} (total ${inserted.toLocaleString()})`);
      i = next;
      continue;
    }
    i = readStatement(sql, i).next;
  }

  db.pragma('synchronous = NORMAL');
  const counts = {};
  for (const name of tables.keys()) {
    counts[name] = db.prepare(`SELECT COUNT(*) AS c FROM "${name}"`).get().c;
  }
  setMeta.run('table_count', String(tables.size));
  db.close();
  log(`Done. ${created} tables, ${inserted.toLocaleString()} rows imported.`);
  return { created, inserted, counts };
}

export function needsImport(dumpPath, dbPath) {
  if (!fs.existsSync(dbPath)) return true;
  try {
    const db = new Database(dbPath, { readonly: true, fileMustExist: true });
    const rows = Object.fromEntries(
      db.prepare('SELECT k, v FROM _meta').all().map((r) => [r.k, r.v])
    );
    db.close();
    const stat = fs.statSync(dumpPath);
    return (
      rows.dump_mtime !== String(stat.mtimeMs) ||
      rows.dump_size !== String(stat.size)
    );
  } catch {
    return true;
  }
}

const __filename = fileURLToPath(import.meta.url);
if (process.argv[1] && path.resolve(process.argv[1]) === __filename) {
  const root = path.resolve(path.dirname(__filename), '..');
  const dumpPath = process.argv[2] || path.resolve(root, '..', 'data', 'inkisrael_app.sql');
  const dbPath = process.argv[3] || path.join(root, 'data', 'inkisrael.sqlite');
  if (!fs.existsSync(dumpPath)) {
    console.error('Dump not found:', dumpPath);
    process.exit(1);
  }
  importDump(dumpPath, dbPath);
}
