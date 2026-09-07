/**
 * Prefer the LAST profile_image per user from the SQL dump (newest),
 * not the first / manifest snapshot. Update live DB + copy + R2.
 *
 *   node tools/backup/use_newest_dump_profiles.mjs
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

const dumpPath = path.join(repoRoot, 'data/inkisrael_app.sql');
const assetDirs = [
  path.join(repoRoot, 'assets/uploads/profile_images'),
  path.join(repoRoot, 'studio/php-admin/assets/uploads/profile_images'),
  path.join(repoRoot, 'backups/smartweb/assets/uploads/profile_images'),
];
const destDir = path.join(repoRoot, 'studio/php-admin/assets/uploads/profile_images');

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

function fileDate(name) {
  const m = String(name).match(/^(\d{4})-(\d{2})-(\d{2})-(\d{2})-(\d{2})-(\d{2})/);
  if (!m) return 0;
  return Date.UTC(+m[1], +m[2] - 1, +m[3], +m[4], +m[5], +m[6]);
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

function loadDumpProfiles() {
  const history = new Map();
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
      if (!id) continue;
      if (!history.has(id)) history.set(id, []);
      if (file) history.get(id).push(file);
      i += inner.length;
    }
  }
  return history;
}

function findOnDisk(name) {
  for (const dir of assetDirs) {
    const p = path.join(dir, name);
    if (fs.existsSync(p) && fs.statSync(p).size > 200) return p;
  }
  return null;
}

function contentType(file) {
  return (
    {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.webp': 'image/webp',
    }[path.extname(file).toLowerCase()] || 'image/jpeg'
  );
}

const history = loadDumpProfiles();
console.log(`dump users with any profile filename: ${history.size}`);

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

const [biz] = await pool.query(
  `SELECT id, name, user_type, profile_image
   FROM tbl_customer
   WHERE is_delete='0' AND (user_type='2' OR is_business='1')
   ORDER BY id`
);

const client = new S3Client({
  region: 'auto',
  endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  },
});

async function upload(local, key) {
  const stat = fs.statSync(local);
  try {
    const head = await client.send(
      new HeadObjectCommand({ Bucket: process.env.R2_BUCKET, Key: key })
    );
    if (head.ContentLength === stat.size) return 'exists';
  } catch {
    // missing
  }
  await client.send(
    new PutObjectCommand({
      Bucket: process.env.R2_BUCKET,
      Key: key,
      Body: fs.createReadStream(local),
      ContentType: contentType(local),
      ContentLength: stat.size,
    })
  );
  return 'uploaded';
}

fs.mkdirSync(destDir, { recursive: true });

const changed = [];
const same = [];
const noNewer = [];

for (const row of biz) {
  const versions = history.get(row.id) || [];
  const unique = [...new Set(versions)];
  const current = basenameSafe(row.profile_image);
  const newest = unique.reduce((best, f) => (fileDate(f) >= fileDate(best) ? f : best), unique[0] || '');
  const first = unique[0] || '';
  if (!newest) {
    noNewer.push({ id: row.id, name: row.name, current, reason: 'no dump file' });
    continue;
  }
  const local = findOnDisk(newest);
  if (newest === current) {
    same.push({ id: row.id, name: row.name, file: newest, versions: unique.length, onDisk: Boolean(local) });
    continue;
  }
  if (!local) {
    noNewer.push({
      id: row.id,
      name: row.name,
      current,
      newest,
      first,
      versions: unique,
      reason: 'newest not on disk',
    });
    continue;
  }
  await pool.query(`UPDATE tbl_customer SET profile_image = ?, date_updated = NOW() WHERE id = ?`, [
    newest,
    row.id,
  ]);
  const dest = path.join(destDir, newest);
  if (!fs.existsSync(dest) || fs.statSync(dest).size !== fs.statSync(local).size) {
    fs.copyFileSync(local, dest);
  }
  const r2 = await upload(local, `assets/uploads/profile_images/${newest}`);
  changed.push({
    id: row.id,
    name: row.name,
    from: current,
    to: newest,
    first,
    versions: unique,
    r2,
  });
  console.log(
    `UPDATE #${row.id} ${row.name}: ${current || '(empty)'} → ${newest} (first was ${first || '-'}) ${r2}`
  );
}

await pool.end();
console.log('\n--- summary ---');
console.log(`already newest: ${same.length}`);
console.log(`updated to newer dump file: ${changed.length}`);
console.log(`could not apply newer: ${noNewer.length}`);
if (changed.length) console.log(JSON.stringify(changed, null, 2));
if (noNewer.filter((x) => x.newest).length) {
  console.log('newer in dump but file missing:');
  for (const x of noNewer.filter((x) => x.newest)) {
    console.log(`  #${x.id} ${x.name}: db=${x.current} dumpNewest=${x.newest} history=${(x.versions || []).join(' | ')}`);
  }
}
