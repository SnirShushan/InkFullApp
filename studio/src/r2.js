import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import crypto from 'node:crypto';
import path from 'node:path';

let client;

function r2() {
  if (client) return client;
  const { R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY } = process.env;
  if (!R2_ACCOUNT_ID || !R2_ACCESS_KEY_ID || !R2_SECRET_ACCESS_KEY) return null;
  client = new S3Client({
    region: 'auto',
    endpoint: `https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId: R2_ACCESS_KEY_ID,
      secretAccessKey: R2_SECRET_ACCESS_KEY,
    },
  });
  return client;
}

export function startupPublicUrl(filename) {
  const name = String(filename || '').trim();
  if (!name) return '';
  if (/^https?:\/\//i.test(name)) return name;
  const base = (process.env.R2_PUBLIC_BASE || '').replace(/\/$/, '');
  if (!base) return '';
  return `${base}/assets/uploads/${name.replace(/^\/+/, '')}`;
}

export async function uploadStartupImage(file) {
  const s3 = r2();
  const bucket = process.env.R2_BUCKET;
  if (!s3 || !bucket || !file?.buffer?.length) return null;

  const original = String(file.originalname || 'startup.jpg');
  let ext = path.extname(original).toLowerCase();
  if (!ext || ext.length > 5) {
    const mime = String(file.mimetype || '');
    ext =
      mime === 'image/png'
        ? '.png'
        : mime === 'image/webp'
          ? '.webp'
          : mime === 'image/gif'
            ? '.gif'
            : '.jpg';
  }
  const filename = `${crypto.createHash('md5').update(String(Date.now())).digest('hex')}_${Date.now()}${ext}`;
  const key = `assets/uploads/${filename}`;
  await s3.send(
    new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: file.buffer,
      ContentType: file.mimetype || 'image/jpeg',
      ContentLength: file.buffer.length,
      CacheControl: 'public, max-age=3600',
    })
  );
  return filename;
}
