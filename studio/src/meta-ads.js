import path from 'node:path';
import { fileURLToPath } from 'node:url';
import dotenv from 'dotenv';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
dotenv.config({ path: path.join(ROOT, '.env') });

const GRAPH = 'https://graph.facebook.com/v23.0';
const RANGES = new Set(['last_7d', 'last_30d', 'last_90d', 'maximum']);
const ZERO_DECIMAL = new Set(['BIF', 'CLP', 'DJF', 'GNF', 'JPY', 'KMF', 'KRW', 'MGA', 'PYG', 'RWF', 'VND', 'VUV', 'XAF', 'XOF', 'XPF']);

const OBJECTIVES = {
  OUTCOME_AWARENESS: 'מודעות',
  OUTCOME_TRAFFIC: 'תנועה',
  OUTCOME_ENGAGEMENT: 'מעורבות',
  OUTCOME_LEADS: 'לידים',
  OUTCOME_APP_PROMOTION: 'קידום אפליקציה',
  OUTCOME_SALES: 'מכירות',
  LINK_CLICKS: 'קליקים',
  CONVERSIONS: 'המרות',
  POST_ENGAGEMENT: 'מעורבות',
  REACH: 'חשיפה',
  BRAND_AWARENESS: 'מודעות למותג',
  APP_INSTALLS: 'התקנות',
  MESSAGES: 'הודעות',
  VIDEO_VIEWS: 'צפיות וידאו',
  LEAD_GENERATION: 'לידים',
  PRODUCT_CATALOG_SALES: 'מכירות קטלוג',
  STORE_VISITS: 'ביקורים בחנות',
};

const STATUSES = {
  ACTIVE: 'פעיל',
  PAUSED: 'מושהה',
  DELETED: 'נמחק',
  ARCHIVED: 'בארכיון',
  IN_PROCESS: 'בעיבוד',
  WITH_ISSUES: 'עם בעיות',
  PENDING_REVIEW: 'ממתין לאישור',
  DISAPPROVED: 'נדחה',
  PREAPPROVED: 'מאושר מראש',
  PENDING_BILLING_INFO: 'חסר חיוב',
  CAMPAIGN_PAUSED: 'הקמפיין מושהה',
  ADSET_PAUSED: 'הקבוצה מושהה',
  LEARNING: 'בלמידה',
  LEARNING_LIMITED: 'למידה מוגבלת',
};

const ACCOUNT_STATUS = {
  1: 'פעיל',
  2: 'מושבת',
  3: 'חוב פתוח',
  7: 'בבדיקה',
  8: 'בבדיקת תשלום',
  9: 'בתקופת חסד',
  100: 'לקראת סגירה',
  101: 'סגור',
};

const OPTIMIZATION = {
  LINK_CLICKS: 'קליקים',
  LANDING_PAGE_VIEWS: 'צפיות בדף',
  IMPRESSIONS: 'חשיפות',
  REACH: 'חשיפה',
  OFFSITE_CONVERSIONS: 'המרות',
  LEAD_GENERATION: 'לידים',
  POST_ENGAGEMENT: 'מעורבות',
  THRUPLAY: 'צפיות וידאו',
  CONVERSATIONS: 'שיחות',
  APP_INSTALLS: 'התקנות',
  VALUE: 'ערך רכישה',
  QUALITY_LEAD: 'לידים איכותיים',
};

const BID = {
  LOWEST_COST_WITHOUT_CAP: 'עלות נמוכה',
  LOWEST_COST_WITH_BID_CAP: 'תקרת הצעה',
  COST_CAP: 'תקרת עלות',
  LOWEST_COST_WITH_MIN_ROAS: 'ROAS מינימלי',
};

