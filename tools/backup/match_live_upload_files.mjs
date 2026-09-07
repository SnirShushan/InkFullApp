import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
dotenv.config({ path: path.join(repoRoot, 'app/api/.env') });

function list(dir) {
  return new Set(
    fs.existsSync(dir)
      ? fs.readdirSync(dir).filter((f) => !f.startsWith('.') && f !== 'index.html')
      : []
  );
}
const sigDisk = list(path.join(repoRoot, 'assets/uploads/signature_images'));
const bodyDisk = list(path.join(repoRoot, 'assets/uploads/body_images'));

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

const [biz] = await pool.query(
  `SELECT id, name, signature_image FROM tbl_customer
   WHERE is_delete='0' AND (user_type='2' OR is_business='1')`
);
const [reqs] = await pool.query(
  `SELECT id, business_id, uid, front_data_image, back_data_image FROM tbl_request`
);
await pool.end();

const bizSig = biz.map((b) => {
  const file = String(b.signature_image || '').trim();
  return {
    id: b.id,
    name: b.name,
    file,
    onDisk: file && sigDisk.has(file),
  };
});
const reqsMapped = reqs
  .filter((r) => String(r.front_data_image || '').trim())
  .map((r) => ({
    requestId: r.id,
    businessId: r.business_id,
    file: String(r.front_data_image).trim(),
    onDisk: bodyDisk.has(String(r.front_data_image).trim()),
  }));

console.log(JSON.stringify({
  businessSignatures: {
    total: bizSig.length,
    withFilename: bizSig.filter((x) => x.file && x.file !== 'default.jpg').length,
    onDisk: bizSig.filter((x) => x.onDisk).length,
    missingFile: bizSig.filter((x) => x.file && x.file !== 'default.jpg' && !x.onDisk).map((x) => ({
      id: x.id,
      name: x.name,
      file: x.file,
    })),
  },
  requestBodies: {
    withFilename: reqsMapped.length,
    onDisk: reqsMapped.filter((x) => x.onDisk).length,
    missingFile: reqsMapped.filter((x) => !x.onDisk).length,
    missingSample: reqsMapped.filter((x) => !x.onDisk).slice(0, 8),
  },
}, null, 2));
