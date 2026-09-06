/**
 * Recover tbl_customer.profile_image files from legacy hosts / Wayback,
 * save under backups/smartweb/assets/uploads/profile_images/, then upload to R2.
 *
 * Usage: node tools/backup/recover_profile_images.mjs
 *        node tools/backup/recover_profile_images.mjs --upload
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { S3Client, PutObjectCommand, HeadObjectCommand } from '@aws-sdk/client-s3';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../..');
dotenv.config({ path: path.join(repoRoot, 'backend/.env') });

const outDir = path.join(
  repoRoot,
  'backups/smartweb/assets/uploads/profile_images'
);
fs.mkdirSync(outDir, { recursive: true });

const remotes = [
  'https://inkisrael.co.il/assets/uploads/profile_images/',
  'https://www.inkisrael.co.il/assets/uploads/profile_images/',
  'http://173.255.254.63/apps/inkapp/assets/uploads/profile_images/',
  'https://itapp2u.com/apps/Inkapp/assets/uploads/profile_images/',
  'https://itapp2u.com/apps/inkapp/assets/uploads/profile_images/',
];

const doUpload = process.argv.includes('--upload');

function contentType(file) {
  const ext = path.extname(file).toLowerCase();
  return (
    {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.webp': 'image/webp',
      '.gif': 'image/gif',
    }[ext] || 'application/octet-stream'
  );
}

async function fetchBin(url, timeoutMs = 15000) {
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), timeoutMs);
  try {
    const res = await fetch(url, {
      signal: ctrl.signal,
      headers: { 'User-Agent': 'InkProfileRecover/1.0', Accept: 'image/*' },
      redirect: 'follow',
    });
    if (!res.ok) return null;
    const ct = (res.headers.get('content-type') || '').toLowerCase();
    if (ct && !ct.includes('image') && !ct.includes('octet-stream')) return null;
    const buf = Buffer.from(await res.arrayBuffer());
    if (buf.length < 200) return null;
    // HTML error pages
    const head = buf.subarray(0, 64).toString('utf8').toLowerCase();
    if (head.includes('<!doctype') || head.includes('<html')) return null;
    return buf;
  } catch {
    return null;
  } finally {
    clearTimeout(t);
  }
}

async function waybackClosest(originalUrl) {
  try {
    const api = `https://archive.org/wayback/available?url=${encodeURIComponent(originalUrl)}`;
    const res = await fetch(api, { headers: { 'User-Agent': 'InkProfileRecover/1.0' } });
    if (!res.ok) return null;
    const data = await res.json();
    const snap = data?.archived_snapshots?.closest;
    if (!snap?.available || !snap?.url) return null;
    return snap.url;
  } catch {
    return null;
  }
}

async function recoverOne(filename) {
  const dest = path.join(outDir, filename);
  if (fs.existsSync(dest) && fs.statSync(dest).size > 200) {
    return { status: 'exists', bytes: fs.statSync(dest).size };
  }

  for (const base of remotes) {
    const buf = await fetchBin(base + filename);
    if (buf) {
      fs.writeFileSync(dest, buf);
      return { status: 'remote', source: base, bytes: buf.length };
    }
  }

  // Wayback for inkisrael path (most common historical host)
  const original = `https://inkisrael.co.il/assets/uploads/profile_images/${filename}`;
  const wb = await waybackClosest(original);
  if (wb) {
    const buf = await fetchBin(wb, 30000);
    if (buf) {
      fs.writeFileSync(dest, buf);
      return { status: 'wayback', source: wb, bytes: buf.length };
    }
  }

  return { status: 'missing' };
}

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  waitForConnections: true,
});

const [rows] = await pool.query(
  `SELECT id, name, user_type, profile_image AS file
   FROM tbl_customer
   WHERE profile_image IS NOT NULL AND TRIM(profile_image) != '' AND is_delete = '0'
   ORDER BY id`
);
await pool.end();

const manifest = rows.map((r) => ({
  id: r.id,
  name: r.name,
  user_type: r.user_type,
  file: path.basename(String(r.file).split('?')[0]),
}));
fs.writeFileSync(
  path.join(repoRoot, 'backups/profile_images_manifest.json'),
  JSON.stringify(manifest, null, 2)
);
console.log(`Found ${manifest.length} profile filenames`);

const report = { recovered: [], missing: [], exists: [] };
for (const row of manifest) {
  process.stdout.write(`#${row.id} ${row.file} ... `);
  const r = await recoverOne(row.file);
  console.log(r.status, r.bytes || '', r.source || '');
  if (r.status === 'missing') report.missing.push(row);
  else if (r.status === 'exists') report.exists.push({ ...row, ...r });
  else report.recovered.push({ ...row, ...r });
}

fs.writeFileSync(
  path.join(repoRoot, 'backups/profile_images_recover_report.json'),
  JSON.stringify(
    {
      total: manifest.length,
      recovered: report.recovered.length,
      already_local: report.exists.length,
      missing: report.missing.length,
      details: report,
    },
    null,
    2
  )
);

console.log(
  `\nDone. recovered=${report.recovered.length} exists=${report.exists.length} missing=${report.missing.length}`
);

if (doUpload) {
  const {
    R2_ACCOUNT_ID,
    R2_ACCESS_KEY_ID,
    R2_SECRET_ACCESS_KEY,
    R2_BUCKET,
  } = process.env;
  if (!R2_ACCOUNT_ID || !R2_ACCESS_KEY_ID || !R2_SECRET_ACCESS_KEY || !R2_BUCKET) {
    console.error('Missing R2 env; skip upload');
    process.exit(1);
  }
  const client = new S3Client({
    region: 'auto',
    endpoint: `https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId: R2_ACCESS_KEY_ID,
      secretAccessKey: R2_SECRET_ACCESS_KEY,
    },
  });
  const files = fs.readdirSync(outDir).filter((f) => !f.startsWith('.'));
  let uploaded = 0;
  let skipped = 0;
  for (const file of files) {
    const full = path.join(outDir, file);
    const key = `assets/uploads/profile_images/${file}`;
    const stat = fs.statSync(full);
    try {
      const head = await client.send(
        new HeadObjectCommand({ Bucket: R2_BUCKET, Key: key })
      );
      if (head.ContentLength === stat.size) {
        skipped++;
        continue;
      }
    } catch {
      // upload
    }
    await client.send(
      new PutObjectCommand({
        Bucket: R2_BUCKET,
        Key: key,
        Body: fs.createReadStream(full),
        ContentType: contentType(full),
        ContentLength: stat.size,
      })
    );
    uploaded++;
    console.log('uploaded', key);
  }
  console.log(`R2 upload: uploaded=${uploaded} skipped=${skipped}`);
}