const RESULT_PRIORITY = {
  OUTCOME_SALES: ['omni_purchase', 'purchase', 'offsite_conversion.fb_pixel_purchase', 'onsite_web_purchase'],
  CONVERSIONS: ['omni_purchase', 'purchase', 'offsite_conversion.fb_pixel_purchase', 'lead', 'offsite_conversion.fb_pixel_lead'],
  OUTCOME_LEADS: ['lead', 'onsite_conversion.lead_grouped', 'offsite_conversion.fb_pixel_lead', 'complete_registration'],
  LEAD_GENERATION: ['lead', 'onsite_conversion.lead_grouped'],
  OUTCOME_TRAFFIC: ['landing_page_view', 'link_click'],
  LINK_CLICKS: ['link_click', 'landing_page_view'],
  OUTCOME_ENGAGEMENT: ['post_engagement', 'page_engagement', 'post_reaction'],
  POST_ENGAGEMENT: ['post_engagement'],
  OUTCOME_APP_PROMOTION: ['omni_app_install', 'mobile_app_install', 'app_install'],
  APP_INSTALLS: ['mobile_app_install', 'app_install'],
  MESSAGES: ['onsite_conversion.messaging_conversation_started_7d', 'onsite_conversion.messaging_first_reply'],
  OUTCOME_AWARENESS: ['reach'],
  REACH: ['reach'],
  BRAND_AWARENESS: ['reach'],
  VIDEO_VIEWS: ['video_view', 'thruplay'],
};

const RESULT_LABELS = {
  omni_purchase: 'רכישות',
  purchase: 'רכישות',
  'offsite_conversion.fb_pixel_purchase': 'רכישות',
  onsite_web_purchase: 'רכישות',
  lead: 'לידים',
  'onsite_conversion.lead_grouped': 'לידים',
  'offsite_conversion.fb_pixel_lead': 'לידים',
  complete_registration: 'הרשמות',
  landing_page_view: 'צפיות בדף',
  link_click: 'קליקים על הקישור',
  post_engagement: 'מעורבויות',
  page_engagement: 'מעורבויות',
  post_reaction: 'תגובות',
  omni_app_install: 'התקנות',
  mobile_app_install: 'התקנות',
  app_install: 'התקנות',
  'onsite_conversion.messaging_conversation_started_7d': 'שיחות',
  'onsite_conversion.messaging_first_reply': 'תשובות',
  reach: 'אנשים שנחשפו',
  video_view: 'צפיות וידאו',
  thruplay: 'צפיות מלאות',
};

const AWARENESS = new Set(['OUTCOME_AWARENESS', 'REACH', 'BRAND_AWARENESS']);

const INSIGHT_FIELDS = [
  'impressions', 'reach', 'frequency', 'clicks', 'unique_clicks', 'ctr', 'unique_ctr',
  'inline_link_clicks', 'inline_link_click_ctr', 'cost_per_inline_link_click',
  'cpc', 'cpm', 'cpp', 'spend', 'actions', 'action_values', 'cost_per_action_type',
  'purchase_roas', 'date_start', 'date_stop',
].join(',');

function httpError(message, status = 500) {
  const err = new Error(message);
  err.status = status;
  return err;
}

function num(value) {
  const n = Number(value);
  return Number.isFinite(n) ? n : 0;
}

function money(amount, currency) {
  const value = Number(amount) || 0;
  try {
    return new Intl.NumberFormat('he-IL', {
      style: 'currency',
      currency: currency || 'ILS',
      maximumFractionDigits: 2,
    }).format(value);
  } catch {
    return `${value.toFixed(2)} ${currency || ''}`.trim();
  }
}

function fromMinor(amount, currency) {
  const n = num(amount);
  if (!n) return 0;
  return n / (ZERO_DECIMAL.has(currency) ? 1 : 100);
}

function friendlyMetaError(error) {
  if (!error) return 'Meta לא החזיר תשובה';
  const msg = String(error.error_user_msg || error.message || '');
  if (error.code === 190) return 'הטוקן של Meta לא תקין או בוטל. צרו טוקן חדש למשתמש המערכת.';
  if (error.code === 200 || /permission|ads_management|ads_read/i.test(msg)) {
    return 'אין הרשאה לחשבון המודעות. ב-Business Settings שייכו את חשבון המודעות למשתמש המערכת עם שליטה מלאה.';
  }
  if (error.code === 17 || error.code === 4 || error.code === 32) return 'Meta הגביל את הקצב. נסו שוב בעוד דקה.';
  return msg || 'שגיאה מ-Meta';
}

