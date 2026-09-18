import crypto from 'crypto';
import { pool } from '../db.js';
import { assetUrl, publicBases } from '../assets.js';

export function ok(data = [], msg = 'Success') {
  return { status: 1, msg, data, ...publicBases() };
}

export function fail(msg = 'Error', status = 0, data = []) {
  return { status, msg, data, ...publicBases() };
}

export function firstImage(imageName) {
  const parts = String(imageName || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  return parts[0] || '';
}

export function imageMeta(imageName, imageId = '') {
  const names = String(imageName || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  const ids = String(imageId || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  const first = names[0] || '';
  return {
    image_name: first ? assetUrl(first) : publicBases().default_img_url,
    image_id: ids[0] || '',
    is_multiple_image: names.length > 1 ? '1' : '0',
  };
}

export function newLoginToken() {
  return crypto.randomBytes(64).toString('hex');
}

function defaultForColumn(col) {
  if (col.Default !== null && col.Default !== undefined) return col.Default;
  const type = String(col.Type || '').toLowerCase();
  if (type.includes('int') || type.includes('decimal') || type.includes('float') || type.includes('double')) {
    return 0;
  }
  if (type.includes('date') || type.includes('time')) return new Date();
  return '';
}

/** Insert a customer row filling every NOT NULL column that has no default. */
export async function insertCustomer(fields) {
  const [cols] = await pool.query('SHOW COLUMNS FROM tbl_customer');
  const row = {};
  for (const col of cols) {
    if (col.Field === 'id' || String(col.Extra || '').includes('auto_increment')) continue;
    row[col.Field] = fields[col.Field] !== undefined ? fields[col.Field] : defaultForColumn(col);
  }
  const keys = Object.keys(row);
  const sql = `INSERT INTO tbl_customer (${keys.join(', ')})
    VALUES (${keys.map((k) => `:${k}`).join(', ')})`;
  const [result] = await pool.query(sql, row);
  return result.insertId;
}

export async function getSettings() {
  const [rows] = await pool.query(
    `SELECT field_name, field_value FROM tbl_settings`
  );
  const settings = {};
  for (const row of rows) {
    if (row?.field_name) settings[row.field_name] = row.field_value ?? '';
  }
  if (Object.keys(settings).length) return settings;
  const [wide] = await pool.query(
    `SELECT * FROM tbl_settings ORDER BY id ASC LIMIT 1`
  );
  return wide[0] || {};
}

export async function getStyleList() {
  const [rows] = await pool.query(
    `SELECT id, name, name_en, image_name, slug, seq
     FROM tbl_styles ORDER BY seq ASC, id ASC`
  );
  return rows.map((r) => ({
    ...r,
    name: r.slug === 'cover-up' ? 'קאבר' : r.name,
    image_url: assetUrl(r.image_name, 'styles'),
  }));
}

export const RETIRED_STYLE_SLUGS = new Set(['tribal', 'bold-line']);

/** Drop retired slugs; tag sketches so inspiration can filter them. */
export function normalizePostStyles(styles, imgType) {
  const parts = String(styles || '')
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s && !RETIRED_STYLE_SLUGS.has(s));
  if (String(imgType) === '1' && !parts.includes('sketch')) {
    parts.push('sketch');
  }
  return parts.join(',');
}

export async function getStyleMap() {
  const styles = await getStyleList();
  const hw = {};
  const en = {};
  for (const s of styles) {
    hw[s.slug] = s.name;
    en[s.slug] = s.name_en;
  }
  return { styles, hw, en };
}

export async function getUserByPhone(phone) {
  const raw = String(phone || '').trim();
  if (!raw) return null;
  const digits = raw.replace(/\D/g, '');
  const [rows] = await pool.query(
    `SELECT * FROM tbl_customer
     WHERE is_delete = '0'
       AND (
         phone = :raw
         OR phone = :digits
         OR REPLACE(REPLACE(phone, '-', ''), ' ', '') = :digits
       )
     ORDER BY id DESC
     LIMIT 1`,
    { raw, digits }
  );
  return rows[0] || null;
}

export async function getUserProfile(id, includePrivate = true) {
  const extra = includePrivate
    ? ', firebase_id, location_enable, udid, push_enable, login_token, is_delete, device_type'
    : '';
  const [rows] = await pool.query(
    `SELECT id${extra}, name, status, email, phone, cnt_code, lang, profile_image,
            styles, business_type, user_type, login_type, address, address_lat,
            address_lng, address_place_id, city_name, about_text, post_limit,
            is_register, is_email_send_plan_upgrade, is_email_send
     FROM tbl_customer
     WHERE id = :id AND is_delete = '0'
     LIMIT 1`,
    { id }
  );
  if (!rows[0]) return null;
  const row = rows[0];
  // PHP returned numeric columns as strings — Flutter RxString / models expect that.
  for (const key of Object.keys(row)) {
    if (row[key] !== null && row[key] !== undefined && typeof row[key] !== 'object') {
      row[key] = String(row[key]);
    }
  }
  if (row.profile_image && String(row.profile_image).trim()) {
    row.profile_image = assetUrl(row.profile_image, 'profile');
  } else {
    row.profile_image = publicBases().default_img_url;
  }
  return row;
}

export async function validateToken(token, uid) {
  if (!token || !uid) return null;
  const [rows] = await pool.query(
    `SELECT id, login_token FROM tbl_customer
     WHERE id = :uid AND login_token = :token AND status = '1' AND is_delete = '0'
     LIMIT 1`,
    { uid, token }
  );
  return rows[0] || null;
}

export async function styleNamesHe(stylesCsv) {
  if (!stylesCsv) return [];
  const { hw } = await getStyleMap();
  return String(stylesCsv)
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean)
    .map((slug) => hw[slug] || slug);
}

function searchWordsFromQuery(search) {
  return String(search || '')
    .split(/[\s,]+/u)
    .map((s) => s.replace(/[%_'"]/g, '').trim())
    .filter((s) => s.length >= 2);
}

function israelDayStamp() {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Jerusalem',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(new Date());
}

function pickDailyTwo(ids) {
  if (!ids.length) return [];
  if (ids.length === 1) return [ids[0]];
  const dayIndex = Math.floor(
    Date.parse(`${israelDayStamp()}T00:00:00+03:00`) / 86400000
  );
  const start = (((dayIndex * 2) % ids.length) + ids.length) % ids.length;
  const first = ids[start];
  const second = ids[(start + 1) % ids.length];
  return first === second ? [first] : [first, second];
}

function sqlInClause(ids, prefix) {
  const params = {};
  const placeholders = ids.map((id, i) => {
    params[`${prefix}${i}`] = id;
    return `:${prefix}${i}`;
  });
  return { clause: placeholders.join(','), params };
}

function interleavePreferFirst(a, b) {
  const out = [];
  let i = 0;
  let j = 0;
  while (i < a.length || j < b.length) {
    if (i < a.length) out.push(a[i++]);
    if (i < a.length) out.push(a[i++]);
    if (j < b.length) out.push(b[j++]);
  }
  return out;
}

let promotedCache = { day: '', ids: [] };

/** Two premium businesses featured today — same pair for every user, rotates daily. */
export async function getDailyPromotedBusinessIds() {
  const day = israelDayStamp();
  if (promotedCache.day === day) return promotedCache.ids;
  const [rows] = await pool.query(
    `
    SELECT DISTINCT c.id
    FROM tbl_customer c
    INNER JOIN tbl_subscription s ON s.cust_id = c.id
    WHERE c.is_delete = '0'
      AND c.status = '1'
      AND c.user_type = '2'
      AND s.status = '1'
      AND s.is_sub_active = '1'
      AND s.is_delete = '0'
      AND s.product_id LIKE '%premium%'
    ORDER BY c.id ASC
    `
  );
  const ids = pickDailyTwo(rows.map((r) => String(r.id)));
  promotedCache = { day, ids };
  return ids;
}

/** Posts for home / inspiration — prefer active subscribers, fall back to any live posts. */
export async function queryPosts({
  styles = '',
  start = 0,
  limit = 6,
  isRandom = false,
  uidOnly = null,
  search = '',
  excludeUid = '',
} = {}) {
  const offset = Math.max(Number(start) || 0, 0);
  const take = Math.min(Math.max(Number(limit) || 6, 1), 50);
  const styleList = String(styles || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

  const wantsSketch = styleList.includes('sketch');
  const styleClause =
    styleList.length > 0
      ? `AND (${styleList
          .map((_, i) => `FIND_IN_SET(:s${i}, p.styles) > 0`)
          .join(' OR ')}${wantsSketch ? ` OR p.img_type = '1'` : ''})`
      : '';
  const styleParams = {};
  styleList.forEach((s, i) => {
    styleParams[`s${i}`] = s;
  });

  const words = searchWordsFromQuery(search);
  const searchParams = {};
  const searchClause =
    words.length > 0
      ? `AND (${words
          .map((_, i) => {
            searchParams[`q${i}`] = `%${words[i]}%`;
            return `(
              p.description LIKE :q${i}
              OR p.styles LIKE :q${i}
              OR c.name LIKE :q${i}
              OR EXISTS (
                SELECT 1 FROM tbl_styles st
                WHERE FIND_IN_SET(st.slug, p.styles) > 0
                  AND (st.name LIKE :q${i} OR st.name_en LIKE :q${i} OR st.slug LIKE :q${i})
              )
            )`;
          })
          .join(' OR ')})`
      : '';

  const uidClause = uidOnly ? 'AND p.uid = :uidOnly' : '';
  const excludeUidClause =
    excludeUid && !uidOnly ? 'AND p.uid <> :excludeUid' : '';
  const order = isRandom ? 'ORDER BY RAND()' : 'ORDER BY p.id DESC';
  const baseParams = { ...styleParams, ...searchParams, uidOnly, excludeUid };

  const fetchRows = async ({ extraWhere = '', extraParams = {}, takeN, offsetN }) => {
    const sqlPremium = `
      SELECT p.id, p.uid, p.image_name, p.image_id, p.styles, p.img_type, p.view_count, p.date_added
      FROM tbl_post p
      INNER JOIN tbl_customer c ON c.id = p.uid AND c.is_delete = '0' AND c.status = '1'
      WHERE p.status = '1'
      AND EXISTS (
        SELECT 1 FROM tbl_subscription s
        WHERE s.cust_id = p.uid AND s.status = '1' AND s.is_sub_active = '1'
        LIMIT 1
      )
      ${styleClause}
      ${searchClause}
      ${uidClause}
      ${excludeUidClause}
      ${extraWhere}
      ${order}
      LIMIT ${takeN} OFFSET ${offsetN}
    `;
    const queryParams = { ...baseParams, ...extraParams };
    const [premium] = await pool.query(sqlPremium, queryParams);
    if (premium.length) return premium;

    const sqlAny = `
      SELECT p.id, p.uid, p.image_name, p.image_id, p.styles, p.img_type, p.view_count, p.date_added
      FROM tbl_post p
      INNER JOIN tbl_customer c ON c.id = p.uid AND c.is_delete = '0'
      WHERE p.status = '1'
      ${styleClause}
      ${searchClause}
      ${uidClause}
      ${excludeUidClause}
      ${extraWhere}
      ${order}
      LIMIT ${takeN} OFFSET ${offsetN}
    `;
    const [any] = await pool.query(sqlAny, queryParams);
    return any;
  };

  let promotedIds = [];
  if (!uidOnly && isRandom) {
    try {
      promotedIds = await getDailyPromotedBusinessIds();
    } catch (_) {
      promotedIds = [];
    }
  }

  if (promotedIds.length) {
    const { clause, params } = sqlInClause(promotedIds, 'pu');
    const promotedTake = Math.ceil(take * 0.6);
    const otherTake = Math.max(take - promotedTake, 0);
    const promotedOffset = Math.floor(offset * 0.6);
    const otherOffset = Math.max(offset - promotedOffset, 0);
    const promotedRows = await fetchRows({
      extraWhere: `AND p.uid IN (${clause})`,
      extraParams: params,
      takeN: promotedTake,
      offsetN: promotedOffset,
    });
    const otherRows = await fetchRows({
      extraWhere: `AND p.uid NOT IN (${clause})`,
      extraParams: params,
      takeN: otherTake + Math.max(promotedTake - promotedRows.length, 0),
      offsetN: otherOffset,
    });
    const mixed = interleavePreferFirst(promotedRows, otherRows);
    const seen = new Set();
    return mixed.filter((row) => {
      const id = String(row.id);
      if (seen.has(id)) return false;
      seen.add(id);
      return true;
    }).slice(0, take);
  }

  return fetchRows({ takeN: take, offsetN: offset });
}

export async function mapPostsForClient(rows, styleNameHw = '') {
  return rows.map((r) => {
    const meta = imageMeta(r.image_name, r.image_id);
    return {
      id: String(r.id),
      uid: String(r.uid),
      styles: r.styles || '',
      style_name: styleNameHw || '',
      style_name_hw: styleNameHw || '',
      img_type: String(r.img_type ?? '0'),
      view_count: String(r.view_count ?? '0'),
      date_added: r.date_added != null ? String(r.date_added) : '',
      ...meta,
    };
  });
}

export async function getBusinessCards({
  styles = '',
  start = 0,
  limit = 6,
  uid = '',
  searchTxt = '',
  recommendedStyles = '',
  popular = false,
  closest = false,
  lat = '',
  lng = '',
} = {}) {
  const offset = Math.max(Number(start) || 0, 0);
  const take = Math.min(Math.max(Number(limit) || 6, 1), 200);
  const styleList = String(styles || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

  let styleClause = '';
  const styleParams = {};
  if (styleList.length) {
    styleClause = `AND (${styleList
      .map((_, i) => `FIND_IN_SET(:bs${i}, c.styles) > 0`)
      .join(' OR ')})`;
    styleList.forEach((s, i) => {
      styleParams[`bs${i}`] = s;
    });
  }

  const recList = String(recommendedStyles || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  let recSelect = '';
  const recParams = {};
  if (recList.length) {
    recSelect = `, CASE WHEN (${recList
      .map((_, i) => `FIND_IN_SET(:rs${i}, c.styles) > 0`)
      .join(' OR ')}) THEN 1 ELSE 0 END AS recommended`;
    recList.forEach((s, i) => {
      recParams[`rs${i}`] = s;
    });
  }

  const search = String(searchTxt || '').trim();
  let searchClause = '';
  const searchParams = {};
  if (search) {
    searchClause = 'AND c.name LIKE :searchQ';
    searchParams.searchQ = `%${search}%`;
  }

  const latN = Number(lat);
  const lngN = Number(lng);
  const hasGeo = Number.isFinite(latN) && Number.isFinite(lngN) && (latN !== 0 || lngN !== 0);
  let distSelect = '';
  const geoParams = {};
  if (closest && hasGeo) {
    distSelect = `, (SQRT(POW(111.32 * (c.address_lat - :userLat), 2) + POW(111.32 * (:userLng - c.address_lng) * COS(c.address_lat / 57.3), 2))) AS distance`;
    geoParams.userLat = latN;
    geoParams.userLng = lngN;
  }

  const popSelect = popular
    ? `, (SELECT COUNT(*) FROM tbl_follows f WHERE f.follow_uid = c.id) AS follower_count`
    : '';

  const selfClause = uid ? 'AND c.id <> :selfUid' : '';
  const selfParams = uid ? { selfUid: uid } : {};
  const extraParams = { ...styleParams, ...selfParams, ...recParams, ...searchParams, ...geoParams };

  let orderBy = 'c.register_date DESC';
  if (popular) {
    orderBy = 'follower_count DESC, c.register_date DESC';
  } else if (closest && hasGeo) {
    orderBy = '(distance IS NULL), distance ASC, c.register_date DESC';
  } else if (recList.length) {
    orderBy = 'recommended DESC, c.register_date DESC';
  }

  const userSelect = `
    SELECT c.id, c.name, c.status, c.profile_image, c.styles, c.business_type,
           c.user_type, c.login_type, c.address, c.about_text, c.city_name
           ${recSelect}
           ${distSelect}
           ${popSelect}
    FROM tbl_customer c
    WHERE c.is_delete = '0'
      AND c.status = '1'
      AND c.user_type = '2'
      ${selfClause}
      ${styleClause}
      ${searchClause}
  `;

  let promotedIds = [];
  try {
    promotedIds = await getDailyPromotedBusinessIds();
  } catch (_) {
    promotedIds = [];
  }
  if (uid) {
    promotedIds = promotedIds.filter((id) => String(id) !== String(uid));
  }

  if (promotedIds.length && (styleList.length || search)) {
    const { clause, params } = sqlInClause(promotedIds, 'pf');
    const [matched] = await pool.query(
      `${userSelect} AND c.id IN (${clause})`,
      { ...extraParams, ...params }
    );
    const allowed = new Set(matched.map((r) => String(r.id)));
    promotedIds = promotedIds.filter((id) => allowed.has(id));
  }

  const excludeClause = promotedIds.length
    ? `AND c.id NOT IN (${sqlInClause(promotedIds, 'ex').clause})`
    : '';
  const excludeParams = promotedIds.length
    ? sqlInClause(promotedIds, 'ex').params
    : {};

  const promotedCount = promotedIds.length;
  const includePromoted = offset === 0 && promotedCount > 0;
  const regularOffset = includePromoted
    ? 0
    : Math.max(0, offset - promotedCount);
  const regularLimit = includePromoted
    ? Math.max(0, take - promotedCount)
    : take;

  let promotedUsers = [];
  if (includePromoted) {
    const { clause, params } = sqlInClause(promotedIds, 'pr');
    const [rows] = await pool.query(
      `${userSelect} AND c.id IN (${clause})`,
      { ...extraParams, ...params }
    );
    const byId = new Map(rows.map((r) => [String(r.id), r]));
    promotedUsers = promotedIds.map((id) => byId.get(id)).filter(Boolean);
  }

  const [regularUsers] = regularLimit > 0
    ? await pool.query(
        `${userSelect}
         ${excludeClause}
         ORDER BY ${orderBy}
         LIMIT ${regularLimit} OFFSET ${regularOffset}`,
        { ...extraParams, ...excludeParams }
      )
    : [[]];

  const { hw } = await getStyleMap();
  const promotedSet = new Set(promotedIds);
  const users = includePromoted
    ? [...promotedUsers, ...regularUsers]
    : regularUsers;

  const likedSet = new Set();
  if (uid && users.length) {
    const ids = users.map((u) => String(u.id));
    const { clause, params } = sqlInClause(ids, 'fl');
    try {
      const [follows] = await pool.query(
        `SELECT follow_uid FROM tbl_follows
         WHERE uid = :uid AND follow_uid IN (${clause})`,
        { uid, ...params }
      );
      for (const row of follows) likedSet.add(String(row.follow_uid));
    } catch (_) {}
  }

  const out = [];
  for (const u of users) {
    const [postRows] = await pool.query(
      `SELECT p.id, p.uid, p.image_name, p.image_id, p.styles, p.img_type, p.view_count, p.date_added
       FROM tbl_post p
       WHERE p.uid = :uid AND p.status = '1'
       ORDER BY p.id DESC
       LIMIT 5`,
      { uid: u.id }
    );
    const business_img = postRows.map((p) => {
      const meta = imageMeta(p.image_name, p.image_id);
      return {
        post_id: String(p.id),
        image_url: meta.image_name,
        is_multiple_image: meta.is_multiple_image,
      };
    });
    const stylesHe = String(u.styles || '')
      .split(',')
      .map((s) => s.trim())
      .filter(Boolean)
      .map((slug) => hw[slug] || slug);

    out.push({
      id: String(u.id),
      name: u.name || '',
      status: String(u.status ?? '1'),
      profile_image: u.profile_image && String(u.profile_image).trim()
        ? assetUrl(u.profile_image, 'profile')
        : publicBases().default_img_url,
      styles: u.styles || '',
      styles_he: stylesHe,
      business_type: String(u.business_type ?? ''),
      user_type: String(u.user_type ?? ''),
      login_type: String(u.login_type ?? ''),
      address: u.address || '',
      about_text: u.about_text || '',
      business_img,
      is_promoted: promotedSet.has(String(u.id)) ? '1' : '0',
      liked: likedSet.has(String(u.id)) ? '1' : '0',
    });
  }
  return out;
}

export async function getNewUserList({ start = 0, limit = 6, uid = '' } = {}) {
  const offset = Math.max(Number(start) || 0, 0);
  const take = Math.min(Math.max(Number(limit) || 6, 1), 30);
  const selfClause = uid ? 'AND c.id <> :selfUid' : '';
  const selfParams = uid ? { selfUid: uid } : {};

  const [rows] = await pool.query(
    `
    SELECT c.id, c.name, c.register_date, c.status, c.email, c.phone, c.cnt_code,
           c.lang, c.profile_image, c.styles, c.business_type, c.user_type,
           c.login_type, c.address, c.address_lat, c.address_lng,
           c.address_place_id, c.about_text, c.post_limit, c.is_register
    FROM tbl_customer c
    WHERE c.is_delete = '0'
      AND c.user_type = '2'
      AND c.status = '1'
      ${selfClause}
    ORDER BY c.register_date DESC
    LIMIT ${take} OFFSET ${offset}
    `,
    selfParams
  );

  return rows.map((r) => ({
    ...r,
    id: String(r.id),
    profile_image: r.profile_image && String(r.profile_image).trim()
      ? assetUrl(r.profile_image, 'profile')
      : publicBases().default_img_url,
  }));
}
