/**
 * Restore signature_image from SQL dump when file exists in OldAssets.
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

const sigDir = path.join(repoRoot, 'OldAssets/uploads/signature_images');
const disk = new Set(
  fs.readdirSync(sigDir).filter((f) => !f.startsWith('.') && f !== 'index.html')
);

const sqlPath = path.join(repoRoot, 'inkisrael_Database/inkisrael_app.sql');
const fileRe =
  /'((?:20\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d+\.png))'/gi;

const rl = readline.createInterface({
  input: fs.createReadStream(sqlPath),
  crlfDelay: Infinity,
});

// signature_image column sits after profile in many schemas; collect id→png near signature-like rows
// Heuristic: for each disk signature filename found in SQL, take nearest preceding (id,
const byId = new Map();
let inCustomer = false;
let buf = '';

function flush() {
  if (!buf) return;
  let m;
  fileRe.lastIndex = 0;
  while ((m = fileRe.exec(buf))) {
    const file = m[1];
    if (!disk.has(file)) continue;
    const idx = m.index;
    const slice = buf.slice(Math.max(0, idx - 800), idx);
    const ids = [...slice.matchAll(/\((\d+),/g)];
    const id = ids.length ? Number(ids[ids.length - 1][1]) : null;
    if (!id) continue;
    // Prefer assignment when this file is NOT already the profile_image for that id
    // Store candidates; later we only set signature_image if column empty
    if (!byId.has(id)) byId.set(id, []);
    byId.get(id).push(file);
  }
  buf = '';
}

for await (const line of rl) {
  if (
    line.includes('INSERT INTO `tbl_customer`') ||
    line.includes('INSERT INTO tbl_customer')
  ) {
    inCustomer = true;
    buf = line;
    if (line.trim().endsWith(';')) {
      flush();
      inCustomer = false;
    }
    continue;
  }
  if (inCustomer) {
    buf += '\n' + line;
    if (line.trim().endsWith(';')) {
      flush();
      inCustomer = false;
    }
  }
}
flush();

const pool = await mysql.createPool({
  host: process.env.DB_HOST,
  port: +process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

// Detect if signature_image column exists
const [cols] = await pool.query(`SHOW COLUMNS FROM tbl_customer LIKE 'signature_image'`);
if (!cols.length) {
  console.log('No signature_image column — skip');
  await pool.end();
  process.exit(0);
}

let updated = 0;
for (const [id, files] of byId) {
  const [rows] = await pool.query(
    `SELECT id, profile_image, signature_image FROM tbl_customer WHERE id = ? AND is_delete = '0'`,
    [id]
  );
  if (!rows.length) continue;
  const profile = String(rows[0].profile_image || '');
  const current = String(rows[0].signature_image || '');
  if (current && disk.has(current)) continue;
  // pick a file that isn't the profile image
  const pick = files.find((f) => f !== profile) || files[0];
  if (!pick || !disk.has(pick)) continue;
  await pool.query(`UPDATE tbl_customer SET signature_image = ? WHERE id = ?`, [
    pick,
    id,
  ]);
  updated++;
}
console.log('signature restored', updated, 'candidates', byId.size);
await pool.end();
