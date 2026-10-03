import 'dotenv/config';
import fs from 'fs';
import os from 'os';
import path from 'path';
import { pool } from '../db.js';
import { renderDailyReportPdf } from './daily-report-pdf.js';

const SCREEN_LABELS = {
  SplashScreen: 'פתיחה',
  DashBoard: 'ניווט ראשי',
  BusinessDashBoard: 'ניווט עסקי',
  HomeScreen: 'בית',
  InspirationScreen: 'השראה',
  BusinessProfiles: 'פרופילים עסקיים',
  BusinessProfileMenuScreen: 'תפריט פרופיל',
  Profilescreen: 'הפרופיל שלי',
  PostDetails: 'פוסט',
  NotificationScreen: 'התראות',
  ScreenChangeUserType: 'מעבר לעסקי',
  PurchaseScreen: 'רכישת מנוי',
  IOSPurchaseScreen: 'רכישת מנוי iOS',
  BusinessProfileScreen: 'פרופיל עסק',
  StudioProfileScreen: 'פרופיל סטודיו',
  RequestForTattoo: 'בקשת קעקוע',
  request_for_tattoo: 'בקשת קעקוע',
  NewPost: 'פוסט חדש',
  EditPostScreen: 'עריכת פוסט',
  CollectionView: 'אוסף',
  login: 'התחברות',
  LoginScreen: 'התחברות',
  tab_home: 'טאב בית',
  tab_inspiration: 'טאב השראה',
  tab_businesses: 'טאב עסקים',
  tab_profile: 'טאב פרופיל',
  tab_new_post: 'טאב פוסט חדש',
};

const ACTION_LABELS = {
  Login: 'התחברות',
  Register: 'הרשמה',
  LoginWithGmail: 'התחברות Google',
  AddPost: 'פרסום פוסט',
  UpdatePost: 'עריכת פוסט',
  RemovePost: 'מחיקת פוסט',
  LikePost: 'לייק',
  FollowUser: 'מעקב',
  RequestForTattoo: 'בקשת קעקוע',
  UpdateProfile: 'עדכון פרופיל',
  UpdateAddress: 'עדכון כתובת',
  UpdateProfileImage: 'תמונת פרופיל',
  UpdateBusinessProfile: 'פרופיל עסקי',
  UpdateStyles: 'עדכון סגנונות',
  ReportPost: 'דיווח על פוסט',
  ReportUser: 'דיווח על משתמש',
  DeleteAccount: 'מחיקת חשבון',
  AndroidSubscription: 'מנוי Android',
  SuccessPurchaseIphone: 'מנוי iOS',
  FreePlanSubscription: 'תוכנית חינם',
  UserInterestToUpgrade: 'עניין בשדרוג',
  ContactUs: 'יצירת קשר',
  GetBusinessDetail: 'צפייה בעסק',
  GetPostDetail: 'צפייה בפוסט',
};

function israelParts(date) {
  const fmt = new Intl.DateTimeFormat('en-US', {
    timeZone: 'Asia/Jerusalem',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    hourCycle: 'h23',
  });
  const parts = Object.fromEntries(fmt.formatToParts(date).map((p) => [p.type, p.value]));
  return {
    year: Number(parts.year),
    month: Number(parts.month),
    day: Number(parts.day),
    hour: Number(parts.hour),
  };
}

function israelMidnightUtc(year, month, day) {
  let utc = Date.UTC(year, month - 1, day, 0, 0, 0);
  for (let i = 0; i < 4; i += 1) {
    const got = israelParts(new Date(utc));
    const delta =
      Date.UTC(year, month - 1, day, 0, 0, 0) -
      Date.UTC(got.year, got.month - 1, got.day, got.hour, 0, 0);
    if (delta === 0) break;
    utc += delta;
  }
  return new Date(utc);
}

function addDays(year, month, day, delta) {
  const shifted = new Date(Date.UTC(year, month - 1, day + delta));
  return {
    year: shifted.getUTCFullYear(),
    month: shifted.getUTCMonth() + 1,
    day: shifted.getUTCDate(),
  };
}

function dayWindow(offsetFromToday) {
  const today = israelParts(new Date());
  const startParts = addDays(today.year, today.month, today.day, offsetFromToday);
  const endParts = addDays(today.year, today.month, today.day, offsetFromToday + 1);
  return {
    start: israelMidnightUtc(startParts.year, startParts.month, startParts.day),
    end: israelMidnightUtc(endParts.year, endParts.month, endParts.day),
    labelDate: israelMidnightUtc(startParts.year, startParts.month, startParts.day),
  };
}

