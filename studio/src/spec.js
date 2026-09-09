import { PLAN_CATALOG, loadFinanceRows, summarizeFinance, readCosts } from './finance.js';

export const SYSTEM_SPEC = {
  updatedAt: '2026-09-08',
  title: 'אפיון המודל העסקי',
  subtitle:
    'מה המערכת באמת עושה היום: האפיון באפליקציה, מה שרץ ב-API, ומה ששמור במסד החי.',
  statusLine:
    'כולם יכולים להקים משתמש עסקי בחינם. שדרוג לחבילה בתשלום קיים במסך הרכישה, אבל ב-API החי הרכישות והבדיקות עדיין לא מחוברות. במסד החי כל העסקים קיבלו מנוי מתנה פרימיום שנתי עד 2099 — לא חבילה חינמית אמיתית, וגם לא משלמים.',

  layers: [
    {
      id: 'designed',
      title: 'האפיון המקורי',
      tone: 'good',
      body: 'Flutter + PHP הישן. נרשמים כציבור, ממירים לעסק, מתחילים בחינם, ואחר כך אפשר לשדרג.',
    },
    {
      id: 'running',
      title: 'מה רץ היום באפליקציה',
      tone: 'warn',
      body: 'האפליקציה מדברת עם ה-API החדש ב-Railway. בדיקת מנוי ורכישות הן stub: האפליקציה מקבלת שאין פרימיום ואין מנוי פעיל.',
    },
    {
      id: 'live',
      title: 'מה שמור במסד החי',
      tone: 'warn',
      body: 'כל העסקים המאושרים סומנו ידנית כ-yearly_premium_plan עם purchase_token=admin_comp ותוקף 2099. זה מנוי מתנה, לא תשלום וגם לא basic_free_plan.',
    },
  ],

  users: [
    {
      title: 'משתמש ציבורי',
      fields: 'user_type = 1',
      body: 'גולש, עוקב, שולח בקשות קעקוע. בלי מסך רכישה. נוצר עם post_limit מההגדרות (ברירת מחדל 35).',
    },
    {
      title: 'סטודיו',
      fields: 'user_type = 2 · business_type = 1',
      body: 'עסק עם כרטיס, פוסטים, אמנים מקושרים וחתימה. מוקם בחינם ואחר כך אפשר לשדרג.',
    },
    {
      title: 'אמן עצמאי',
      fields: 'user_type = 2 · business_type = 2',
      body: 'אותו מסלול כמו סטודיו. ב-PHP הישן, פקיעת מנוי בתשלום החזירה את המשתמש ל-business_type=2 ולחבילה החינמית.',
    },
  ],

  plans: [
    {
      id: 'basic_free_plan',
      label: 'חינם',
      price: '0 ₪',
      premium: 'לא',
      notes: 'החבילה שבה מתחילים. ב-PHP היא אף פעם לא פגה (device_type=3). מגבלת פוסטים לפי tbl_settings.',
    },
    {
      id: 'monthly_basic_plan',
      label: 'בסיסי חודשי',
      price: '99.90 ₪ / חודש',
      premium: 'לא',
      notes: 'רכישה בחנות. is_premium=0. אותה מגבלת העלאה כמו החינמית אלא אם האדמין שינה post_limit.',
    },
    {
      id: 'yearly_basic_plan',
      label: 'בסיסי שנתי',
      price: '1,599.90 ₪ / שנה',
      premium: 'לא',
      notes: 'אותה חבילה בסיסית, חיוב שנתי.',
    },
    {
      id: 'monthly_premium_plan',
      label: 'פרימיום חודשי',
      price: '99.90 ₪ / חודש',
      premium: 'כן',
      notes: 'פותח פיצ׳רים של פרימיום באפליקציה (תפריט סטודיו, מסכים שבודקים is_premium).',
    },
    {
      id: 'yearly_premium_plan',
      label: 'פרימיום שנתי',
      price: '2,699.90 ₪ / שנה',
      premium: 'כן',
      notes: 'החבילה שבה סומנו כרגע כל העסקים החיים — כמתנה מנהלתית, לא כרכישה.',
    },
  ],

  designedFlow: [
    {
      step: '1',
      title: 'הרשמה רגילה',
      body: 'טלפון ו-OTP. המשתמש נשמר כציבורי (user_type=1). אין תשלום.',
    },
    {
      step: '2',
      title: 'הקמת עסק בחינם',
      body: 'שם, כתובת, סגנונות וחתימה. האפליקציה בודקת ששם העסק פנוי (CheckSubscription עם name), ואז פותחת את מסך הרכישה.',
    },
    {
      step: '3',
      title: 'התחילו עכשיו בחינם',
      body: 'הכפתור הראשי בחבילה הבסיסית. קורא ל-FreePlanSubscription, כותב basic_free_plan, מעדכן post_limit, ואז ממיר ל-user_type=2 ונכנס לדשבורד העסקי.',
    },
    {
      step: '4',
      title: 'שדרוג מאוחר יותר',
      body: 'מאותו מסך אפשר לקנות בסיסי או פרימיום, חודשי או שנתי, דרך Google Play / App Store.',
    },
    {
      step: '5',
      title: 'פקיעת תשלום',
      body: 'ב-PHP: המנוי נסגר, נפתחת שוב חבילה חינמית, ומגבלת הפוסטים חוזרת להגדרות. החבילה החינמית עצמה לא פגה.',
    },
  ],

  runningToday: [
    {
      title: 'CheckSubscription וכל רכישות החנות',
      body: 'CheckSubscription קורא את tbl_subscription. רכישת iOS/Android וחבילה חינמית נשמרות במסד. שחזור רכישה מפעיל מחדש את המנוי.',
    },
    {
      title: 'FreePlanSubscription',
      body: 'כותב basic_free_plan במסד, מעדכן post_limit, ומחזיר is_sub_active=1.',
    },
    {
      title: 'המרה לעסק',
      body: 'UpdateBusinessProfile מעדכן פרופיל. ההמרה ל-user_type=2 תלויה במה שהאפליקציה שולחת אחרי מסך הרכישה — לא נוצר מנוי במסד.',
    },
    {
      title: 'העלאת פוסט',
      body: 'AddPost ב-Node לא בודק post_limit. באפיון הישן המגבלה נבדקה ב-CheckSubscription לפני העלאה.',
    },
    {
      title: 'פיד הבית',
      body: 'כרטיסי עסקים: כל user_type=2 עם status=1, בלי דרישת מנוי. פוסטים: קודם מבעלי מנוי פעיל, ואם אין — מכולם.',
    },
  ],

  gates: [
    {
      title: 'מה פתוח לכולם',
      items: [
        'גלישה, חיפוש, מעקב, בקשות קעקוע',
        'הקמת כרטיס עסקי אחרי טופס וחתימה',
        'הופעה בפיד כעסק מאושר, גם בלי מנוי משולם',
      ],
    },
    {
      title: 'מה אמור להיפתח בפרימיום',
      items: [
        'מסכים באפליקציה שבודקים is_premium == 1 (תפריט סטודיו, חלקים בדשבורד ובעריכת פרופיל)',
        'הסרת מגבלת העלאה / פנייה לשדרוג כשמגיעים ל-post_limit',
      ],
    },
    {
      title: 'מה קורה בפועל באפליקציה החיה',
      items: [
        'כל משתמש מקבל את מצב המנוי מהמסד — פרימיום נפתח רק למנוי פרימיום פעיל',
        'במסד חלק מהעסקים מסומנים כפרימיום-מתנה; האפליקציה רואה את זה אחרי CheckSubscription',
        'רכישת חנות ושמירת מנוי מחוברות ל-API',
      ],
    },
  ],

  truth: [
    {
      question: 'אפשר להקים עסק בלי לשלם?',
      designed: 'כן. כפתור «התחילו עכשיו בחינם».',
      running: 'כן במסך. ה-API מאשר בלי לשמור מנוי.',
      live: 'העסקים הקיימים לא על חינם — על מתנת פרימיום.',
    },
    {
      question: 'אפשר לשדרג אחר כך?',
      designed: 'כן. מנוי בסיסי או פרימיום, חודשי או שנתי.',
      running: 'המסך קיים. הרכישה לא נשמרת ב-API.',
      live: 'אין רכישות אמיתיות.',
    },
    {
      question: 'כולם בחבילה חינמית?',
      designed: 'כן, עד שמשדרגים.',
      running: 'האפליקציה חושבת שאין מנוי פעיל בכלל.',
      live: 'לא. 56 עסקים על yearly_premium_plan + admin_comp.',
    },
    {
      question: 'פרימיום פתוח?',
      designed: 'רק אחרי רכישת premium.',
      running: 'לא. CheckSubscription תמיד מחזיר 0.',
      live: 'השדה במסד אומר שכן, האפליקציה מתעלמת.',
    },
    {
      question: 'מה קורה כשמנוי בתשלום נגמר?',
      designed: 'חוזרים אוטומטית ל-basic_free_plan.',
      running: 'לא מיושם ב-Node.',
      live: 'לא רלוונטי — התוקף של המתנות הוא 2099.',
    },
  ],

  tables: [
    { name: 'tbl_customer', use: 'סוג משתמש, סוג עסק, post_limit, sub_id, סטטוס אישור' },
    { name: 'tbl_subscription', use: 'product_id, status, is_sub_active, expire_date, purchase_token, device_type' },
    { name: 'tbl_settings', use: 'post_limit לכל מי שנכנס לחבילה החינמית' },
  ],

  codes: {
    user_type: { 1: 'ציבורי', 2: 'עסקי' },
    business_type: { 1: 'סטודיו', 2: 'אמן' },
    device_type: { 1: 'אנדרואיד', 2: 'אייפון', 3: 'חבילה חינמית (לא חנות)' },
    sub_status: { 1: 'פעיל', 2: 'פג / סגור' },
  },
};

export async function buildSpec({ source, costsPath, liveConfigured }) {
  const rows = await loadFinanceRows(source);
  const costs = readCosts(costsPath);
  const finance = summarizeFinance({ ...rows, costs });
  const snapshot = {
    businesses: finance.users.business,
    studios: finance.users.studios,
    artists: finance.users.artists,
    approvedBusiness: finance.users.approvedBusiness,
    paying: finance.subscriptions.payingActive,
    complimentary: finance.subscriptions.complimentary,
    free: finance.subscriptions.free,
    expired: finance.subscriptions.expired,
    noSubscription: finance.subscriptions.noSubscription,
  };
  return {
    source: source.id || source.name || 'live',
    liveConfigured,
    generatedAt: new Date().toISOString(),
    spec: SYSTEM_SPEC,
    snapshot,
    plansCatalog: PLAN_CATALOG,
  };
}
