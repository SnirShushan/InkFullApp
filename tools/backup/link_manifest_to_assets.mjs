/**
 * For each row in backups/profile_images_manifest.json, find the file
 * in assets/ by filename and attach it to that user:
 *   - UPDATE tbl_customer.profile_image
 *   - copy into studio/php-admin uploads
 *   - upload to R2 so the app can load it
 *
 *   node tools/backup/link_manifest_to_assets.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import {
  S3Client,
  PutObjectCommand,
  HeadObjectCommand,
} from '@aws-sdk/client-s3';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
dotenv.config({ path: path.join(repoRoot, 'app/api/.env') });

const manifestPath = path.join(repoRoot, 'backups/profile_images_manifest.json');
const assetsRoot = path.join(repoRoot, 'assets');
const localDestDir = path.join(
  repoRoot,
  'studio/php-admin/assets/uploads/profile_images'
);

const IMAGE_EXT = new Set(['.jpg', '.jpeg', '.png', '.webp', '.gif']);

function contentType(file) {
  return (
    {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.webp': 'image/webp',
      '.gif': 'image/gif',
    }[path.extname(file).toLowerCase()] || 'image/jpeg'
  );
}

function walkImages(dir, out = []) {
  if (!fs.existsSync(dir)) return out;
  for (const name of fs.readdirSync(dir)) {
    if (name.startsWith('.')) continue;
    const full = path.join(dir, name);
    let st;
    try {
      st = fs.statSync(full);
    } catch {
      continue;
    }
    if (st.isDirectory()) walkImages(full, out);
    else if (st.isFile() && st.size > 200 && IMAGE_EXT.has(path.extname(name).toLowerCase())) {
      out.push({ name, full, bytes: st.size });
    }
  }
  return out;
}

function indexAssets(files) {
  const exact = new Map();
  const byStem = new Map();
  const byTail = new Map();
  for (const f of files) {
    exact.set(f.name.toLowerCase(), f);
    const stem = path.parse(f.name).name.toLowerCase();
    if (!byStem.has(stem)) byStem.set(stem, f);
    const parts = stem.split('-');
    const tail = parts[parts.length - 1];
    if (tail && /^\d{6,}$/.test(tail) && !byTail.has(tail)) byTail.set(tail, f);
  }
  return { exact, byStem, byTail };
}

function findAsset(wanted, index) {
  const base = path.basename(String(wanted || '').split('?')[0]).trim();
  if (!base) return null;
  const lower = base.toLowerCase();
  if (index.exact.has(lower)) return index.exact.get(lower);
  const stem = path.parse(lower).name;
  if (index.byStem.has(stem)) return index.byStem.get(stem);
  const parts = stem.split('-');
  const tail = parts[parts.length - 1];
  if (tail && index.byTail.has(tail)) return index.byTail.get(tail);
  return null;
}

const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const files = walkImages(assetsRoot);
const index = indexAssets(files);
console.log(`assets images: ${files.length}`);
console.log(`manifest rows: ${manifest.length}`);

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  waitForConnections: true,
});

fs.mkdirSync(localDestDir, { recursive: true });

const {
  R2_ACCOUNT_ID,
  R2_ACCESS_KEY_ID,
  R2_SECRET_ACCESS_KEY,
  R2_BUCKET,
  R2_PUBLIC_BASE = '',
} = process.env;

const client = new S3Client({
  region: 'auto',
  endpoint: `https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: R2_ACCESS_KEY_ID,
    secretAccessKey: R2_SECRET_ACCESS_KEY,
  },
});

async function uploadOne(localPath, key) {
  const stat = fs.statSync(localPath);
  try {
    const head = await client.send(new HeadObjectCommand({ Bucket: R2_BUCKET, Key: key }));
    if (head.ContentLength === stat.size) return 'exists';
  } catch {
    // missing
  }
  await client.send(
    new PutObjectCommand({
      Bucket: R2_BUCKET,
      Key: key,
      Body: fs.createReadStream(localPath),
      ContentType: contentType(localPath),
      ContentLength: stat.size,
    })
  );
  return 'uploaded';
}

const report = { linked: [], missing: [], failed: [] };

for (const row of manifest) {
  const hit = findAsset(row.file, index);
  if (!hit) {
    report.missing.push({ id: row.id, name: row.name, file: row.file });
    console.log(`MISS  #${row.id} ${row.name} → ${row.file}`);
    continue;
  }
  const dest = path.join(localDestDir, hit.name);
  if (!fs.existsSync(dest) || fs.statSync(dest).size !== hit.bytes) {
    fs.copyFileSync(hit.full, dest);
  }
  await pool.query(`UPDATE tbl_customer SET profile_image = ?, date_updated = NOW() WHERE id = ?`, [
    hit.name,
    row.id,
  ]);
  const key = `assets/uploads/profile_images/${hit.name}`;
  let r2 = 'skip';
  try {
    r2 = await uploadOne(hit.full, key);
  } catch (err) {
    r2 = `fail:${err.message}`;
    report.failed.push({ id: row.id, name: row.name, file: hit.name, error: err.message });
  }
  report.linked.push({
    id: row.id,
    name: row.name,
    file: hit.name,
    from: path.relative(assetsRoot, hit.full),
    bytes: hit.bytes,
    r2,
  });
  console.log(`OK    #${row.id} ${row.name} → ${hit.name} (${r2})`);
}

await pool.end();

const publicBase = String(R2_PUBLIC_BASE).replace(/\/$/, '');
const pasha = report.linked.find((r) => r.id === 24);
console.log('\n--- summary ---');
console.log(`linked: ${report.linked.length}`);
console.log(`missing file in assets: ${report.missing.length}`);
console.log(`r2 failed: ${report.failed.length}`);
if (pasha) {
  console.log(
    `PashaStudio: ${pasha.file} from assets/${pasha.from.replaceAll('\\', '/')} → ${publicBase}/${`assets/uploads/profile_images/${pasha.file}`}`
  );
}
if (report.missing.length) {
  console.log('still missing:');
  for (const m of report.missing) console.log(`  #${m.id} ${m.name} ${m.file}`);
}
