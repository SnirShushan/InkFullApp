/**
 * Activate all business users with a complimentary long-term plan.
 * Does not create App Store / Play purchases — admin grant only.
 *
 *   node tools/backup/activate_business_users_comp.mjs
 */
import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.join(__dirname, '../../app/api/.env') });

const PRODUCT_ID = 'yearly_premium_plan';
const EXPIRE = '2099-12-31 23:59:59';
const POST_LIMIT = 999;

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  waitForConnections: true,
});

const [users] = await pool.query(
  `SELECT id, name, status, user_type, is_business, sub_id, post_limit
   FROM tbl_customer
   WHERE is_delete = '0' AND (user_type = '2' OR is_business = '1')
   ORDER BY id`
);

console.log(`Business users: ${users.length}`);

let inserted = 0;
let updated = 0;
let approved = 0;

for (const u of users) {
  const [subs] = await pool.query(
    `SELECT id FROM tbl_subscription
     WHERE cust_id = ? AND is_delete = '0'
     ORDER BY id DESC LIMIT 1`,
    [u.id]
  );

  await pool.query(
    `UPDATE tbl_subscription
     SET status = '2', is_sub_active = '2', date_updated = NOW()
     WHERE cust_id = ? AND is_delete = '0'`,
    [u.id]
  );

  let subId;
  if (subs.length) {
    subId = subs[0].id;
    await pool.query(
      `UPDATE tbl_subscription SET
         product_id = ?,
         purchase_token = 'admin_comp',
         subscription_data = ?,
         transaction_id = 'admin_comp',
         status = '1',
         is_sub_active = '1',
         expire_date = ?,
         date_updated = NOW(),
         is_delete = '0'
       WHERE id = ?`,
      [
        PRODUCT_ID,
        JSON.stringify({ source: 'admin_comp', productId: PRODUCT_ID }),
        EXPIRE,
        subId,
      ]
    );
    updated++;
  } else {
    const [ins] = await pool.query(
      `INSERT INTO tbl_subscription
        (cust_id, device_type, product_id, purchase_token, subscription_data,
         transaction_id, status, expire_date, is_sub_active, date_added, date_updated, is_delete)
       VALUES (?, '3', ?, 'admin_comp', ?, 'admin_comp', '1', ?, '1', NOW(), NOW(), '0')`,
      [
        u.id,
        PRODUCT_ID,
        JSON.stringify({ source: 'admin_comp', productId: PRODUCT_ID }),
        EXPIRE,
      ]
    );
    subId = ins.insertId;
    inserted++;
  }

  const [res] = await pool.query(
    `UPDATE tbl_customer SET
       status = '1',
       user_type = '2',
       is_business = '1',
       sub_id = ?,
       post_limit = ?,
       date_updated = NOW()
     WHERE id = ?`,
    [subId, POST_LIMIT, u.id]
  );
  if (String(u.status) !== '1') approved++;
}

const [[active]] = await pool.query(
  `SELECT COUNT(*) AS n
   FROM tbl_customer c
   JOIN tbl_subscription s ON s.id = c.sub_id
   WHERE c.is_delete = '0' AND c.user_type = '2'
     AND c.status = '1'
     AND s.status = '1' AND s.is_sub_active = '1'
     AND s.expire_date > NOW()`
);

console.log(`approved (were not status 1): ${approved}`);
console.log(`subscriptions updated: ${updated}`);
console.log(`subscriptions inserted: ${inserted}`);
console.log(`now active with live plan: ${active.n}`);

await pool.end();