function sqlUtc(date) {
  return date.toISOString().slice(0, 19).replace('T', ' ');
}

function delta(current, previous) {
  if (current == null || previous == null || (current === 0 && previous === 0)) {
    return { sub: '', tone: 'flat' };
  }
  const diff = current - previous;
  const tone = diff > 0 ? 'up' : diff < 0 ? 'down' : 'flat';
  if (previous === 0) return { sub: 'חדש', tone };
  const pct = Math.round((diff / previous) * 100);
  const sign = diff > 0 ? '+' : '';
  return { sub: `${sign}${pct}%`, tone };
}

function metric(label, current, previous, hint = '', invert = false) {
  const change = delta(current, previous);
  let tone = change.tone;
  if (invert && tone === 'up') tone = 'down';
  else if (invert && tone === 'down') tone = 'up';
  return {
    label,
    value: current == null ? '—' : String(current),
    sub: hint || change.sub,
    tone,
  };
}

function labelScreen(name) {
  return SCREEN_LABELS[name] || name || 'לא ידוע';
}

function labelAction(name) {
  return ACTION_LABELS[name] || name || 'לא ידוע';
}

async function scalar(sql, params) {
  try {
    const [rows] = await pool.query(sql, params);
    return Number(rows[0]?.c ?? 0);
  } catch (err) {
    console.error('metric failed:', err.message);
    return null;
  }
}

async function rows(sql, params) {
  try {
    const [result] = await pool.query(sql, params);
    return result;
  } catch (err) {
    console.error('metric failed:', err.message);
    return [];
  }
}

async function tableExists(name) {
  const [found] = await pool.query('SHOW TABLES LIKE ?', [name]);
  return found.length > 0;
}