function safeUrl(url) {
  if (!url) return '';
  try {
    const parsed = new URL(url);
    parsed.searchParams.delete('access_token');
    return parsed.toString();
  } catch {
    return String(url).replace(/access_token=[^&]+/gi, '');
  }
}

async function graph(pathname, { method = 'GET', body } = {}) {
  const token = process.env.META_ACCESS_TOKEN || '';
  if (!token) throw httpError('META_ACCESS_TOKEN לא מוגדר בשרת', 503);
  const url = new URL(String(pathname).startsWith('http') ? pathname : `${GRAPH}${pathname}`);
  url.searchParams.set('access_token', token);
  const res = await fetch(url, {
    method,
    headers: body ? { 'Content-Type': 'application/json' } : undefined,
    body: body ? JSON.stringify(body) : undefined,
  });
  const json = await res.json().catch(() => ({}));
  if (!res.ok || json.error) {
    const status = res.status === 401 || res.status === 403 ? res.status : 502;
    throw httpError(friendlyMetaError(json.error), status);
  }
  return json;
}

async function graphAll(pathname, cap = 8) {
  const rows = [];
  let next = pathname;
  for (let i = 0; i < cap && next; i++) {
    const page = await graph(next);
    rows.push(...(page.data || []));
    next = page.paging?.next || '';
  }
  return rows;
}

function accountKey(account) {
  if (account?.account_id) return String(account.account_id);
  return String(account?.id || '').replace(/^act_/, '');
}

async function edgeAccounts(pathname) {
  try {
    return await graphAll(pathname);
  } catch {
    return [];
  }
}

async function discoverAccounts() {
  const seen = new Map();
  const edges = await Promise.all([
    edgeAccounts('/me/adaccounts?fields=id,account_id,name,account_status,currency,amount_spent,balance,timezone_name&limit=50'),
    edgeAccounts('/me/assigned_ad_accounts?fields=id,account_id,name,account_status,currency,amount_spent,balance,timezone_name&limit=50'),
  ]);
  for (const row of edges.flat()) {
    if (row?.id) seen.set(row.id, { ...row, inaccessible: false });
  }

  const extra = String(process.env.META_AD_ACCOUNT_ID || '')
    .split(',')
    .map((part) => part.trim())
    .filter(Boolean);
  for (const raw of extra) {
    const id = raw.startsWith('act_') ? raw : `act_${raw}`;
    if (seen.has(id)) continue;
    try {
      const row = await graph(`/${id}?fields=id,account_id,name,account_status,currency,amount_spent,balance,timezone_name`);
      seen.set(row.id, { ...row, inaccessible: false });
    } catch (err) {
      seen.set(id, { id, name: id, inaccessible: true, error: err.message });
    }
  }
  return [...seen.values()];
}

function pickAction(actions, types) {
  const list = Array.isArray(actions) ? actions : [];
  for (const type of types) {
    const hit = list.find((row) => row.action_type === type);
    if (hit && num(hit.value) > 0) return { type, value: num(hit.value) };
  }
  return null;
}

function metricsFrom(row, objective) {
  const spend = num(row?.spend);
  const impressions = num(row?.impressions);
  const reach = num(row?.reach);
  const clicks = num(row?.clicks);
  const linkClicks = num(row?.inline_link_clicks);
  const priority = RESULT_PRIORITY[objective] || ['landing_page_view', 'link_click', 'lead', 'purchase'];
  let action = pickAction(row?.actions, priority);
  if (!action && priority.includes('link_click') && linkClicks > 0) action = { type: 'link_click', value: linkClicks };
  if (!action && priority.includes('reach') && reach > 0) action = { type: 'reach', value: reach };
  const results = action?.value || 0;
  const resultType = action?.type || '';
  const costHit = resultType ? pickAction(row?.cost_per_action_type, [resultType]) : null;
  const roasRow = Array.isArray(row?.purchase_roas) ? row.purchase_roas[0] : null;
  return {
    spend,
    impressions,
    reach,
    clicks,
    linkClicks,
    ctr: num(row?.ctr),
    linkCtr: num(row?.inline_link_click_ctr),
    cpc: num(row?.cpc),
    cpm: num(row?.cpm),
    frequency: num(row?.frequency),
    results,
    resultType,
    resultLabel: RESULT_LABELS[resultType] || 'תוצאות',
    costPerResult: results > 0 ? (costHit ? costHit.value : spend / results) : 0,
    roas: roasRow ? num(roasRow.value) : 0,
    awareness: AWARENESS.has(objective),
    dateStart: row?.date_start || '',
    dateStop: row?.date_stop || '',
  };
}

