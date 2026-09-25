import { pool } from '../db.js';
import { ok, fail, validateToken } from './helpers.js';

const LOG_TYPES = new Set([
  'flutter',
  'uncaught',
  'platform',
  'network',
  'api',
  'login',
  'server',
]);

let tableReady = false;

export async function ensureAppErrorLogsTable() {
  if (tableReady) return;
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
  tableReady = true;
}

function clip(value, max) {
  return String(value ?? '').trim().slice(0, max);
}

function toUid(value) {
  const n = Number(value);
  return Number.isInteger(n) && n > 0 ? n : null;
}

function parseLogs(raw) {
  if (Array.isArray(raw)) return raw;
  if (typeof raw === 'string' && raw.trim()) {
    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }
  return [];
}

function extraJson(raw) {
  if (!raw) return null;
  if (typeof raw === 'object') {
    try {
      return JSON.stringify(raw).slice(0, 4000);
    } catch {
      return null;
    }
  }
  const text = String(raw).trim();
  return text ? text.slice(0, 4000) : null;
}

export async function insertAppErrorLogs(rows) {
  if (!rows.length) return 0;
  await ensureAppErrorLogsTable();
  const values = rows.map((row) => [
    row.uid,
    row.log_type,
    row.source,
    row.message,
    row.stack,
    row.screen_name,
    row.action_name,
    row.device_type,
    row.app_version,
    row.extra,
  ]);
  await pool.query(
    `INSERT INTO tbl_app_error_logs
      (uid, log_type, source, message, stack, screen_name, action_name, device_type, app_version, extra)
     VALUES ?`,
    [values]
  );
  return values.length;
}

export function logServerError({
  message,
  stack,
  action,
  uid,
  deviceType,
  appVersion,
  extra,
} = {}) {
  const text = clip(message, 2000);
  if (!text) return;
  insertAppErrorLogs([
    {
      uid: toUid(uid),
      log_type: 'server',
      source: 'api',
      message: text,
      stack: clip(stack, 8000) || null,
      screen_name: null,
      action_name: clip(action, 80) || null,
      device_type: clip(deviceType, 8) || null,
      app_version: clip(appVersion, 20) || null,
      extra: extraJson(extra),
    },
  ]).catch((err) => {
    console.error('error log failed', err.message);
  });
}

export async function handleLogAppError(p) {
  try {
    await ensureAppErrorLogsTable();
    let uid = toUid(p.uid);
    if (uid && p.login_token) {
      const row = await validateToken(p.login_token, uid);
      if (!row) uid = toUid(p.uid);
    }
    const deviceType = clip(p.device_type, 8) || null;
    const appVersion = clip(p.app_version, 20) || null;
    const incoming = parseLogs(p.logs || p.errors).slice(0, 30);
    const rows = [];
    for (const raw of incoming) {
      if (!raw || typeof raw !== 'object') continue;
      const message = clip(raw.message || raw.error || raw.title, 2000);
      if (!message) continue;
      const logType = clip(raw.log_type || raw.type, 32) || 'uncaught';
      rows.push({
        uid,
        log_type: LOG_TYPES.has(logType) ? logType : 'uncaught',
        source: clip(raw.source, 16) || 'app',
        message,
        stack: clip(raw.stack || raw.stack_trace, 8000) || null,
        screen_name: clip(raw.screen_name || raw.screen, 80) || null,
        action_name: clip(raw.action_name || raw.action, 80) || null,
        device_type: clip(raw.device_type, 8) || deviceType,
        app_version: clip(raw.app_version, 20) || appVersion,
        extra: extraJson(raw.extra),
      });
    }
    if (!rows.length && clip(p.message, 2000)) {
      const logType = clip(p.log_type || p.type, 32) || 'uncaught';
      rows.push({
        uid,
        log_type: LOG_TYPES.has(logType) ? logType : 'uncaught',
        source: 'app',
        message: clip(p.message, 2000),
        stack: clip(p.stack, 8000) || null,
        screen_name: clip(p.screen_name, 80) || null,
        action_name: clip(p.action_name, 80) || null,
        device_type: deviceType,
        app_version: appVersion,
        extra: extraJson(p.extra),
      });
    }
    const inserted = await insertAppErrorLogs(rows);
    return ok({ inserted }, 'Success');
  } catch (e) {
    return fail(e?.message || 'Log failed');
  }
}

export async function handleLoginFailLog(p) {
  const message = clip(p.error_text || p.message, 2000) || 'Login failed';
  logServerError({
    message,
    action: 'LoginFailDBLog',
    uid: p.uid,
    deviceType: p.device_type,
    appVersion: p.app_version,
    extra: {
      source: 'login',
      phone: clip(p.phone, 32),
      cnt_code: clip(p.cnt_code, 8),
    },
  });
  try {
    await pool.query(
      `INSERT INTO tbl_login_error_db (cnt_code, phone, error_text, device_type, date_added)
       VALUES (?, ?, ?, ?, NOW())`,
      [
        clip(p.cnt_code, 8),
        clip(p.phone, 32),
        message,
        clip(p.device_type, 8),
      ]
    );
  } catch (_) {
    // legacy table may be missing; the new error log is enough
  }
  return ok([], 'Logged');
}
