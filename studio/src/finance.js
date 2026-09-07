import fs from 'node:fs';
import path from 'node:path';

export const PLAN_CATALOG = {
  monthly_basic_plan: { ils: 99.9, period: 'month', labelHe: 'בסיסי חודשי' },
  monthly_premium_plan: { ils: 99.9, period: 'month', labelHe: 'פרימיום חודשי' },
  yearly_basic_plan: { ils: 1599.9, period: 'year', labelHe: 'בסיסי שנתי' },
  yearly_premium_plan: { ils: 2699.9, period: 'year', labelHe: 'פרימיום שנתי' },
  basic_free_plan: { ils: 0, period: 'none', labelHe: 'חינם' },
};

const DEFAULT_COSTS = {
  currency: 'ILS',
  storeFeePercent: 15,
  updatedAt: null,
  items: [],
};

function num(v) {
  const n = Number(v);
  return Number.isFinite(n) ? n : 0;
}

function daysAgo(date, days) {
  const d = parseDate(date);
  if (!d) return false;
  return d.getTime() >= Date.now() - days * 86400000;
}

function parseDate(value) {
  if (!value) return null;
  const d = value instanceof Date ? value : new Date(value);
  return Number.isNaN(d.getTime()) ? null : d;
}

function isTruthyDelete(v) {
  return v === 1 || v === '1' || v === true;
}

function planOf(productId) {
  return PLAN_CATALOG[productId] || { ils: 0, period: 'unknown', labelHe: productId || 'לא ידוע' };
}

function monthlyRevenue(productId) {
  const plan = planOf(productId);
  if (plan.period === 'year') return plan.ils / 12;
  if (plan.period === 'month') return plan.ils;
  return 0;
}

function isSandbox(sub) {
  return /"environment"\s*:\s*"Sandbox"/i.test(String(sub.subscription_data || ''));
}

function isComplimentary(sub) {
  return String(sub.purchase_token || '').trim() === 'admin_comp';
}

function isActiveSub(sub, now) {
  if (String(sub.status) !== '1' || String(sub.is_sub_active) !== '1') return false;
  const exp = parseDate(sub.expire_date);
  if (!exp) return true;
  return exp.getTime() > now.getTime();
}

function latestSubsByUser(subs) {
  const map = new Map();
  for (const sub of subs) {
    if (isTruthyDelete(sub.is_delete)) continue;
    const prev = map.get(sub.cust_id);
    if (!prev || num(sub.id) > num(prev.id)) map.set(sub.cust_id, sub);
  }
  return map;
}

function firstPayingDate(subs, custId) {
  const dates = subs
    .filter(
      (s) =>
        s.cust_id === custId &&
        !isTruthyDelete(s.is_delete) &&
        !isComplimentary(s) &&
        monthlyRevenue(s.product_id) > 0
    )
    .map((s) => parseDate(s.date_added))
    .filter(Boolean)
    .sort((a, b) => a - b);
  return dates[0] || null;
}

export function readCosts(filePath) {
  if (!fs.existsSync(filePath)) return structuredClone(DEFAULT_COSTS);
  try {
    const parsed = JSON.parse(fs.readFileSync(filePath, 'utf8'));
    return {
      ...DEFAULT_COSTS,
      ...parsed,
      items: Array.isArray(parsed.items) ? parsed.items : [],
    };
  } catch {
    return structuredClone(DEFAULT_COSTS);
  }
}

export function writeCosts(filePath, body) {
  const current = readCosts(filePath);
  const items = Array.isArray(body.items)
    ? body.items.map((item, i) => ({
        id: String(item.id || `item_${i + 1}`).slice(0, 64),
        label: String(item.label || 'סעיף').slice(0, 120),
        monthlyIls: Math.max(0, num(item.monthlyIls)),
        note: String(item.note || '').slice(0, 400),
      }))
    : current.items;
  const next = {
    currency: 'ILS',
    storeFeePercent: Math.min(40, Math.max(0, num(body.storeFeePercent ?? current.storeFeePercent))),
    updatedAt: new Date().toISOString(),
    items,
  };
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, JSON.stringify(next, null, 2) + '\n');
  return next;
}

