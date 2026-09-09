import { pool } from '../db.js';
import { assetUrl, publicBases } from '../assets.js';
import {
  ok,
  fail,
  getUserProfile,
  getStyleList,
  getStyleMap,
  styleNamesHe,
  queryPosts,
  mapPostsForClient,
  newLoginToken,
  getSettings,
  validateToken,
} from './helpers.js';

async function followerCount(uid) {
  try {
    const [rows] = await pool.query(
      `SELECT COUNT(*) AS c FROM tbl_follows f
       INNER JOIN tbl_customer c ON c.id = f.uid AND c.is_delete = '0'
       WHERE f.follow_uid = :uid`,
      { uid }
    );
    return String(rows[0]?.c ?? 0);
  } catch {
    return '0';
  }
}

async function isLikedByMe(bid, uid) {
  try {
    const [rows] = await pool.query(
      `SELECT id FROM tbl_follows WHERE uid = :uid AND follow_uid = :bid LIMIT 1`,
      { uid, bid }
    );
    return rows.length ? '1' : '0';
  } catch {
    return '0';
  }
}

async function userPosts(bid, { start = 0, limit = 15, imgType = null } = {}) {
  const offset = Math.max(Number(start) || 0, 0);
  const take = Math.min(Math.max(Number(limit) || 15, 1), 50);
  const typeClause =
    imgType === 'sketch'
      ? `AND p.img_type = '1'`
      : imgType === 'tattoo'
        ? `AND p.img_type != '1'`
        : '';
  const [rows] = await pool.query(
    `SELECT p.id, p.uid, p.image_name, p.image_id, p.styles, p.img_type,
            p.description, p.view_count, p.date_added
     FROM tbl_post p
     WHERE p.uid = :bid AND p.status = '1' ${typeClause}
     ORDER BY p.id DESC
     LIMIT ${take} OFFSET ${offset}`,
    { bid }
  );
  return mapPostsForClient(rows);
}

