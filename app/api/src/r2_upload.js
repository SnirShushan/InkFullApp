import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import path from 'path';
import crypto from 'crypto';

let _client;
function r2() {
  if (_client) return _client;
  const { R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY } = process.env;
  if (!R2_ACCOUNT_ID || !R2_ACCESS_KEY_ID || !R2_SECRET_ACCESS_KEY) {
    return null;
  }
  _client = new S3Client({
    region: 'auto',
    endpoint: `https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId: R2_ACCESS_KEY_ID,
      secretAccessKey: R2_SECRET_ACCESS_KEY,
    },
  });
  return _client;
}

function contentType(filename, mime) {
  if (mime && String(mime).startsWith('image/')) return mime;
  const ext = path.extname(filename || '').toLowerCase();
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

/**
 * Upload a profile image buffer to R2.
 * @returns {Promise<string|null>} basename stored in DB
 */
export async function uploadProfileImageToR2(file) {
  const client = r2();
  const bucket = process.env.R2_BUCKET;
  if (!client || !bucket || !file?.buffer?.length) return null;

  const original = String(file.originalname || file.filename || 'profile.jpg');
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

  const now = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  const stamp = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}-${pad(now.getHours())}-${pad(now.getMinutes())}-${pad(now.getSeconds())}`;
  const filename = `${stamp}-${crypto.randomInt(1e9, 2e9)}${ext}`;
  const key = `assets/uploads/profile_images/${filename}`;

  await client.send(
    new PutObjectCommand({
      Bucket: bucket,
      Key: key,
      Body: file.buffer,
      ContentType: contentType(filename, file.mimetype),
      ContentLength: file.buffer.length,
    })
  );
  return filename;
}
