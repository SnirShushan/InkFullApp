/**
 * Match tbl_customer.business_type=2 profile_image filenames to assets,
 * copy them into local admin assets, and upload to R2 with the same name.
 *
 *   node tools/backup/restore_business_profile_images.mjs
 *   node tools/backup/restore_business_profile_images.mjs --upload
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

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../..');
dotenv.config({ path: path.join(repoRoot, 'app/api/.env') });

const doUpload = process.argv.includes('--upload');
const doRestoreDb = process.argv.includes('--restore-db');
const dumpPath = path.join(repoRoot, 'data', 'inkisrael_app.sql');
const REMOTES = [
  'https://inkisrael.co.il/assets/uploads/profile_images/',
  'https://www.inkisrael.co.il/assets/uploads/profile_images/',
  'http://173.255.254.63/apps/inkapp/assets/uploads/profile_images/',
  'https://itapp2u.com/apps/Inkapp/assets/uploads/profile_images/',
];

const oldProfileDir = path.join(repoRoot, 'assets', 'uploads', 'profile_images');
const localDestDir = path.join(
  repoRoot,
  'studio',
  'php-admin',
  'assets',
  'uploads',
  'profile_images'
);

const {
  R2_ACCOUNT_ID,
  R2_ACCESS_KEY_ID,
  R2_SECRET_ACCESS_KEY,
  R2_BUCKET,
  R2_PUBLIC_BASE = '',
  DB_HOST,
  DB_PORT,
  DB_USER,
  DB_PASS,
  DB_NAME,
} = process.env;

function contentType(file) {
  const ext = path.extname(file).toLowerCase();
  return (
    {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.webp': 'image/webp',
      '.gif': 'image/gif',
    }[ext] || 'image/jpeg'
  );
}

function basenameSafe(v) {
  const raw = String(v || '').trim();
  if (!raw || raw === 'null' || raw === 'undefined') return '';
  const noQuery = raw.split('?')[0];
  if (/^https?:\/\//i.test(noQuery)) {
    try {
      return path.basename(new URL(noQuery).pathname);
    } catch {
      return path.basename(noQuery);
    }
  }
  return path.basename(noQuery.replace(/\\/g, '/'));
}

function parseSqlValues(tuple) {
  const out = [];
  let cur = '';
  let inStr = false;
  for (let i = 0; i < tuple.length; i++) {
    const ch = tuple[i];
    if (inStr) {
      if (ch === '\\' && i + 1 < tuple.length) {
        cur += tuple[i + 1];
        i++;
        continue;
      }
      if (ch === "'") {
        if (tuple[i + 1] === "'") {
          cur += "'";
          i++;
          continue;
        }
        inStr = false;
        continue;
      }
      cur += ch;
      continue;
    }
    if (ch === "'") {
      inStr = true;
      continue;
    }
    if (ch === ',') {
      out.push(cur.trim());
      cur = '';
      continue;
    }
    cur += ch;
  }
  if (cur.length) out.push(cur.trim());
  return out;
}

function extractSqlTuple(text, start) {
  let inStr = false;
  for (let i = start + 1; i < text.length; i++) {
    const ch = text[i];
    if (inStr) {
      if (ch === '\\') {
        i++;
        continue;
      }
      if (ch === "'" && text[i + 1] === "'") {
        i++;
        continue;
      }
      if (ch === "'") inStr = false;
      continue;
    }
    if (ch === "'") {
      inStr = true;
      continue;
    }
    if (ch === ')') return text.slice(start + 1, i);
  }
  return '';
}

function loadDumpProfileById() {
  const map = new Map();
  if (!fs.existsSync(dumpPath)) return map;
  const text = fs.readFileSync(dumpPath, 'utf8');
  const marker = 'INSERT INTO `tbl_customer`';
  let from = 0;
  while (from < text.length) {
    const start = text.indexOf(marker, from);
    if (start < 0) break;
    const nextInsert = text.indexOf('\nINSERT INTO `', start + marker.length);
    const chunk = nextInsert > 0 ? text.slice(start, nextInsert) : text.slice(start);
    from = nextInsert > 0 ? nextInsert : text.length;
    for (let i = 0; i < chunk.length; i++) {
      if (chunk[i] !== '(') continue;
      if (i > 0 && /[^\s,(]/.test(chunk[i - 1])) continue;
      if (!/\d/.test(chunk[i + 1] || '')) continue;
      const inner = extractSqlTuple(chunk, i);
      const fields = parseSqlValues(inner);
      if (fields.length < 12) continue;
      const id = Number(fields[0]);
      const file = basenameSafe(fields[11]);
      if (id && file) map.set(id, file);
      i += inner.length;
    }
  }
  return map;
}

async function downloadTo(file, destPath) {
  for (const base of REMOTES) {
    try {
      const res = await fetch(base + file, {
        redirect: 'follow',
        headers: { Accept: 'image/*', 'User-Agent': 'InkProfileRestore/1.0' },
        signal: AbortSignal.timeout(5000),
      });
      if (!res.ok) continue;
      const ctype = String(res.headers.get('content-type') || '');
      if (ctype && !ctype.startsWith('image/')) continue;
      const buf = Buffer.from(await res.arrayBuffer());
      if (buf.length < 64) continue;
      fs.writeFileSync(destPath, buf);
      return destPath;
    } catch {
      // try next host
    }
  }
  return null;
}

function listProfileFiles(dir) {
  if (!fs.existsSync(dir)) return new Map();
  const map = new Map();
  for (const name of fs.readdirSync(dir)) {
    if (name.startsWith('.') || name === 'index.html') continue;
    const full = path.join(dir, name);
    if (!fs.statSync(full).isFile()) continue;
    map.set(name, full);
  }
  return map;
}

const disk = listProfileFiles(oldProfileDir);
console.log(`assets profile files: ${disk.size}`);

const pool = mysql.createPool({
  host: DB_HOST,
  port: Number(DB_PORT || 3306),
  user: DB_USER,
  password: DB_PASS,
  database: DB_NAME,
  waitForConnections: true,
});

const dumpMap = loadDumpProfileById();
console.log(`SQL dump profile filenames: ${dumpMap.size}`);

const [rows] = await pool.query(
  `SELECT id, name, user_type, is_business, business_type, profile_image
   FROM tbl_customer
   WHERE is_delete = '0' AND (business_type = '2' OR user_type = '2')
   ORDER BY id`
);

const matched = [];
const missingFile = [];
const emptyImage = [];
const seenFiles = new Set();

for (const row of rows) {
  const file = basenameSafe(row.profile_image);
  if (!file) {
    emptyImage.push({ id: row.id, name: row.name });
    continue;
  }
  const local = disk.get(file);
  if (!local) {
    missingFile.push({ id: row.id, name: row.name, file });
    continue;
  }
  seenFiles.add(file);
  matched.push({
    id: row.id,
    name: row.name,
    file,
    local,
    bytes: fs.statSync(local).size,
  });
}

console.log(`business accounts (user_type=2 or business_type=2): ${rows.length}`);
console.log(`  with filename + file on disk: ${matched.length}`);
console.log(`  with filename missing on disk: ${missingFile.length}`);
console.log(`  empty profile_image: ${emptyImage.length}`);

fs.mkdirSync(localDestDir, { recursive: true });

const restoredDb = [];
const downloaded = [];
const stillEmpty = [];

async function resolveFile(file) {
  if (!file) return null;
  if (disk.has(file)) return disk.get(file);
  const dest = path.join(localDestDir, file);
  if (fs.existsSync(dest) && fs.statSync(dest).size > 64) {
    disk.set(file, dest);
    return dest;
  }
  console.log(`  downloading ${file} ...`);
  const got = await downloadTo(file, dest);
  if (got) {
    disk.set(file, got);
    downloaded.push(file);
    return got;
  }
  return null;
}

for (const item of [...missingFile]) {
  const local = await resolveFile(item.file);
  if (!local) continue;
  const idx = missingFile.findIndex((m) => m.id === item.id);
  if (idx >= 0) missingFile.splice(idx, 1);
  matched.push({
    id: item.id,
    name: item.name,
    file: item.file,
    local,
    bytes: fs.statSync(local).size,
  });
}

for (const item of emptyImage) {
  const dumpFile = dumpMap.get(Number(item.id)) || '';
  if (!dumpFile) {
    stillEmpty.push(item);
    continue;
  }
  const local = await resolveFile(dumpFile);
  await pool.query(
    `UPDATE tbl_customer SET profile_image = ? WHERE id = ? AND (profile_image IS NULL OR profile_image = '')`,
    [dumpFile, item.id]
  );
  restoredDb.push({ id: item.id, name: item.name, file: dumpFile, hasFile: Boolean(local) });
  if (local) {
    matched.push({
      id: item.id,
      name: item.name,
      file: dumpFile,
      local,
      bytes: fs.statSync(local).size,
    });
  } else {
    missingFile.push({ id: item.id, name: item.name, file: dumpFile });
  }
}

console.log(`  restored DB filenames: ${restoredDb.length}`);
console.log(`  downloaded from old hosts: ${downloaded.length}`);
console.log(`  still empty (no dump filename): ${stillEmpty.length}`);
console.log(`  still missing file: ${missingFile.length}`);
console.log(`  ready to publish: ${matched.length}`);

let copied = 0;
let copySkipped = 0;
for (const item of matched) {
  const dest = path.join(localDestDir, item.file);
  const already =
    fs.existsSync(dest) && fs.statSync(dest).size === item.bytes;
  if (already) {
    copySkipped++;
    continue;
  }
  fs.copyFileSync(item.local, dest);
  copied++;
}
console.log(`Local copy: copied=${copied} skipped=${copySkipped} -> ${localDestDir}`);

let client = null;
if (doUpload) {
  if (!R2_ACCOUNT_ID || !R2_ACCESS_KEY_ID || !R2_SECRET_ACCESS_KEY || !R2_BUCKET) {
    console.error('Missing R2_* env');
    process.exit(1);
  }
  client = new S3Client({
    region: 'auto',
    endpoint: `https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId: R2_ACCESS_KEY_ID,
      secretAccessKey: R2_SECRET_ACCESS_KEY,
    },
  });
}

const uploadStats = { uploaded: 0, skipped: 0, failed: [] };

async function uploadOne(localPath, key) {
  const stat = fs.statSync(localPath);
  if (!client) return 'dry-run';
  try {
    const head = await client.send(
      new HeadObjectCommand({ Bucket: R2_BUCKET, Key: key })
    );
    if (head.ContentLength === stat.size) {
      uploadStats.skipped++;
      return 'skipped';
    }
  } catch {
    // not found
  }
  try {
    await client.send(
      new PutObjectCommand({
        Bucket: R2_BUCKET,
        Key: key,
        Body: fs.createReadStream(localPath),
        ContentType: contentType(localPath),
        ContentLength: stat.size,
      })
    );
    uploadStats.uploaded++;
    return 'uploaded';
  } catch (e) {
    uploadStats.failed.push({ key, error: e.message });
    return 'failed';
  }
}

const uniqueUploads = [...new Map(matched.map((m) => [m.file, m])).values()];
console.log(
  `\nR2 plan: ${uniqueUploads.length} unique files` + (doUpload ? '' : ' (dry-run, pass --upload)')
);

if (doUpload) {
  let i = 0;
  for (const item of uniqueUploads) {
    i++;
    const key = `assets/uploads/profile_images/${item.file}`;
    const status = await uploadOne(item.local, key);
    if (i % 10 === 0 || status === 'failed' || item.id === 359) {
      console.log(`[${i}/${uniqueUploads.length}] ${status} id=${item.id} ${item.file}`);
    }
  }
  console.log(
    `R2 done: uploaded=${uploadStats.uploaded} skipped=${uploadStats.skipped} failed=${uploadStats.failed.length}`
  );
}

const sampleUrl = (file) =>
  R2_PUBLIC_BASE
    ? `${String(R2_PUBLIC_BASE).replace(/\/$/, '')}/assets/uploads/profile_images/${file}`
    : file;

const marchello = matched.find((m) => m.id === 359);
console.log('\nMarchello id=359:');
if (marchello) {
  console.log(`  MATCH ${marchello.file} (${marchello.bytes} bytes)`);
  console.log(`  ${sampleUrl(marchello.file)}`);
} else {
  const row = rows.find((r) => Number(r.id) === 359);
  console.log('  not matched', row || 'row missing');
}

const outPath = path.join(repoRoot, 'backups', 'business_profile_restore_report.json');
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(
  outPath,
  JSON.stringify(
    {
      businessAccounts: rows.length,
      matched: matched.length,
      uniqueFiles: uniqueUploads.length,
      missingFile,
      stillEmpty,
      restoredDb,
      downloaded,
      copied,
      copySkipped,
      upload: doUpload ? uploadStats : 'dry-run',
      sampleMatched: matched.slice(0, 25).map((m) => ({
        id: m.id,
        name: m.name,
        file: m.file,
        url: sampleUrl(m.file),
      })),
    },
    null,
    2
  )
);

await pool.end();
console.log(`\nReport: ${outPath}`);
