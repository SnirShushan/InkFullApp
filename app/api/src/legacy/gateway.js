import {
  ok,
  fail,
  getSettings,
  getStyleList,
  getStyleMap,
  getUserByPhone,
  getUserProfile,
  validateToken,
  styleNamesHe,
  newLoginToken,
  queryPosts,
  mapPostsForClient,
  getBusinessCards,
  getNewUserList,
} from './helpers.js';
import { assetUrl } from '../assets.js';
import { pool } from '../db.js';
import * as extra from './actions_extra.js';
import * as subs from './subscriptions.js';
import { handleSendSms } from './sms.js';

function params(req) {
  return { ...(req.query || {}), ...(req.body || {}) };
}

function firstUpload(req) {
  const files = req.files;
  if (!Array.isArray(files) || !files.length) return null;
  return (
    files.find((f) => f.fieldname === 'profile_image') ||
    files.find((f) => f.fieldname === 'files') ||
    files[0]
  );
}

async function requireAuth(p) {
  const uid = p.uid;
  const token = p.login_token;
  const row = await validateToken(token, uid);
  if (!row) return { error: fail('יש להתחבר מחדש', 2) };
  return { uid, token, row };
}

async function handleLogin(p) {
  const loginType = String(p.login_type || '1');
  const settings = await getSettings();
  const postLimit = settings.post_limit || '35';
  const startupImage = settings.startup_image
    ? assetUrl(settings.startup_image)
    : '';

  if (loginType !== '1') {
    return fail('Only phone login is migrated on this gateway');
  }

  const phone = String(p.phone || '').trim();
  if (!phone) return fail('Missing phone');

  let user = await getUserByPhone(phone);
  const loginToken = newLoginToken();
  const now = new Date();

  if (user) {
    const isRegister = !user.email || user.email === '' ? '1' : '0';
    await pool.query(
      `UPDATE tbl_customer SET
         device_type = :device_type,
         udid = :udid,
         login_token = :login_token,
         app_version = :app_version,
         login_date = :login_date,
         is_register = :is_register
       WHERE id = :id`,
      {
        device_type: p.device_type || 'a',
        udid: p.udid || 'dev',
        login_token: loginToken,
        app_version: p.app_version || '',
        login_date: now,
        is_register: isRegister,
        id: user.id,
      }
    );
  } else {
    const [result] = await pool.query(
      `INSERT INTO tbl_customer
        (phone, cnt_code, device_type, login_type, app_version, register_date,
         date_added, date_updated, post_limit, is_register, status, user_type)
       VALUES
        (:phone, :cnt_code, :device_type, '1', :app_version, :now,
         :now, :now, :post_limit, '1', '1', '1')`,
      {
        phone,
        cnt_code: p.cnt_code || '972',
        device_type: p.device_type || 'a',
        app_version: p.app_version || '',
        now,
        post_limit: postLimit,
      }
    );
    const newId = result.insertId;
    await pool.query(
      `UPDATE tbl_customer SET udid = :udid, login_token = :login_token, login_date = :login_date
       WHERE id = :id`,
      {
        udid: p.udid || 'dev',
        login_token: loginToken,
        login_date: now,
        id: newId,
      }
    );
    user = { id: newId };
  }

  const profile = await getUserProfile(user.id, true);
  if (!profile) return fail('Login failed');
  profile.styles_he = await styleNamesHe(profile.styles);
  // Ensure client gets the fresh token
  profile.login_token = loginToken;

  const stylesList = await getStyleList();
  return ok(
    {
      profile,
      styles_list: stylesList,
      startup_image: startupImage,
      followers: '0',
    },
    'התחברת בהצלחה'
  );
}

async function handleCheckPhone(p) {
  const user = await getUserByPhone(p.phone);
  return ok({
    is_exists: user ? 1 : 0,
    email: user?.email || '',
  });
}

