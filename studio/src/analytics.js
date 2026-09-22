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
  LikePost: 'לייק לפוסט',
  FollowUser: 'מעקב אחרי משתמש',
  RequestForTattoo: 'שליחת בקשת קעקוע',
  UpdateProfile: 'עדכון פרופיל',
  UpdateAddress: 'עדכון כתובת',
  UpdateProfileImage: 'עדכון תמונת פרופיל',
  UpdateBusinessProfile: 'עדכון פרופיל עסקי',
  UpdateStyles: 'עדכון סגנונות',
  ReportPost: 'דיווח על פוסט',
  ReportUser: 'דיווח על משתמש',
  DeleteAccount: 'מחיקת חשבון',
  AndroidSubscription: 'רכישת מנוי Android',
  SuccessPurchaseIphone: 'רכישת מנוי iOS',
  FreePlanSubscription: 'מעבר לתוכנית חינם',
  UserInterestToUpgrade: 'עניין בשדרוג',
  ContactUs: 'יצירת קשר',
  GetBusinessDetail: 'צפייה בפרופיל עסק',
  GetPostDetail: 'צפייה בפוסט',
  session_start: 'תחילת סשן',
  session_end: 'סיום סשן',
  screen_view: 'כניסה למסך',
};

function israelHourExpr(column) {
  return `HOUR(DATE_ADD(${column}, INTERVAL 3 HOUR))`;
}

function israelDateExpr(column) {
  return `DATE(DATE_ADD(${column}, INTERVAL 3 HOUR))`;
}

function hoursTemplate() {
  return Array.from({ length: 24 }, (_, hour) => ({
    hour,
    events: 0,
    logins: 0,
    posts: 0,
    requests: 0,
  }));
}

function fillHours(rows, key) {
  const map = hoursTemplate();
  for (const row of rows) {
    const hour = Number(row.hour);
    if (hour >= 0 && hour <= 23) map[hour][key] = Number(row.c || 0);
  }
  return map;
}

function mergeHours(...lists) {
  const map = hoursTemplate();
  for (const list of lists) {
    for (const row of list) {
      const target = map[row.hour];
      target.events += row.events || 0;
      target.logins += row.logins || 0;
      target.posts += row.posts || 0;
      target.requests += row.requests || 0;
    }
  }
  return map;
}

function labelScreen(name) {
  return SCREEN_LABELS[name] || name || 'לא ידוע';
}

function labelAction(name) {
  return ACTION_LABELS[name] || name || 'לא ידוע';
}

async function tableExists(pool, name) {
  const [rows] = await pool.query('SHOW TABLES LIKE ?', [name]);
  return rows.length > 0;
}

