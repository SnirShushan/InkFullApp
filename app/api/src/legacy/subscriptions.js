import { pool } from '../db.js';
import { ok, fail, validateToken, getSettings } from './helpers.js';

function sqlDate(d = new Date()) {
  const x = d instanceof Date ? d : new Date(d);
  if (Number.isNaN(x.getTime())) return sqlDate(new Date());
  return x.toISOString().slice(0, 19).replace('T', ' ');
}

function planKind(productId) {
  const id = String(productId || '');
  const parts = id.split('_');
  return {
    id,
    isPremium: parts.includes('premium'),
    isFree: id === 'basic_free_plan',
    isYearly: parts.includes('yearly'),
    isBasic: parts.includes('basic'),
  };
}

function expireFromProduct(productId, from = new Date()) {
  const d = new Date(from);
  if (planKind(productId).isYearly) d.setFullYear(d.getFullYear() + 1);
  else d.setMonth(d.getMonth() + 1);
  return d;
}

function isActiveRow(row, now = new Date()) {
  if (!row) return false;
  if (String(row.status) !== '1' || String(row.is_sub_active) !== '1') return false;
  const kind = planKind(row.product_id);
  if (kind.isFree || String(row.device_type) === '3') return true;
  if (String(row.purchase_token || '') === 'admin_comp') {
    if (!row.expire_date) return true;
  }
  if (!row.expire_date) return true;
  const exp = new Date(row.expire_date);
  if (Number.isNaN(exp.getTime())) return true;
  return exp.getTime() >= now.getTime();
}

async function requireAuth(p) {
  const row = await validateToken(p.login_token, p.uid);
  if (!row) return { error: fail('יש להתחבר מחדש', 2) };
  return { uid: p.uid, row };
}

async function latestSub(uid) {
  const [rows] = await pool.query(
    `SELECT * FROM tbl_subscription
     WHERE cust_id = :uid AND is_delete = '0'
     ORDER BY id DESC
     LIMIT 1`,
    { uid }
  );
  return rows[0] || null;
}

async function postCount(uid) {
  const [rows] = await pool.query(
    `SELECT COUNT(*) AS n FROM tbl_post WHERE uid = :uid AND status != '3'`,
    { uid }
  );
  return Number(rows[0]?.n || 0);
}

async function touchCustomer(uid, subId) {
  const settings = await getSettings();
  await pool.query(
    `UPDATE tbl_customer SET sub_id = :subId, date_updated = NOW()
     WHERE id = :uid`,
    { subId, uid }
  );
  return settings;
}

async function nameTaken(uid, name) {
  const n = String(name || '').trim();
  if (!n) return false;
  const [rows] = await pool.query(
    `SELECT id FROM tbl_customer
     WHERE name = :name AND is_delete = '0' AND id != :uid
     LIMIT 1`,
    { name: n, uid }
  );
  return rows.length > 0;
}

async function activateFreePlan(uid) {
  const now = sqlDate();
  const existing = await latestSub(uid);
  if (existing && planKind(existing.product_id).isFree && isActiveRow(existing)) {
    return existing.id;
  }
  const [ins] = await pool.query(
    `INSERT INTO tbl_subscription
      (cust_id, device_type, product_id, purchase_token, subscription_data, transaction_id,
       status, expire_date, is_sub_active, date_added, date_updated, is_delete)
     VALUES
      (:uid, '3', 'basic_free_plan', '', '[]', '',
       '1', :now, '1', :now, :now, '0')`,
    { uid, now }
  );
  const settings = await getSettings();
  await pool.query(
    `UPDATE tbl_customer
     SET sub_id = :subId, post_limit = :postLimit, date_updated = NOW()
     WHERE id = :uid`,
    { subId: ins.insertId, postLimit: settings.post_limit || '35', uid }
  );
  return ins.insertId;
}

async function closePaidAndFallBackToFree(uid) {
  await pool.query(
    `UPDATE tbl_subscription
     SET status = '2', is_sub_active = '2', date_updated = NOW()
     WHERE cust_id = :uid AND is_delete = '0'`,
    { uid }
  );
  await pool.query(
    `DELETE FROM tbl_subscription
     WHERE cust_id = :uid AND product_id = 'basic_free_plan' AND status = '2'`,
    { uid }
  );
  const [cust] = await pool.query(
    `SELECT business_type FROM tbl_customer WHERE id = :uid LIMIT 1`,
    { uid }
  );
  if (cust[0] && String(cust[0].business_type) !== '2') {
    await pool.query(
      `UPDATE tbl_customer SET business_type = '2', date_updated = NOW() WHERE id = :uid`,
      { uid }
    );
  }
  return activateFreePlan(uid);
}

