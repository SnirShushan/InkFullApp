import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
dotenv.config({ path: path.join(repoRoot, 'app/api/.env') });

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

const [biz] = await pool.query(
  `SELECT id, name, profile_image, register_date
   FROM tbl_customer
   WHERE is_delete='0' AND (user_type='2' OR is_business='1')
   ORDER BY id`
);

const [posts] = await pool.query(
  `SELECT uid, image_name, date_added, id
   FROM tbl_post
   ORDER BY id`
);

await pool.end();

function firstToken(s) {
  return String(s || '')
    .split(',')
    .map((x) => path.basename(String(x).trim().split('?')[0]))
    .filter(Boolean);
}

function fileDate(name) {
  const m = String(name).match(/^(\d{4})-(\d{2})-(\d{2})-(\d{2})-(\d{2})-(\d{2})/);
  if (!m) return 0;
  return Date.UTC(+m[1], +m[2] - 1, +m[3], +m[4], +m[5], +m[6]);
}

const postsByUser = new Map();
for (const p of posts) {
  if (!postsByUser.has(p.uid)) postsByUser.set(p.uid, []);
  postsByUser.get(p.uid).push(p);
}

const disk = new Set(
  fs.existsSync(path.join(repoRoot, 'assets/uploads/profile_images'))
    ? fs.readdirSync(path.join(repoRoot, 'assets/uploads/profile_images'))
    : []
);
const bodyDisk = new Set(
  fs.existsSync(path.join(repoRoot, 'assets/uploads/body_images'))
    ? fs.readdirSync(path.join(repoRoot, 'assets/uploads/body_images'))
    : []
);

const samples = [];
for (const u of biz) {
  const current = path.basename(String(u.profile_image || '').split('?')[0]);
  const userPosts = postsByUser.get(u.id) || [];
  const postFiles = [];
  for (const p of userPosts) postFiles.push(...firstToken(p.image_name));
  const newestPost = postFiles.reduce((b, f) => (fileDate(f) >= fileDate(b) ? f : b), '');
  const currentDate = fileDate(current);
  const postDate = fileDate(newestPost);
  const newerPostOnDisk =
    newestPost &&
    postDate > currentDate &&
    (disk.has(newestPost) || bodyDisk.has(newestPost));
  if (u.id === 24 || u.id === 359 || newerPostOnDisk || (newestPost && postDate > currentDate)) {
    samples.push({
      id: u.id,
      name: u.name,
      profile: current,
      profileDate: current ? new Date(currentDate).toISOString() : '',
      posts: userPosts.length,
      newestPost,
      newerThanProfile: postDate > currentDate,
      newestPostInProfileDir: disk.has(newestPost),
      newestPostInBodyDir: bodyDisk.has(newestPost),
    });
  }
}

console.log(JSON.stringify({ totalBiz: biz.length, interesting: samples }, null, 2));
