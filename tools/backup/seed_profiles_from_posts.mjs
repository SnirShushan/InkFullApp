/**
 * Profile avatars were stored on the old PHP server disk (NOT Firebase).
 * Those hosts are dead and no backup exists. This seeds R2 avatars by copying
 * each user's first post image into assets/uploads/profile_images/{filename}.
 *
 * - Users who already have a profile_image filename keep that name (so API URLs work)
 * - Users with empty profile_image but posts get a new filename written to DB
 *
 * Usage: node tools/backup/seed_profiles_from_posts.mjs
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

if (!R2_ACCOUNT_ID || !R2_ACCESS_KEY_ID || !R2_SECRET_ACCESS_KEY || !R2_BUCKET) {
  console.error('Missing R2_* env');
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

const outDir = path.join(
  repoRoot,
  'backups/smartweb/assets/uploads/profile_images'
);
fs.mkdirSync(outDir, { recursive: true });

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

function firstImageToken(imageName) {
  return String(imageName || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean)[0] || '';
}

function guessExt(url, buf) {
  const m = String(url).match(/\.(jpe?g|png|webp|gif)(?:\?|$)/i);
  if (m) return `.${m[1].toLowerCase().replace('jpeg', 'jpg')}`;
  if (buf[0] === 0xff && buf[1] === 0xd8) return '.jpg';
  if (buf[0] === 0x89 && buf[1] === 0x50) return '.png';
  return '.jpg';
}

async function fetchBin(url) {
  const ctrl = new AbortController();
  const t = setTimeout(() => ctrl.abort(), 25000);
  try {
    const res = await fetch(url, {
      signal: ctrl.signal,
      headers: { 'User-Agent': 'InkSeedProfiles/1.0', Accept: 'image/*' },
      redirect: 'follow',
    });
    if (!res.ok) return null;
    const buf = Buffer.from(await res.arrayBuffer());
    if (buf.length < 200) return null;
    const head = buf.subarray(0, 32).toString('utf8').toLowerCase();
    if (head.includes('<!doctype') || head.includes('<html')) return null;
    return buf;
  } catch {
    return null;
  } finally {
    clearTimeout(t);
  }
}

async function putProfile(keyFile, buf) {
  const key = `assets/uploads/profile_images/${keyFile}`;
  try {
    const head = await client.send(
      new HeadObjectCommand({ Bucket: R2_BUCKET, Key: key })
    );
    if (head.ContentLength === buf.length) return { status: 'skipped', key };
  } catch {
    // missing
  }
  await client.send(
    new PutObjectCommand({
      Bucket: R2_BUCKET,
      Key: key,
      Body: buf,
      ContentType: contentType(keyFile),
      ContentLength: buf.length,
    })
  );
  return { status: 'uploaded', key };
}

const pool = mysql.createPool({
  host: DB_HOST,
  port: Number(DB_PORT || 3306),
  user: DB_USER,
  password: DB_PASS,
  database: DB_NAME,
  namedPlaceholders: true,
});

// Prefer business users (artists/studios) first — they show on home cards
const [users] = await pool.query(
  `SELECT c.id, c.name, c.user_type, c.business_type, c.profile_image,
          (
            SELECT p.image_name FROM tbl_post p
            WHERE p.uid = c.id AND p.status = '1'
            ORDER BY p.id DESC LIMIT 1
          ) AS post_image
   FROM tbl_customer c
   WHERE c.is_delete = '0' AND c.status = '1'
     AND (
       (c.profile_image IS NOT NULL AND TRIM(c.profile_image) != '')
       OR EXISTS (
         SELECT 1 FROM tbl_post p WHERE p.uid = c.id AND p.status = '1' LIMIT 1
       )
     )
   ORDER BY c.user_type DESC, c.id ASC`
);

const report = {
  total_candidates: users.length,
  uploaded: 0,
  skipped: 0,
  updated_db: 0,
  no_source: 0,
  failed: 0,
  details: [],
};

const publicBase = String(R2_PUBLIC_BASE || '').replace(/\/$/, '');

for (const u of users) {
  const postToken = firstImageToken(u.post_image);
  if (!postToken) {
    report.no_source++;
    report.details.push({ id: u.id, status: 'no_post_image' });
    continue;
  }

  // Resolve source URL (already absolute R2/firebase, or relative)
  let sourceUrl = postToken;
  if (!/^https?:\/\//i.test(sourceUrl)) {
    if (sourceUrl.startsWith('firebase/')) {
      sourceUrl = `${publicBase}/${sourceUrl}`;
    } else if (sourceUrl.includes('creatorImages/')) {
      sourceUrl = `${publicBase}/firebase/${sourceUrl.replace(/^\/?firebase\//, '')}`;
    } else {
      sourceUrl = `${publicBase}/firebase/${sourceUrl.replace(/^\//, '')}`;
    }
  }

  process.stdout.write(`#${u.id} ${u.name} <- ${sourceUrl.slice(0, 90)}... `);
  const buf = await fetchBin(sourceUrl);
  if (!buf) {
    console.log('FAIL fetch');
    report.failed++;
    report.details.push({ id: u.id, status: 'fetch_failed', sourceUrl });
    continue;
  }

  let filename = String(u.profile_image || '').trim();
  // If stored value is somehow a URL, keep only basename
  if (/^https?:\/\//i.test(filename)) {
    filename = path.basename(filename.split('?')[0]);
  }
  if (!filename) {
    const ext = guessExt(sourceUrl, buf);
    filename = `seeded-${u.id}-${Date.now()}${ext}`;
    await pool.execute(
      `UPDATE tbl_customer SET profile_image = ? WHERE id = ?`,
      [filename, u.id]
    );
    report.updated_db++;
  }

  fs.writeFileSync(path.join(outDir, filename), buf);
  try {
    const put = await putProfile(filename, buf);
    console.log(put.status, put.key);
    if (put.status === 'uploaded') report.uploaded++;
    else report.skipped++;
    report.details.push({
      id: u.id,
      filename,
      status: put.status,
      sourceUrl,
    });
  } catch (e) {
    console.log('FAIL upload', e.message);
    report.failed++;
    report.details.push({ id: u.id, status: 'upload_failed', error: e.message });
  }
}

await pool.end();

fs.writeFileSync(
  path.join(repoRoot, 'backups/profile_images_seed_report.json'),
  JSON.stringify(report, null, 2)
);
console.log('\nSummary:', {
  candidates: report.total_candidates,
  uploaded: report.uploaded,
  skipped: report.skipped,
  updated_db: report.updated_db,
  no_source: report.no_source,
  failed: report.failed,
});