async function collect(window) {
  const start = sqlUtc(window.start);
  const end = sqlUtc(window.end);
  const span = [start, end];
  const hasEvents = await tableExists('tbl_app_events');
  const hasErrors = await tableExists('tbl_app_error_logs');

  const registered = await scalar(
    `SELECT COUNT(*) AS c FROM tbl_customer
     WHERE COALESCE(register_date, date_added) >= ? AND COALESCE(register_date, date_added) < ?
       AND COALESCE(register_date, date_added) > '2000-01-01'`,
    span
  );
  const registeredBusiness = await scalar(
    `SELECT COUNT(*) AS c FROM tbl_customer
     WHERE user_type = '2'
       AND COALESCE(register_date, date_added) >= ? AND COALESCE(register_date, date_added) < ?
       AND COALESCE(register_date, date_added) > '2000-01-01'`,
    span
  );
  const newUsers = await rows(
    `SELECT name, user_type, city_name
     FROM tbl_customer
     WHERE COALESCE(register_date, date_added) >= ? AND COALESCE(register_date, date_added) < ?
       AND COALESCE(register_date, date_added) > '2000-01-01'
     ORDER BY COALESCE(register_date, date_added)
     LIMIT 8`,
    span
  );
  const logins = await scalar(
    `SELECT COUNT(*) AS c FROM tbl_customer
     WHERE is_delete = '0' AND login_date >= ? AND login_date < ?
       AND login_date > '2000-01-01'`,
    span
  );
  const posts = await scalar(
    `SELECT COUNT(*) AS c FROM tbl_post
     WHERE date_added >= ? AND date_added < ? AND date_added > '2000-01-01'`,
    span
  );
  const requests = await scalar(
    `SELECT COUNT(*) AS c FROM tbl_request
     WHERE date_added >= ? AND date_added < ? AND date_added > '2000-01-01'`,
    span
  );
  const follows = await scalar(
    `SELECT COUNT(*) AS c FROM tbl_follows
     WHERE date_added >= ? AND date_added < ?`,
    span
  );
  const paidSubs = await scalar(
    `SELECT COUNT(*) AS c FROM tbl_subscription
     WHERE date_added >= ? AND date_added < ?
       AND is_delete = '0'
       AND product_id <> 'basic_free_plan'
       AND (purchase_token IS NULL OR purchase_token <> 'admin_comp')`,
    span
  );
  const freePlans = await scalar(
    `SELECT COUNT(*) AS c FROM tbl_subscription
     WHERE date_added >= ? AND date_added < ?
       AND is_delete = '0'
       AND product_id = 'basic_free_plan'`,
    span
  );
  const reportPosts = await scalar(
    `SELECT COUNT(*) AS c FROM tbl_report_posts
     WHERE date_added >= ? AND date_added < ?`,
    span
  );
  const reportUsers = await scalar(
    `SELECT COUNT(*) AS c FROM tbl_report_users
     WHERE date_added >= ? AND date_added < ?`,
    span
  );

  let activeUsers = null;
  let sessions = null;
  let avgSessionMin = null;
  let deleted = null;
  let screens = [];
  let actions = [];
  let devices = [];
  let versions = [];
  let peak = null;
  let errors = null;

  if (hasEvents) {
    activeUsers = await scalar(
      `SELECT COUNT(DISTINCT uid) AS c FROM tbl_app_events
       WHERE created_at >= ? AND created_at < ? AND uid IS NOT NULL`,
      span
    );
    sessions = await scalar(
      `SELECT COUNT(*) AS c FROM tbl_app_events
       WHERE event_type = 'session' AND event_name = 'session_start'
         AND created_at >= ? AND created_at < ?`,
      span
    );
    const avgRows = await rows(
      `SELECT COALESCE(AVG(duration_ms), 0) AS avg_ms
       FROM tbl_app_events
       WHERE event_type = 'session' AND event_name = 'session_end'
         AND duration_ms IS NOT NULL
         AND created_at >= ? AND created_at < ?`,
      span
    );
    const avgMs = Number(avgRows[0]?.avg_ms || 0);
    avgSessionMin = avgMs ? Math.round((avgMs / 60000) * 10) / 10 : 0;
    deleted = await scalar(
      `SELECT COUNT(*) AS c FROM tbl_app_events
       WHERE event_type = 'action' AND event_name = 'DeleteAccount'
         AND created_at >= ? AND created_at < ?`,
      span
    );
    screens = await rows(
      `SELECT COALESCE(screen_name, event_name) AS name, COUNT(*) AS views
       FROM tbl_app_events
       WHERE event_type = 'screen' AND created_at >= ? AND created_at < ?
       GROUP BY name
       ORDER BY views DESC
       LIMIT 8`,
      span
    );
    actions = await rows(
      `SELECT event_name AS name, COUNT(*) AS c
       FROM tbl_app_events
       WHERE event_type = 'action' AND created_at >= ? AND created_at < ?
       GROUP BY event_name
       ORDER BY c DESC
       LIMIT 8`,
      span
    );
    devices = await rows(
      `SELECT device_type AS name, COUNT(DISTINCT uid) AS c
       FROM tbl_app_events
       WHERE created_at >= ? AND created_at < ?
         AND uid IS NOT NULL
         AND device_type IS NOT NULL AND device_type <> ''
       GROUP BY device_type`,
      span
    );
    versions = await rows(
      `SELECT app_version AS name, COUNT(DISTINCT uid) AS c
       FROM tbl_app_events
       WHERE created_at >= ? AND created_at < ?
         AND uid IS NOT NULL
         AND app_version IS NOT NULL AND app_version <> ''
       GROUP BY app_version
       ORDER BY c DESC
       LIMIT 4`,
      span
    );
    const buckets = await rows(
      `SELECT DATE_FORMAT(created_at, '%Y-%m-%d %H:00:00') AS bucket, COUNT(*) AS c
       FROM tbl_app_events
       WHERE created_at >= ? AND created_at < ?
       GROUP BY bucket`,
      span
    );
    const byHour = new Map();
    for (const row of buckets) {
      const utc = new Date(String(row.bucket).replace(' ', 'T') + 'Z');
      const hour = israelParts(utc).hour;
      byHour.set(hour, (byHour.get(hour) || 0) + Number(row.c || 0));
    }
    let bestHour = null;
    let bestCount = 0;
    for (const [hour, count] of byHour) {
      if (count > bestCount) {
        bestHour = hour;
        bestCount = count;
      }
    }
    if (bestHour != null) peak = { hour: bestHour, count: bestCount };
  }

  if (hasErrors) {
    errors = await scalar(
      `SELECT COUNT(*) AS c FROM tbl_app_error_logs
       WHERE created_at >= ? AND created_at < ?`,
      span
    );
  }

  return {
    registered,
    registeredBusiness,
    newUsers,
    logins,
    posts,
    requests,
    follows,
    paidSubs,
    freePlans,
    reportPosts,
    reportUsers,
    activeUsers,
    sessions,
    avgSessionMin,
    deleted,
    screens,
    actions,
    devices,
    versions,
    peak,
    errors,
    hasEvents,
  };
}

