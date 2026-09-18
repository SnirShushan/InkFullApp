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
  insertCustomer,
  validateToken,
  normalizePostStyles,
} from './helpers.js';

function toIsoDate(value) {
  if (value == null || value === '') return '';
  const d = value instanceof Date ? value : new Date(value);
  if (Number.isNaN(d.getTime())) return '';
  return d.toISOString();
}

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
    `SELECT p.* FROM tbl_post p WHERE p.id = :pid AND p.status = '1' LIMIT 1`,
    { pid }
  );
  if (!rows.length) return fail('הפוסט לא נמצא');
  const post = rows[0];
  await pool.query(
    `UPDATE tbl_post SET view_count = COALESCE(view_count,0) + 1 WHERE id = :pid`,
    { pid }
  );

  // Flutter PostDetails expects nested owner/artist (PHP get_post_detail).
  // Without owner the client immediately Get.back() and kicks the user out.
  const owner = await getUserProfile(post.uid, false);
  let artist = [];
  if (owner && String(owner.business_type) === '1' && post.artist_uid) {
    artist = (await getUserProfile(post.artist_uid, false)) || [];
  }

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
    excludeUid: auth.uid,
  });
  const related_posts = (await mapPostsForClient(relatedRows))
    .filter((r) => String(r.id) !== String(pid))
    .map((r) => ({
      id: r.id,
      uid: r.uid,
      img_type: r.img_type,
      styles: r.styles || '',
      description: r.description || '',
      image_name: r.image_name,
      image_id: r.image_id,
      is_multiple_image: r.is_multiple_image,
    }));

  const detail = {
    id: String(post.id),
    uid: String(post.uid),
    img_type: post.img_type != null ? String(post.img_type) : '0',
    styles: post.styles || '',
    description: post.description || '',
    image_name: names,
    image_id: ids,
    date_added: toIsoDate(post.date_added),
    date_updated: toIsoDate(post.date_updated),
    artist_uid: post.artist_uid != null ? String(post.artist_uid) : '',
    status: post.status != null ? String(post.status) : '1',
    studio_uid: post.studio_uid != null ? String(post.studio_uid) : '',
    owner: owner || null,
    artist,
    liked: await isLikedByMe(post.uid, auth.uid),
    is_multiple_image: names.length > 1 ? '1' : '0',
    tag_list,
    tag_str: tag_list.join(','),
    tag_list_en,
    tag_str_en: tag_list_en.join(','),
    related_posts,
    view_count: String(Number(post.view_count || 0) + 1),
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

async function notifyBusinessFollow(followerId, businessId) {
  const [targets] = await pool.query(
    `SELECT id, user_type, push_enable, udid, firebase_id, device_type
     FROM tbl_customer
     WHERE id = :id AND is_delete = '0' LIMIT 1`,
    { id: businessId }
  );
  const target = targets[0];
  if (!target || String(target.user_type) !== '2') return;

  const follower = await getUserProfile(followerId, false);
  const followerName = follower?.name || 'משתמש';

  await pool.query(
    `INSERT INTO tbl_notifications
      (noti_type, date_added, uid, pid, me, is_read, status)
     VALUES
      ('new_follow', NOW(), :uid, 0, :me, '2', '0')`,
    { uid: followerId, me: businessId }
  );

  if (String(target.push_enable) !== '1') return;
  const token = String(target.udid || target.firebase_id || '').trim();
  if (!token) return;

  const { sendPush } = await import('../push.js');
  await sendPush({
    token,
    title: `${followerName} הוסיף אותך למעקב`,
    body: '',
    deviceType: target.device_type,
    data: {
      screen: 'notification',
      is_request: '0',
      pid: '0',
      badge_count: '1',
      description: '',
    },
  });
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
        notifyBusinessFollow(auth.uid, fid).catch((err) =>
          console.error('follow push failed', err?.message || err)
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
  if (String(p.name || '').trim() !== '') {
    fields.is_register = '0';
  }
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

export async function handleUpdateBusinessProfile(p, files) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;

  const name = String(p.name || '').trim();
  if (name) {
    const [taken] = await pool.query(
      `SELECT id FROM tbl_customer
       WHERE name = :name AND is_delete = '0' AND id != :uid
       LIMIT 1`,
      { name, uid: auth.uid }
    );
    if (taken.length) return fail('השם כבר קיים', 4);
  }

  const businessType = String(p.business_type || '2') === '1' ? '1' : '2';
  const fileList = Array.isArray(files) ? files : [];
  const sigFile = fileList.find(
    (f) => f.fieldname === 'signature_image' || f.fieldname === 'files'
  );
  let signatureName = '';
  try {
    if (sigFile?.buffer?.length) {
      const { uploadImageToR2 } = await import('../r2_upload.js');
      signatureName =
        (await uploadImageToR2(sigFile, 'assets/uploads/signature_images')) || '';
    }
  } catch (err) {
    console.error('signature upload failed', err?.message || err);
  }

  const fields = {
    user_type: '2',
    business_type: businessType,
    name: name || undefined,
    address: p.address,
    city_name: p.city_name,
    about_text: p.about_text || p.about,
    address_lat: p.address_lat || p.lat,
    address_lng: p.address_lng || p.lng,
    address_place_id: p.address_place_id || p.place_id,
    styles: p.styles,
    email: p.email,
    signature_image: signatureName || undefined,
  };
  const sets = ["user_type = '2'", "business_type = :business_type", 'date_updated = NOW()', 'register_date = NOW()'];
  const params = { uid: auth.uid, business_type: businessType };
  for (const [k, v] of Object.entries(fields)) {
    if (k === 'user_type' || k === 'business_type') continue;
    if (v === undefined || v === null || String(v) === '') continue;
    sets.push(`${k} = :${k}`);
    params[k] = v;
  }

  try {
    await pool.query(
      `UPDATE tbl_customer SET ${sets.join(', ')}, is_business = '1' WHERE id = :uid`,
      params
    );
  } catch (err) {
    console.error('UpdateBusinessProfile is_business failed', err?.message || err);
    await pool.query(
      `UPDATE tbl_customer SET ${sets.join(', ')} WHERE id = :uid`,
      params
    );
  }

  const memberIds = String(p.member_ids || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  for (const memberId of memberIds) {
    try {
      const artistId = businessType === '1' ? memberId : auth.uid;
      const studioId = businessType === '1' ? auth.uid : memberId;
      const [ex] = await pool.query(
        `SELECT id FROM tbl_artist_business_map
         WHERE uid = :uid AND bid = :bid LIMIT 1`,
        { uid: artistId, bid: studioId }
      );
      if (ex.length) continue;
      await pool.query(
        `INSERT INTO tbl_artist_business_map
          (uid, bid, req_status, date_added, date_updated)
         VALUES (:uid, :bid, '0', NOW(), NOW())`,
        { uid: artistId, bid: studioId }
      );
    } catch (err) {
      console.error('UpdateBusinessProfile member map failed', err?.message || err);
    }
  }

  const profile = await getUserProfile(auth.uid, true);
  if (profile) profile.styles_he = await styleNamesHe(profile.styles);
  return ok(
    { profile, styles_list: await getStyleList() },
    'פרופיל עיסקי עודכן בהצלחה'
  );
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
  if (!String(p.description || '').trim()) return fail('יש להזין תיאור');
  const imgType = p.image_type || p.img_type || '0';
  const [result] = await pool.query(
    `INSERT INTO tbl_post
      (uid, image_name, image_id, img_type, styles, description, status, date_added, view_count)
     VALUES
      (:uid, :image_name, :image_id, :img_type, :styles, :description, '1', NOW(), 0)`,
    {
      uid: p.creator_id || auth.uid,
      image_name: p.image_name || '',
      image_id: p.image_id || '',
      img_type: imgType,
      styles: normalizePostStyles(p.styles || '', imgType),
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
  if (params.styles !== undefined) {
    params.styles = normalizePostStyles(
      params.styles,
      params.img_type ?? p.image_type ?? p.img_type
    );
  }
  if (params.description !== undefined && !String(params.description).trim()) {
    return fail('יש להזין תיאור');
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
      `SELECT n.*,
              c.id AS cust_id,
              c.name AS cust_name,
              c.profile_image AS cust_profile_image
       FROM tbl_notifications n
       LEFT JOIN tbl_customer c ON c.id = n.uid AND c.is_delete = '0'
       WHERE n.me = :uid
       ORDER BY n.id DESC
       LIMIT ${limit} OFFSET ${start}`,
      { uid: auth.uid }
    );
    const [unread] = await pool.query(
      `SELECT COUNT(*) AS c
       FROM tbl_notifications n
       INNER JOIN tbl_customer c ON c.id = n.uid AND c.is_delete = '0'
       WHERE n.me = :uid AND n.is_read = '2'`,
      { uid: auth.uid }
    );
    return ok({
      notification: rows.map((r) => ({
        ...r,
        id: String(r.id),
        pid: String(r.pid ?? '0'),
        uid: String(r.uid ?? ''),
        me: String(r.me ?? ''),
        is_read: String(r.is_read ?? '1'),
        cust_id: r.cust_id != null ? String(r.cust_id) : '',
        cust_name: r.cust_name || '',
        cust_profile_image: r.cust_profile_image
          ? assetUrl(r.cust_profile_image, 'profile')
          : '',
        noti_date: r.date_added,
      })),
      unread_notification_count: String(unread[0]?.c ?? 0),
      is_new_notification: Number(unread[0]?.c) > 0 ? '1' : '2',
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

function parseRequestImages(raw) {
  if (!raw) return [];
  if (Array.isArray(raw)) return raw;
  if (typeof raw === 'string') {
    try {
      const parsed = JSON.parse(raw);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }
  return [];
}

async function mapTattooRequestRow(r) {
  const business_row = r.business_id
    ? await getUserProfile(r.business_id, false)
    : null;
  const sender_row = r.uid ? await getUserProfile(r.uid, false) : null;
  const artist_row = r.artists_uid
    ? await getUserProfile(r.artists_uid, false)
    : null;
  const str = (v) => (v == null ? '' : String(v));
  return {
    id: str(r.id),
    uid: str(r.uid),
    business_id: str(r.business_id),
    artists_uid: str(r.artists_uid),
    name: r.name || sender_row?.name || '',
    phone: r.phone || sender_row?.phone || '',
    email: r.email || sender_row?.email || '',
    cnt_code: r.cnt_code || sender_row?.cnt_code || '',
    tattoo_size: str(r.tattoo_size),
    styles: r.styles || '',
    description: r.description || '',
    front_side: r.front_side || '',
    back_side: r.back_side || '',
    front_data: r.front_data || '',
    back_data: r.back_data || '',
    front_data_image: resolveRequestMedia(r.front_data_image),
    back_data_image: resolveRequestMedia(r.back_data_image),
    image1_id: str(r.image1_id),
    image2_id: str(r.image2_id),
    image3_id: str(r.image3_id),
    image1_name: resolveRequestMedia(r.image1_name),
    image2_name: resolveRequestMedia(r.image2_name),
    image3_name: resolveRequestMedia(r.image3_name),
    is_read: str(r.is_read || '1'),
    status: str(r.status || '1'),
    is_contact_request: str(r.is_contact_request || '0'),
    date_added: toIsoDate(r.date_added),
    date_updated: toIsoDate(r.date_updated),
    request_images: parseRequestImages(r.request_images).map((img) => {
      if (!img || typeof img !== 'object') return img;
      return {
        ...img,
        imageUrl: resolveRequestMedia(img.imageUrl || img.name),
      };
    }),
    business_row: business_row || {
      id: str(r.business_id),
      name: r.name || '',
    },
    sender_row: sender_row || [],
    artist_row: artist_row || [],
  };
}

export async function handleGetTattooRequest(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const type = String(p.type || '').toLowerCase();
  const isSent = type === 'sent';
  const start = Math.max(Number(p.start || 0), 0);
  const limit = Math.min(Math.max(Number(p.limit || 20), 1), 50);
  const where = isSent
    ? `r.uid = :uid AND IFNULL(r.business_id, '0') != '0' AND r.business_id != ''`
    : `r.business_id = :uid`;

  try {
    const [rows] = await pool.query(
      `SELECT r.* FROM tbl_request r
       WHERE ${where}
       ORDER BY r.id DESC
       LIMIT ${limit} OFFSET ${start}`,
      { uid: auth.uid }
    );
    const list = [];
    for (const r of rows) {
      try {
        const mapped = await mapTattooRequestRow(r);
        if (!mapped) continue;
        if (isSent) mapped.is_read = '1';
        list.push(mapped);
      } catch (err) {
        console.error('mapTattooRequestRow failed', r?.id, err?.message || err);
      }
    }
    let unread = 0;
    try {
      const [[countRow]] = await pool.query(
        `SELECT COUNT(*) AS c FROM tbl_request r
         INNER JOIN tbl_customer cus ON r.uid = cus.id AND cus.is_delete = '0'
         WHERE r.business_id = :uid AND r.is_read = '2'`,
        { uid: auth.uid }
      );
      unread = Number(countRow?.c ?? 0);
    } catch (_) {}
    return ok({
      unread_request_count: String(unread),
      request_list: list,
    });
  } catch (e) {
    console.error('GetTattooRequest failed', e?.message || e);
    return ok({ request_list: [], unread_request_count: '0' });
  }
}

function shortImageName(v) {
  const s = String(v ?? '').trim();
  if (!s) return '';
  try {
    const raw = /^https?:\/\//i.test(s) ? decodeURIComponent(new URL(s).pathname) : s;
    const base = raw.replace(/^.*[\\/]/, '').split('?')[0];
    return String(base || s).slice(0, 255);
  } catch {
    return s.replace(/^.*[\\/]/, '').slice(0, 255);
  }
}

function resolveRequestMedia(v) {
  const s = String(v ?? '').trim();
  if (!s) return '';
  return assetUrl(s, 'body');
}

export async function handleRequestForTattoo(p, files) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const businessId = String(p.business_id || p.bid || '').trim();
  if (!businessId || businessId === '0') {
    return fail('לא ניתן לשלוח את הפנייה. נסו שוב.');
  }

  const clip = (v, n) => String(v ?? '').slice(0, n);
  const fileList = Array.isArray(files) ? files : [];
  const frontFile = fileList.find((f) => f.fieldname === 'front_data_image');
  const backFile = fileList.find((f) => f.fieldname === 'back_data_image');
  const exampleFiles = [1, 2, 3].map((n) =>
    fileList.find(
      (f) =>
        f.fieldname === `example_image_${n}` ||
        f.fieldname === `request_image_${n}` ||
        f.fieldname === `image${n}`
    )
  );
  let frontImageName = clip(shortImageName(p.front_data_image), 255);
  let backImageName = clip(shortImageName(p.back_data_image), 255);
  const uploadedExamples = [];
  try {
    const { uploadImageToR2 } = await import('../r2_upload.js');
    if (frontFile?.buffer?.length) {
      frontImageName = (await uploadImageToR2(frontFile, 'assets/uploads/body_images')) || frontImageName;
    }
    if (backFile?.buffer?.length) {
      backImageName = (await uploadImageToR2(backFile, 'assets/uploads/body_images')) || backImageName;
    }
    for (const file of exampleFiles) {
      if (!file?.buffer?.length) continue;
      const name = await uploadImageToR2(file, 'assets/uploads/body_images');
      if (!name) continue;
      uploadedExamples.push({
        imageId: '',
        name,
        imageUrl: resolveRequestMedia(name),
        uid: String(auth.uid),
      });
    }
  } catch (err) {
    console.error('RequestForTattoo image upload failed', err?.message || err);
  }

  let requestImagesRaw = p.request_images || '';
  if (requestImagesRaw && typeof requestImagesRaw !== 'string') {
    requestImagesRaw = JSON.stringify(requestImagesRaw);
  }
  let parsedImages = parseRequestImages(requestImagesRaw);
  if (uploadedExamples.length) {
    parsedImages = uploadedExamples.map((uploaded, i) => ({
      ...(parsedImages[i] || {}),
      ...uploaded,
      imageId: parsedImages[i]?.imageId || uploaded.imageId,
    }));
  }
  parsedImages = parsedImages.map((img) => {
    if (!img || typeof img !== 'object') return img;
    const name = shortImageName(img.name || img.imageUrl);
    return {
      ...img,
      name,
      imageUrl: resolveRequestMedia(img.imageUrl || name),
      uid: img.uid || String(auth.uid),
    };
  });
  const imageFields = {
    image1_id: clip(p.image1_id || parsedImages[0]?.imageId, 255),
    image2_id: clip(p.image2_id || parsedImages[1]?.imageId, 255),
    image3_id: clip(p.image3_id || parsedImages[2]?.imageId, 255),
    image1_name: clip(
      shortImageName(p.image1_name || parsedImages[0]?.name || parsedImages[0]?.imageUrl),
      255
    ),
    image2_name: clip(
      shortImageName(p.image2_name || parsedImages[1]?.name || parsedImages[1]?.imageUrl),
      255
    ),
    image3_name: clip(
      shortImageName(p.image3_name || parsedImages[2]?.name || parsedImages[2]?.imageUrl),
      255
    ),
  };

  const payload = {
    uid: auth.uid,
    business_id: businessId,
    name: clip(p.name, 255),
    tattoo_size: clip(p.tattoo_size, 255),
    styles: String(p.styles || ''),
    description: String(p.description || ''),
    artists_uid: clip(p.artists_uid, 255),
    email: clip(p.email, 255),
    phone: clip(p.phone, 64),
    ...imageFields,
    request_images: JSON.stringify(parsedImages),
    front_side: String(p.front_side || ''),
    back_side: String(p.back_side || ''),
    front_data: String(p.front_data || ''),
    back_data: String(p.back_data || ''),
    front_data_image: frontImageName,
    back_data_image: backImageName,
    is_contact_request: clip(p.is_contact_request || '0', 8),
    is_read: '2',
  };

  try {
    await pool.query(
      `INSERT INTO tbl_request
        (uid, business_id, name, phone, email, tattoo_size, styles, description, artists_uid,
         image1_id, image2_id, image3_id, image1_name, image2_name, image3_name,
         request_images, front_side, back_side, front_data, back_data,
         front_data_image, back_data_image, is_contact_request, is_read, date_added, date_updated)
       VALUES
        (:uid, :business_id, :name, :phone, :email, :tattoo_size, :styles, :description, :artists_uid,
         :image1_id, :image2_id, :image3_id, :image1_name, :image2_name, :image3_name,
         :request_images, :front_side, :back_side, :front_data, :back_data,
         :front_data_image, :back_data_image, :is_contact_request, :is_read, NOW(), NOW())`,
      payload
    );
  } catch (e) {
    console.error('RequestForTattoo insert failed', e?.message || e);
    return fail('לא ניתן לשלוח את הפנייה');
  }

  try {
    await notifyBusinessTattooRequest(auth.uid, businessId, payload.name);
  } catch (err) {
    console.error('RequestForTattoo notify failed', err?.message || err);
  }
  return ok({ sent: '1' }, 'הפנייה נשלחה');
}

async function notifyBusinessTattooRequest(senderId, businessId, senderName) {
  const [targets] = await pool.query(
    `SELECT id, user_type, push_enable, udid, firebase_id, device_type
     FROM tbl_customer
     WHERE id = :id AND is_delete = '0' LIMIT 1`,
    { id: businessId }
  );
  const target = targets[0];
  if (!target) return;
  const title = `${senderName || 'משתמש'} שלח לך בקשה`;
  const token = String(target.udid || target.firebase_id || '').trim();
  if (String(target.push_enable) !== '1' || !token) return;
  const { sendPush } = await import('../push.js');
  await sendPush({
    token,
    title,
    body: '',
    deviceType: target.device_type,
    data: {
      screen: 'notification',
      is_request: '1',
      pid: '0',
      badge_count: '1',
      description: '',
    },
  });
}

export async function handleReadTattooRequest(p) {
  const auth = await requireAuthLocal(p);
  if (auth.error) return auth.error;
  const requestId = String(p.request_id || p.rid || p.id || '').trim();
  const isRead = String(p.is_read || '1');
  const type = String(p.type || '').toLowerCase();
  if (!requestId || type === 'sent') {
    return ok([], 'Success');
  }
  try {
    await pool.query(
      `UPDATE tbl_request SET is_read = :is_read, date_updated = NOW()
       WHERE id = :id AND business_id = :uid`,
      { id: requestId, uid: auth.uid, is_read: isRead }
    );
  } catch (e) {
    console.error('ReadTattooRequest failed', e?.message || e);
  }
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
  const [active] = await pool.query(
    `SELECT * FROM tbl_customer WHERE email = :email AND is_delete = '0' LIMIT 1`,
    { email }
  );
  let user = active[0];
  const loginToken = newLoginToken();
  const settings = await getSettings();
  if (!user) {
    const [deleted] = await pool.query(
      `SELECT * FROM tbl_customer WHERE email = :email AND is_delete = '1' ORDER BY id DESC LIMIT 1`,
      { email }
    );
    if (deleted[0]) {
      user = deleted[0];
      await pool.query(
        `UPDATE tbl_customer SET
           is_delete = '0',
           status = '1',
           is_register = '1',
           login_type = '3',
           login_token = :tok,
           udid = :udid,
           device_type = :device_type,
           app_version = :app_version,
           name = IF(:name = '', name, :name),
           login_date = NOW(),
           date_updated = NOW()
         WHERE id = :id`,
        {
          tok: loginToken,
          udid: p.udid || 'dev',
          device_type: p.device_type || 'a',
          app_version: p.app_version || '',
          name: p.name || '',
          id: user.id,
        }
      );
    } else {
      const newId = await insertCustomer({
        email,
        name: p.name || '',
        device_type: p.device_type || 'a',
        login_type: '3',
        app_version: p.app_version || '',
        register_date: new Date(),
        date_added: new Date(),
        date_updated: new Date(),
        post_limit: settings.post_limit || '35',
        is_register: '1',
        status: '1',
        user_type: '1',
      });
      user = { id: newId };
    }
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
      startup_image: settings.startup_image || '',
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
