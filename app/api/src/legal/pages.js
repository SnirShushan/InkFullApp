const CONTACT_EMAIL = 'inkraelco@gmail.com';
const CONTACT_PHONE = '050-8821562';
const COMPANY = 'אינק ישראל ח.פ. 434564515';

export function legalBase() {
  const explicit = String(process.env.LEGAL_PUBLIC_BASE || '').trim().replace(/\/$/, '');
  if (explicit) return explicit;
  const railway = String(process.env.RAILWAY_PUBLIC_DOMAIN || '').trim();
  if (railway) return `https://${railway.replace(/^https?:\/\//, '')}`;
  return 'https://ink-api-production-2e1d.up.railway.app';
}

function shell({ title, body }) {
  return `<!doctype html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>${title}</title>
  <style>
    :root { color-scheme: light; }
    body { font-family: "Segoe UI", Arial, sans-serif; margin: 0; background: #f6f4f2; color: #1b1714; line-height: 1.7; }
    header { background: #16121a; color: #fff; padding: 1.4rem 1.2rem; }
    header a { color: #e8c39a; }
    main { max-width: 46rem; margin: 0 auto; padding: 1.6rem 1.2rem 3rem; background: #fff; }
    h1 { font-size: 1.6rem; margin: 0 0 .4rem; }
    h2 { font-size: 1.15rem; margin-top: 1.6rem; }
    nav { display: flex; gap: 1rem; flex-wrap: wrap; margin: .6rem 0 0; }
    .muted { color: #5c564f; font-size: .95rem; }
    ul { padding-right: 1.2rem; }
  </style>
</head>
<body>
  <header>
    <strong>אינק ישראל</strong>
    <nav>
      <a href="/terms">תנאי שימוש</a>
      <a href="/privacy">מדיניות פרטיות</a>
    </nav>
  </header>
  <main>${body}</main>
</body>
</html>`;
}

export function termsHtml() {
  return shell({
    title: 'תנאי שימוש | אינק ישראל',
    body: `
      <h1>תנאי שימוש</h1>
      <p class="muted">עודכן לאחרונה: 9 בספטמבר 2026. הבעלים: ${COMPANY}.</p>
      <h2>1. כללי</h2>
      <p>ברוכים הבאים לאפליקציה אינק ישראל. השימוש באפליקציה כפוף לתנאים אלה. אם אינך מסכים להם, יש להימנע משימוש באפליקציה.</p>
      <p>האפליקציה מיועדת לגיל 13 ומעלה. משתמש מתחת לגיל 13 אינו רשאי להשתמש בשירות ללא הסכמת הורה.</p>
      <h2>2. השירות</h2>
      <p>אינק היא פלטפורמה לחיבור בין מחפשי קעקוע לבין סטודיואים ומקעקעים. ניתן לגלוש, לשמור השראה, לשלוח פניות, ולפתוח פרופיל עסקי.</p>
      <h2>3. חשבון</h2>
      <p>ההרשמה מתבצעת באמצעות מספר טלפון וקוד אימות, או באמצעות Sign in with Apple / Google לפי הזמינות במכשיר. אתה אחראי לדיוק הפרטים ולשמירה על החשבון. ניתן למחוק את החשבון מתוך האפליקציה.</p>
      <h2>4. מנויים ותשלומים</h2>
      <p>פתיחת פרופיל עסקי בסיסי אפשרית ללא תשלום. שדרוג לחבילת פרימיום מתבצע כרכישה בתוך האפליקציה דרך App Store או Google Play בלבד. אין תשלום בכרטיס אשראי בתוך האפליקציה.</p>
      <p>מנויים בתשלום הם מנויים מתחדשים אוטומטית (חודשי או שנתי) במחיר המוצג במסך הרכישה:</p>
      <ul>
        <li>התשלום יחויב מחשבון ה-Apple ID / Google של המשתמש באישור הרכישה.</li>
        <li>המנוי מתחדש אוטומטית אלא אם הביטול יתבצע לפחות 24 שעות לפני תום התקופה הנוכחית.</li>
        <li>החיוב לתקופה הבאה מתבצע במהלך 24 השעות שלפני סיום התקופה.</li>
        <li>ניהול וביטול: ב-iPhone דרך הגדרות ← Apple ID ← מנויים. ב-Android דרך Google Play ← מנויים.</li>
        <li>אם מוצעת תקופת ניסיון או חודש מתנה, יתרת התקופה שאינה מנוצלת תפקע עם רכישת המנוי.</li>
      </ul>
      <h2>5. תוכן משתמשים</h2>
      <p>אתה אחראי לתמונות ולטקסטים שאתה מעלה. אין להעלות תוכן בלתי חוקי, פוגעני או מפר זכויות. הבעלים רשאים להסיר תוכן לפי שיקול דעתם.</p>
      <h2>6. אחריות</h2>
      <p>השירות ניתן AS IS. הבעלים אינם אחראים לעסקאות בין משתמשים לבין מקעקעים, לתוכן צד שלישי, או לתקלות תקשורת.</p>
      <h2>7. דין</h2>
      <p>דיני מדינת ישראל. סמכות השיפוט: בתי המשפט במחוז תל אביב או המרכז.</p>
      <h2>8. יצירת קשר</h2>
      <p>דוא״ל: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a> · טלפון: ${CONTACT_PHONE}</p>
    `,
  });
}

