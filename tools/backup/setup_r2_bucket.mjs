/**
 * Create ink-media bucket (if needed), put a health object, print next steps.
 */
import { S3Client, CreateBucketCommand, ListBucketsCommand, PutObjectCommand, HeadBucketCommand } from '@aws-sdk/client-s3';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.resolve(__dirname, '../../backend/.env') });

const accountId = process.env.R2_ACCOUNT_ID;
const bucket = process.env.R2_BUCKET || 'ink-media';

const client = new S3Client({
  region: 'auto',
  endpoint: `https://${accountId}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY,
  },
});

async function main() {
  console.log('endpoint', `https://${accountId}.r2.cloudflarestorage.com`);
  try {
    const listed = await client.send(new ListBucketsCommand({}));
    console.log('buckets', (listed.Buckets || []).map((b) => b.Name));
  } catch (e) {
    console.error('LIST FAIL', e.name, e.message);
    process.exitCode = 1;
    return;
  }

  try {
    await client.send(new HeadBucketCommand({ Bucket: bucket }));
    console.log('bucket exists', bucket);
  } catch {
    try {
      await client.send(new CreateBucketCommand({ Bucket: bucket }));
      console.log('created bucket', bucket);
    } catch (e) {
      console.error('CREATE FAIL', e.name, e.message);
      process.exitCode = 1;
      return;
    }
  }

  await client.send(
    new PutObjectCommand({
      Bucket: bucket,
      Key: '_healthcheck.txt',
      Body: Buffer.from('ink-r2-ok'),
      ContentType: 'text/plain',
    })
  );
  console.log('PUT OK _healthcheck.txt');
}

main();
