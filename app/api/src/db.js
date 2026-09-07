import mysql from 'mysql2/promise';

export const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || 'user',
  password: process.env.DB_PASS || 'password',
  database: process.env.DB_NAME || 'inkisrael_app',
  waitForConnections: true,
  connectionLimit: 10,
  namedPlaceholders: true,
  charset: 'utf8mb4',
});

export async function ping() {
  try {
    const [rows] = await pool.query('SELECT 1 AS ok');
    return rows?.[0]?.ok === 1;
  } catch (e) {
    console.error('DB ping failed:', e.message);
    return false;
  }
}
