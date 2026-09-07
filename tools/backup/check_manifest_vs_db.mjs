import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
dotenv.config({ path: path.join(repoRoot, 'app/api/.env') });

const manifest = JSON.parse(
  fs.readFileSync(path.join(repoRoot, 'backups/profile_images_manifest.json'), 'utf8')
);

const dirs = [
  path.join(repoRoot, 'assets/uploads/profile_images'),
  path.join(repoRoot, 'studio/php-admin/assets/uploads/profile_images'),
  path.join(repoRoot, 'backups/smartweb/assets/uploads/profile_images'),
];

function findFile(name) {
  for (const dir of dirs) {
    const p = path.join(dir, name);
    if (fs.existsSync(p) && fs.statSync(p).size > 200) return { dir, bytes: fs.statSync(p).size };
  }
  return null;
}

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

const ids = manifest.map((r) => r.id);
const [live] = await pool.query(
  `SELECT id, name, user_type, business_type, is_business, profile_image, is_delete
   FROM tbl_customer WHERE id IN (?)`,
  [ids]
);
const [allBiz] = await pool.query(
  `SELECT id, name, profile_image FROM tbl_customer
   WHERE is_delete='0' AND (user_type='2' OR is_business='1')`
);
await pool.end();

const byId = new Map(live.map((r) => [r.id, r]));
const r2 = String(process.env.R2_PUBLIC_BASE || '').replace(/\/$/, '');

const summary = {
  manifest: manifest.length,
  business: 0,
  fileOnDisk: 0,
  dbHasSameFile: 0,
  dbEmpty: 0,
  dbDifferent: 0,
  canRestoreFromDisk: [],
  mappedButFileMissing: [],
  alreadyLinked: [],
};

for (const row of manifest) {
  const isBiz = String(row.user_type) === '2';
  if (isBiz) summary.business += 1;
  const disk = findFile(row.file);
  if (disk) summary.fileOnDisk += 1;
  const db = byId.get(row.id);
  const dbFile = db ? path.basename(String(db.profile_image || '').split('?')[0]) : '';
  const empty = !dbFile || dbFile === 'null';
  if (empty) summary.dbEmpty += 1;
  else if (dbFile === row.file) summary.dbHasSameFile += 1;
  else summary.dbDifferent += 1;

  const item = {
    id: row.id,
    name: row.name,
    user_type: row.user_type,
    file: row.file,
    dbFile: dbFile || '',
    onDisk: Boolean(disk),
  };
  if (disk && (empty || dbFile !== row.file)) summary.canRestoreFromDisk.push(item);
  else if (!disk && (empty || dbFile !== row.file)) summary.mappedButFileMissing.push(item);
  else summary.alreadyLinked.push(item);
}

const bizEmpty = allBiz.filter((r) => !String(r.profile_image || '').trim());
const bizInManifest = new Set(manifest.filter((m) => String(m.user_type) === '2').map((m) => m.id));
const bizEmptyNotInManifest = bizEmpty.filter((r) => !bizInManifest.has(r.id));

console.log(JSON.stringify({
  manifestTotal: summary.manifest,
  manifestBusiness: summary.business,
  fileOnDisk: summary.fileOnDisk,
  dbAlreadySame: summary.dbHasSameFile,
  dbEmpty: summary.dbEmpty,
  dbDifferent: summary.dbDifferent,
  canRestoreFromDisk: summary.canRestoreFromDisk.length,
  mappedButFileMissing: summary.mappedButFileMissing.length,
  liveBusiness: allBiz.length,
  liveBusinessEmptyPhoto: bizEmpty.length,
  emptyBusinessNotInManifest: bizEmptyNotInManifest.map((r) => ({ id: r.id, name: r.name })),
  restoreCandidates: summary.canRestoreFromDisk,
  missingFiles: summary.mappedButFileMissing.filter((r) => String(r.user_type) === '2'),
  r2BaseSet: Boolean(r2),
}, null, 2));