function deviceCount(list, code) {
  const row = list.find((item) => String(item.name) === code);
  return row ? Number(row.c || 0) : 0;
}

function reportWhen(when) {
  const noon = new Date(when.getTime() + 12 * 60 * 60 * 1000);
  const title = new Intl.DateTimeFormat('he-IL', {
    timeZone: 'Asia/Jerusalem',
    weekday: 'long',
    day: 'numeric',
    month: 'long',
  }).format(noon);
  const stamp = new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Asia/Jerusalem',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(noon);
  return { title, stamp };
}

function personLine(user) {
  const name = String(user.name || '').trim() || 'בלי שם';
  const kind = String(user.user_type) === '2' ? 'עסק' : 'לקוח';
  const city = String(user.city_name || '').trim();
  return city ? `${name} · ${kind} · ${city}` : `${name} · ${kind}`;
}

function countOf(list, name, field = 'c') {
  const row = list.find((item) => item.name === name);
  return row ? Number(row[field] || 0) : 0;
}

function recommendations(day, prev) {
  const ideas = [];
  const add = (score, text) => ideas.push({ score, text });
  const num = (value) => Number(value || 0);
  const dropped = (current, previous) => num(previous) > 0 && num(current) < num(previous);

  if (num(day.errors) > 0) {
    add(
      100,
      `נרשמו ${day.errors} שגיאות. כדאי לטפל קודם בשגיאה שחוזרת, לפני שהיא חוסמת הרשמה או פרסום.`
    );
  }
  if (!day.hasEvents) {
    add(
      92,
      'אין אירועי מסכים. בלי זה אי אפשר לדעת איפה אנשים עוצרים, אז שווה לוודא שהאפליקציה שולחת כניסה לכל מסך.'
    );
  } else if (!day.screens.length && num(day.activeUsers) + num(day.logins) > 0) {
    add(
      90,
      'יש פעילות בלי כניסות למסכים. כדאי לבדוק שהמעקב אחרי מסכים נשלח, אחרת לא רואים איפה המשתמש נתקע.'
    );
  }
  if (num(day.sessions) === 0 && num(day.activeUsers) > 0) {
    add(
      84,
      'יש משתמשים פעילים בלי סשנים. מדידת פתיחה וסגירה תראה אם נכנסים ויוצאים מיד.'
    );
  }
  if (dropped(day.registered, prev.registered)) {
    add(
      86,
      `ההרשמות ירדו מ-${prev.registered} ל-${day.registered}. שווה לבדוק את מסך ההתחברות ואת מה שפורסם אתמול.`
    );
  } else if (num(day.registered) === 0) {
    add(
      70,
      'לא נרשם אף אחד. פוסט עם הזמנה להצטרף, או בדיקה שההרשמה לא נשברת, עדיפים על לחכות ליום הבא.'
    );
  }
  if (num(day.registered) > 0 && num(day.posts) === 0) {
    add(
      80,
      'נרשמו אנשים ולא פורסם פוסט. בקשה לצלם עבודה ביום הראשון מעלה את הסיכוי שהחשבון יישאר פעיל.'
    );
  }
  if (num(day.requests) === 0 && num(day.activeUsers) + num(day.logins) > 0) {
    add(
      78,
      'הייתה תנועה באפליקציה ולא נשלחה בקשת קעקוע. כדאי להבליט את כפתור הבקשה בפרופיל העסק.'
    );
  }
  if (num(day.paidSubs) === 0 && num(day.freePlans) > 0) {
    add(
      82,
      `עברו ${day.freePlans} לתוכנית חינם בלי מנוי בתשלום. במסך הרכישה כדאי להראות במשפט אחד מה נשאר בחוץ בחינם.`
    );
  }
  const purchaseViews = day.screens
    .filter((row) => /purchase/i.test(String(row.name)))
    .reduce((sum, row) => sum + Number(row.views || 0), 0);
  if (purchaseViews > 0 && num(day.paidSubs) === 0) {
    add(
      88,
      `נכנסו ${purchaseViews} פעמים למסך רכישה ולא נסגר מנוי. כדאי לקצר את המסך ולבדוק באיזה שלב יוצאים.`
    );
  }
  if (num(day.deleted) > 0) {
    add(
      87,
      `נמחקו ${day.deleted} חשבונות. כדאי לבדוק אם זה קרה אחרי רכישה, דיווח או מסך שנשבר.`
    );
  }
  if (num(day.reportPosts) + num(day.reportUsers) > 0) {
    add(83, 'יש דיווחים חדשים. טיפול באותו יום מונע מתוכן בעייתי להישאר בפיד.');
  }
  if (num(day.sessions) > 0 && num(day.avgSessionMin) > 0 && num(day.avgSessionMin) < 1) {
    add(76, 'זמן הסשן הממוצע קצר מדקה. מסך הבית כנראה לא נותן סיבה להישאר אחרי הפתיחה.');
  }
  if (num(day.registeredBusiness) === 0 && num(day.registered) > 0) {
    add(
      74,
      'הנרשמים הם לקוחות, בלי עסק חדש. אם חסרים אמנים, הזמנה אישית לסטודיו תזיז את זה יותר מפרסום כללי.'
    );
  }
  const ios = deviceCount(day.devices, 'i');
  const android = deviceCount(day.devices, 'a');
  if (ios + android >= 1 && (ios === 0 || android === 0)) {
    const only = ios ? 'iOS' : 'Android';
    add(66, `כל הפעילות המזוהה היא ב-${only}. שווה לפתוח את הצד השני ולבדוק אם מסך שם נשבר.`);
  }
  if (day.peak && (day.peak.hour >= 19 || day.peak.hour <= 8)) {
    const hour = String(day.peak.hour).padStart(2, '0');
    add(64, `שעת השיא הייתה ${hour}:00. פוסט או התראה בשעה הזו יגיעו ליותר אנשים מאשר באמצע היום.`);
  }
  if (day.screens[0] && Number(day.screens[0].views) > 0) {
    const before = countOf(prev.screens, day.screens[0].name, 'views');
    const nowViews = Number(day.screens[0].views);
    if (before > 0 && nowViews < before * 0.6) {
      add(
        79,
        `${labelScreen(day.screens[0].name)} ירד מ-${before} ל-${nowViews} כניסות. שווה לבדוק אם משהו שם נשבר או הוזז.`
      );
    } else {
      add(
        48,
        `${labelScreen(day.screens[0].name)} הוא המסך הכי פעיל, עם ${nowViews} כניסות. שיפור אחד שם ישפיע יותר משינוי במסך שכמעט לא נפתח.`
      );
    }
  }
  if (day.actions[0]) {
    add(
      46,
      `הפעולה הבולטת הייתה ${labelAction(day.actions[0].name)}, ${Number(day.actions[0].c)} פעמים. אם זו לא הפעולה שחשובה לעסק, המסך מוביל למקום הלא נכון.`
    );
  }
  if (dropped(day.follows, prev.follows) && num(prev.follows) >= 2) {
    add(
      60,
      `המעקבים ירדו מ-${prev.follows} ל-${day.follows}. כפתור המעקב ליד תמונת הפרופיל צריך להיות ברור יותר.`
    );
  }
  if (num(day.posts) > 0 && num(day.follows) === 0) {
    add(58, 'פורסמו פוסטים בלי מעקבים חדשים. אחרי צפייה בפוסט כדאי להציע לעקוב אחרי האמן.');
  }
  if (day.versions.length > 1) {
    add(
      52,
      `פעילים על ${day.versions.length} גרסאות. עדכון שמכנס את כולם לגרסה האחרונה יפשט את התיקונים.`
    );
  }
  if (num(day.registered) + num(day.posts) + num(day.requests) + num(day.activeUsers) === 0) {
    add(
      44,
      'היום היה שקט. פוסט אחד והתראה קצרה יבדקו שהשרשרת מהאפליקציה ועד הדוח עדיין עובדת.'
    );
  }

  ideas.sort((a, b) => b.score - a.score);
  const picked = [];
  const seen = new Set();
  for (const idea of ideas) {
    if (seen.has(idea.text)) continue;
    seen.add(idea.text);
    picked.push(idea.text);
    if (picked.length === 5) break;
  }
  return picked;
}