function emptyMetrics() {
  return metricsFrom(null, '');
}

function median(values) {
  const sorted = values.filter((n) => n > 0).sort((a, b) => a - b);
  if (!sorted.length) return 0;
  const mid = Math.floor(sorted.length / 2);
  return sorted.length % 2 ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2;
}

function adviseCampaign(campaign, ctx) {
  const m = campaign.metrics;
  const notes = [];
  let verdict = 'idle';
  const ctr = m.linkCtr || m.ctr;

  if (campaign.effectiveStatus === 'WITH_ISSUES' || campaign.effectiveStatus === 'DISAPPROVED') {
    notes.push('יש בעיה במסירה או שהמודעה נדחתה. בדקו ב-Ads Manager את סיבת הדחייה לפני שמעלים תקציב.');
    verdict = 'bad';
  }

  if (m.spend <= 0 && campaign.configuredStatus !== 'ACTIVE') {
    notes.push('הקמפיין לא רץ בטווח הזה, אז אי אפשר לדעת אם הוא עובד. אם המודעה מאושרת, הפעילו אותו עם תקציב יומי קטן ובדקו אחרי 3 ימים.');
    return { verdict: 'idle', notes };
  }
  if (m.spend <= 0 && campaign.configuredStatus === 'ACTIVE') {
    notes.push('הקמפיין מסומן כפעיל אבל לא הייתה הוצאה. בדקו תקציב, קהל צר מדי, או מודעה שממתינה לאישור.');
    return { verdict: 'warn', notes };
  }

  verdict = verdict === 'bad' ? 'bad' : 'warn';

  if (!m.awareness && m.spend >= 40 && m.results === 0) {
    verdict = 'bad';
    notes.push(`יצאו ${money(m.spend, ctx.currency)} בלי ${m.resultLabel}. זה לא עובד. עצרו, והחליפו גם את המודעה וגם את הקהל לפני הפעלה מחדש.`);
  } else if (!m.awareness && m.results > 0 && ctx.medianCpr > 0) {
    if (m.costPerResult <= ctx.medianCpr * 0.85 && verdict !== 'bad') {
      verdict = 'good';
      notes.push(`העלות ל${m.resultLabel} נמוכה משאר הקמפיינים. זה הקמפיין שכדאי להזין בתקציב.`);
    } else if (m.costPerResult >= ctx.medianCpr * 1.6) {
      verdict = 'bad';
      notes.push(`העלות ל${m.resultLabel} גבוהה משמעותית משאר החשבון. צמצמו תקציב או עצרו עד שהמודעה משתפרת.`);
    }
  }

  if (m.impressions >= 800 && ctr > 0 && ctr < 0.7) {
    if (verdict === 'good') verdict = 'warn';
    notes.push(`CTR ${ctr.toFixed(2)}% נמוך. בקעקועים עובד צילום עבודה מוגמרת מקרוב, עם עיר ומחיר התחלתי בשורה הראשונה — לא לוגו ולא טקסט כללי.`);
  } else if (ctr >= 1.5 && m.impressions >= 500) {
    notes.push(`CTR ${ctr.toFixed(2)}% חזק. הקריאייטיב תופס. שמרו על הפורמט הזה ושכפלו אותו למודעות חלשות.`);
    if (verdict === 'warn' && m.results > 0) verdict = 'good';
  }

  if (m.frequency >= 4) {
    notes.push(`תדירות ${m.frequency.toFixed(1)} גבוהה: אותם אנשים רואים את המודעה יותר מדי. החליפו תמונה או הרחיבו קהל, אחרת המחיר יעלה.`);
    if (verdict === 'good') verdict = 'warn';
  } else if (m.frequency >= 2.6) {
    notes.push(`תדירות ${m.frequency.toFixed(1)} מתחילה להתעייף. הכינו גרסה שנייה של המודעה לפני שמעלים תקציב.`);
  } else if (verdict === 'good' && m.frequency > 0 && m.frequency < 2.2) {
    notes.push('עוד יש קהל חדש. אם מעלים תקציב, עד כ-20% כל יומיים, לא בקפיצה.');
  }

  if (ctx.avgCpm > 0 && m.cpm > ctx.avgCpm * 1.5 && m.impressions >= 500) {
    notes.push('ה-CPM גבוה יחסית לשאר החשבון. הקהל צר מדי או שהמודעה פחות רלוונטית. נסו קהל רחב יותר באזור, עם תחומי עניין של קעקועים.');
  }

  if (m.roas > 0) {
    notes.push(m.roas >= 2
      ? `ROAS ${m.roas.toFixed(2)} — ההכנסה מכסה את המודעה. אפשר להגדיל בזהירות.`
      : `ROAS ${m.roas.toFixed(2)} מתחת ל-2. המכירות לא מחזירות את ההוצאה. בדקו את דף היעד וההצעה, לא רק את המודעה.`);
    if (m.roas < 1) verdict = 'bad';
  }

  if (campaign.bestAd && campaign.bestAd.metrics.impressions >= 300) {
    const adCtr = campaign.bestAd.metrics.linkCtr || campaign.bestAd.metrics.ctr;
    if (adCtr >= 1) {
      notes.push(`המודעה החזקה בקמפיין: «${campaign.bestAd.name}». תנו לה יותר תקציב וכבו מודעות עם CTR נמוך.`);
    }
  }

  if (!notes.length) {
    notes.push('אין עדיין מספיק נתונים כדי להכריע. תנו לקמפיין עוד כמה ימים עם תקציב יציב לפני שינוי.');
  }
  return { verdict, notes: notes.slice(0, 4) };
}

