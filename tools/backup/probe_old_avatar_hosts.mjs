/**
 * Probe historical avatar hosts (from Flutter git history) for profile images.
 * Usage: node tools/backup/probe_old_avatar_hosts.mjs
 *        node tools/backup/probe_old_avatar_hosts.mjs --download
 *        node tools/backup/probe_old_avatar_hosts.mjs --download --upload
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { S3Client, PutObjectCommand, HeadObjectCommand } from '@aws-sdk/client-s3';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../..');
dotenv.config({ path: path.join(repoRoot, 'app/api/.env') });

const doDownload = process.argv.includes('--download');
const doUpload = process.argv.includes('--upload');

const outDir = path.join(
  repoRoot,
  'backups/smartweb/assets/uploads/profile_images'
);
fs.mkdirSync(outDir, { recursive: true });

const remotes = [
  'https://smartweb-tech.com/apps/ink/assets/uploads/profile_images/',
  'https://itapp2u.com/apps/Inkapp/assets/uploads/profile_images/',
  'https://itapp2u.com/apps/inkapp/assets/uploads/profile_images/',
  'https://inkisrael.co.il/assets/uploads/profile_images/',
  'https://www.inkisrael.co.il/assets/uploads/profile_images/',
  'http://173.255.254.63/apps/inkapp/assets/uploads/profile_images/',
];

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
      headers: { 'User-Agent': 'InkAvatarProbe/1.0', Accept: 'image/*' },
      redirect: 'follow',
    });
    if (!res.ok) return { ok: false, status: res.status };
    const ct = (res.headers.get('content-type') || '').toLowerCase();
    const buf = Buffer.from(await res.arrayBuffer());
    if (buf.length < 200) return { ok: false, status: res.status, bytes: buf.length, ct };
    const head = buf.subarray(0, 64).toString('utf8').toLowerCase();
    if (head.includes('<!doctype') || head.includes('<html')) {
      return { ok: false, status: res.status, bytes: buf.length, ct, html: true };
    }
    if (ct && !ct.includes('image') && !ct.includes('octet-stream')) {
      return { ok: false, status: res.status, bytes: buf.length, ct };
    }
    return { ok: true, status: res.status, bytes: buf.length, ct, buf };
  } catch (e) {
    return { ok: false, error: e.name || String(e) };
  } finally {
    clearTimeout(t);
  }
}

async function waybackClosest(originalUrl) {
  try {
    const api = `https://archive.org/wayback/available?url=${encodeURIComponent(originalUrl)}`;
    const res = await fetch(api, { headers: { 'User-Agent': 'InkAvatarProbe/1.0' } });
    if (!res.ok) return null;
    const data = await res.json();
    const snap = data?.archived_snapshots?.closest;
    if (!snap?.available || !snap?.url) return null;
    return snap.url;
  } catch {
    return null;
  }
}

function basenameSafe(file) {
  return path.basename(String(file || '').split('?')[0]);
}

// Collect filenames: DB + previous manifests
const files = new Map(); // basename -> {ids:[]}

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  waitForConnections: true,
});

try {
  const [rows] = await pool.query(
    `SELECT id, name, profile_image AS file
     FROM tbl_customer
     WHERE profile_image IS NOT NULL AND TRIM(profile_image) != '' AND is_delete = '0'`
  );
  for (const r of rows) {
    const f = basenameSafe(r.file);
    if (!f || f === 'defult.png' || f === 'default.png') continue;
    if (!files.has(f)) files.set(f, { ids: [], names: [] });
    files.get(f).ids.push(r.id);
    files.get(f).names.push(r.name);
  }
  console.log(`DB filenames: ${files.size}`);
} catch (e) {
  console.warn('DB query failed:', e.message);
} finally {
  await pool.end();
}

for (const p of [
  'backups/profile_images_manifest.json',
  'backups/profile_images_recover_report.json',
]) {
  const full = path.join(repoRoot, p);
  if (!fs.existsSync(full)) continue;
  try {
    const data = JSON.parse(fs.readFileSync(full, 'utf8'));
    const list = Array.isArray(data)
      ? data
      : [...(data?.details?.missing || []), ...(data?.details?.recovered || []), ...(data?.details?.exists || [])];
    for (const row of list) {
      const f = basenameSafe(row.file || row);
      if (!f || f === 'defult.png') continue;
      if (!files.has(f)) files.set(f, { ids: row.id ? [row.id] : [], names: [] });
    }
  } catch {
    // ignore
  }
}

console.log(`Total unique filenames to probe: ${files.size}`);

// Probe a few sample files on each host first
const sampleFiles = [...files.keys()].slice(0, 8);
console.log('\n=== Host probe (sample files) ===');
for (const base of remotes) {
  let hits = 0;
  for (const f of sampleFiles) {
    const r = await fetchBin(base + f, 10000);
    if (r.ok) hits++;
    console.log(
      `${r.ok ? 'HIT' : 'miss'} ${r.status || r.error || ''} ${r.bytes || 0}b  ${base}${f}`
    );
  }
  console.log(`→ ${base} hits ${hits}/${sampleFiles.length}\n`);
}

const report = { found: [], missing: [], local: [] };

for (const [file, meta] of files) {
  const dest = path.join(outDir, file);
  if (fs.existsSync(dest) && fs.statSync(dest).size > 200) {
    report.local.push({ file, ...meta, bytes: fs.statSync(dest).size });
    process.stdout.write(`# local ${file}\n`);
    continue;
  }

  let found = null;
  for (const base of remotes) {
    const r = await fetchBin(base + file);
    if (r.ok) {
      found = { source: base + file, ...r };
      break;
    }
  }

  if (!found) {
    for (const host of [
      `https://inkisrael.co.il/assets/uploads/profile_images/${file}`,
      `https://itapp2u.com/apps/Inkapp/assets/uploads/profile_images/${file}`,
      `https://smartweb-tech.com/apps/ink/assets/uploads/profile_images/${file}`,
    ]) {
      const wb = await waybackClosest(host);
      if (!wb) continue;
      const r = await fetchBin(wb, 30000);
      if (r.ok) {
        found = { source: wb, waybackOf: host, ...r };
        break;
      }
    }
  }

  if (found) {
    console.log(`FOUND ${file} ${found.bytes}b ← ${found.source}`);
    if (doDownload) {
      fs.writeFileSync(dest, found.buf);
    }
    report.found.push({
      file,
      ...meta,
      bytes: found.bytes,
      source: found.source,
      waybackOf: found.waybackOf || null,
      saved: doDownload,
    });
  } else {
    console.log(`MISS  ${file}`);
    report.missing.push({ file, ...meta });
  }
}

const outReport = path.join(repoRoot, 'backups/profile_images_host_probe_report.json');
fs.writeFileSync(
  outReport,
  JSON.stringify(
    {
      total: files.size,
      found: report.found.length,
      already_local: report.local.length,
      missing: report.missing.length,
      remotes,
      details: report,
    },
    null,
    2
  )
);
console.log(
  `\nDone. found=${report.found.length} local=${report.local.length} missing=${report.missing.length}`
);
console.log('report:', outReport);

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
  const diskFiles = fs.readdirSync(outDir).filter((f) => !f.startsWith('.'));
  let uploaded = 0;
  let skipped = 0;
  for (const file of diskFiles) {
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
