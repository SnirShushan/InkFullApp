import { Router } from 'express';
import { ping, pool } from '../db.js';
import { publicBases } from '../assets.js';

export const healthRouter = Router();

healthRouter.get('/health', async (_req, res) => {
  const db = await ping();
  let counts = {};
  if (db) {
    const [[c]] = await pool.query('SELECT COUNT(*) AS n FROM tbl_customer');
    const [[p]] = await pool.query('SELECT COUNT(*) AS n FROM tbl_post');
    counts = { customers: c.n, posts: p.n };
  }
  res.json({
    ok: true,
    db,
    counts,
    assets: publicBases(),
    architecture: 'node-mysql-r2',
  });
});