function buildRecommendations(campaigns, currency) {
  const recs = [];
  const active = campaigns.filter((c) => c.configuredStatus === 'ACTIVE');
  const measured = campaigns.filter((c) => c.metrics.spend > 0 && !c.metrics.awareness && c.metrics.results > 0);
  if (measured.length) {
    const best = [...measured].sort((a, b) => a.metrics.costPerResult - b.metrics.costPerResult)[0];
    recs.push({
      tone: 'good',
      title: `מה עובד: ${best.name}`,
      body: `העלות הנמוכה ביותר ל${best.metrics.resultLabel} היא ${money(best.metrics.costPerResult, currency)}. זה הקמפיין להשאיר דולק. אל תשנו אותו כל יום — שינוי מאפס את הלמידה.`,
    });
    const worst = [...measured].sort((a, b) => b.metrics.costPerResult - a.metrics.costPerResult)[0];
    if (worst.id !== best.id && best.metrics.costPerResult > 0 && worst.metrics.costPerResult > best.metrics.costPerResult * 1.5) {
      const ratio = (worst.metrics.costPerResult / best.metrics.costPerResult).toFixed(1);
      recs.push({
        tone: 'bad',
        title: `מה לא עובד: ${worst.name}`,
        body: `העלות ל${worst.metrics.resultLabel} היא ${money(worst.metrics.costPerResult, currency)}, בערך פי ${ratio} מהקמפיין הטוב. העבירו את התקציב לקמפיין שעובד.`,
      });
    }
  }
  const burners = campaigns.filter((c) => !c.metrics.awareness && c.metrics.spend >= 40 && c.metrics.results === 0);
  if (burners.length) {
    recs.push({
      tone: 'bad',
      title: 'תקציב בלי תוצאה',
      body: `${burners.map((c) => c.name).join(', ')} הוציאו כסף בלי תוצאה מדידה. עצרו אותם עד שיש מודעה חדשה וקהל אחר.`,
    });
  }
  const tired = campaigns.filter((c) => c.metrics.frequency >= 3.5 && c.metrics.spend > 0);
  if (tired.length) {
    recs.push({
      tone: 'warn',
      title: 'המודעות נשחקו',
      body: `${tired.map((c) => c.name).join(', ')} רצים על תדירות גבוהה. הוסיפו קריאייטיב חדש (עבודה אחרת, זווית אחרת) במקום להעלות תקציב.`,
    });
  }
  if (!active.length && campaigns.length) {
    const restart = [...campaigns].filter((c) => c.metrics.results > 0).sort((a, b) => a.metrics.costPerResult - b.metrics.costPerResult)[0];
    recs.push({
      tone: 'warn',
      title: 'אין קמפיין פעיל',
      body: restart
        ? `אף קמפיין לא רץ. «${restart.name}» היה היעיל ביותר בטווח הזה — אפשר להפעיל אותו מחדש עם תקציב יומי קטן.`
        : 'אף קמפיין לא רץ, ואין בטווח הזה קמפיין עם תוצאות. הפעילו קמפיין אחד עם מודעה ברורה ומדדו 3 ימים.',
    });
  }
  if (!recs.length && campaigns.length) {
    recs.push({
      tone: 'warn',
      title: 'עוד מוקדם להכריע',
      body: 'יש מעט הוצאה או מעט תוצאות. השאירו קמפיין אחד פעיל עם תקציב יציב, ובדקו שוב אחרי כמה מאות קליקים או אחרי 3 ימים.',
    });
  }
  return recs.slice(0, 5);
}

