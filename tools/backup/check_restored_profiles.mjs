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

const [c] = await pool.query(
  `SELECT COUNT(*) AS n FROM tbl_customer
   WHERE profile_image IS NOT NULL AND TRIM(profile_image) != '' AND is_delete = '0'`
);
const [sample] = await pool.query(
  `SELECT id, name, profile_image FROM tbl_customer
   WHERE profile_image IS NOT NULL AND TRIM(profile_image) != '' AND is_delete = '0'
   ORDER BY id LIMIT 15`
);
console.log('with_profile', c[0].n);
console.log(sample);

// Compare local assets size vs what we expect for restored files
const map = JSON.parse(
  fs.readFileSync(path.join(__dirname, '../../backups/sql_profile_image_map.json'), 'utf8')
);
const dir = path.join(__dirname, '../../assets/uploads/profile_images');
let missingLocal = 0;
for (const row of map) {
  const p = path.join(dir, row.file);
  if (!fs.existsSync(p)) missingLocal++;
}
console.log('sql map size', map.length, 'missing local', missingLocal);
await pool.end();
