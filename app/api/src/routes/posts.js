import { Router } from 'express';
import { pool } from '../db.js';
import { assetUrl } from '../assets.js';

export const postsRouter = Router();

postsRouter.get('/', async (req, res) => {
  const limit = Math.min(Number(req.query.limit || 20), 100);
  const offset = Math.max(Number(req.query.offset || 0), 0);
  const [rows] = await pool.query(
    `SELECT id, uid, image_name, img_type, styles, status, date_added
     FROM tbl_post
     WHERE status = '1'
     ORDER BY id DESC
     LIMIT :limit OFFSET :offset`,
    { limit, offset }
  );
  res.json({
    status: 1,
    data: rows.map((r) => {
      const first = String(r.image_name || '')
        .split(',')
        .map((s) => s.trim())
        .filter(Boolean)[0];
      return {
        id: r.id,
        uid: r.uid,
        image_name: r.image_name,
        image_url: assetUrl(first),
        img_type: r.img_type,
        styles: r.styles,
        date_added: r.date_added,
      };
    }),
  });
});

postsRouter.get('/:id', async (req, res) => {
  const [rows] = await pool.query(
    `SELECT id, uid, image_name, img_type, styles, status, date_added
     FROM tbl_post WHERE id = :id LIMIT 1`,
    { id: req.params.id }
  );
  if (!rows.length) {
    return res.status(404).json({ status: 0, msg: 'Not found', data: null });
  }
  const r = rows[0];
  const images = String(r.image_name || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean)
    .map((u) => assetUrl(u));
  res.json({
    status: 1,
    data: {
      ...r,
      images,
      image_url: images[0] || null,
    },
  });
});
