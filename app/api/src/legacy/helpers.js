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

export async function getSettings() {
  const [rows] = await pool.query(
    `SELECT * FROM tbl_settings ORDER BY id ASC LIMIT 1`
  );
  return rows[0] || {};
}

export async function getStyleList() {
  const [rows] = await pool.query(
    `SELECT id, name, name_en, image_name, slug, seq
     FROM tbl_styles ORDER BY seq ASC, id ASC`
  );
  return rows.map((r) => ({
    ...r,
    image_url: assetUrl(r.image_name, 'styles'),
  }));
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

/** Posts for home / inspiration — prefer active subscribers, fall back to any live posts. */
export async function queryPosts({
  styles = '',
  start = 0,
  limit = 6,
  isRandom = false,
  uidOnly = null,
} = {}) {
  const offset = Math.max(Number(start) || 0, 0);
  const take = Math.min(Math.max(Number(limit) || 6, 1), 50);
  const styleList = String(styles || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

  const styleClause =
    styleList.length > 0
      ? `AND (${styleList.map((_, i) => `FIND_IN_SET(:s${i}, p.styles) > 0`).join(' OR ')})`
      : '';
  const styleParams = {};
  styleList.forEach((s, i) => {
    styleParams[`s${i}`] = s;
  });

  const uidClause = uidOnly ? 'AND p.uid = :uidOnly' : '';
  const order = isRandom ? 'ORDER BY RAND()' : 'ORDER BY p.id DESC';

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
    ${uidClause}
    ${order}
    LIMIT ${take} OFFSET ${offset}
  `;

  const [premium] = await pool.query(sqlPremium, { ...styleParams, uidOnly });
  if (premium.length) return premium;

  const sqlAny = `
    SELECT p.id, p.uid, p.image_name, p.image_id, p.styles, p.img_type, p.view_count, p.date_added
    FROM tbl_post p
    INNER JOIN tbl_customer c ON c.id = p.uid AND c.is_delete = '0'
    WHERE p.status = '1'
    ${styleClause}
    ${uidClause}
    ${order}
    LIMIT ${take} OFFSET ${offset}
  `;
  const [any] = await pool.query(sqlAny, { ...styleParams, uidOnly });
  return any;
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

export async function getBusinessCards({ styles = '', start = 0, limit = 6 } = {}) {
  const offset = Math.max(Number(start) || 0, 0);
  const take = Math.min(Math.max(Number(limit) || 6, 1), 20);
  const styleList = String(styles || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

  let styleClause = '';
  const params = {};
  if (styleList.length) {
    styleClause = `AND (${styleList
      .map((_, i) => `FIND_IN_SET(:bs${i}, c.styles) > 0`)
      .join(' OR ')})`;
    styleList.forEach((s, i) => {
      params[`bs${i}`] = s;
    });
  }

  const [users] = await pool.query(
    `
    SELECT c.id, c.name, c.status, c.profile_image, c.styles, c.business_type,
           c.user_type, c.login_type, c.address, c.about_text, c.city_name
    FROM tbl_customer c
    WHERE c.is_delete = '0'
      AND c.status = '1'
      AND c.user_type = '2'
      ${styleClause}
    ORDER BY c.register_date DESC
    LIMIT ${take} OFFSET ${offset}
    `,
    params
  );

  const { hw } = await getStyleMap();
  const out = [];
  for (const u of users) {
    // Latest unique posts for the home card strip (no subscription join — avoids duplicates)
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
    });
  }
  return out;
}

export async function getNewUserList({ start = 0, limit = 6 } = {}) {
  const offset = Math.max(Number(start) || 0, 0);
  const take = Math.min(Math.max(Number(limit) || 6, 1), 30);

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
    ORDER BY c.register_date DESC
    LIMIT ${take} OFFSET ${offset}
    `
  );

  return rows.map((r) => ({
    ...r,
    id: String(r.id),
    profile_image: r.profile_image && String(r.profile_image).trim()
      ? assetUrl(r.profile_image, 'profile')
      : publicBases().default_img_url,
  }));
}
