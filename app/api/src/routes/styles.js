import { Router } from 'express';
import { pool } from '../db.js';
import { assetUrl } from '../assets.js';

export const stylesRouter = Router();

stylesRouter.get('/', async (_req, res) => {
  const [rows] = await pool.query(
    'SELECT id, name, name_en, image_name, slug, seq FROM tbl_styles ORDER BY seq ASC, id ASC'
  );
  res.json({
    status: 1,
    data: rows.map((r) => ({
      id: r.id,
      name: r.name,
      name_en: r.name_en,
      image_name: r.image_name,
      image_url: assetUrl(r.image_name, 'styles'),
      slug: r.slug,
      seq: r.seq,
    })),
  });
});
