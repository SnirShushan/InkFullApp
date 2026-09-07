import { Router } from 'express';
import { pool } from '../db.js';

export const settingsRouter = Router();

settingsRouter.get('/', async (_req, res) => {
  const [rows] = await pool.query(
    'SELECT field_name, field_value FROM tbl_settings ORDER BY id ASC'
  );
  const settings = {};
  for (const row of rows) {
    settings[row.field_name] = row.field_value;
  }
  res.json({ status: 1, data: settings });
});

settingsRouter.get('/stats', async (_req, res) => {
  const tables = [
    'tbl_customer',
    'tbl_post',
    'tbl_subscription',
    'tbl_follows',
    'tbl_notifications',
    'tbl_request',
    'tbl_styles',
  ];
  const counts = {};
  for (const table of tables) {
    const [[row]] = await pool.query(`SELECT COUNT(*) AS n FROM ${table}`);
    counts[table] = row.n;
  }
  res.json({ status: 1, data: counts });
});