export async function loadAnalytics(pool, days = 30) {
  const rangeDays = [7, 30, 90].includes(Number(days)) ? Number(days) : 30;
  const hasEvents = await tableExists(pool, 'tbl_app_events');
  const queries = [
    pool.query(
      `SELECT COUNT(*) AS c FROM tbl_customer
       WHERE is_delete = '0' AND login_date >= DATE_SUB(NOW(), INTERVAL :days DAY)
         AND login_date > '2000-01-01'`,
      { days: rangeDays }
    ),
    pool.query(
      `SELECT ${israelHourExpr('login_date')} AS hour, COUNT(*) AS c
       FROM tbl_customer
       WHERE login_date >= DATE_SUB(NOW(), INTERVAL :days DAY)
         AND login_date > '2000-01-01'
       GROUP BY hour`,
      { days: rangeDays }
    ),
    pool.query(
      `SELECT ${israelDateExpr('COALESCE(register_date, date_added)')} AS day, COUNT(*) AS c
       FROM tbl_customer
       WHERE COALESCE(register_date, date_added) >= DATE_SUB(NOW(), INTERVAL :days DAY)
         AND COALESCE(register_date, date_added) > '2000-01-01'
       GROUP BY day
       ORDER BY day`,
      { days: rangeDays }
    ),
    pool.query(
      `SELECT ${israelHourExpr('date_added')} AS hour, COUNT(*) AS c
       FROM tbl_post
       WHERE date_added >= DATE_SUB(NOW(), INTERVAL :days DAY)
         AND date_added > '2000-01-01'
       GROUP BY hour`,
      { days: rangeDays }
    ),
    pool.query(
      `SELECT ${israelDateExpr('date_added')} AS day, COUNT(*) AS c
       FROM tbl_post
       WHERE date_added >= DATE_SUB(NOW(), INTERVAL :days DAY)
         AND date_added > '2000-01-01'
       GROUP BY day
       ORDER BY day`,
      { days: rangeDays }
    ),
    pool.query(
      `SELECT ${israelHourExpr('date_added')} AS hour, COUNT(*) AS c
       FROM tbl_request
       WHERE date_added >= DATE_SUB(NOW(), INTERVAL :days DAY)
         AND date_added > '2000-01-01'
       GROUP BY hour`,
      { days: rangeDays }
    ),
    pool.query(
      `SELECT COUNT(*) AS c FROM tbl_request
       WHERE date_added >= DATE_SUB(NOW(), INTERVAL :days DAY)`,
      { days: rangeDays }
    ),
    pool.query(
      `SELECT COUNT(*) AS c FROM tbl_post
       WHERE date_added >= DATE_SUB(NOW(), INTERVAL :days DAY)`,
      { days: rangeDays }
    ),
    pool.query(
      `SELECT COUNT(*) AS c FROM tbl_follows
       WHERE date_added >= DATE_SUB(NOW(), INTERVAL :days DAY)`,
      { days: rangeDays }
    ).catch(() => [[{ c: 0 }]]),
    pool.query(
      `SELECT COUNT(*) AS c FROM tbl_customer
       WHERE COALESCE(register_date, date_added) >= DATE_SUB(NOW(), INTERVAL :days DAY)
         AND COALESCE(register_date, date_added) > '2000-01-01'`,
      { days: rangeDays }
    ),
  ];

  if (hasEvents) {
    queries.push(
      pool.query(
        `SELECT COUNT(*) AS c FROM tbl_app_events
         WHERE created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)`,
        { days: rangeDays }
      ),
      pool.query(
        `SELECT COUNT(DISTINCT uid) AS c FROM tbl_app_events
         WHERE created_at >= DATE_SUB(NOW(), INTERVAL :days DAY) AND uid IS NOT NULL`,
        { days: rangeDays }
      ),
      pool.query(
        `SELECT COUNT(*) AS c FROM tbl_app_events
         WHERE event_type = 'session' AND event_name = 'session_start'
           AND created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)`,
        { days: rangeDays }
      ),
      pool.query(
        `SELECT COALESCE(AVG(duration_ms), 0) AS avg_ms,
                COALESCE(SUM(duration_ms), 0) AS sum_ms
         FROM tbl_app_events
         WHERE event_type = 'session' AND event_name = 'session_end'
           AND duration_ms IS NOT NULL
           AND created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)`,
        { days: rangeDays }
      ),
      pool.query(
        `SELECT ${israelHourExpr('created_at')} AS hour, COUNT(*) AS c
         FROM tbl_app_events
         WHERE created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
         GROUP BY hour`,
        { days: rangeDays }
      ),
      pool.query(
        `SELECT COALESCE(screen_name, event_name) AS name, COUNT(*) AS views,
                ROUND(AVG(duration_ms) / 1000) AS avg_sec
         FROM tbl_app_events
         WHERE event_type = 'screen'
           AND created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
         GROUP BY name
         ORDER BY views DESC
         LIMIT 20`,
        { days: rangeDays }
      ),
      pool.query(
        `SELECT event_name AS name, COUNT(*) AS c
         FROM tbl_app_events
         WHERE event_type = 'action'
           AND created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
         GROUP BY event_name
         ORDER BY c DESC
         LIMIT 20`,
        { days: rangeDays }
      ),
      pool.query(
        `SELECT ${israelDateExpr('created_at')} AS day,
                COUNT(*) AS events,
                COUNT(DISTINCT uid) AS users,
                SUM(event_type = 'session' AND event_name = 'session_start') AS sessions,
                ROUND(SUM(CASE WHEN event_type = 'session' AND event_name = 'session_end'
                  THEN duration_ms ELSE 0 END) / 60000) AS duration_min
         FROM tbl_app_events
         WHERE created_at >= DATE_SUB(NOW(), INTERVAL :days DAY)
         GROUP BY day
         ORDER BY day`,
        { days: rangeDays }
      )
    );
  }

  const results = await Promise.all(queries);
  const rowsOf = (index) => results[index]?.[0] || [];
  const countOf = (index) => Number(rowsOf(index)[0]?.c || 0);

  const loginHours = rowsOf(1);
  const registerDays = rowsOf(2);
  const postHours = rowsOf(3);
  const postDays = rowsOf(4);
  const requestHours = rowsOf(5);
  const existingActions = [
    { name: 'Login', c: countOf(0) },
    { name: 'Register', c: countOf(9) },
    { name: 'AddPost', c: countOf(7) },
    { name: 'RequestForTattoo', c: countOf(6) },
    { name: 'FollowUser', c: countOf(8) },
  ].filter((row) => row.c > 0);

  const eventOffset = 10;
  const eventBlock = hasEvents
    ? {
        totalEvents: countOf(eventOffset),
        eventUsers: countOf(eventOffset + 1),
        sessions: countOf(eventOffset + 2),
        avgSessionMs: Number(rowsOf(eventOffset + 3)[0]?.avg_ms || 0),
        eventHours: rowsOf(eventOffset + 4),
        screens: rowsOf(eventOffset + 5),
        actions: rowsOf(eventOffset + 6),
        dailyEvents: rowsOf(eventOffset + 7),
      }
    : {
        totalEvents: 0,
        eventUsers: 0,
        sessions: 0,
        avgSessionMs: 0,
        eventHours: [],
        screens: [],
        actions: [],
        dailyEvents: [],
      };

  const hours = mergeHours(
    fillHours(eventBlock.eventHours, 'events'),
    fillHours(loginHours, 'logins'),
    fillHours(postHours, 'posts'),
    fillHours(requestHours, 'requests')
  );

  const avgSessionMin = eventBlock.avgSessionMs
    ? Math.round((eventBlock.avgSessionMs / 60000) * 10) / 10
    : 0;

  const actionRows = eventBlock.actions.length ? eventBlock.actions : existingActions;

  return {
    days: rangeDays,
    has_events: hasEvents,
    kpis: {
      recent_logins: countOf(0),
      event_users: eventBlock.eventUsers,
      sessions: eventBlock.sessions,
      avg_session_min: avgSessionMin,
      total_events: eventBlock.totalEvents,
      posts: countOf(7),
      requests: countOf(6),
    },
    hours,
    screens: eventBlock.screens.map((row) => ({
      name: row.name,
      label: labelScreen(row.name),
      views: Number(row.views || 0),
      avg_sec: Number(row.avg_sec || 0),
    })),
    actions: actionRows.map((row) => ({
      name: row.name,
      label: labelAction(row.name),
      count: Number(row.c || 0),
    })),
    daily_events: eventBlock.dailyEvents.map((row) => ({
      day: String(row.day).slice(0, 10),
      events: Number(row.events || 0),
      users: Number(row.users || 0),
      sessions: Number(row.sessions || 0),
      duration_min: Number(row.duration_min || 0),
    })),
    registrations: registerDays.map((row) => ({
      day: String(row.day).slice(0, 10),
      count: Number(row.c || 0),
    })),
    posts: postDays.map((row) => ({
      day: String(row.day).slice(0, 10),
      count: Number(row.c || 0),
    })),
  };
}
