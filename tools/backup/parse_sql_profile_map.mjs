/**
 * Parse inkisrael SQL dump → {id, profile_image} for files present in assets.
 * node tools/backup/parse_sql_profile_map.mjs
 */
import fs from 'fs';
import readline from 'readline';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '../..');
const sqlPath = path.join(repoRoot, 'data/inkisrael_app.sql');
const profileDir = path.join(repoRoot, 'assets/uploads/profile_images');
const outPath = path.join(repoRoot, 'backups/sql_profile_image_map.json');

const disk = new Set(
  fs
    .readdirSync(profileDir)
    .filter((f) => !f.startsWith('.') && f !== 'index.html')
);

const fileRe =
  /'((?:20\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d{2}-\d+\.(?:png|jpe?g|gif|webp)))'/gi;

const rl = readline.createInterface({
  input: fs.createReadStream(sqlPath),
  crlfDelay: Infinity,
});

const byId = new Map();
let inCustomer = false;
let buf = '';

function flush() {
  if (!buf) return;
  const hits = [];
  let m;
  fileRe.lastIndex = 0;
  while ((m = fileRe.exec(buf))) {
    const file = m[1];
    if (!disk.has(file)) continue;
    const idx = m.index;
    const slice = buf.slice(Math.max(0, idx - 800), idx);
    const ids = [...slice.matchAll(/\((\d+),/g)];
    const id = ids.length ? Number(ids[ids.length - 1][1]) : null;
    if (id) hits.push({ id, file });
  }
  for (const h of hits) byId.set(h.id, h.file);
  buf = '';
}

for await (const line of rl) {
  if (
    line.includes('INSERT INTO `tbl_customer`') ||
    line.includes('INSERT INTO tbl_customer')
  ) {
    inCustomer = true;
    buf = line;
    if (line.trim().endsWith(';')) {
      flush();
      inCustomer = false;
    }
    continue;
  }
  if (inCustomer) {
    buf += '\n' + line;
    if (line.trim().endsWith(';')) {
      flush();
      inCustomer = false;
    }
  }
}
flush();

const rows = [...byId.entries()]
  .map(([id, file]) => ({ id, file }))
  .sort((a, b) => a.id - b.id);

fs.mkdirSync(path.dirname(outPath), { recursive: true });
fs.writeFileSync(outPath, JSON.stringify(rows, null, 2));
console.log(`Wrote ${rows.length} id→profile_image mappings to ${outPath}`);
console.log('sample', rows.slice(0, 12));
