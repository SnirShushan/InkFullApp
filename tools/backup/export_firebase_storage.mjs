/**
 * Export Firebase/GCS bucket using service account (Node has working SSL on Windows).
 * Usage: node tools/backup/export_firebase_storage.mjs
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { GoogleAuth } from 'google-auth-library';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../..');
const keyPath = path.join(repoRoot, 'api/inkapp-api-admin/api/fcm.json');
const outDir = path.join(repoRoot, 'backups/firebase');
const manifestPath = path.join(repoRoot, 'backups/firebase_manifest.jsonl');
const bucket = 'ink-flutter-app.appspot.com';

fs.mkdirSync(outDir, { recursive: true });

const auth = new GoogleAuth({
  keyFile: keyPath,
  scopes: ['https://www.googleapis.com/auth/devstorage.read_only'],
});
const client = await auth.getClient();

async function listPage(pageToken) {
  const qs = new URLSearchParams({
    maxResults: '200',
    fields: 'nextPageToken,items(name,size,contentType,updated)',
  });
  if (pageToken) qs.set('pageToken', pageToken);
  const url = `https://storage.googleapis.com/storage/v1/b/${encodeURIComponent(bucket)}/o?${qs}`;
  const res = await client.request({ url });
  return res.data;
}

async function downloadObject(name, dest) {
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  const url =
    `https://storage.googleapis.com/storage/v1/b/${encodeURIComponent(bucket)}/o/` +
    `${encodeURIComponent(name)}?alt=media`;
  const res = await client.request({ url, responseType: 'arraybuffer' });
  fs.writeFileSync(dest, Buffer.from(res.data));
}

let pageToken = null;
let total = 0;
let skipped = 0;
let errors = 0;
const manifest = fs.createWriteStream(manifestPath, { flags: 'a' });

console.log(`Exporting gs://${bucket} -> ${outDir}`);

do {
  const data = await listPage(pageToken);
  for (const item of data.items || []) {
    const name = item.name;
    if (!name || name.endsWith('/')) continue;
    const dest = path.join(outDir, ...name.split('/'));
    const remoteSize = item.size != null ? Number(item.size) : -1;
    if (fs.existsSync(dest) && remoteSize >= 0 && fs.statSync(dest).size === remoteSize) {
      skipped++;
      total++;
      continue;
    }
    try {
      await downloadObject(name, dest);
      const size = fs.statSync(dest).size;
      manifest.write(
        JSON.stringify({
          name,
          size,
          contentType: item.contentType || null,
          updated: item.updated || null,
          local: dest,
          exported_at: new Date().toISOString(),
        }) + '\n'
      );
      total++;
      if (total % 25 === 0) console.log(`... ${total} files`);
      else console.log(`OK ${name} (${size})`);
    } catch (e) {
      errors++;
      console.error(`FAIL ${name}: ${e.message}`);
    }
  }
  pageToken = data.nextPageToken || null;
} while (pageToken);

manifest.end();
console.log(`Done. files=${total} skipped_existing≈${skipped} errors=${errors}`);
console.log(`Manifest: ${manifestPath}`);
