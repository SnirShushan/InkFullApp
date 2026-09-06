/**
 * Full restore: parse ALL profile_image values from SQL dump,
 * match to OldAssets/profile_images, update live DB.
 *
 * node tools/backup/restore_all_profiles_from_sql.mjs
 */
import fs from 'fs';
import readline from 'readline';
import path from 'path';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../..');
dotenv.config({ path: path.join(repoRoot, 'backend/.env') });

const sqlPath = path.join(repoRoot, 'inkisrael_Database/inkisrael_app.sql');
const profileDir = path.join(repoRoot, 'OldAssets/uploads/profile_images');
const outPath = path.join(repoRoot, 'backups/sql_profile_image_map_full.json');

const disk = new Set(
  fs
    .readdirSync(profileDir)
    .filter((f) => !f.startsWith('.') && f !== 'index.html')
);

/**
 * INSERT lists columns; profile_image is after register_type.
 * Values: (id, name, email, phone, cnt_code, lang, user_type, is_business,
 *          business_type, login_type, register_type, profile_image, ...)
 */
function parseSqlStringLiterals(row) {
  const out = [];
  let i = 0;
  while (i < row.length) {
    if (row[i] !== "'") {
      i++;
      continue;
    }
    i++;
    let s = '';
    while (i < row.length) {
      if (row[i] === '\\') {
        s += row[i + 1] ?? '';
        i += 2;
        continue;
      }
      if (row[i] === "'" && row[i + 1] === "'") {
        s += "'";
        i += 2;
        continue;
      }
      if (row[i] === "'") {
        i++;
        break;
      }
      s += row[i++];
    }
    out.push(s);
  }
  return out;
}

function extractRows(buf) {
  // Split on "),(" boundaries carefully enough for our dump
  const rows = [];
  let depth = 0;
  let start = -1;
  for (let i = 0; i < buf.length; i++) {
    const ch = buf[i];
    if (ch === "'" ) {
      // skip string
      i++;
      while (i < buf.length) {
        if (buf[i] === '\\') {
          i += 2;
          continue;
        }
        if (buf[i] === "'" && buf[i + 1] === "'") {
          i += 2;
          continue;
        }
        if (buf[i] === "'") break;
        i++;
      }
      continue;
    }
    if (ch === '(') {
      if (depth === 0) start = i + 1;
      depth++;
    } else if (ch === ')') {
      depth--;
      if (depth === 0 && start >= 0) {
        rows.push(buf.slice(start, i));
        start = -1;
      }
    }
  }
  return rows;
}

const byId = new Map();
const rl = readline.createInterface({
  input: fs.createReadStream(sqlPath),
  crlfDelay: Infinity,
});

let inCustomer = false;
let buf = '';
let columns = null;

for await (const line of rl) {
  if (
    line.includes('INSERT INTO `tbl_customer`') ||
    line.includes('INSERT INTO tbl_customer')
  ) {
    inCustomer = true;
    buf = line;
    const colMatch = line.match(/INSERT INTO `?tbl_customer`?\s*\(([^)]+)\)/i);
    if (colMatch) {
      columns = colMatch[1].split(',').map((c) => c.replace(/[`\s]/g, ''));
    }
    if (line.trim().endsWith(';')) {
      // process below
    } else continue;
  } else if (inCustomer) {
    buf += '\n' + line;
    if (!line.trim().endsWith(';')) continue;
  } else continue;

  inCustomer = false;
  if (!columns) {
    buf = '';
    continue;
  }
  const profileIdx = columns.indexOf('profile_image');
  const idIdx = columns.indexOf('id');
  const nameIdx = columns.indexOf('name');
  if (profileIdx < 0 || idIdx < 0) {
    buf = '';
    continue;
  }

  // Prefer numeric id as first field of each value tuple
  for (const row of extractRows(buf)) {
    const m = row.match(/^\s*(\d+)\s*,/);
    if (!m) continue;
    const id = Number(m[1]);
    const literals = parseSqlStringLiterals(row);
    // After numeric id, string fields start at literals[0] = name
    // profile_image is the 12th column (index 11), with id as col0 numeric:
    // string index ≈ profileIdx - 1 (because id is not a quoted string)
    // Columns before profile_image that are strings: name,email,phone,cnt_code,lang,user_type,is_business,business_type,login_type,register_type = 10 strings
    // So profile is literals[10] when id is numeric unquoted.
    const file =
      literals[profileIdx - 1] ||
      literals.find((s) =>
        /^20\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d+\.(png|jpe?g|gif|webp)$/i.test(
          s
        )
      ) ||
      '';
    if (!file) continue;
    const name = literals[nameIdx - 1] || '';
    byId.set(id, { id, name, file });
  }
  buf = '';
}

const all = [...byId.values()];
const onDisk = all.filter((r) => disk.has(r.file));
const emptyOrMissing = all.filter((r) => !r.file || !disk.has(r.file));

fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(
  outPath,
  JSON.stringify({ total: all.length, onDisk: onDisk.length, rows: onDisk }, null, 2)
);

console.log(`SQL customers with profile_image set: ${all.length}`);
console.log(`Of those, file exists in OldAssets: ${onDisk.length}`);
console.log(`Missing file or empty: ${emptyOrMissing.length}`);
console.log(
  'example 1890486313:',
  all.find((r) => r.file.includes('1890486313'))
);

const pool = await mysql.createPool({
  host: process.env.DB_HOST,
  port: +process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

let updated = 0;
let skipped = 0;
let missingUser = 0;
for (const row of onDisk) {
  const [rows] = await pool.query(
    `SELECT id, profile_image FROM tbl_customer WHERE id = ? AND is_delete = '0'`,
    [row.id]
  );
  if (!rows.length) {
    missingUser++;
    continue;
  }
  if (String(rows[0].profile_image || '') === row.file) {
    skipped++;
    continue;
  }
  await pool.query(`UPDATE tbl_customer SET profile_image = ? WHERE id = ?`, [
    row.file,
    row.id,
  ]);
  updated++;
  console.log(`restored #${row.id} ${row.name} → ${row.file}`);
}

const [c] = await pool.query(
  `SELECT COUNT(*) AS n FROM tbl_customer
   WHERE profile_image IS NOT NULL AND TRIM(profile_image) != '' AND is_delete = '0'`
);
console.log({ updated, skipped, missingUser, with_profile_now: c[0].n });
await pool.end();
