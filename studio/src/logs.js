const TABLES = {
  errors: {
    id: 'errors',
    label: 'שגיאות אפליקציה',
    table: 'tbl_app_error_logs',
  },
  legacy: {
    id: 'legacy',
    label: 'לוגים ישנים',
    table: 'tbl_app_log',
  },
  login: {
    id: 'login',
    label: 'שגיאות התחברות',
    table: 'tbl_login_error_db',
  },
  events: {
    id: 'events',
    label: 'אירועי שימוש',
    table: 'tbl_app_events',
  },
};

const ERROR_TYPE_LABELS = {
  flutter: 'ממשק',
  uncaught: 'לא נתפסה',
  platform: 'מערכת',
  network: 'רשת',
  api: 'API',
  login: 'התחברות',
  server: 'שרת',
};

const EVENT_TYPE_LABELS = {
  screen: 'מסך',
  action: 'פעולה',
  session: 'סשן',
};

export const LOG_TABLES = Object.values(TABLES).map(({ id, label }) => ({ id, label }));

async function tableExists(pool, name) {
  const [rows] = await pool.query('SHOW TABLES LIKE ?', [name]);
  return rows.length > 0;
}

async function ensureErrorLogs(pool) {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS tbl_app_error_logs (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      uid INT NULL,
      log_type VARCHAR(32) NOT NULL DEFAULT 'uncaught',
      source VARCHAR(16) NOT NULL DEFAULT 'app',
      message TEXT NOT NULL,
      stack TEXT NULL,
      screen_name VARCHAR(80) NULL,
      action_name VARCHAR(80) NULL,
      device_type VARCHAR(8) NULL,
      app_version VARCHAR(20) NULL,
      extra JSON NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      KEY idx_type_created (log_type, created_at),
      KEY idx_source_created (source, created_at),
      KEY idx_uid_created (uid, created_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);
}

function emptyResult(table, page, limit) {
  return {
    table,
    page,
    limit,
    total: 0,
    pages: 1,
    rows: [],
    types: [],
    missing: true,
  };
}

export async function loadLogs(pool, query = {}) {
  const page = Math.max(1, Number(query.page) || 1);
  const limit = Math.min(100, Math.max(10, Number(query.limit) || 25));
  const offset = (page - 1) * limit;
  const q = String(query.q || '').trim();
  const type = String(query.type || '').trim();
  const tableKey = TABLES[query.table] ? query.table : 'errors';
  const spec = TABLES[tableKey];

  if (tableKey === 'errors') {
    await ensureErrorLogs(pool);
  } else if (!(await tableExists(pool, spec.table))) {
    return emptyResult(tableKey, page, limit);
  }

  if (tableKey === 'errors') return loadErrorLogs(pool, { page, limit, offset, q, type });
  if (tableKey === 'legacy') return loadLegacyLogs(pool, { page, limit, offset, q });
  if (tableKey === 'login') return loadLoginLogs(pool, { page, limit, offset, q, type });
  return loadEventLogs(pool, { page, limit, offset, q, type });
}

async function loadErrorLogs(pool, { page, limit, offset, q, type }) {
  const params = { limit, offset };
  const where = [];
  if (type) {
    params.type = type;
    where.push('log_type = :type');
  }
  if (q) {
    params.q = `%${q}%`;
    where.push(
      '(message LIKE :q OR stack LIKE :q OR action_name LIKE :q OR screen_name LIKE :q OR CAST(uid AS CHAR) LIKE :q)'
    );
  }
  const clause = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const [[totalRow]] = await pool.query(
    `SELECT COUNT(*) AS c FROM tbl_app_error_logs ${clause}`,
    params
  );
  const [rows] = await pool.query(
    `SELECT
       id, uid, log_type, source, message, stack, screen_name, action_name,
       device_type, app_version, extra,
       CAST(created_at AS CHAR) AS created_at
     FROM tbl_app_error_logs
     ${clause}
     ORDER BY id DESC
     LIMIT :limit OFFSET :offset`,
    params
  );
  const [typeRows] = await pool.query(
    `SELECT log_type AS id, COUNT(*) AS c FROM tbl_app_error_logs GROUP BY log_type ORDER BY c DESC`
  );
  const total = Number(totalRow.c);
  return {
    table: 'errors',
    page,
    limit,
    total,
    pages: Math.max(1, Math.ceil(total / limit)),
    types: typeRows.map((row) => ({
      id: row.id,
      label: ERROR_TYPE_LABELS[row.id] || row.id,
      count: Number(row.c || 0),
    })),
    rows: rows.map((row) => ({
      ...row,
      type_label: ERROR_TYPE_LABELS[row.log_type] || row.log_type,
      extra: stringifyExtra(row.extra),
    })),
    missing: false,
  };
}

async function loadLegacyLogs(pool, { page, limit, offset, q }) {
  const params = { limit, offset };
  let clause = '';
  if (q) {
    params.q = `%${q}%`;
    clause = 'WHERE CAST(log_date AS CHAR) LIKE :q OR log_data LIKE :q';
  }
  const [[totalRow]] = await pool.query(
    `SELECT COUNT(*) AS c FROM tbl_app_log ${clause}`,
    params
  );
  const [rows] = await pool.query(
    `SELECT id, CAST(log_date AS CHAR) AS log_date, log_data,
            CAST(created_at AS CHAR) AS created_at,
            CAST(updated_at AS CHAR) AS updated_at
     FROM tbl_app_log
     ${clause}
     ORDER BY log_date DESC
     LIMIT :limit OFFSET :offset`,
    params
  ).catch(async () => {
    const [fallback] = await pool.query(
      `SELECT * FROM tbl_app_log ${clause} ORDER BY 1 DESC LIMIT :limit OFFSET :offset`,
      params
    );
    return [fallback];
  });
  const total = Number(totalRow.c);
  return {
    table: 'legacy',
    page,
    limit,
    total,
    pages: Math.max(1, Math.ceil(total / limit)),
    types: [],
    rows: rows.map((row) => ({
      id: row.id,
      created_at: row.log_date || row.created_at || row.updated_at,
      log_type: 'legacy',
      type_label: 'לוג יומי',
      message: clip(row.log_data, 180) || '—',
      stack: row.log_data || '',
      extra: '',
    })),
    missing: false,
  };
}

async function loadLoginLogs(pool, { page, limit, offset, q, type }) {
  const params = { limit, offset };
  const where = [];
  if (type) {
    params.type = type;
    where.push('device_type = :type');
  }
  if (q) {
    params.q = `%${q}%`;
    where.push('(error_text LIKE :q OR phone LIKE :q OR cnt_code LIKE :q)');
  }
  const clause = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const [[totalRow]] = await pool.query(
    `SELECT COUNT(*) AS c FROM tbl_login_error_db ${clause}`,
    params
  );
  const [rows] = await pool.query(
    `SELECT id, cnt_code, phone, error_text, device_type,
            CAST(date_added AS CHAR) AS date_added
     FROM tbl_login_error_db
     ${clause}
     ORDER BY id DESC
     LIMIT :limit OFFSET :offset`,
    params
  );
  const [typeRows] = await pool.query(
    `SELECT device_type AS id, COUNT(*) AS c FROM tbl_login_error_db GROUP BY device_type`
  );
  const total = Number(totalRow.c);
  return {
    table: 'login',
    page,
    limit,
    total,
    pages: Math.max(1, Math.ceil(total / limit)),
    types: typeRows.map((row) => ({
      id: row.id,
      label: row.id === 'i' ? 'iOS' : row.id === 'a' ? 'Android' : row.id || 'לא ידוע',
      count: Number(row.c || 0),
    })),
    rows: rows.map((row) => ({
      id: row.id,
      uid: null,
      log_type: row.device_type || 'login',
      type_label: row.device_type === 'i' ? 'iOS' : row.device_type === 'a' ? 'Android' : 'התחברות',
      message: row.error_text || '—',
      stack: '',
      screen_name: '',
      action_name: row.phone || '',
      device_type: row.device_type,
      app_version: row.cnt_code,
      created_at: row.date_added,
      extra: '',
    })),
    missing: false,
  };
}

async function loadEventLogs(pool, { page, limit, offset, q, type }) {
  const params = { limit, offset };
  const where = [];
  if (type) {
    params.type = type;
    where.push('event_type = :type');
  }
  if (q) {
    params.q = `%${q}%`;
    where.push(
      '(event_name LIKE :q OR screen_name LIKE :q OR session_id LIKE :q OR CAST(uid AS CHAR) LIKE :q)'
    );
  }
  const clause = where.length ? `WHERE ${where.join(' AND ')}` : '';
  const [[totalRow]] = await pool.query(
    `SELECT COUNT(*) AS c FROM tbl_app_events ${clause}`,
    params
  );
  const [rows] = await pool.query(
    `SELECT id, uid, session_id, event_type, event_name, screen_name, duration_ms,
            device_type, app_version, extra, CAST(created_at AS CHAR) AS created_at
     FROM tbl_app_events
     ${clause}
     ORDER BY id DESC
     LIMIT :limit OFFSET :offset`,
    params
  );
  const [typeRows] = await pool.query(
    `SELECT event_type AS id, COUNT(*) AS c FROM tbl_app_events GROUP BY event_type ORDER BY c DESC`
  );
  const total = Number(totalRow.c);
  return {
    table: 'events',
    page,
    limit,
    total,
    pages: Math.max(1, Math.ceil(total / limit)),
    types: typeRows.map((row) => ({
      id: row.id,
      label: EVENT_TYPE_LABELS[row.id] || row.id,
      count: Number(row.c || 0),
    })),
    rows: rows.map((row) => ({
      id: row.id,
      uid: row.uid,
      log_type: row.event_type,
      type_label: EVENT_TYPE_LABELS[row.event_type] || row.event_type,
      message: row.event_name || '—',
      stack: '',
      screen_name: row.screen_name,
      action_name: row.session_id,
      device_type: row.device_type,
      app_version: row.app_version,
      created_at: row.created_at,
      extra: stringifyExtra(row.extra),
    })),
    missing: false,
  };
}

function stringifyExtra(value) {
  if (value == null || value === '') return '';
  if (typeof value === 'string') return value;
  try {
    return JSON.stringify(value);
  } catch {
    return String(value);
  }
}

function clip(value, max) {
  const text = String(value ?? '');
  return text.length > max ? `${text.slice(0, max)}…` : text;
}
