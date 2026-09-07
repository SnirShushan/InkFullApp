/**
 * Put the newer seeded profile photos (backups/smartweb) back on R2.
 * Those were overwritten by the older first-upload files from assets/.
 *
 *   node tools/backup/restore_seeded_profiles_to_r2.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import dotenv from 'dotenv';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
dotenv.config({ path: path.join(repoRoot, 'app/api/.env') });

const srcDir = path.join(repoRoot, 'backups/smartweb/assets/uploads/profile_images');
const destDir = path.join(repoRoot, 'studio/php-admin/assets/uploads/profile_images');

const client = new S3Client({
  region: 'auto',
  endpoint: `https://${process.env.R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  },
});

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

fs.mkdirSync(destDir, { recursive: true });
const names = fs.readdirSync(srcDir).filter((f) => !f.startsWith('.') && f !== 'index.html');
console.log(`seeded files: ${names.length}`);

let uploaded = 0;
for (const name of names) {
  const src = path.join(srcDir, name);
  const stat = fs.statSync(src);
  if (!stat.isFile() || stat.size < 200) continue;
  fs.copyFileSync(src, path.join(destDir, name));
  await client.send(
    new PutObjectCommand({
      Bucket: process.env.R2_BUCKET,
      Key: `assets/uploads/profile_images/${name}`,
      Body: fs.createReadStream(src),
      ContentType: contentType(name),
      ContentLength: stat.size,
    })
  );
  uploaded++;
  console.log(`PUT ${name} ${stat.size}`);
}
console.log(`uploaded ${uploaded} newer profile files to R2`);
