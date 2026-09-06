/**
 * Upload local backups/ to Cloudflare R2 (S3-compatible).
 * Requires env: R2_ACCOUNT_ID R2_ACCESS_KEY_ID R2_SECRET_ACCESS_KEY R2_BUCKET R2_PUBLIC_BASE
 * Usage: node tools/backup/upload_to_r2.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { S3Client, PutObjectCommand, HeadObjectCommand } from '@aws-sdk/client-s3';
import dotenv from 'dotenv';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../..');
dotenv.config({ path: path.join(repoRoot, 'backend/.env') });
dotenv.config({ path: path.join(repoRoot, '.env') });

const {
  R2_ACCOUNT_ID,
  R2_ACCESS_KEY_ID,
  R2_SECRET_ACCESS_KEY,
  R2_BUCKET,
  R2_PUBLIC_BASE = '',
} = process.env;

if (!R2_ACCOUNT_ID || !R2_ACCESS_KEY_ID || !R2_SECRET_ACCESS_KEY || !R2_BUCKET) {
  console.error('Missing R2_* env vars. Copy backend/.env.example -> backend/.env and fill them.');
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

const sources = [
  { dir: path.join(repoRoot, 'backups/firebase'), prefix: 'firebase/' },
  { dir: path.join(repoRoot, 'backups/smartweb/assets'), prefix: 'assets/' },
];

function walk(dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) out.push(...walk(full));
    else out.push(full);
  }
  return out;
}

function contentType(file) {
  const ext = path.extname(file).toLowerCase();
  return (
    {
      '.jpg': 'image/jpeg',
      '.jpeg': 'image/jpeg',
      '.png': 'image/png',
      '.webp': 'image/webp',
      '.gif': 'image/gif',
      '.svg': 'image/svg+xml',
      '.pdf': 'application/pdf',
      '.json': 'application/json',
    }[ext] || 'application/octet-stream'
  );
}

let uploaded = 0;
let skipped = 0;
let errors = 0;

for (const src of sources) {
  const files = walk(src.dir);
  console.log(`Source ${src.dir} (${files.length} files)`);
  for (const file of files) {
    const rel = path.relative(src.dir, file).split(path.sep).join('/');
    const key = `${src.prefix}${rel}`;
    try {
      const stat = fs.statSync(file);
      try {
        const head = await client.send(new HeadObjectCommand({ Bucket: R2_BUCKET, Key: key }));
        if (head.ContentLength === stat.size) {
          skipped++;
          continue;
        }
      } catch {
        // not found -> upload
      }
      await client.send(
        new PutObjectCommand({
          Bucket: R2_BUCKET,
          Key: key,
          Body: fs.createReadStream(file),
          ContentType: contentType(file),
          ContentLength: stat.size,
        })
      );
      uploaded++;
      const pub = R2_PUBLIC_BASE ? `${R2_PUBLIC_BASE.replace(/\/$/, '')}/${key}` : key;
      console.log(`OK ${key} -> ${pub}`);
    } catch (e) {
      errors++;
      console.error(`FAIL ${key}: ${e.message}`);
    }
  }
}

console.log(`Done. uploaded=${uploaded} skipped=${skipped} errors=${errors}`);
