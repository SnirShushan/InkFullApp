import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
dotenv.config({ path: path.join(repoRoot, 'app/api/.env') });

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

const [sig] = await pool.query(
  `SELECT COUNT(*) c, SUM(signature_image IS NOT NULL AND TRIM(signature_image) != '') filled
   FROM tbl_customer WHERE is_delete='0'`
);
const [sigBiz] = await pool.query(
  `SELECT id, name, signature_image FROM tbl_customer
   WHERE is_delete='0' AND (user_type='2' OR is_business='1')
     AND signature_image IS NOT NULL AND TRIM(signature_image) != ''
   LIMIT 20`
);
const [sigCountBiz] = await pool.query(
  `SELECT
     SUM(user_type='2' OR is_business='1') biz,
     SUM((user_type='2' OR is_business='1') AND signature_image IS NOT NULL AND TRIM(signature_image)!='') bizWithSig
   FROM tbl_customer WHERE is_delete='0'`
);
const [reqImgs] = await pool.query(
  `SELECT id, business_id, uid, front_data_image, back_data_image FROM tbl_request
   WHERE (front_data_image IS NOT NULL AND TRIM(front_data_image)!='')
      OR (back_data_image IS NOT NULL AND TRIM(back_data_image)!='')
   LIMIT 20`
);
const [reqCounts] = await pool.query(
  `SELECT COUNT(*) total,
     SUM(front_data_image IS NOT NULL AND TRIM(front_data_image)!='') fronts,
     SUM(back_data_image IS NOT NULL AND TRIM(back_data_image)!='') backs
   FROM tbl_request`
);
await pool.end();
console.log(JSON.stringify({ sig, sigCountBiz, sampleBizSig: sigBiz, reqCounts, sampleReq: reqImgs }, null, 2));