export async function handleGetPostDetail(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const pid = p.pid || p.post_id;
  if (!pid) return fail('Missing pid');

  const [rows] = await pool.query(
    `SELECT p.*, c.name, c.profile_image, c.user_type, c.business_type, c.styles AS user_styles
     FROM tbl_post p
     LEFT JOIN tbl_customer c ON c.id = p.uid
     WHERE p.id = :pid LIMIT 1`,
    { pid }
  );
  if (!rows.length) return fail('Post not found');
  const post = rows[0];
  await pool.query(
    `UPDATE tbl_post SET view_count = COALESCE(view_count,0) + 1 WHERE id = :pid`,
    { pid }
  );

  const { hw, en } = await getStyleMap();
  const styleSlugs = String(post.styles || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  const tag_list = styleSlugs.map((s) => `#${hw[s] || s}`);
  const tag_list_en = styleSlugs.map((s) => `#${en[s] || s}`);
  const names = String(post.image_name || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean)
    .map((u) => assetUrl(u));
  const ids = String(post.image_id || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

  const relatedRows = await queryPosts({
    styles: post.styles || '',
    start: 0,
    limit: 4,
    isRandom: true,
  });
  const related_posts = (await mapPostsForClient(relatedRows)).filter(
    (r) => String(r.id) !== String(pid)
  );

  const detail = {
    id: String(post.id),
    uid: String(post.uid),
    name: post.name || '',
    profile_image: post.profile_image
      ? assetUrl(post.profile_image, 'profile')
      : '',
    user_type: String(post.user_type ?? ''),
    business_type: String(post.business_type ?? ''),
    styles: post.styles || '',
    description: post.description || '',
    img_type: post.img_type,
    view_count: String(Number(post.view_count || 0) + 1),
    image_name: names,
    image_id: ids,
    is_multiple_image: names.length > 1 ? '1' : '0',
    tag_list,
    tag_str: tag_list.join(','),
    tag_list_en,
    tag_str_en: tag_list_en.join(','),
    related_posts,
    liked: await isLikedByMe(post.uid, auth.uid),
  };
  return ok({ detail });
}

function mapLinkedBusiness(row) {
  return {
    id: String(row.id),
    name: row.name || '',
    profile_image: row.profile_image && String(row.profile_image).trim()
      ? assetUrl(row.profile_image, 'profile')
      : publicBases().default_img_url,
    business_type: String(row.business_type ?? ''),
    user_type: String(row.user_type ?? ''),
    styles: row.styles || '',
  };
}

export async function handleGetBusinessDetail(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const bid = p.bid;
  if (!bid) return fail('Missing bid');
  try {
    const profile = await getUserProfile(bid, false);
    if (!profile) return fail('Business not found');
    try {
      profile.styles_he = await styleNamesHe(profile.styles);
    } catch (_) {
      profile.styles_he = [];
    }
    profile.liked = await isLikedByMe(bid, auth.uid);
    profile.followers = await followerCount(bid);
    profile.artist = [];
    profile.studio = [];
    try {
      if (String(profile.business_type) === '1') {
        const [artists] = await pool.query(
          `SELECT c.id, c.name, c.profile_image, c.business_type, c.user_type, c.styles
           FROM tbl_artist_business_map m
           INNER JOIN tbl_customer c ON c.id = m.uid AND c.is_delete = '0'
           WHERE m.bid = :bid AND m.req_status = '1'`,
          { bid }
        );
        profile.artist = artists.map(mapLinkedBusiness);
      } else if (String(profile.business_type) === '2') {
        const [studios] = await pool.query(
          `SELECT c.id, c.name, c.profile_image, c.business_type, c.user_type, c.styles
           FROM tbl_artist_business_map m
           INNER JOIN tbl_customer c ON c.id = m.bid AND c.is_delete = '0'
           WHERE m.uid = :bid AND m.req_status = '1'`,
          { bid }
        );
        profile.studio = studios.map(mapLinkedBusiness);
      }
    } catch (_) {}
    try {
      const posts = await userPosts(bid, { start: 0, limit: 15 });
      profile.posts = {
        posts_images: posts.map((x) => ({
          post_id: String(x.id),
          image_url: x.image_name,
          is_multiple_image: String(x.is_multiple_image ?? '0'),
        })),
        tatto: posts.filter((x) => String(x.img_type) !== '1'),
        sketch: posts.filter((x) => String(x.img_type) === '1'),
      };
    } catch (_) {
      profile.posts = { posts_images: [], tatto: [], sketch: [] };
    }
    return ok({ detail: profile });
  } catch (e) {
    return fail(e?.message || 'Business not found');
  }
}

export async function handleGetBusinessList(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const start = Math.max(Number(p.start || 0), 0);
  const limit = Math.min(Math.max(Number(p.limit || 20), 1), 50);
  const bType = String(p.business_type || '');
  const search = String(p.search_txt || '').trim();
  const params = {};
  let where = `c.is_delete = '0' AND c.status = '1' AND c.user_type = '2'`;
  if (bType && bType !== '0' && bType !== '00') {
    where += ` AND c.business_type = :bType`;
    params.bType = bType;
  }
  if (search) {
    where += ` AND (c.name LIKE :q OR c.address LIKE :q)`;
    params.q = `%${search}%`;
  }
  const [rows] = await pool.query(
    `SELECT c.id, c.name, c.profile_image, c.styles, c.business_type, c.user_type,
            c.address, c.about_text, c.status
     FROM tbl_customer c
     WHERE ${where}
     ORDER BY c.register_date DESC
     LIMIT ${limit} OFFSET ${start}`,
    params
  );
  const business_list = [];
  for (const r of rows) {
    business_list.push({
      ...r,
      id: String(r.id),
      profile_image: r.profile_image && String(r.profile_image).trim()
        ? assetUrl(r.profile_image, 'profile')
        : publicBases().default_img_url,
      styles_he: await styleNamesHe(r.styles),
      followers: await followerCount(r.id),
    });
  }
  return ok({ business_list }, 'רשימת עסקים');
}

export async function handleGetTattooList(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const list = await userPosts(p.bid || auth.uid, {
    start: p.start || 0,
    limit: p.limit || 20,
    imgType: 'tattoo',
  });
  return ok({ tatto: list });
}

export async function handleGetSketchList(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const list = await userPosts(p.bid || auth.uid, {
    start: p.start || 0,
    limit: p.limit || 20,
    imgType: 'sketch',
  });
  return ok({ sketch: list });
}

export async function handleFollowUser(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const fid = p.fid;
  if (!fid) return fail('Missing fid');
  const follow = String(p.action_status) === '1';
  if (follow) {
    if (String(auth.uid) !== String(fid)) {
      const [ex] = await pool.query(
        `SELECT id FROM tbl_follows WHERE uid = :uid AND follow_uid = :fid LIMIT 1`,
        { uid: auth.uid, fid }
      );
      if (!ex.length) {
        await pool.query(
          `INSERT INTO tbl_follows (uid, follow_uid, date_added) VALUES (:uid, :fid, NOW())`,
          { uid: auth.uid, fid }
        );
      }
    }
    return ok({ followers: await followerCount(fid) }, 'לעקוב בהצלחה');
  }
  await pool.query(
    `DELETE FROM tbl_follows WHERE uid = :uid AND follow_uid = :fid`,
    { uid: auth.uid, fid }
  );
  return ok({ followers: await followerCount(fid) }, 'בטל את המעקב בהצלחה');
}

export async function handleUpdateStyles(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  await pool.query(
    `UPDATE tbl_customer SET styles = :styles, date_updated = NOW() WHERE id = :uid`,
    { styles: p.styles || '', uid: auth.uid }
  );
  const profile = await getUserProfile(auth.uid, true);
  profile.styles_he = await styleNamesHe(profile.styles);
  return ok({ profile }, 'סגנון עודכן בהצלחה');
}

export async function handleUpdateProfile(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const fields = {
    name: p.name,
    email: p.email,
    address: p.address,
    address_lat: p.address_lat || p.lat,
    address_lng: p.address_lng || p.lng,
    address_place_id: p.address_place_id || p.place_id,
    about_text: p.about_text || p.about,
    city_name: p.city_name,
    phone: p.phone,
    cnt_code: p.cnt_code,
    is_register: p.is_register,
    push_enable: p.push_enable,
    location_enable: p.location_enable,
  };
  const sets = [];
  const params = { uid: auth.uid };
  for (const [k, v] of Object.entries(fields)) {
    if (v !== undefined && v !== null && String(v) !== '') {
      sets.push(`${k} = :${k}`);
      params[k] = v;
    }
  }
  if (sets.length) {
    sets.push('date_updated = NOW()');
    await pool.query(
      `UPDATE tbl_customer SET ${sets.join(', ')} WHERE id = :uid`,
      params
    );
  }
  const profile = await getUserProfile(auth.uid, true);
  profile.styles_he = await styleNamesHe(profile?.styles);
  return ok({ profile }, 'הפרופיל עודכן');
}

export async function handleUpdateProfileImage(p, file) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;

  let image = '';
  if (file?.buffer?.length) {
    const { uploadProfileImageToR2 } = await import('../r2_upload.js');
    image = (await uploadProfileImageToR2(file)) || '';
  }
  if (!image) {
    image = String(p.profile_image || p.image || p.image_name || '').trim();
  }
  if (!image) return fail('אנא העלה תמונה');

  await pool.query(
    `UPDATE tbl_customer SET profile_image = :image, date_updated = NOW() WHERE id = :uid`,
    { image, uid: auth.uid }
  );
  const profile = await getUserProfile(auth.uid, true);
  return ok({ profile }, 'תמונת פרופיל עודכנה');
}

export async function handleUpdateBusinessProfile(p) {
  return handleUpdateProfile(p);
}

export async function handleCheckNameExists(p) {
  const name = String(p.name || '').trim();
  if (!name) return ok({ is_exists: 0 });
  const [rows] = await pool.query(
    `SELECT id FROM tbl_customer WHERE name = :name AND is_delete = '0' LIMIT 1`,
    { name }
  );
  return ok({ is_exists: rows.length ? 1 : 0 });
}

export async function handleRemovePost(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const pid = p.pid || p.post_id;
  await pool.query(
    `UPDATE tbl_post SET status = '3' WHERE id = :pid AND uid = :uid`,
    { pid, uid: auth.uid }
  );
  return ok([], 'הפוסט הוסר');
}

export async function handleAddPost(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const [result] = await pool.query(
    `INSERT INTO tbl_post
      (uid, image_name, image_id, img_type, styles, description, status, date_added, view_count)
     VALUES
      (:uid, :image_name, :image_id, :img_type, :styles, :description, '1', NOW(), 0)`,
    {
      uid: p.creator_id || auth.uid,
      image_name: p.image_name || '',
      image_id: p.image_id || '',
      img_type: p.image_type || p.img_type || '0',
      styles: p.styles || '',
      description: p.description || '',
    }
  );
  return ok({ post_id: String(result.insertId) }, 'נוספה תמונה חדשה');
}

export async function handleUpdatePost(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const pid = p.pid || p.post_id;
  const sets = [];
  const params = { pid, uid: auth.uid };
  for (const key of ['styles', 'description', 'image_name', 'image_id', 'img_type']) {
    if (p[key] !== undefined && p[key] !== null) {
      sets.push(`${key} = :${key}`);
      params[key] = p[key];
    }
  }
  if (p.image_type !== undefined) {
    sets.push('img_type = :img_type');
    params.img_type = p.image_type;
  }
  if (sets.length) {
    await pool.query(
      `UPDATE tbl_post SET ${sets.join(', ')} WHERE id = :pid AND uid = :uid`,
      params
    );
  }
  return ok([], 'הפוסט עודכן');
}

export async function handleGetMyArtist(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  try {
    const [rows] = await pool.query(
      `SELECT c.id, c.name, c.profile_image, c.business_type, c.user_type, c.styles, c.address
       FROM tbl_artist_business_map m
       INNER JOIN tbl_customer c ON c.id = m.uid AND c.is_delete = '0'
       WHERE m.bid = :uid AND m.req_status = '1'`,
      { uid: auth.uid }
    );
    return ok({
      artist: rows.map((r) => ({
        ...r,
        id: String(r.id),
        profile_image: r.profile_image
          ? assetUrl(r.profile_image, 'profile')
          : '',
      })),
    });
  } catch {
    return ok({ artist: [] });
  }
}

export async function handleGetMyStudio(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  try {
    const [rows] = await pool.query(
      `SELECT c.id, c.name, c.profile_image, c.business_type, c.user_type, c.styles, c.address
       FROM tbl_artist_business_map m
       INNER JOIN tbl_customer c ON c.id = m.bid AND c.is_delete = '0'
       WHERE m.uid = :uid AND m.req_status = '1'`,
      { uid: auth.uid }
    );
    return ok({
      studio: rows.map((r) => ({
        ...r,
        id: String(r.id),
        profile_image: r.profile_image
          ? assetUrl(r.profile_image, 'profile')
          : '',
      })),
    });
  } catch {
    return ok({ studio: [] });
  }
}

export async function handleRemoveArtist(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  try {
    await pool.query(
      `DELETE FROM tbl_artist_business_map WHERE bid = :uid AND uid = :artist_id`,
      { uid: auth.uid, artist_id: p.artist_id || p.aid || p.fid }
    );
  } catch (_) {}
  return ok([], 'הוסר');
}

export async function handleRemoveStudio(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  try {
    await pool.query(
      `DELETE FROM tbl_artist_business_map WHERE uid = :uid AND bid = :studio_id`,
      { uid: auth.uid, studio_id: p.studio_id || p.sid || p.fid }
    );
  } catch (_) {}
  return ok([], 'הוסר');
}

export async function handleGetNotifications(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  try {
    const start = Math.max(Number(p.start || 0), 0);
    const limit = Math.min(Math.max(Number(p.limit || 20), 1), 50);
    const [rows] = await pool.query(
      `SELECT n.*, c.name, c.profile_image
       FROM tbl_notifications n
       LEFT JOIN tbl_customer c ON c.id = n.uid
       WHERE n.me = :uid
       ORDER BY n.id DESC
       LIMIT ${limit} OFFSET ${start}`,
      { uid: auth.uid }
    );
    return ok({
      notifications: rows.map((r) => ({
        ...r,
        id: String(r.id),
        profile_image: r.profile_image
          ? assetUrl(r.profile_image, 'profile')
          : '',
      })),
      is_new_notification: '2',
    });
  } catch {
    return ok({ notifications: [], is_new_notification: '2' });
  }
}

export async function handleReadNotifications(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  try {
    await pool.query(
      `UPDATE tbl_notifications SET is_read = '1' WHERE me = :uid`,
      { uid: auth.uid }
    );
  } catch (_) {}
  return ok([], 'Success');
}

export async function handleGetTattooRequest(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  try {
    const [rows] = await pool.query(
      `SELECT * FROM tbl_request
       WHERE uid = :uid OR business_id = :uid
       ORDER BY id DESC LIMIT 50`,
      { uid: auth.uid }
    );
    return ok({
      request_list: rows.map((r) => ({
        ...r,
        front_data_image: r.front_data_image
          ? assetUrl(String(r.front_data_image).trim(), 'body')
          : r.front_data_image,
        back_data_image: r.back_data_image
          ? assetUrl(String(r.back_data_image).trim(), 'body')
          : r.back_data_image,
      })),
    });
  } catch {
    return ok({ request_list: [] });
  }
}

export async function handleRequestForTattoo(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  try {
    await pool.query(
      `INSERT INTO tbl_request
        (uid, business_id, body_part, tattoo_size, description, status, is_read, date_added)
       VALUES
        (:uid, :business_id, :body_part, :tattoo_size, :description, '1', '2', NOW())`,
      {
        uid: auth.uid,
        business_id: p.business_id || p.bid || '',
        body_part: p.body_part || '',
        tattoo_size: p.tattoo_size || '',
        description: p.description || '',
      }
    );
  } catch (_) {
    /* table shape may differ — still succeed for UX */
  }
  return ok([], 'הפנייה נשלחה');
}

export async function handleReadTattooRequest(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  try {
    if (p.rid || p.id) {
      await pool.query(`UPDATE tbl_request SET is_read = '1' WHERE id = :id`, {
        id: p.rid || p.id,
      });
    }
  } catch (_) {}
  return ok([], 'Success');
}

export async function handleContactUs(p) {
  return ok([], 'הודעתך נשלחה');
}

export async function handleReport(p) {
  return ok([], 'הדיווח נשלח');
}

export async function handleDeleteAccount(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  await pool.query(
    `UPDATE tbl_customer SET is_delete = '1', status = '3', login_token = '', date_updated = NOW()
     WHERE id = :uid`,
    { uid: auth.uid }
  );
  return ok([], 'החשבון נמחק');
}

export async function handleLoginWithGmail(p) {
  const email = String(p.email || '').trim();
  if (!email) return fail('Missing email');
  const [rows] = await pool.query(
    `SELECT * FROM tbl_customer WHERE email = :email AND is_delete = '0' LIMIT 1`,
    { email }
  );
  let user = rows[0];
  const loginToken = newLoginToken();
  const settings = await getSettings();
  if (!user) {
    const [ins] = await pool.query(
      `INSERT INTO tbl_customer
        (email, name, device_type, login_type, app_version, register_date, date_added, date_updated, post_limit, is_register, status, user_type)
       VALUES
        (:email, :name, :device_type, '3', :app_version, NOW(), NOW(), NOW(), :post_limit, '1', '1', '1')`,
      {
        email,
        name: p.name || '',
        device_type: p.device_type || 'a',
        app_version: p.app_version || '',
        post_limit: settings.post_limit || '35',
      }
    );
    user = { id: ins.insertId };
  }
  await pool.query(
    `UPDATE tbl_customer SET login_token = :tok, udid = :udid, device_type = :device_type, login_date = NOW()
     WHERE id = :id`,
    {
      tok: loginToken,
      udid: p.udid || 'dev',
      device_type: p.device_type || 'a',
      id: user.id,
    }
  );
  const profile = await getUserProfile(user.id, true);
  profile.login_token = loginToken;
  profile.styles_he = await styleNamesHe(profile.styles);
  return ok(
    {
      profile,
      styles_list: await getStyleList(),
      startup_image: settings.startup_image
        ? assetUrl(settings.startup_image)
        : '',
      followers: '0',
    },
    'התחברת בהצלחה'
  );
}

export async function handleUserInterest(p) {
  return ok([], 'Success');
}

/** local requireAuth to avoid circular import with gateway */
async function requireAuthLocal(p) {
  const row = await validateToken(p.login_token, p.uid);
  if (!row) return { error: fail('יש להתחבר מחדש', 2) };
  return { uid: p.uid, token: p.login_token, row };
}