function buildModel(day, prev, when) {
  const { title, stamp } = reportWhen(when);
  const personal =
    day.registered == null || day.registeredBusiness == null
      ? ''
      : `לקוחות ${day.registered - day.registeredBusiness} · עסקים ${day.registeredBusiness}`;
  const sessionHint = day.sessions ? `ממוצע ${day.avgSessionMin} דק׳` : '';
  const reports =
    day.reportPosts == null && day.reportUsers == null
      ? null
      : Number(day.reportPosts || 0) + Number(day.reportUsers || 0);
  const prevReports =
    prev.reportPosts == null && prev.reportUsers == null
      ? null
      : Number(prev.reportPosts || 0) + Number(prev.reportUsers || 0);

  const ios = deviceCount(day.devices, 'i');
  const android = deviceCount(day.devices, 'a');
  const versions = day.versions.map((row) => String(row.name)).join(', ');
  const peak = day.peak ? `שיא ${String(day.peak.hour).padStart(2, '0')}:00` : '';

  return {
    title,
    stamp,
    kpis: [
      metric('נרשמו', day.registered, prev.registered, personal),
      metric('התחברו', day.logins, prev.logins),
      metric('פעילים', day.activeUsers, prev.activeUsers),
      metric('סשנים', day.sessions, prev.sessions, sessionHint),
      metric('פוסטים', day.posts, prev.posts),
      metric('בקשות קעקוע', day.requests, prev.requests),
    ],
    people: day.registered != null && day.registered <= 8 ? day.newUsers.map(personLine) : [],
    screens: day.screens.map((row) => ({
      label: labelScreen(row.name),
      value: Number(row.views || 0),
    })),
    screensEmpty: day.hasEvents ? 'לא נרשמו כניסות למסכים' : 'אין עדיין אירועי מסכים',
    actions: day.actions.map((row) => ({
      label: labelAction(row.name),
      value: Number(row.c || 0),
    })),
    actionsEmpty: day.hasEvents ? 'לא נרשמו פעולות' : 'אין עדיין אירועי פעולות',
    stats: [
      metric('מעקבים', day.follows, prev.follows),
      metric('מנויים בתשלום', day.paidSubs, prev.paidSubs),
      metric('תוכניות חינם', day.freePlans, prev.freePlans),
      metric('שגיאות', day.errors, prev.errors, '', true),
      metric('דיווחים', reports, prevReports, '', true),
      metric('מחיקות חשבון', day.deleted, prev.deleted, '', true),
    ],
    footer: [
      ios || android ? `iOS ${ios} · Android ${android}` : '',
      versions ? `גרסה ${versions}` : '',
      peak,
    ],
    recommendations: recommendations(day, prev),
  };
}

