/**
 * Upload Cover-up.png and Sketch.png from scripts/style-icons to R2.
 *   railway run --service ink-api node scripts/upload-style-icons.mjs
 */
import { readFileSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';

const dir = join(dirname(fileURLToPath(import.meta.url)), 'style-icons');
const files = [
  { local: 'Cover-up.png', key: 'Cover-up.png' },
  { local: 'Cover-up.png', key: 'Cover-up-v2.png' },
  { local: 'Sketch.png', key: 'Sketch.png' },
  { local: 'Sketch.png', key: 'Sketch-v2.png' },
];

const { R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET } =
  process.env;
if (!R2_ACCOUNT_ID || !R2_ACCESS_KEY_ID || !R2_SECRET_ACCESS_KEY || !R2_BUCKET) {
  console.error('R2 env missing');
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

for (const { local, key } of files) {
  const buf = readFileSync(join(dir, local));
  await client.send(
    new PutObjectCommand({
      Bucket: R2_BUCKET,
      Key: `assets/images/styles/${key}`,
      Body: buf,
      ContentType: 'image/png',
      ContentLength: buf.length,
      CacheControl: 'public, max-age=3600',
    })
  );
  console.log('Uploaded', key, buf.length);
}
