import { Router } from 'express';

const SETTINGS_FIELDS = ['admin_email', 'admin_phone', 'package_name', 'post_limit'];

const PLAN_LABELS = {
  subscription_premium_5day: 'פרימיום 5 ימים',
  subscription_basic_5day: 'בסיסי 5 ימים',
  subscription_premium_10day: 'פרימיום 10 ימים',
  subscription_premium_10days: 'פרימיום 10 ימים',
  subscription_basic_10day: 'בסיסי 10 ימים',
  subscription_premium_15day: 'פרימיום 15 ימים',
  subscription_basic_15day: 'בסיסי 15 ימים',
  subscription_premium_20day: 'פרימיום 20 ימים',
  subscription_basic_20day: 'בסיסי 20 ימים',
  subscription_silver: 'כסף',
  subscription_yearly: 'שנתי',
  yearly_premium_plan: 'פרימיום שנתי',
  monthly_premium_plan: 'פרימיום חודשי',
  monthly_basic_plan: 'בסיסי חודשי',
  yearly_basic_plan: 'בסיסי שנתי',
  basic_free_plan: 'חינם',
};

function now() {
  return new Date().toISOString().slice(0, 19).replace('T', ' ');
}

function paging(query) {
  const page = Math.max(1, Number(query.page) || 1);
  const limit = Math.min(100, Math.max(10, Number(query.limit) || 25));
  return { page, limit, offset: (page - 1) * limit, q: String(query.q || '').trim() };
}

function wrap(fn) {
  return (req, res, next) => {
    Promise.resolve(fn(req, res)).catch(next);
  };
}

function countOf(rows) {
  return Number(rows?.[0]?.c || 0);
}