function chatIds() {
  const raw = process.env.TELEGRAM_CHAT_ID || '';
  return [...new Set(raw.split(/[\s,]+/).map((id) => id.trim()).filter(Boolean))];
}

async function sendTelegramPdf(pdf, filename, caption) {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  const ids = chatIds();
  if (!token || !ids.length) {
    throw new Error('Missing TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID');
  }
  const failures = [];
  for (const chatId of ids) {
    const form = new FormData();
    form.append('chat_id', chatId);
    form.append('caption', caption);
    form.append('document', new File([pdf], filename, { type: 'application/pdf' }));
    const response = await fetch(`https://api.telegram.org/bot${token}/sendDocument`, {
      method: 'POST',
      body: form,
    });
    const body = await response.json().catch(() => ({}));
    if (!response.ok || !body.ok) {
      failures.push(`${chatId}: ${body.description || `HTTP ${response.status}`}`);
    } else {
      console.log(`sent to ${chatId}`);
    }
  }
  if (failures.length) {
    throw new Error(failures.join('; '));
  }
}

async function main() {
  const now = israelParts(new Date());
  const force = process.env.FORCE_REPORT === '1';
  if (!force && now.hour !== 6) {
    console.log(`skip: Israel hour is ${now.hour}, report runs at 06:00`);
    return;
  }

  const yesterday = dayWindow(-1);
  const before = dayWindow(-2);
  const [day, prev] = await Promise.all([collect(yesterday), collect(before)]);
  const model = buildModel(day, prev, yesterday.start);
  const pdf = await renderDailyReportPdf(model);
  if (process.env.DRY_RUN === '1') {
    const out = process.env.PDF_OUT || path.join(os.tmpdir(), `ink-daily-${model.stamp}.pdf`);
    fs.writeFileSync(out, pdf);
    console.log(out);
    return;
  }
  await sendTelegramPdf(pdf, `ink-daily-${model.stamp}.pdf`, `דוח יומי — ${model.title}`);
  console.log('daily report sent');
}

main()
  .catch((err) => {
    console.error(err.message || err);
    process.exitCode = 1;
  })
  .finally(async () => {
    await pool.end();
  });
