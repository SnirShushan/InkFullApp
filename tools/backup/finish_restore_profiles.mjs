import fs from 'fs';
import path from 'path';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, '../../backend/.env') });

const map = JSON.parse(
  fs.readFileSync(path.join(__dirname, '../../backups/sql_profile_image_map.json'), 'utf8')
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
for (const row of map) {
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
  console.log('restored', row.id, row.file);
}
const [c] = await pool.query(
  `SELECT COUNT(*) AS n FROM tbl_customer
   WHERE profile_image IS NOT NULL AND TRIM(profile_image) != '' AND is_delete = '0'`
);
console.log({ updated, skipped, missingUser, with_profile: c[0].n });
await pool.end();