export function summarizeFinance({ customers, subscriptions, posts, reports, requests, costs }) {
  const now = new Date();
  const people = customers.filter((c) => !isTruthyDelete(c.is_delete));
  const latest = latestSubsByUser(subscriptions);

  const users = {
    total: people.length,
    regular: people.filter((c) => String(c.user_type) === '1').length,
    business: people.filter((c) => String(c.user_type) === '2' || String(c.is_business) === '1').length,
    studios: people.filter((c) => String(c.business_type) === '1' && String(c.user_type) === '2').length,
    artists: people.filter((c) => String(c.business_type) === '2' && String(c.user_type) === '2').length,
    approvedBusiness: people.filter((c) => String(c.user_type) === '2' && String(c.status) === '1').length,
    new7d: people.filter((c) => daysAgo(c.register_date, 7)).length,
    new30d: people.filter((c) => daysAgo(c.register_date, 30)).length,
    logged7d: people.filter((c) => daysAgo(c.login_date, 7)).length,
  };

  const buckets = {
    payingActive: [],
    complimentary: [],
    free: [],
    expired: [],
    sandbox: [],
    unknown: [],
  };

  for (const person of people) {
    const sub = latest.get(person.id);
    if (!sub) {
      buckets.unknown.push({ person, sub: null });
      continue;
    }
    if (isSandbox(sub) && isActiveSub(sub, now) && !isComplimentary(sub)) {
      buckets.sandbox.push({ person, sub });
    }
    if (isComplimentary(sub) && isActiveSub(sub, now)) {
      buckets.complimentary.push({ person, sub });
      continue;
    }
    if (isActiveSub(sub, now) && monthlyRevenue(sub.product_id) > 0) {
      buckets.payingActive.push({ person, sub });
      continue;
    }
    if (planOf(sub.product_id).ils === 0 && isActiveSub(sub, now)) {
      buckets.free.push({ person, sub });
      continue;
    }
    buckets.expired.push({ person, sub });
  }

  const newPaying = buckets.payingActive.filter(({ person, sub }) => {
    const first = firstPayingDate(subscriptions, person.id) || parseDate(sub.date_added);
    return first && daysAgo(first, 30);
  });
  const oldPaying = buckets.payingActive.filter(({ person, sub }) => {
    const first = firstPayingDate(subscriptions, person.id) || parseDate(sub.date_added);
    return !(first && daysAgo(first, 30));
  });
  const newPaying7d = buckets.payingActive.filter(({ person, sub }) => {
    const first = firstPayingDate(subscriptions, person.id) || parseDate(sub.date_added);
    return first && daysAgo(first, 7);
  });

  const planMix = {};
  for (const row of buckets.payingActive) {
    const id = row.sub.product_id || 'unknown';
    if (!planMix[id]) {
      const plan = planOf(id);
      planMix[id] = {
        productId: id,
        labelHe: plan.labelHe,
        count: 0,
        monthlyIls: 0,
        listPrice: plan.ils,
        period: plan.period,
      };
    }
    planMix[id].count += 1;
    planMix[id].monthlyIls += monthlyRevenue(id);
  }

  const iosPaying = buckets.payingActive.filter(({ sub }) => String(sub.device_type) === '2').length;
  const androidPaying = buckets.payingActive.filter(({ sub }) => String(sub.device_type) === '1').length;

  const grossMrr = Object.values(planMix).reduce((s, p) => s + p.monthlyIls, 0);
  const storeFeePercent = num(costs.storeFeePercent);
  const storeFee = grossMrr * (storeFeePercent / 100);
  const netMrr = grossMrr - storeFee;
  const operating = (costs.items || []).reduce((s, item) => s + num(item.monthlyIls), 0);
  const netAfterCosts = netMrr - operating;
  const payingCount = buckets.payingActive.length;
  const arpu = payingCount ? netMrr / payingCount : 0;

  return {
    generatedAt: now.toISOString(),
    currency: 'ILS',
    users,
    subscriptions: {
      payingActive: payingCount,
      newPaying30d: newPaying.length,
      newPaying7d: newPaying7d.length,
      oldPaying: oldPaying.length,
      complimentary: buckets.complimentary.length,
      free: buckets.free.length,
      expired: buckets.expired.length,
      sandboxActive: buckets.sandbox.length,
      noSubscription: buckets.unknown.length,
      iosPaying,
      androidPaying,
    },
    plans: Object.values(planMix).sort((a, b) => b.monthlyIls - a.monthlyIls),
    money: {
      listGrossMrr: round2(grossMrr),
      estimatedAnnualGross: round2(grossMrr * 12),
      storeFeePercent,
      storeFeeMonthly: round2(storeFee),
      netMrr: round2(netMrr),
      operatingMonthly: round2(operating),
      netAfterCosts: round2(netAfterCosts),
      arpu: round2(arpu),
      costPerPayingUser: payingCount ? round2(operating / payingCount) : 0,
    },
    activity: {
      posts: num(posts),
      reports: num(reports),
      requests: num(requests),
    },
    costs,
    notes: [
      'הכנסה מחושבת לפי מחירון האפליקציה למנויים פעילים בלבד, בלי מנויי מתנה ובלי Sandbox.',
      'מנוי שנתי נספר כחלק יחסי לחודש (מחיר שנתי חלקי 12).',
      'עמלת חנות היא הערכה — אפשר לשנות את האחוז במסך.',
      'הוצאות התפעול נשמרות מקומית וניתן לערוך אותן כאן.',
    ],
  };
}

function round2(n) {
  return Math.round(num(n) * 100) / 100;
}

export async function loadFinanceRows(source) {
  const customers = await source.rows('tbl_customer', {
    whereSql: '',
    params: {},
    orderSql: '',
    limit: 100000,
    offset: 0,
  });
  const subscriptions = await source.rows('tbl_subscription', {
    whereSql: '',
    params: {},
    orderSql: '',
    limit: 100000,
    offset: 0,
  });
  const countSafe = async (table) => {
    try {
      return await source.count(table);
    } catch {
      return 0;
    }
  };
  return {
    customers,
    subscriptions,
    posts: await countSafe('tbl_post'),
    reports: (await countSafe('tbl_report_posts')) + (await countSafe('tbl_report_users')),
    requests: await countSafe('tbl_request'),
  };
}