function mapAd(row, insight, objective) {
  const creative = row.creative || {};
  return {
    id: row.id,
    name: row.name || creative.title || row.id,
    configuredStatus: row.status || '',
    effectiveStatus: row.effective_status || row.status || '',
    statusLabel: STATUSES[row.effective_status] || STATUSES[row.status] || row.effective_status || '',
    thumbnail: safeUrl(creative.thumbnail_url || creative.image_url || ''),
    title: creative.title || '',
    body: creative.body || '',
    metrics: metricsFrom(insight, objective),
  };
}

function bestAdOf(ads) {
  const ranked = ads
    .filter((ad) => ad.metrics.impressions >= 200)
    .sort((a, b) => (b.metrics.linkCtr || b.metrics.ctr) - (a.metrics.linkCtr || a.metrics.ctr));
  return ranked[0] || null;
}

async function loadAccount(account, range) {
  const id = account.id;
  const currency = account.currency || 'ILS';
  const [campaignsRaw, adsetsRaw, adsRaw, campaignInsights, adsetInsights, adInsights, accountInsights, daily] = await Promise.all([
    graphAll(`/${id}/campaigns?fields=id,name,status,effective_status,objective,daily_budget,lifetime_budget,bid_strategy,start_time,stop_time,created_time,updated_time&limit=100&filtering=${encodeURIComponent(JSON.stringify([{ field: 'effective_status', operator: 'IN', value: ['ACTIVE', 'PAUSED', 'ARCHIVED', 'WITH_ISSUES', 'IN_PROCESS', 'CAMPAIGN_PAUSED', 'ADSET_PAUSED'] }]))}`),
    graphAll(`/${id}/adsets?fields=id,name,status,effective_status,campaign_id,daily_budget,lifetime_budget,optimization_goal,destination_type,start_time,end_time&limit=200`),
    graphAll(`/${id}/ads?fields=id,name,status,effective_status,campaign_id,adset_id,creative{title,body,thumbnail_url,image_url}&limit=200`),
    graphAll(`/${id}/insights?level=campaign&date_preset=${range}&fields=campaign_id,${INSIGHT_FIELDS}&limit=200`),
    graphAll(`/${id}/insights?level=adset&date_preset=${range}&fields=adset_id,campaign_id,${INSIGHT_FIELDS}&limit=300`),
    graphAll(`/${id}/insights?level=ad&date_preset=${range}&fields=ad_id,adset_id,campaign_id,${INSIGHT_FIELDS}&limit=400`),
    graph(`/${id}/insights?date_preset=${range}&fields=${INSIGHT_FIELDS}&limit=1`).catch(() => ({ data: [] })),
    graphAll(`/${id}/insights?date_preset=${range}&time_increment=1&fields=spend,impressions,clicks,inline_link_clicks,date_start&limit=100`),
  ]);

  const byCampaign = new Map(campaignInsights.map((row) => [row.campaign_id, row]));
  const byAdset = new Map(adsetInsights.map((row) => [row.adset_id, row]));
  const byAd = new Map(adInsights.map((row) => [row.ad_id, row]));

  const campaigns = campaignsRaw.map((row) => {
    const objective = row.objective || '';
    const adsets = adsetsRaw
      .filter((adset) => adset.campaign_id === row.id)
      .map((adset) => ({
        id: adset.id,
        name: adset.name,
        configuredStatus: adset.status || '',
        effectiveStatus: adset.effective_status || adset.status || '',
        statusLabel: STATUSES[adset.effective_status] || STATUSES[adset.status] || adset.effective_status || '',
        optimization: OPTIMIZATION[adset.optimization_goal] || adset.optimization_goal || '',
        dailyBudget: fromMinor(adset.daily_budget, currency),
        lifetimeBudget: fromMinor(adset.lifetime_budget, currency),
        metrics: metricsFrom(byAdset.get(adset.id), objective),
      }))
      .sort((a, b) => b.metrics.spend - a.metrics.spend);
    const ads = adsRaw
      .filter((ad) => ad.campaign_id === row.id)
      .map((ad) => mapAd(ad, byAd.get(ad.id), objective))
      .sort((a, b) => (b.metrics.linkCtr || b.metrics.ctr) - (a.metrics.linkCtr || a.metrics.ctr));
    const bestAd = bestAdOf(ads);
    return {
      id: row.id,
      accountId: id,
      name: row.name || row.id,
      configuredStatus: row.status || '',
      effectiveStatus: row.effective_status || row.status || '',
      statusLabel: STATUSES[row.effective_status] || STATUSES[row.status] || row.effective_status || '',
      objective,
      objectiveLabel: OBJECTIVES[objective] || objective || 'ללא יעד',
      bidStrategy: BID[row.bid_strategy] || row.bid_strategy || '',
      dailyBudget: fromMinor(row.daily_budget, currency),
      lifetimeBudget: fromMinor(row.lifetime_budget, currency),
      budgetOnAdsets: num(row.daily_budget) === 0 && num(row.lifetime_budget) === 0,
      startTime: row.start_time || '',
      stopTime: row.stop_time || '',
      createdTime: row.created_time || '',
      updatedTime: row.updated_time || '',
      metrics: metricsFrom(byCampaign.get(row.id), objective),
      adsets,
      ads,
      bestAd: bestAd ? { id: bestAd.id, name: bestAd.name, metrics: bestAd.metrics } : null,
    };
  });

  const spenders = campaigns.filter((c) => c.metrics.spend > 0);
  const ctx = {
    currency,
    medianCpr: median(spenders.filter((c) => !c.metrics.awareness && c.metrics.results > 0).map((c) => c.metrics.costPerResult)),
    avgCpm: (() => {
      const impressions = spenders.reduce((sum, c) => sum + c.metrics.impressions, 0);
      const spend = spenders.reduce((sum, c) => sum + c.metrics.spend, 0);
      return impressions ? (spend / impressions) * 1000 : 0;
    })(),
  };
  for (const campaign of campaigns) {
    const advice = adviseCampaign(campaign, ctx);
    campaign.verdict = advice.verdict;
    campaign.notes = advice.notes;
  }
  campaigns.sort((a, b) => {
    const rank = { ACTIVE: 0, PAUSED: 1 };
    const ar = rank[a.configuredStatus] ?? 2;
    const br = rank[b.configuredStatus] ?? 2;
    if (ar !== br) return ar - br;
    return b.metrics.spend - a.metrics.spend;
  });

  const accountRow = accountInsights.data?.[0] || null;
  return {
    id,
    name: account.name || id,
    currency,
    status: ACCOUNT_STATUS[account.account_status] || String(account.account_status || ''),
    timezone: account.timezone_name || '',
    amountSpent: fromMinor(account.amount_spent, currency),
    balance: fromMinor(account.balance, currency),
    totals: metricsFrom(accountRow, ''),
    trend: daily.slice(-60).map((day) => ({
      date: day.date_start,
      spend: num(day.spend),
      impressions: num(day.impressions),
      clicks: num(day.clicks),
    })),
    campaigns,
    recommendations: buildRecommendations(campaigns, currency),
  };
}

