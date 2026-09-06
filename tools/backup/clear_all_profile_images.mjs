/**
 * We do not have the original PHP profile_images backup.
 * Clear all profile_image filenames so the API/client show the default avatar
 * until users upload a new photo (stored on Cloudflare R2).
 */
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, '../../backend/.env') });

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: +process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

const [before] = await pool.query(
  `SELECT COUNT(*) AS c FROM tbl_customer
   WHERE profile_image IS NOT NULL AND TRIM(profile_image) != ''`
);
const [result] = await pool.query(
  `UPDATE tbl_customer
   SET profile_image = ''
   WHERE profile_image IS NOT NULL AND TRIM(profile_image) != ''`
);
const [after] = await pool.query(
  `SELECT COUNT(*) AS c FROM tbl_customer
   WHERE profile_image IS NOT NULL AND TRIM(profile_image) != ''`
);
await pool.end();
console.log({
  had_profile_image: before[0].c,
  cleared: result.affectedRows,
  remaining: after[0].c,
});
