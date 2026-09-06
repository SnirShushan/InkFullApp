/**
 * After images are uploaded to R2, rewrite Firebase URLs in DB to R2 public URLs.
 * Dry-run by default. Pass --apply to write.
 *
 * Mapping:
 *   https://firebasestorage.googleapis.com/v0/b/ink-flutter-app.appspot.com/o/PATH?alt=media&token=...
 *   -> ${R2_PUBLIC_BASE}/firebase/PATH (decoded)
 *
 * Usage:
 *   node tools/backup/rewrite_urls_to_r2.mjs
 *   node tools/backup/rewrite_urls_to_r2.mjs --apply
 */
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../..');
dotenv.config({ path: path.join(repoRoot, 'backend/.env') });

const apply = process.argv.includes('--apply');
const base = (process.env.R2_PUBLIC_BASE || '').replace(/\/$/, '');
if (!base) {
  console.error('Set R2_PUBLIC_BASE in backend/.env first.');
  process.exit(1);
}

const bucketPrefix =
  'https://firebasestorage.googleapis.com/v0/b/ink-flutter-app.appspot.com/o/';

function toR2(url) {
  if (!url || !url.includes('firebasestorage.googleapis.com')) return null;
  try {
    const u = new URL(url);
    // pathname like /v0/b/bucket/o/encodedPath
    const marker = '/o/';
    const idx = u.pathname.indexOf(marker);
    if (idx < 0) return null;
    const encoded = u.pathname.slice(idx + marker.length);
    const objectPath = decodeURIComponent(encoded);
    return `${base}/firebase/${objectPath}`;
  } catch {
    return null;
  }
}

const pool = await mysql.createConnection({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'user',
  password: process.env.DB_PASS || 'password',
  database: process.env.DB_NAME || 'inkisrael_app',
  charset: 'utf8mb4',
});

const [posts] = await pool.query(
  `SELECT id, image_name FROM tbl_post WHERE image_name LIKE '%firebasestorage%'`
);

let changed = 0;
for (const row of posts) {
  const parts = String(row.image_name || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  let dirty = false;
  const next = parts.map((p) => {
    const r2 = toR2(p);
    if (r2 && r2 !== p) {
      dirty = true;
      return r2;
    }
    return p;
  });
  if (!dirty) continue;
  changed++;
  const newVal = next.join(',');
  console.log(`post ${row.id}:`);
  console.log(`  FROM ${parts[0]?.slice(0, 90)}...`);
  console.log(`  TO   ${next[0]?.slice(0, 90)}...`);
  if (apply) {
    await pool.query('UPDATE tbl_post SET image_name = ? WHERE id = ?', [newVal, row.id]);
  }
}

console.log(
  `${apply ? 'Updated' : 'Would update'} ${changed} / ${posts.length} posts. ${
    apply ? '' : 'Re-run with --apply to write.'
  }`
);
await pool.end();

// write a small report
fs.mkdirSync(path.join(repoRoot, 'backups'), { recursive: true });
fs.writeFileSync(
  path.join(repoRoot, 'backups/r2_rewrite_report.json'),
  JSON.stringify({ changed, total: posts.length, apply, base, at: new Date().toISOString() }, null, 2)
);
