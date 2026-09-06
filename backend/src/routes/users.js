import { Router } from 'express';
import { pool } from '../db.js';
import { assetUrl } from '../assets.js';

export const usersRouter = Router();

usersRouter.get('/:id', async (req, res) => {
  const [rows] = await pool.query(
    `SELECT id, name, email, phone, cnt_code, user_type, business_type, profile_image,
            styles, about_text, status, is_delete
     FROM tbl_customer
     WHERE id = :id
     LIMIT 1`,
    { id: req.params.id }
  );
  if (!rows.length) {
    return res.status(404).json({ status: 0, msg: 'Not found', data: null });
  }
  const u = rows[0];
  res.json({
    status: 1,
    data: {
      ...u,
      profile_image_url: assetUrl(u.profile_image, 'profile'),
    },
  });
});