function emptyCheckPayload(now, nameMsg = '') {
  return {
    product_id: '',
    subscription_detail: '',
    subscription_status: 0,
    is_premium: 0,
    expire_date: '',
    current_date: now,
    is_post_limit: '0',
    popup_text: '',
    popup_text_title: '',
    popup_text_subtitle: '',
    is_name_exist: nameMsg,
  };
}

export async function handleCheckSubscription(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;

  const now = new Date();
  const nowSql = sqlDate(now);
  const nameMsg = (await nameTaken(auth.uid, p.name)) ? 'השם כבר קיים' : '';
  let row = await latestSub(auth.uid);

  if (!row) {
    return ok(emptyCheckPayload(nowSql, nameMsg), 'Success');
  }

  let subscribeStatus = isActiveRow(row, now) ? 1 : 0;
  if (!subscribeStatus) {
    await closePaidAndFallBackToFree(auth.uid);
    row = await latestSub(auth.uid);
    subscribeStatus = 1;
  }

  const kind = planKind(row?.product_id);
  let isPremium = kind.isPremium ? 1 : 0;
  let isPostLimit = '0';
  let popupText = '';
  let popupTitle = '';
  let popupSubtitle = '';

  if (String(p.is_add_post) === '1' && subscribeStatus === 1 && !kind.isPremium) {
    const [cust] = await pool.query(
      `SELECT post_limit FROM tbl_customer WHERE id = :uid LIMIT 1`,
      { uid: auth.uid }
    );
    const limit = Number(cust[0]?.post_limit || 0);
    const uploaded = await postCount(auth.uid);
    if (limit > 0 && uploaded >= limit) {
      isPostLimit = '1';
      popupText =
        'הגעת לכמות המירבית של תמונות שניתן להעלות. אנחנו על זה!\nניצור איתך קשר בקרוב (עד 3 ימי עסקים) ';
      popupTitle = 'הגעת למקסימום התמונות שאפשר להעלות';
      popupSubtitle =
        "שדרוג התוכנית יאפשר לך להעלות תמונות נוספות ללא הגבלה ועוד פיצ'רים נוספים";
    }
  }

  return ok(
    {
      product_id: row?.product_id || '',
      subscription_detail: subscribeStatus === 1 ? 'Subscription Activated' : 'Subscription Expired',
      subscription_status: subscribeStatus,
      is_premium: isPremium,
      expire_date: row?.expire_date ? sqlDate(row.expire_date) : '',
      current_date: nowSql,
      is_post_limit: isPostLimit,
      popup_text: popupText,
      popup_text_title: popupTitle,
      popup_text_subtitle: popupSubtitle,
      is_name_exist: nameMsg,
      package_name: '',
    },
    'Success'
  );
}

export async function handleFreePlan(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;
  await activateFreePlan(auth.uid);
  return ok({ is_premium: '0', is_sub_active: '1' }, 'Success');
}

async function upsertPaidSub({
  uid,
  productId,
  deviceType,
  purchaseToken = '',
  transactionId = '',
  subscriptionData = '',
  expireDate,
}) {
  const now = sqlDate();
  const latest = await latestSub(uid);
  const token = String(purchaseToken || '');
  const tx = String(transactionId || '');
  const data = typeof subscriptionData === 'string'
    ? subscriptionData
    : JSON.stringify(subscriptionData || {});

  if (latest && isActiveRow(latest)) {
    const sameProduct = String(latest.product_id) === String(productId);
    const sameTx =
      (tx && String(latest.transaction_id || '') === tx) ||
      (token && String(latest.purchase_token || '') === token);
    if (sameProduct && sameTx) {
      await touchCustomer(uid, latest.id);
      return { already: true, id: latest.id };
    }
    await pool.query(
      `UPDATE tbl_subscription SET
         product_id = :productId,
         device_type = :deviceType,
         purchase_token = :purchaseToken,
         subscription_data = :subscriptionData,
         transaction_id = :transactionId,
         status = '1',
         is_sub_active = '1',
         expire_date = :expireDate,
         date_updated = :now
       WHERE id = :id`,
      {
        productId,
        deviceType,
        purchaseToken: token,
        subscriptionData: data || '',
        transactionId: tx,
        expireDate,
        now,
        id: latest.id,
      }
    );
    await touchCustomer(uid, latest.id);
    return { updated: true, id: latest.id };
  }

  const [ins] = await pool.query(
    `INSERT INTO tbl_subscription
      (cust_id, device_type, product_id, purchase_token, subscription_data, transaction_id,
       status, expire_date, is_sub_active, date_added, date_updated, is_delete)
     VALUES
      (:uid, :deviceType, :productId, :purchaseToken, :subscriptionData, :transactionId,
       '1', :expireDate, '1', :now, :now, '0')`,
    {
      uid,
      deviceType,
      productId,
      purchaseToken: token,
      subscriptionData: data || '',
      transactionId: tx,
      expireDate,
      now,
    }
  );
  const settings = await getSettings();
  await pool.query(
    `UPDATE tbl_customer
     SET sub_id = :subId, post_limit = :postLimit, date_updated = NOW()
     WHERE id = :uid`,
    { subId: ins.insertId, postLimit: settings.post_limit || '35', uid }
  );
  return { inserted: true, id: ins.insertId };
}