async function handleGetHomeData(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;

  const profile = await getUserProfile(auth.uid, true);
  const styles = profile?.styles || '';
  const start = p.start ?? 0;
  const limit = p.limit ?? 6;

  const tattooRows = await queryPosts({
    styles,
    start: 0,
    limit: 6,
    isRandom: true,
  });
  const tattos_in_style = await mapPostsForClient(tattooRows);

  const new_user_list = await getNewUserList({ start, limit });
  const business = await getBusinessCards({
    styles,
    start: 0,
    limit: 6,
  });

  let is_new_notification = '2';
  try {
    const [noti] = await pool.query(
      `SELECT n.id FROM tbl_notifications n
       INNER JOIN tbl_customer c ON n.uid = c.id AND c.is_delete = '0'
       WHERE n.me = :uid AND n.is_read = '2'
       ORDER BY n.id DESC LIMIT 1`,
      { uid: auth.uid }
    );
    if (noti.length) is_new_notification = '1';
  } catch (_) {
    /* table may differ */
  }

  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total FROM tbl_post WHERE status = '1'`
  );

  return ok({
    tattos_in_style,
    new_user_list,
    business,
    is_new_notification,
    total_post_count: String(countRows[0]?.total ?? 0),
  });
}

async function handleGetHomePostsNew(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;

  const profile = await getUserProfile(auth.uid, true);
  const { styles, hw } = await getStyleMap();
  let styleArr = String(profile?.styles || '')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

  if (!styleArr.length) {
    styleArr = styles.map((s) => s.slug);
  }
  styleArr = [...new Set(styleArr)];
  if (styleArr.length < 3) {
    const remaining = styles
      .map((s) => s.slug)
      .filter((s) => !styleArr.includes(s));
    for (let i = remaining.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [remaining[i], remaining[j]] = [remaining[j], remaining[i]];
    }
    styleArr = styleArr.concat(remaining.slice(0, 3 - styleArr.length));
  }

  for (let i = styleArr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [styleArr[i], styleArr[j]] = [styleArr[j], styleArr[i]];
  }

  const selected_styles = [];
  const posts = {};
  const used = new Set();

  const tryStyle = async (styleName) => {
    if (selected_styles.length >= 3 || used.has(styleName)) return;
    const rows = await queryPosts({
      styles: styleName,
      start: 0,
      limit: Number(p.limit || 6),
      isRandom: String(p.is_random) === '1',
    });
    if (!rows.length) return;
    posts[styleName] = await mapPostsForClient(rows, hw[styleName] || '');
    selected_styles.push(styleName);
    used.add(styleName);
  };

  for (const s of styleArr) {
    await tryStyle(s);
  }
  if (selected_styles.length < 3) {
    for (const s of styles.map((x) => x.slug)) {
      await tryStyle(s);
    }
  }

  const [countRows] = await pool.query(
    `SELECT COUNT(*) AS total FROM tbl_post WHERE status = '1'`
  );

  return ok({
    selected_styles,
    posts,
    total_post_count: String(countRows[0]?.total ?? 0),
  });
}

async function handleGetPostsNew(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;

  const { hw } = await getStyleMap();
  const style = String(p.styles || '').trim();
  // Profile "my posts" (PHP get_posts_new with my=1): own posts split into tatto/sketch
  const isMy = String(p.my || '').trim() !== '';
  const rows = await queryPosts({
    styles: style,
    start: p.start || 0,
    limit: p.limit || 20,
    isRandom: !isMy && String(p.is_random) === '1',
    uidOnly: isMy ? auth.uid : null,
  });
  const styleName = style.includes(',')
    ? ''
    : hw[style] || style;
  const list = await mapPostsForClient(rows, styleName);
  if (isMy) {
    return ok({
      tatto: list.filter((x) => String(x.img_type) !== '1'),
      sketch: list.filter((x) => String(x.img_type) === '1'),
    });
  }
  return ok({ posts: list, total_post_count: String(list.length) });
}

async function handleStartupImage(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;
  const settings = await getSettings();
  const startup = settings.startup_image
    ? assetUrl(settings.startup_image)
    : '';
  return ok({ startup_image: startup });
}

async function handleGetUser(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;
  const profile = await getUserProfile(auth.uid, true);
  if (!profile) return fail('User not found');
  profile.styles_he = await styleNamesHe(profile.styles);
  const stylesList = await getStyleList();
  return ok({
    profile,
    styles_list: stylesList,
    artist: [],
    studio: [],
    followers: '0',
    followers_list: [],
  });
}

async function handleGetBusiness(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;
  const profile = await getUserProfile(auth.uid, true);
  const business = await getBusinessCards({
    styles: p.styles || profile?.styles || '',
    start: p.start || 0,
    limit: p.limit || 6,
  });
  return ok({
    business,
    is_filter: p.styles ? '1' : '2',
    popup_text: '',
  });
}

async function handleGetPostCount(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;
  const [rows] = await pool.query(
    `SELECT COUNT(*) AS total FROM tbl_post WHERE status = '1'`
  );
  return ok({ total_post_count: String(rows[0]?.total ?? 0) });
}

async function handleGetFollowersList(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;
  const start = Math.max(Number(p.start || 0), 0);
  const limit = Math.min(Math.max(Number(p.limit || 20), 1), 50);
  const following = String(p.is_following || '0') === '1';

  // is_following=1 → people I follow; otherwise people who follow me
  const sql = following
    ? `SELECT c.id, c.name, c.profile_image, c.user_type, c.business_type, c.styles
       FROM tbl_follows f
       INNER JOIN tbl_customer c ON c.id = f.follow_uid AND c.is_delete = '0'
       WHERE f.uid = :uid
       ORDER BY f.id DESC
       LIMIT ${limit} OFFSET ${start}`
    : `SELECT c.id, c.name, c.profile_image, c.user_type, c.business_type, c.styles
       FROM tbl_follows f
       INNER JOIN tbl_customer c ON c.id = f.uid AND c.is_delete = '0'
       WHERE f.follow_uid = :uid
       ORDER BY f.id DESC
       LIMIT ${limit} OFFSET ${start}`;

  let list = [];
  try {
    const [rows] = await pool.query(sql, { uid: auth.uid });
    list = rows.map((r) => ({
      ...r,
      id: String(r.id),
      profile_image: r.profile_image
        ? assetUrl(r.profile_image, 'profile')
        : '',
    }));
  } catch (_) {
    list = [];
  }

  return ok({
    followers: String(list.length),
    followers_list: list,
  });
}

async function handleGetStyles() {
  const data = await getStyleList();
  return ok(data);
}

/**
 * PHP-compatible action gateway used by the Flutter client.
 */
export async function handleLegacyAction(req) {
  const p = params(req);
  const action = String(p.action || '');
  const token = String(p.app_token || '');
  if (process.env.APP_TOKEN && token && token !== process.env.APP_TOKEN) {
    return fail('Invalid app token');
  }

  try {
    switch (action) {
      case '':
      case 'CheckServerStatus':
        return ok([], 'Success');
      case 'GetStyleList':
      case 'GetStyles':
        return handleGetStyles();
      case 'Login':
        return handleLogin(p);
      case 'CheckPhoneExists':
        return handleCheckPhone(p);
      case 'SendSms':
        return handleSendSms(p);
      case 'LoginFailDBLog':
        return ok([], 'Logged');
      case 'GetHomeData':
        return handleGetHomeData(p);
      case 'GetHomePostsNew':
        return handleGetHomePostsNew(p);
      case 'GetPostsNew':
        return handleGetPostsNew(p);
      case 'StartupImage':
        return handleStartupImage(p);
      case 'GetUser':
        return handleGetUser(p);
      case 'GetBusiness':
      case 'GetBusinessNew':
        return handleGetBusiness(p);
      case 'GetPostCount':
        return handleGetPostCount(p);
      case 'getFollowersList':
        return handleGetFollowersList(p);
      case 'GetPosts':
        return handleGetPostsNew(p);
      case 'GetHomeDataSection1':
      case 'GetHomeNewData':
        return handleGetHomeData(p);
      case 'GetPostDetail':
        return extra.handleGetPostDetail(p);
      case 'GetBusinessDetail':
        return extra.handleGetBusinessDetail(p);
      case 'GetBusinessList':
        return extra.handleGetBusinessList(p);
      case 'GetTattooList':
        return extra.handleGetTattooList(p);
      case 'GetSketchList':
        return extra.handleGetSketchList(p);
      case 'FollowUser':
        return extra.handleFollowUser(p);
      case 'UpdateStyles':
        return extra.handleUpdateStyles(p);
      case 'UpdateProfile':
      case 'UpdateAddress':
        return extra.handleUpdateProfile(p);
      case 'UpdateProfileImage':
        return extra.handleUpdateProfileImage(p, firstUpload(req));
      case 'UpdateBusinessProfile':
        return extra.handleUpdateBusinessProfile(p);
      case 'CheckNameExists':
        return extra.handleCheckNameExists(p);
      case 'RemovePost':
        return extra.handleRemovePost(p);
      case 'AddPost':
        return extra.handleAddPost(p);
      case 'UpdatePost':
        return extra.handleUpdatePost(p);
      case 'GetMyArtist':
        return extra.handleGetMyArtist(p);
      case 'GetMyStudio':
        return extra.handleGetMyStudio(p);
      case 'RemoveArtistFromList':
        return extra.handleRemoveArtist(p);
      case 'RemoveStudioFromList':
        return extra.handleRemoveStudio(p);
      case 'GetNotifications':
      case 'GetNotificationsNew':
        return extra.handleGetNotifications(p);
      case 'ReadNotifications':
        return extra.handleReadNotifications(p);
      case 'GetTattooRequest':
        return extra.handleGetTattooRequest(p);
      case 'RequestForTattoo':
        return extra.handleRequestForTattoo(p);
      case 'ReadTattooRequest':
        return extra.handleReadTattooRequest(p);
      case 'ContactUs':
        return extra.handleContactUs(p);
      case 'ReportPost':
      case 'ReportUser':
        return extra.handleReport(p);
      case 'DeleteAccount':
        return extra.handleDeleteAccount(p);
      case 'LoginWithGmail':
        return extra.handleLoginWithGmail(p);
      case 'FreePlanSubscription':
        return subs.handleFreePlan(p);
      case 'UserInterestToUpgrade':
        return extra.handleUserInterest(p);
      case 'GetPages':
        return ok({ content: '' }, 'Success');
      case 'CheckSubscription':
        return subs.handleCheckSubscription(p);
      case 'AndroidSubscription':
        return subs.handleAndroidSubscription(p);
      case 'GetSubscriptionPackageName':
        return subs.handleGetSubscriptionPackageName(p);
      case 'SubscriptionIpnCall':
        return subs.handleSubscriptionIpn(p);
      case 'IosSubscriptionIpnCall':
        return subs.handleIosSubscriptionIpn(p);
      case 'SuccessPurchaseIphone':
        return subs.handleSuccessPurchaseIphone(p);
      case 'LikePost':
        return ok({ liked: '1' });
      case 'ResArtistReq':
      case 'ResStudioReq':
        return ok([], 'Success');
      case 'Register':
        return handleLogin(p);
      case 'RemoveProfileImage':
        p.profile_image = '';
        return extra.handleUpdateProfileImage(p);
      default:
        // Explicit soft stub — action acknowledged, empty success payload
        console.warn(`[legacy] stubbed action: ${action || '(none)'}`);
        return ok([], `Action stubbed: ${action || '(none)'}`);
    }
  } catch (e) {
    console.error('legacy action error', action, e);
    return fail(e.message || 'Server error');
  }
}
