import { pool } from '../db.js';
import { ok, fail, validateToken } from './helpers.js';

const TRACKED_ACTIONS = new Set([
  'Login',
  'Register',
  'LoginWithGmail',
  'AddPost',
  'UpdatePost',
  'RemovePost',
  'LikePost',
  'FollowUser',
  'RequestForTattoo',
  'UpdateProfile',
  'UpdateAddress',
  'UpdateProfileImage',
  'UpdateBusinessProfile',
  'UpdateStyles',
  'ReportPost',
  'ReportUser',
  'DeleteAccount',
  'AndroidSubscription',
  'SuccessPurchaseIphone',
  'FreePlanSubscription',
  'UserInterestToUpgrade',
  'ContactUs',
  'GetBusinessDetail',
  'GetPostDetail',
]);

let tableReady = false;

export async function ensureAppEventsTable() {
  if (tableReady) return;
  await pool.query(`
    CREATE TABLE IF NOT EXISTS tbl_app_events (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      uid INT NULL,
      session_id VARCHAR(64) NOT NULL DEFAULT '',
      event_type VARCHAR(16) NOT NULL,
      event_name VARCHAR(80) NOT NULL,
      screen_name VARCHAR(80) NULL,
      duration_ms INT NULL,
      device_type VARCHAR(8) NULL,
      app_version VARCHAR(20) NULL,
      extra JSON NULL,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      KEY idx_type_created (event_type, created_at),
      KEY idx_name_created (event_name, created_at),
      KEY idx_screen_created (screen_name, created_at),
      KEY idx_uid_created (uid, created_at),
      KEY idx_session (session_id)
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

function toDuration(value) {
  const n = Number(value);
  if (!Number.isFinite(n) || n < 0) return null;
  return Math.min(Math.round(n), 24 * 60 * 60 * 1000);
}

function parseEvents(raw) {
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

export async function insertAppEvents(events) {
  if (!events.length) return 0;
  await ensureAppEventsTable();
  const values = events.map((e) => [
    e.uid,
    e.session_id,
    e.event_type,
    e.event_name,
    e.screen_name,
    e.duration_ms,
    e.device_type,
    e.app_version,
    e.extra,
  ]);
  await pool.query(
    `INSERT INTO tbl_app_events
      (uid, session_id, event_type, event_name, screen_name, duration_ms, device_type, app_version, extra)
     VALUES ?`,
    [values]
  );
  return values.length;
}

export function logServerAction(p, action) {
  if (!TRACKED_ACTIONS.has(action)) return;
  const event = {
    uid: toUid(p.uid),
    session_id: clip(p.session_id || `srv-${action}`, 64),
    event_type: 'action',
    event_name: action,
    screen_name: null,
    duration_ms: null,
    device_type: clip(p.device_type, 8) || null,
    app_version: clip(p.app_version, 20) || null,
    extra: JSON.stringify({ source: 'api' }),
  };
  insertAppEvents([event]).catch((err) => {
    console.error('analytics log failed', err.message);
  });
}

export async function handleLogAppEvents(p) {
  try {
    await ensureAppEventsTable();
    let uid = toUid(p.uid);
    if (uid && p.login_token) {
      const row = await validateToken(p.login_token, uid);
      if (!row) uid = toUid(p.uid);
    }
    const sessionId = clip(p.session_id, 64);
    const deviceType = clip(p.device_type, 8) || null;
    const appVersion = clip(p.app_version, 20) || null;
    const incoming = parseEvents(p.events).slice(0, 50);
    const events = [];
    for (const raw of incoming) {
      if (!raw || typeof raw !== 'object') continue;
      const eventType = clip(raw.event_type || raw.type, 16);
      const eventName = clip(raw.event_name || raw.name, 80);
      if (!['screen', 'action', 'session'].includes(eventType) || !eventName) continue;
      let extra = null;
      if (raw.extra && typeof raw.extra === 'object') {
        extra = JSON.stringify(raw.extra);
      } else if (typeof raw.extra === 'string' && raw.extra.trim()) {
        extra = raw.extra.slice(0, 2000);
      }
      events.push({
        uid,
        session_id: clip(raw.session_id, 64) || sessionId,
        event_type: eventType,
        event_name: eventName,
        screen_name: clip(raw.screen_name, 80) || null,
        duration_ms: toDuration(raw.duration_ms),
        device_type: clip(raw.device_type, 8) || deviceType,
        app_version: clip(raw.app_version, 20) || appVersion,
        extra,
      });
    }
    const inserted = await insertAppEvents(events);
    return ok({ inserted }, 'Success');
  } catch (e) {
    return fail(e?.message || 'Analytics failed');
  }
}