export async function handleSuccessPurchaseIphone(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;

  let productId = String(p.productID || p.product_id || p.sku || '').trim();
  if (p.purchase_status === 'Restored' && productId === 'monthly_basic_plan') {
    productId = 'monthly_premium_plan';
  }
  if (!productId) return fail('Missing productID');

  const transactionId = String(
    p.original_transaction_id || p.purchaseID || p.transaction_id || ''
  );
  const expireDate = sqlDate(expireFromProduct(productId));
  const receipt = p.receipt_data || p.skPaymentTransaction || '';
  const subscriptionData =
    typeof receipt === 'string' && receipt.length > 4000
      ? JSON.stringify({
          productID: productId,
          purchaseID: p.purchaseID || '',
          purchase_status: p.purchase_status || '',
        })
      : typeof receipt === 'string'
        ? receipt
        : JSON.stringify(receipt || {});

  const result = await upsertPaidSub({
    uid: auth.uid,
    productId,
    deviceType: '2',
    purchaseToken: '',
    transactionId,
    subscriptionData,
    expireDate,
  });

  const kind = planKind(productId);
  return ok(
    {
      ...result,
      product_id: productId,
      is_premium: kind.isPremium ? '1' : '0',
      is_sub_active: '1',
      expire_date: expireDate,
    },
    result.already ? 'מנוי כבר מופעל' : 'Success'
  );
}

export async function handleAndroidSubscription(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;

  let sku = String(p.sku || p.productID || p.product_id || '').trim();
  if (p.purchase_status === 'Restored' && sku === 'monthly_basic_plan') {
    sku = 'monthly_premium_plan';
  }
  if (!sku) return fail('Missing sku');

  let expireDate = expireFromProduct(sku);
  try {
    const raw = p.originalJson ? JSON.parse(p.originalJson) : null;
    if (raw?.expiryTimeMillis) {
      expireDate = new Date(Number(raw.expiryTimeMillis));
    }
  } catch {
    // keep computed expiry
  }

  const result = await upsertPaidSub({
    uid: auth.uid,
    productId: sku,
    deviceType: '1',
    purchaseToken: p.purchaseToken || '',
    transactionId: '',
    subscriptionData: p.originalJson || '',
    expireDate: sqlDate(expireDate),
  });

  const kind = planKind(sku);
  return ok(
    {
      ...result,
      product_id: sku,
      is_premium: kind.isPremium ? '1' : '0',
      is_sub_active: '1',
    },
    result.already ? 'מנוי כבר מופעל' : 'Success'
  );
}

export async function handleGetSubscriptionPackageName(p) {
  const auth = await requireAuth(p);
  if (auth.error) return auth.error;
  const settings = await getSettings();
  return ok({ package_name: settings.package_name || '' }, 'Success');
}

function decodeAppleJws(token) {
  if (!token || typeof token !== 'string') return null;
  const parts = token.split('.');
  if (parts.length < 2) return null;
  try {
    const json = Buffer.from(
      parts[1].replace(/-/g, '+').replace(/_/g, '/'),
      'base64'
    ).toString('utf8');
    return JSON.parse(json);
  } catch {
    return null;
  }
}

function appleMsToSql(ms) {
  const n = Number(ms);
  if (!n) return sqlDate(new Date());
  return sqlDate(new Date(n));
}

