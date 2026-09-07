/**
 * Link assets/uploads/{profile,body,signature}_images to users/requests
 * from live DB + SQL dump, then upload relevant files to R2.
 *
 * Does NOT overwrite newer seeded profile photos with old first-upload files.
 *
 *   node tools/backup/link_and_upload_legacy_uploads.mjs
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
const dirs = {
  profile: path.join(repoRoot, 'assets/uploads/profile_images'),
  body: path.join(repoRoot, 'assets/uploads/body_images'),
  signature: path.join(repoRoot, 'assets/uploads/signature_images'),
};
const seededDir = path.join(repoRoot, 'backups/smartweb/assets/uploads/profile_images');

function listFiles(dir) {
  if (!fs.existsSync(dir)) return new Set();
  return new Set(
    fs.readdirSync(dir).filter((f) => !f.startsWith('.') && f !== 'index.html')
  );
}

function basenameSafe(v) {
  const raw = String(v || '').trim();
  if (!raw || raw === 'null' || raw === 'undefined' || raw === '[]') return '';
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

function tokens(value) {
  const raw = String(value || '').trim();
  if (!raw || raw === '[]') return [];
  if (raw.startsWith('[')) {
    try {
      const parsed = JSON.parse(raw);
      return (Array.isArray(parsed) ? parsed : [])
        .map(basenameSafe)
        .filter(Boolean);
    } catch {
      return [];
    }
  }
  return raw
    .split(',')
    .map(basenameSafe)
    .filter(Boolean);
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

function parseInserts(text, table) {
  const rows = [];
  const marker = `INSERT INTO \`${table}\``;
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
      if (fields.length) rows.push(fields);
      i += inner.length;
    }
  }
  return rows;
}

function contentType(file) {
  return (
    {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.webp': 'image/webp',
      '.gif': 'image/gif',
    }[path.extname(file).toLowerCase()] || 'image/png'
  );
}

const disk = {
  profile: listFiles(dirs.profile),
  body: listFiles(dirs.body),
  signature: listFiles(dirs.signature),
  seeded: listFiles(seededDir),
};

console.log(
  `disk: profile=${disk.profile.size} body=${disk.body.size} signature=${disk.signature.size} seeded=${disk.seeded.size}`
);

console.log('parsing SQL dump…');
const dumpText = fs.readFileSync(dumpPath, 'utf8');
const dumpCustomers = parseInserts(dumpText, 'tbl_customer');
const dumpRequests = parseInserts(dumpText, 'tbl_request');
console.log(`dump customers=${dumpCustomers.length} requests=${dumpRequests.length}`);

const dumpSig = new Map();
const dumpProfile = new Map();
for (const f of dumpCustomers) {
  const id = Number(f[0]);
  if (!id) continue;
  const profile = basenameSafe(f[11]);
  const signature = basenameSafe(f[38]);
  if (profile) dumpProfile.set(id, profile);
  if (signature) dumpSig.set(id, signature);
}

const dumpReq = new Map();
for (const f of dumpRequests) {
  const id = Number(f[0]);
  if (!id) continue;
  dumpReq.set(id, {
    back: basenameSafe(f[16]),
    front: basenameSafe(f[17]),
    extra: [...tokens(f[8]), ...tokens(f[9]), ...tokens(f[10]), ...tokens(f[24])],
    businessId: Number(f[20]) || 0,
    uid: Number(f[21]) || 0,
  });
}

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

const [customers] = await pool.query(
  `SELECT id, name, user_type, is_business, profile_image, signature_image
   FROM tbl_customer WHERE is_delete='0'`
);
const [requests] = await pool.query(
  `SELECT id, uid, business_id, front_data_image, back_data_image, request_images,
          image1_name, image2_name, image3_name
   FROM tbl_request`
);

const report = {
  signaturesLinked: [],
  bodiesLinked: [],
  uploads: { signature: 0, body: 0, profileSkippedSeeded: 0, profileUnreferenced: 0 },
};

for (const c of customers) {
  const live = basenameSafe(c.signature_image);
  const fromDump = dumpSig.get(c.id) || '';
  if (live && disk.signature.has(live)) continue;
  const pick = (fromDump && disk.signature.has(fromDump) && fromDump !== basenameSafe(c.profile_image))
    ? fromDump
    : '';
  if (!pick) continue;
  await pool.query(`UPDATE tbl_customer SET signature_image = ? WHERE id = ?`, [pick, c.id]);
  report.signaturesLinked.push({ id: c.id, name: c.name, file: pick });
}

for (const r of requests) {
  const dump = dumpReq.get(r.id) || {};
  const liveFront = basenameSafe(r.front_data_image);
  const liveBack = basenameSafe(r.back_data_image);
  const nextFront = liveFront || (disk.body.has(dump.front) ? dump.front : '');
  const nextBack = liveBack || (disk.body.has(dump.back) ? dump.back : '');
  if (nextFront !== liveFront || nextBack !== liveBack) {
    await pool.query(
      `UPDATE tbl_request SET front_data_image = ?, back_data_image = ? WHERE id = ?`,
      [nextFront || liveFront, nextBack || liveBack, r.id]
    );
    report.bodiesLinked.push({
      requestId: r.id,
      businessId: r.business_id,
      uid: r.uid,
      front: nextFront || liveFront,
      back: nextBack || liveBack,
    });
  }
}

const client = new S3Client({
  region: 'auto',
  endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  },
});

async function upload(localPath, key) {
  const stat = fs.statSync(localPath);
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
      Body: fs.createReadStream(localPath),
      ContentType: contentType(localPath),
      ContentLength: stat.size,
    })
  );
  return 'uploaded';
}

const referencedSig = new Set([
  ...customers.map((c) => basenameSafe(c.signature_image)),
  ...report.signaturesLinked.map((x) => x.file),
  ...dumpSig.values(),
].filter((f) => disk.signature.has(f)));

const referencedBody = new Set();
for (const r of requests) {
  for (const f of [
    basenameSafe(r.front_data_image),
    basenameSafe(r.back_data_image),
    ...tokens(r.request_images),
    ...tokens(r.image1_name),
    ...tokens(r.image2_name),
    ...tokens(r.image3_name),
  ]) {
    if (disk.body.has(f)) referencedBody.add(f);
  }
}
for (const d of dumpReq.values()) {
  for (const f of [d.front, d.back, ...d.extra]) {
    if (disk.body.has(f)) referencedBody.add(f);
  }
}

console.log(`referenced signatures on disk: ${referencedSig.size}/${disk.signature.size}`);
console.log(`referenced body images on disk: ${referencedBody.size}/${disk.body.size}`);

// Upload every signature and body file — legal + request archive.
// Unreferenced files stay on R2 under the same path if a dump/DB restore needs them later.
const sigToUpload = [...disk.signature];
const bodyToUpload = [...disk.body];

let i = 0;
for (const name of sigToUpload) {
  i++;
  const status = await upload(
    path.join(dirs.signature, name),
    `assets/uploads/signature_images/${name}`
  );
  if (status === 'uploaded') report.uploads.signature++;
  if (i % 100 === 0) console.log(`signatures ${i}/${sigToUpload.length}`);
}
i = 0;
for (const name of bodyToUpload) {
  i++;
  const status = await upload(path.join(dirs.body, name), `assets/uploads/body_images/${name}`);
  if (status === 'uploaded') report.uploads.body++;
  if (i % 50 === 0) console.log(`body ${i}/${bodyToUpload.length}`);
}

// Profiles: only files that are current DB names AND not replaced by a seeded newer photo.
const liveProfiles = new Set(customers.map((c) => basenameSafe(c.profile_image)).filter(Boolean));
for (const name of liveProfiles) {
  if (disk.seeded.has(name)) {
    report.uploads.profileSkippedSeeded++;
    continue;
  }
  if (!disk.profile.has(name)) continue;
  await upload(path.join(dirs.profile, name), `assets/uploads/profile_images/${name}`);
}

await pool.end();

const out = {
  disk: {
    profile: disk.profile.size,
    body: disk.body.size,
    signature: disk.signature.size,
  },
  linkedSignatures: report.signaturesLinked.length,
  linkedBodies: report.bodiesLinked.length,
  uploadedNew: report.uploads,
  sampleSignatures: report.signaturesLinked.slice(0, 15),
  sampleBodies: report.bodiesLinked.slice(0, 15),
  unreferencedSignatures: disk.signature.size - referencedSig.size,
  unreferencedBodies: disk.body.size - referencedBody.size,
};
fs.writeFileSync(
  path.join(repoRoot, 'backups/legacy_uploads_link_report.json'),
  JSON.stringify(out, null, 2)
);
console.log('\n--- summary ---');
console.log(JSON.stringify(out, null, 2));