export function createAdminRouter(getLivePool) {
  const router = Router();

  function poolOrThrow() {
    const pool = getLivePool();
    if (!pool) {
      const err = new Error('Live Railway database is not configured');
      err.status = 503;
      throw err;
    }
    return pool;
  }

  router.get(
    '/dashboard',
    wrap(async (_req, res) => {
      const pool = poolOrThrow();
      const [[regular], [business], [posts], [requests], [userReports], [postReports]] = await Promise.all([
        pool.query(`SELECT COUNT(*) AS c FROM tbl_customer WHERE user_type = '1' AND is_delete = '0'`),
        pool.query(`SELECT COUNT(*) AS c FROM tbl_customer WHERE user_type = '2' AND is_delete = '0'`),
        pool.query(`SELECT COUNT(*) AS c FROM tbl_post WHERE status = '1'`),
        pool.query(`SELECT COUNT(*) AS c FROM tbl_request`),
        pool.query(`SELECT COUNT(*) AS c FROM tbl_report_users WHERE status = '0'`),
        pool.query(`SELECT COUNT(*) AS c FROM tbl_report_posts WHERE status = '0'`),
      ]);
      res.json({
        regular: countOf(regular),
        business: countOf(business),
        posts: countOf(posts),
        requests: countOf(requests),
        pendingUserReports: countOf(userReports),
        pendingPostReports: countOf(postReports),
      });
    })
  );

  router.get(
    '/users',
    wrap(async (req, res) => {
      const pool = poolOrThrow();
      const { page, limit, offset, q } = paging(req.query);
      const type = req.query.type === 'business' ? '2' : '1';
      const params = { type, limit, offset };
      let search = '';
      if (q) {
        params.q = `%${q}%`;
        search = `AND (c.name LIKE :q OR c.email LIKE :q OR c.phone LIKE :q OR c.city_name LIKE :q)`;
      }
      const [[totalRow]] = await pool.query(
        `SELECT COUNT(*) AS c FROM tbl_customer c
         WHERE c.is_delete = '0' AND c.user_type = :type ${search}`,
        params
      );
      const [rows] = await pool.query(
        `SELECT
           c.id, c.name, c.email, c.phone, c.cnt_code, c.user_type, c.business_type,
           c.status, c.city_name, c.register_date, c.login_date, c.post_limit, c.sub_id,
           c.profile_image, c.register_type,
           s.product_id AS plan_name, s.expire_date, s.is_sub_active
         FROM tbl_customer c
         LEFT JOIN tbl_subscription s ON s.id = c.sub_id
         WHERE c.is_delete = '0' AND c.user_type = :type ${search}
         ORDER BY c.id DESC
         LIMIT :limit OFFSET :offset`,
        params
      );
      const total = Number(totalRow.c);
      res.json({
        type: type === '2' ? 'business' : 'regular',
        page,
        limit,
        total,
        pages: Math.max(1, Math.ceil(total / limit)),
        rows: rows.map((row) => ({
          ...row,
          plan_label: PLAN_LABELS[row.plan_name] || row.plan_name || '',
        })),
      });
    })
  );

  router.post(
    '/users/:id/status',
    wrap(async (req, res) => {
      const pool = poolOrThrow();
      const id = Number(req.params.id);
      const action = String(req.body?.action || '');
      if (!id) {
        res.status(400).json({ error: 'Missing user id' });
        return;
      }
      const patch = { date_updated: now() };
      if (action === 'block') patch.status = '2';
      else if (action === 'activate') patch.status = '1';
      else if (action === 'delete') {
        patch.is_delete = '1';
        patch.delete_source = '2';
      } else {
        res.status(400).json({ error: 'Unknown action' });
        return;
      }
      const fields = Object.keys(patch);
      const sets = fields.map((key) => `\`${key}\` = :${key}`).join(', ');
      await pool.query(`UPDATE tbl_customer SET ${sets} WHERE id = :id LIMIT 1`, { ...patch, id });
      res.json({ ok: true, id, action });
    })
  );

  router.post(
    '/users/:id/post-limit',
    wrap(async (req, res) => {
      const pool = poolOrThrow();
      const id = Number(req.params.id);
      const postLimit = Number(req.body?.post_limit);
      if (!id || !Number.isFinite(postLimit) || postLimit < 0) {
        res.status(400).json({ error: 'Invalid post limit' });
        return;
      }
      await pool.query(
        'UPDATE tbl_customer SET post_limit = :postLimit, date_updated = :dt WHERE id = :id LIMIT 1',
        { postLimit, dt: now(), id }
      );
      res.json({ ok: true, id, post_limit: postLimit });
    })
  );

  router.get(
    '/reports/users',
    wrap(async (req, res) => {
      const pool = poolOrThrow();
      const { page, limit, offset, q } = paging(req.query);
      const params = { limit, offset };
      let search = '';
      if (q) {
        params.q = `%${q}%`;
        search = `WHERE u.name LIKE :q OR reporter.name LIKE :q OR r.comment LIKE :q`;
      }
      const [[totalRow]] = await pool.query(
        `SELECT COUNT(*) AS c
         FROM tbl_report_users r
         LEFT JOIN tbl_customer u ON u.id = r.uid
         LEFT JOIN tbl_customer reporter ON reporter.id = r.reported_by_uid
         ${search}`,
        params
      );
      const [rows] = await pool.query(
        `SELECT r.id, r.uid, r.reported_by_uid, r.comment, r.status, r.date_added,
                u.name AS user_name, reporter.name AS reported_by
         FROM tbl_report_users r
         LEFT JOIN tbl_customer u ON u.id = r.uid
         LEFT JOIN tbl_customer reporter ON reporter.id = r.reported_by_uid
         ${search}
         ORDER BY r.id DESC
         LIMIT :limit OFFSET :offset`,
        params
      );
      const total = Number(totalRow.c);
      res.json({ page, limit, total, pages: Math.max(1, Math.ceil(total / limit)), rows });
    })
  );

  router.get(
    '/reports/posts',
    wrap(async (req, res) => {
      const pool = poolOrThrow();
      const { page, limit, offset, q } = paging(req.query);
      const params = { limit, offset };
      let search = '';
      if (q) {
        params.q = `%${q}%`;
        search = `WHERE owner.name LIKE :q OR reporter.name LIKE :q OR r.comment LIKE :q`;
      }
      const [[totalRow]] = await pool.query(
        `SELECT COUNT(*) AS c
         FROM tbl_report_posts r
         LEFT JOIN tbl_customer owner ON owner.id = r.owner
         LEFT JOIN tbl_customer reporter ON reporter.id = r.reported_by_uid
         ${search}`,
        params
      );
      const [rows] = await pool.query(
        `SELECT r.id, r.owner, r.reported_by_uid, r.pid, r.comment, r.status, r.date_added,
                owner.name AS owner_name, reporter.name AS reported_by, p.image_name AS post_image
         FROM tbl_report_posts r
         LEFT JOIN tbl_customer owner ON owner.id = r.owner
         LEFT JOIN tbl_customer reporter ON reporter.id = r.reported_by_uid
         LEFT JOIN tbl_post p ON p.id = r.pid
         ${search}
         ORDER BY r.id DESC
         LIMIT :limit OFFSET :offset`,
        params
      );
      const total = Number(totalRow.c);
      res.json({ page, limit, total, pages: Math.max(1, Math.ceil(total / limit)), rows });
    })
  );

  router.post(
    '/reports/:kind/:id',
    wrap(async (req, res) => {
      const pool = poolOrThrow();
      const id = Number(req.params.id);
      const kind = req.params.kind === 'posts' ? 'posts' : 'users';
      const action = String(req.body?.action || '');
      if (!id || !['block', 'keep'].includes(action)) {
        res.status(400).json({ error: 'Invalid report action' });
        return;
      }
      const reportStatus = action === 'block' ? '1' : '2';
      const dt = now();
      if (kind === 'users') {
        const [[report]] = await pool.query('SELECT uid FROM tbl_report_users WHERE id = :id LIMIT 1', { id });
        if (!report) {
          res.status(404).json({ error: 'Report not found' });
          return;
        }
        await pool.query(
          'UPDATE tbl_report_users SET status = :status, date_updated = :dt WHERE id = :id LIMIT 1',
          { status: reportStatus, dt, id }
        );
        await pool.query(
          'UPDATE tbl_customer SET status = :status, date_updated = :dt WHERE id = :uid LIMIT 1',
          { status: action === 'block' ? '2' : '1', dt, uid: report.uid }
        );
      } else {
        const [[report]] = await pool.query('SELECT pid FROM tbl_report_posts WHERE id = :id LIMIT 1', { id });
        if (!report) {
          res.status(404).json({ error: 'Report not found' });
          return;
        }
        await pool.query(
          'UPDATE tbl_report_posts SET status = :status, date_updated = :dt WHERE id = :id LIMIT 1',
          { status: reportStatus, dt, id }
        );
        await pool.query(
          'UPDATE tbl_post SET status = :status, date_updated = :dt WHERE id = :pid LIMIT 1',
          { status: action === 'block' ? '2' : '1', dt, pid: report.pid }
        );
      }
      res.json({ ok: true, id, kind, action });
    })
  );

  router.get(
    '/requests',
    wrap(async (req, res) => {
      const pool = poolOrThrow();
      const { page, limit, offset, q } = paging(req.query);
      const params = { limit, offset };
      let search = '';
      if (q) {
        params.q = `%${q}%`;
        search = `WHERE r.name LIKE :q OR r.phone LIKE :q OR r.email LIKE :q OR r.description LIKE :q OR biz.name LIKE :q`;
      }
      const [[totalRow]] = await pool.query(
        `SELECT COUNT(*) AS c
         FROM tbl_request r
         LEFT JOIN tbl_customer biz ON biz.id = r.business_id
         ${search}`,
        params
      );
      const [rows] = await pool.query(
        `SELECT r.id, r.name, r.phone, r.email, r.tattoo_size, r.styles, r.description,
                r.business_id, r.uid, r.date_added, r.is_contact_request, r.is_read,
                biz.name AS business_name, cust.name AS customer_name
         FROM tbl_request r
         LEFT JOIN tbl_customer biz ON biz.id = r.business_id
         LEFT JOIN tbl_customer cust ON cust.id = r.uid
         ${search}
         ORDER BY r.id DESC
         LIMIT :limit OFFSET :offset`,
        params
      );
      const total = Number(totalRow.c);
      res.json({ page, limit, total, pages: Math.max(1, Math.ceil(total / limit)), rows });
    })
  );

  router.get(
    '/settings',
    wrap(async (_req, res) => {
      const pool = poolOrThrow();
      const [rows] = await pool.query(
        `SELECT field_name, field_value FROM tbl_settings
         WHERE field_name IN (${SETTINGS_FIELDS.map((f) => `'${f}'`).join(',')})`
      );
      const settings = Object.fromEntries(SETTINGS_FIELDS.map((f) => [f, '']));
      for (const row of rows) settings[row.field_name] = row.field_value ?? '';
      res.json({ settings });
    })
  );

  router.put(
    '/settings',
    wrap(async (req, res) => {
      const pool = poolOrThrow();
      const body = req.body || {};
      const updated = [];
      for (const field of SETTINGS_FIELDS) {
        if (!Object.prototype.hasOwnProperty.call(body, field)) continue;
        const value = String(body[field] ?? '');
        await pool.query(
          `UPDATE tbl_settings SET field_value = :value WHERE field_name = :field LIMIT 1`,
          { value, field }
        );
        updated.push(field);
      }
      res.json({ ok: true, updated });
    })
  );

  return router;
}
