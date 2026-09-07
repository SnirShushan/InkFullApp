import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import fs from 'fs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, '../../app/api/.env') });

const pool = await mysql.createPool({
  host: process.env.DB_HOST,
  port: +process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

const file = '2025-06-05-22-20-18-1890486313.jpg';
const [byFile] = await pool.query(
  `SELECT id, name, is_delete, profile_image FROM tbl_customer
   WHERE profile_image LIKE ? OR name LIKE '%chlo%' OR id = 325`,
  [`%${file}%`]
);
console.log('lookup', byFile);

const map = JSON.parse(
  fs.readFileSync(
    path.join(__dirname, '../../backups/sql_profile_image_map_full.json'),
    'utf8'
  )
);
const missing = [];
for (const row of map.rows) {
  const [r] = await pool.query(
    `SELECT id, is_delete FROM tbl_customer WHERE id = ?`,
    [row.id]
  );
  if (!r.length) missing.push({ ...row, reason: 'no row' });
  else if (String(r[0].is_delete) !== '0')
    missing.push({ ...row, reason: 'deleted', is_delete: r[0].is_delete });
}
console.log('onDisk mapped but not active in live DB:', missing.length);
console.log(missing);

// How many disk files are NOT in SQL map?
const disk = fs
  .readdirSync(path.join(__dirname, '../../assets/uploads/profile_images'))
  .filter((f) => !f.startsWith('.') && f !== 'index.html');
const sqlFiles = new Set(map.rows.map((r) => r.file));
const orphans = disk.filter((f) => !sqlFiles.has(f));
console.log('disk files not in SQL dump profile_image:', orphans.length);
console.log('orphan sample', orphans.slice(0, 15));

await pool.end();
