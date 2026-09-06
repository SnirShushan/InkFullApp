import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { S3Client, HeadObjectCommand } from '@aws-sdk/client-s3';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, '../../backend/.env') });

const client = new S3Client({
  region: 'auto',
  endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  },
});

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: +process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  namedPlaceholders: true,
});

const [rows] = await pool.query(
  `SELECT id, profile_image FROM tbl_customer
   WHERE profile_image IS NOT NULL AND TRIM(profile_image) != '' AND is_delete='0'`
);

let cleared = 0;
let ok = 0;
for (const r of rows) {
  const file = String(r.profile_image).split('/').pop().split('?')[0];
  const key = `assets/uploads/profile_images/${file}`;
  try {
    await client.send(
      new HeadObjectCommand({ Bucket: process.env.R2_BUCKET, Key: key })
    );
    ok++;
  } catch {
    await pool.query(
      `UPDATE tbl_customer SET profile_image = '' WHERE id = :id`,
      { id: r.id }
    );
    cleared++;
    console.log('cleared broken', r.id, file);
  }
}
await pool.end();
console.log({ ok, cleared });