export function privacyHtml() {
  return shell({
    title: 'מדיניות פרטיות | אינק ישראל',
    body: `
      <h1>מדיניות פרטיות</h1>
      <p class="muted">עודכן לאחרונה: 9 בספטמבר 2026. מדיניות זו חלה על אפליקציית אינק ישראל (${COMPANY}).</p>
      <h2>1. מה אנחנו אוספים</h2>
      <ul>
        <li><strong>חשבון:</strong> מספר טלפון, שם, דוא״ל (אם נמסר), סוג משתמש.</li>
        <li><strong>פרופיל עסקי:</strong> שם עסק, כתובת, קואורדינטות מיקום, סגנונות, תיאור, תמונת פרופיל, חתימה.</li>
        <li><strong>תוכן:</strong> תמונות קעקוע/סקיצות שאתה מעלה, פניות קעקוע, הודעות ודיווחים.</li>
        <li><strong>מכשיר:</strong> סוג מכשיר, גרסת אפליקציה, מזהה מכשיר לצורך התראות.</li>
        <li><strong>רכישות:</strong> מזהה מוצר, אסימון רכישה/עסקה של App Store או Google Play. אין לנו גישה למספר כרטיס אשראי.</li>
        <li><strong>שימוש:</strong> אירועי שימוש בסיסיים לשיפור השירות. מעקב פרסומי (IDFA) מתבצע רק אם אישרת זאת בדיאלוג App Tracking Transparency.</li>
      </ul>
      <h2>2. למה אנחנו משתמשים במידע</h2>
      <ul>
        <li>ליצור חשבון, לאמת זהות באמצעות SMS, ולהפעיל את השירות.</li>
        <li>להציג עסקים לפי מיקום וסגנון, ולשלוח פניות למקעקעים.</li>
        <li>לשמור תמונות בפרופיל ובגלריה, ולנהל מגבלות העלאה לפי חבילה.</li>
        <li>לשחזר מנוי ולספק תמיכה.</li>
        <li>לשלוח התראות שביקשת לקבל.</li>
      </ul>
      <h2>3. הרשאות במכשיר</h2>
      <ul>
        <li><strong>מצלמה / גלריה:</strong> רק כדי לצלם או לבחור תמונת פרופיל, פוסט או פניית קעקוע.</li>
        <li><strong>מיקום בזמן שימוש:</strong> כדי למצוא סטודיואים ומקעקעים לידך ולהשלים כתובת עסק. אין איסוף מיקום ברקע.</li>
        <li><strong>התראות:</strong> לעדכונים על פניות והודעות, רק אם אישרת.</li>
        <li><strong>מעקב:</strong> רק לאחר אישור מפורש ב-iOS, לניתוח שימוש ולשיפור האפליקציה.</li>
      </ul>
      <h2>4. שיתוף עם צדדים שלישיים</h2>
      <p>אנחנו לא מוכרים מידע אישי. מידע עשוי להיות מעובד אצל ספקי תשתית שעוזרים להפעיל את השירות, בכפוף להתחייבות לשמירה דומה על המידע:</p>
      <ul>
        <li>Apple ו-Google — התחברות, רכישות מנוי והתראות.</li>
        <li>Firebase — אימות, התראות, קישורים דינמיים ושמירת תיקיות השראה.</li>
        <li>ספק אירוח ומסד נתונים (Railway / MySQL) ואחסון מדיה (Cloudflare R2).</li>
        <li>Meta / Facebook SDK — אירועי שימוש, ורק מעקב פרסומי אם אישרת ATT.</li>
        <li>ספק SMS לשליחת קוד אימות.</li>
      </ul>
      <h2>5. שמירה ומחיקה</h2>
      <p>המידע נשמר כל עוד החשבון פעיל. מחיקת חשבון מתוך האפליקציה מסמנת את החשבון כמחוק ומנתקת את הגישה. ניתן גם לפנות אלינו בבקשת מחיקה לכתובת שבהמשך.</p>
      <h2>6. הסכמה וביטול</h2>
      <p>שימוש באפליקציה מהווה הסכמה למדיניות זו. ניתן למשוך הסכמה על ידי מחיקת החשבון, כיבוי הרשאות במערכת, או פנייה אלינו. פונקציות בתשלום אינן מותנות במתן הרשאת מעקב או מיקום.</p>
      <h2>7. יצירת קשר</h2>
      <p>לשאלות פרטיות או בקשת גישה/מחיקה: <a href="mailto:${CONTACT_EMAIL}">${CONTACT_EMAIL}</a> · ${CONTACT_PHONE}</p>
    `,
  });
}

export function legalIndexHtml() {
  return shell({
    title: 'מסמכים משפטיים | אינק ישראל',
    body: `
      <h1>מסמכים משפטיים</h1>
      <p>כאן מפורסמים המסמכים הציבוריים של אפליקציית אינק ישראל.</p>
      <ul>
        <li><a href="/terms">תנאי שימוש</a></li>
        <li><a href="/privacy">מדיניות פרטיות</a></li>
      </ul>
      <p class="muted">כתובות אלה מיועדות גם ל-App Store Connect ול-Google Play.</p>
    `,
  });
}