export async function handleIosSubscriptionIpn(p) {
  const signedPayload = p.signedPayload || p.signed_payload;
  if (!signedPayload) {
    return ok({ received: '1' }, 'Success');
  }

  const notification = decodeAppleJws(signedPayload);
  const tx = decodeAppleJws(notification?.data?.signedTransactionInfo);
  if (!tx || !tx.originalTransactionId) {
    return ok({ received: '1', parsed: '0' }, 'Success');
  }

  let productId = String(tx.productId || '');
  if (tx.transactionReason === 'RENEWAL' && productId === 'monthly_basic_plan') {
    productId = 'monthly_premium_plan';
  }
  const originalId = String(tx.originalTransactionId);
  const expireDate = appleMsToSql(tx.expiresDate);
  const now = sqlDate();

  try {
    const [existingIpn] = await pool.query(
      `SELECT id FROM tbl_ios_subscription_ipn
       WHERE original_transaction_id = :originalId
       LIMIT 1`,
      { originalId }
    );
    const ipnRow = {
      signed_payload: String(signedPayload).slice(0, 65000),
      date_added: now,
      transcation_id: String(tx.transactionId || ''),
      original_transaction_id: originalId,
      web_order_line_item_id: String(tx.webOrderLineItemId || ''),
      bundle_id: String(tx.bundleId || ''),
      product_id: productId,
      subscription_group_identifier: String(tx.subscriptionGroupIdentifier || ''),
      purchase_date: appleMsToSql(tx.purchaseDate),
      original_purchase_date: appleMsToSql(tx.originalPurchaseDate),
      expires_date: expireDate,
      quantity: String(tx.quantity ?? '1'),
      type: String(tx.type || ''),
      inapp_ownership_type: String(tx.inAppOwnershipType || ''),
      signed_date: appleMsToSql(tx.signedDate),
      environment: String(tx.environment || ''),
      transaction_reason: String(tx.transactionReason || ''),
      store_front: String(tx.storefront || ''),
      store_front_id: String(tx.storefrontId || ''),
    };
    if (existingIpn[0]) {
      await pool.query(
        `UPDATE tbl_ios_subscription_ipn SET
           signed_payload = :signed_payload,
           transcation_id = :transcation_id,
           web_order_line_item_id = :web_order_line_item_id,
           product_id = :product_id,
           expires_date = :expires_date,
           purchase_date = :purchase_date,
           transaction_reason = :transaction_reason,
           environment = :environment,
           signed_date = :signed_date
         WHERE original_transaction_id = :original_transaction_id`,
        ipnRow
      );
    } else {
      await pool.query(
        `INSERT INTO tbl_ios_subscription_ipn
          (signed_payload, date_added, transcation_id, original_transaction_id,
           web_order_line_item_id, bundle_id, product_id, subscription_group_identifier,
           purchase_date, original_purchase_date, expires_date, quantity, type,
           inapp_ownership_type, signed_date, environment, transaction_reason,
           store_front, store_front_id)
         VALUES
          (:signed_payload, :date_added, :transcation_id, :original_transaction_id,
           :web_order_line_item_id, :bundle_id, :product_id, :subscription_group_identifier,
           :purchase_date, :original_purchase_date, :expires_date, :quantity, :type,
           :inapp_ownership_type, :signed_date, :environment, :transaction_reason,
           :store_front, :store_front_id)`,
        ipnRow
      );
    }
  } catch (e) {
    console.error('ios ipn log table', e?.message || e);
  }

  try {
    const [subs] = await pool.query(
      `SELECT id, cust_id FROM tbl_subscription
       WHERE is_delete = '0' AND transaction_id = :originalId
       ORDER BY id DESC LIMIT 1`,
      { originalId }
    );
    if (subs[0]) {
      const uid = subs[0].cust_id;
      await pool.query(
        `UPDATE tbl_subscription
         SET status = '2', is_sub_active = '2', date_updated = :now
         WHERE cust_id = :uid AND is_delete = '0'`,
        { uid, now }
      );
      await pool.query(
        `DELETE FROM tbl_subscription
         WHERE cust_id = :uid AND product_id = 'basic_free_plan' AND status = '2'`,
        { uid }
      );
      await pool.query(
        `UPDATE tbl_subscription SET
           subscription_data = :data,
           purchase_token = '',
           device_type = '2',
           product_id = :productId,
           status = '1',
           is_sub_active = '1',
           expire_date = :expireDate,
           date_updated = :now
         WHERE id = :id`,
        {
          data: JSON.stringify(tx),
          productId,
          expireDate,
          now,
          id: subs[0].id,
        }
      );
      await pool.query(
        `UPDATE tbl_subscription
         SET status = '1', is_sub_active = '1'
         WHERE id = :id`,
        { id: subs[0].id }
      );
      await touchCustomer(uid, subs[0].id);
    }
  } catch (e) {
    console.error('ios ipn subscription update', e?.message || e);
  }

  return ok({ received: '1', original_id: originalId }, 'Success');
}

export async function handleSubscriptionIpn(p) {
  return ok({ received: '1' }, 'Success');
}