function setupPayload(systemUser) {
  return {
    title: 'אין חשבון מודעות משויך',
    message: `החיבור ל-Meta תקין. משתמש המערכת הוא «${systemUser.name}». לא משויך אליו אף חשבון מודעות, ולכן אין קמפיינים לקרוא. המספר שמופיע אצל משתמש המערכת ב-Meta הוא לא מספר חשבון המודעות.`,
    steps: [
      'ב-Meta Business Settings פתחו משתמשים ← משתמשי מערכת.',
      `פתחו את «${systemUser.name}».`,
      'הוסיפו נכסים ← חשבון המודעות ← שליטה מלאה.',
      'חזרו לטאב הזה ורעננו. ההפעלה והעצירה יעבדו על הקמפיינים של החשבון ששויך.',
    ],
  };
}

export async function loadCampaignDashboard({ range = 'last_30d' } = {}) {
  const preset = RANGES.has(range) ? range : 'last_30d';
  const systemUser = await graph('/me?fields=id,name');
  const found = await discoverAccounts();
  const readable = found.filter((account) => !account.inaccessible);
  const blocked = found.filter((account) => account.inaccessible).map((account) => ({
    id: account.id,
    error: account.error || 'אין הרשאה',
  }));
  if (!readable.length) {
    return {
      range: preset,
      generatedAt: new Date().toISOString(),
      systemUser: { id: systemUser.id, name: systemUser.name },
      setup: setupPayload(systemUser),
      blocked,
      accounts: [],
    };
  }

  const accounts = [];
  const errors = [];
  for (const account of readable) {
    try {
      accounts.push(await loadAccount(account, preset));
    } catch (err) {
      errors.push({ id: account.id, name: account.name || account.id, error: err.message });
    }
  }
  return {
    range: preset,
    generatedAt: new Date().toISOString(),
    systemUser: { id: systemUser.id, name: systemUser.name },
    setup: accounts.length ? null : setupPayload(systemUser),
    blocked,
    errors,
    accounts,
  };
}

export async function setCampaignStatus(campaignId, status) {
  if (!/^\d+$/.test(String(campaignId || ''))) throw httpError('מזהה קמפיין לא תקין', 400);
  if (status !== 'ACTIVE' && status !== 'PAUSED') throw httpError('אפשר רק להפעיל או לעצור קמפיין', 400);
  const campaign = await graph(`/${campaignId}?fields=id,name,account_id,status`);
  const accounts = await discoverAccounts();
  const allowed = new Set(accounts.filter((account) => !account.inaccessible).map(accountKey));
  if (!allowed.has(String(campaign.account_id))) {
    throw httpError('הקמפיין לא שייך לחשבון מודעות שהטוקן יכול לנהל', 403);
  }
  const token = process.env.META_ACCESS_TOKEN || '';
  const url = new URL(`${GRAPH}/${campaignId}`);
  url.searchParams.set('access_token', token);
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({ status }),
  });
  const json = await res.json().catch(() => ({}));
  if (!res.ok || json.error) throw httpError(friendlyMetaError(json.error), res.status === 403 ? 403 : 502);
  return {
    ok: true,
    id: campaign.id,
    name: campaign.name,
    status,
    statusLabel: STATUSES[status] || status,
  };
}
