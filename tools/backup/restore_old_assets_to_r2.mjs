/**
 * Restore OldAssets → Cloudflare R2 + match profile images to DB users.
 *
 * Usage:
 *   node tools/backup/restore_old_assets_to_r2.mjs            # dry-run report
 *   node tools/backup/restore_old_assets_to_r2.mjs --upload    # upload to R2
 *   node tools/backup/restore_old_assets_to_r2.mjs --upload --restore-db
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
dotenv.config({ path: path.join(repoRoot, 'backend/.env') });

const doUpload = process.argv.includes('--upload');
const doRestoreDb = process.argv.includes('--restore-db');

const oldRoot = path.join(repoRoot, 'OldAssets');
const profileDir = path.join(oldRoot, 'uploads', 'profile_images');
const bodyDir = path.join(oldRoot, 'uploads', 'body_images');
const sigDir = path.join(oldRoot, 'uploads', 'signature_images');
const stylesDir = path.join(oldRoot, 'images', 'styles');
const imgDir = path.join(oldRoot, 'img');
const uploadsRoot = path.join(oldRoot, 'uploads');

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
      '.pdf': 'application/pdf',
      '.html': 'text/html',
      '.htaccess': 'text/plain',
    }[ext] || 'application/octet-stream'
  );
}

function listFiles(dir) {
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter((f) => !f.startsWith('.') && f !== 'index.html')
    .map((f) => path.join(dir, f))
    .filter((p) => fs.statSync(p).isFile());
}

function basenameSafe(v) {
  return path.basename(String(v || '').split('?')[0]).trim();
}

const report = {
  oldAssets: {
    profiles: 0,
    body: 0,
    signatures: 0,
    styles: 0,
    pdfs: [],
    img: [],
    uploadsRootImages: [],
  },
  match: {
    dbWithFilename: 0,
    dbEmpty: 0,
    matchedByFilename: [],
    missingOnDisk: [],
    orphanOnDisk: [],
    restoredDb: [],
  },
  upload: { uploaded: 0, skipped: 0, failed: [] },
};

const profileFiles = listFiles(profileDir);
const bodyFiles = listFiles(bodyDir);
const sigFiles = listFiles(sigDir);
const styleFiles = listFiles(stylesDir);
const imgFiles = listFiles(imgDir);
const uploadRootFiles = listFiles(uploadsRoot);

report.oldAssets.profiles = profileFiles.length;
report.oldAssets.body = bodyFiles.length;
report.oldAssets.signatures = sigFiles.length;
report.oldAssets.styles = styleFiles.length;
report.oldAssets.pdfs = uploadRootFiles
  .filter((p) => path.extname(p).toLowerCase() === '.pdf')
  .map((p) => ({ name: path.basename(p), bytes: fs.statSync(p).size }));
report.oldAssets.img = imgFiles.map((p) => path.basename(p));
report.oldAssets.uploadsRootImages = uploadRootFiles
  .filter((p) => /\.(png|jpe?g|gif|webp)$/i.test(p))
  .map((p) => path.basename(p));

const diskProfileSet = new Set(profileFiles.map((p) => path.basename(p)));

console.log('OldAssets inventory:');
console.log(`  profile_images: ${profileFiles.length}`);
console.log(`  body_images:    ${bodyFiles.length}`);
console.log(`  signatures:    ${sigFiles.length}`);
console.log(`  styles:         ${styleFiles.length}`);
console.log(`  PDFs:           ${report.oldAssets.pdfs.map((p) => p.name).join(', ')}`);
console.log(`  img/:           ${report.oldAssets.img.join(', ')}`);

const pool = mysql.createPool({
  host: DB_HOST,
  port: Number(DB_PORT || 3306),
  user: DB_USER,
  password: DB_PASS,
  database: DB_NAME,
  waitForConnections: true,
});

const [customers] = await pool.query(
  `SELECT id, name, user_type, profile_image, signature_image
   FROM tbl_customer
   WHERE is_delete = '0'
   ORDER BY id`
);

const byFile = new Map(); // filename -> [customers]
for (const row of customers) {
  const f = basenameSafe(row.profile_image);
  if (!f) {
    report.match.dbEmpty++;
    continue;
  }
  report.match.dbWithFilename++;
  if (!byFile.has(f)) byFile.set(f, []);
  byFile.get(f).push(row);
}

for (const [file, rows] of byFile) {
  if (diskProfileSet.has(file)) {
    report.match.matchedByFilename.push({
      file,
      users: rows.map((r) => ({ id: r.id, name: r.name, user_type: r.user_type })),
    });
  } else {
    report.match.missingOnDisk.push({
      file,
      users: rows.map((r) => ({ id: r.id, name: r.name })),
    });
  }
}

for (const file of diskProfileSet) {
  if (!byFile.has(file)) {
    report.match.orphanOnDisk.push(file);
  }
}

console.log('\nProfile match:');
console.log(`  DB with profile_image: ${report.match.dbWithFilename}`);
console.log(`  DB empty profile_image: ${report.match.dbEmpty}`);
console.log(`  matched on disk: ${report.match.matchedByFilename.length}`);
console.log(`  DB filename missing on disk: ${report.match.missingOnDisk.length}`);
console.log(`  disk orphans (no DB row currently): ${report.match.orphanOnDisk.length}`);

// Historical sources if DB was cleared: SQL dump map + older manifests
const histById = new Map(); // id -> {id, file, name?}

const sqlMapPath = path.join(repoRoot, 'backups/sql_profile_image_map.json');
if (fs.existsSync(sqlMapPath)) {
  try {
    const rows = JSON.parse(fs.readFileSync(sqlMapPath, 'utf8'));
    for (const row of rows) {
      const f = basenameSafe(row.file);
      if (!f || !diskProfileSet.has(f)) continue;
      histById.set(Number(row.id), { id: Number(row.id), file: f, source: 'sql' });
    }
  } catch {
    // ignore
  }
}

for (const mp of [
  path.join(repoRoot, 'backups/profile_images_manifest.json'),
  path.join(repoRoot, 'backups/profile_images_recover_report.json'),
]) {
  if (!fs.existsSync(mp)) continue;
  try {
    const data = JSON.parse(fs.readFileSync(mp, 'utf8'));
    const list = Array.isArray(data)
      ? data
      : [
          ...(data?.details?.missing || []),
          ...(data?.details?.recovered || []),
          ...(data?.details?.exists || []),
        ];
    for (const row of list) {
      const f = basenameSafe(row.file);
      const id = Number(row.id);
      if (!f || !diskProfileSet.has(f) || !id) continue;
      if (!histById.has(id)) {
        histById.set(id, { id, file: f, name: row.name, source: 'manifest' });
      }
    }
  } catch {
    // ignore
  }
}
console.log(`  restorable from SQL/manifests: ${histById.size}`);

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

async function uploadOne(localPath, key) {
  const stat = fs.statSync(localPath);
  if (client) {
    try {
      const head = await client.send(
        new HeadObjectCommand({ Bucket: R2_BUCKET, Key: key })
      );
      if (head.ContentLength === stat.size) {
        report.upload.skipped++;
        return 'skipped';
      }
    } catch {
      // upload
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
      report.upload.uploaded++;
      return 'uploaded';
    } catch (e) {
      report.upload.failed.push({ key, error: e.message });
      return 'failed';
    }
  }
  return 'dry-run';
}

const jobs = [];

// Profiles → assets/uploads/profile_images/
for (const p of profileFiles) {
  const name = path.basename(p);
  jobs.push({ local: p, key: `assets/uploads/profile_images/${name}` });
}
// Body
for (const p of bodyFiles) {
  jobs.push({ local: p, key: `assets/uploads/body_images/${path.basename(p)}` });
}
// Signatures
for (const p of sigFiles) {
  jobs.push({
    local: p,
    key: `assets/uploads/signature_images/${path.basename(p)}`,
  });
}
// Styles
for (const p of styleFiles) {
  jobs.push({ local: p, key: `assets/images/styles/${path.basename(p)}` });
}
// Default / logo
for (const p of imgFiles) {
  jobs.push({ local: p, key: `assets/img/${path.basename(p)}` });
}
// PDFs + startup images in uploads root
for (const p of uploadRootFiles) {
  const ext = path.extname(p).toLowerCase();
  if (ext === '.htaccess' || path.basename(p) === 'index.html') continue;
  jobs.push({ local: p, key: `assets/uploads/${path.basename(p)}` });
}

console.log(`\nUpload plan: ${jobs.length} files` + (doUpload ? '' : ' (dry-run)'));

if (doUpload) {
  let i = 0;
  for (const job of jobs) {
    i++;
    const status = await uploadOne(job.local, job.key);
    if (i % 50 === 0 || status === 'failed') {
      console.log(`[${i}/${jobs.length}] ${status} ${job.key}`);
    }
  }
  console.log(
    `Upload done: uploaded=${report.upload.uploaded} skipped=${report.upload.skipped} failed=${report.upload.failed.length}`
  );
}

// Restore DB profile_image from SQL dump / manifests when empty but file exists
if (doRestoreDb) {
  for (const [id, h] of histById) {
    const [rows] = await pool.query(
      `SELECT id, profile_image FROM tbl_customer WHERE id = ? AND is_delete = '0'`,
      [id]
    );
    if (!rows.length) continue;
    const current = basenameSafe(rows[0].profile_image);
    if (current && diskProfileSet.has(current)) continue; // already good
    if (!diskProfileSet.has(h.file)) continue;
    await pool.query(`UPDATE tbl_customer SET profile_image = ? WHERE id = ?`, [
      h.file,
      id,
    ]);
    report.match.restoredDb.push({
      id,
      file: h.file,
      name: h.name || null,
      source: h.source || null,
    });
  }

  console.log(`DB restored profile_image rows: ${report.match.restoredDb.length}`);
}

await pool.end();

const outPath = path.join(repoRoot, 'backups/old_assets_restore_report.json');
fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(
  outPath,
  JSON.stringify(
    {
      ...report,
      publicBase: R2_PUBLIC_BASE || null,
      sampleMatched: report.match.matchedByFilename.slice(0, 20),
      sampleMissing: report.match.missingOnDisk.slice(0, 20),
      sampleOrphans: report.match.orphanOnDisk.slice(0, 30),
      historicalRestorable: [...histById.values()].slice(0, 40),
    },
    null,
    2
  )
);
console.log(`\nReport: ${outPath}`);
if (!doUpload) {
  console.log('Re-run with --upload to push to R2, add --restore-db to fix DB filenames.');
}
