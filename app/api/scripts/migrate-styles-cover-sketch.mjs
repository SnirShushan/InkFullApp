/**
 * ClickUp 86973wf0y
 * Remove Bold Line + Tribal. Add Cover-up + Sketch so inspiration can filter sketches.
 *
 * Run on Railway (injects DB + R2):
 *   railway run --service ink-api node scripts/migrate-styles-cover-sketch.mjs
 */
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { pool } from '../src/db.js';

const REMOVE_SLUGS = new Set(['tribal', 'bold-line']);
const PUBLIC = (process.env.R2_PUBLIC_BASE || '').replace(/\/$/, '');

const NEW_STYLES = [
  {
    name: 'קאבר לקעקוע קיים',
    name_en: 'Cover-up',
    slug: 'cover-up',
    image_name: 'Cover-up-v2.png',
    source: 'Cover-up-v2.png',
  },
  {
    name: 'סקיצה',
    name_en: 'Sketch',
    slug: 'sketch',
    image_name: 'Sketch-v2.png',
    source: 'Sketch-v2.png',
  },
];

function stripSlugs(csv, remove) {
  return String(csv || '')
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s && !remove.has(s))
    .join(',');
}

function addSlug(csv, slug) {
  const parts = String(csv || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  if (!parts.includes(slug)) parts.push(slug);
  return parts.join(',');
}

async function uploadPlaceholder(imageName, sourceName) {
  const { R2_ACCOUNT_ID, R2_ACCESS_KEY_ID, R2_SECRET_ACCESS_KEY, R2_BUCKET } =
    process.env;
  if (!R2_ACCOUNT_ID || !R2_ACCESS_KEY_ID || !R2_SECRET_ACCESS_KEY || !R2_BUCKET) {
    console.warn('R2 env missing — skip icon upload for', imageName);
    return sourceName;
  }
  const srcUrl = `${PUBLIC}/assets/images/styles/${encodeURIComponent(sourceName)}`;
  const res = await fetch(srcUrl);
  if (!res.ok) {
    console.warn('Could not download', srcUrl, res.status);
    return sourceName;
  }
  const buf = Buffer.from(await res.arrayBuffer());
  const client = new S3Client({
    region: 'auto',
    endpoint: `https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId: R2_ACCESS_KEY_ID,
      secretAccessKey: R2_SECRET_ACCESS_KEY,
    },
  });
  await client.send(
    new PutObjectCommand({
      Bucket: R2_BUCKET,
      Key: `assets/images/styles/${imageName}`,
      Body: buf,
      ContentType: 'image/png',
      ContentLength: buf.length,
    })
  );
  console.log('Uploaded', imageName, buf.length);
  return imageName;
}

async function main() {
  const [cols] = await pool.query('SHOW COLUMNS FROM tbl_styles');
  const colNames = new Set(cols.map((c) => c.Field));
  console.log('tbl_styles columns:', [...colNames].join(', '));

  const [maxRows] = await pool.query('SELECT MAX(seq) AS m FROM tbl_styles');
  let seq = Number(maxRows[0]?.m || 0);

  for (const style of NEW_STYLES) {
    const imageName = await uploadPlaceholder(style.image_name, style.source);
    const [existing] = await pool.query(
      'SELECT id FROM tbl_styles WHERE slug = :slug LIMIT 1',
      { slug: style.slug }
    );
    if (existing.length) {
      await pool.query(
        'UPDATE tbl_styles SET name = :name, name_en = :name_en, image_name = :image_name WHERE slug = :slug',
        {
          name: style.name,
          name_en: style.name_en,
          image_name: imageName,
          slug: style.slug,
        }
      );
      console.log('Updated style', style.slug);
      continue;
    }
    seq += 1;
    const fields = ['name', 'name_en', 'slug'];
    const values = {
      name: style.name,
      name_en: style.name_en,
      slug: style.slug,
    };
    if (colNames.has('image_name')) {
      fields.push('image_name');
      values.image_name = imageName;
    }
    if (colNames.has('seq')) {
      fields.push('seq');
      values.seq = seq;
    }
    const placeholders = fields.map((f) => `:${f}`).join(', ');
    await pool.query(
      `INSERT INTO tbl_styles (${fields.join(', ')}) VALUES (${placeholders})`,
      values
    );
    console.log('Inserted style', style.slug, 'seq', seq);
  }

  const [del] = await pool.query(
    `DELETE FROM tbl_styles WHERE slug IN ('tribal', 'bold-line')`
  );
  console.log('Removed tribal/bold-line rows', del.affectedRows ?? del);

  const [posts] = await pool.query('SELECT id, styles, img_type FROM tbl_post');
  let postUpdates = 0;
  for (const p of posts) {
    let styles = stripSlugs(p.styles, REMOVE_SLUGS);
    if (String(p.img_type) === '1') styles = addSlug(styles, 'sketch');
    if (styles !== String(p.styles || '')) {
      await pool.query('UPDATE tbl_post SET styles = :styles WHERE id = :id', {
        styles,
        id: p.id,
      });
      postUpdates += 1;
    }
  }
  console.log('Updated posts', postUpdates, '/', posts.length);

  const [customers] = await pool.query(
    `SELECT id, styles FROM tbl_customer
     WHERE styles IS NOT NULL AND styles != ''`
  );
  let custUpdates = 0;
  for (const c of customers) {
    const styles = stripSlugs(c.styles, REMOVE_SLUGS);
    if (styles !== String(c.styles || '')) {
      await pool.query(
        'UPDATE tbl_customer SET styles = :styles WHERE id = :id',
        { styles, id: c.id }
      );
      custUpdates += 1;
    }
  }
  console.log('Updated customers', custUpdates, '/', customers.length);

  const [finalStyles] = await pool.query(
    'SELECT id, slug, name, name_en, seq FROM tbl_styles ORDER BY seq ASC, id ASC'
  );
  console.log('Catalog now:');
  for (const s of finalStyles) {
    console.log(`  ${s.seq} ${s.slug} | ${s.name} | ${s.name_en}`);
  }

  await pool.end();
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
