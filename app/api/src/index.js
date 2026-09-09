import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import multer from 'multer';
import { ping } from './db.js';
import { healthRouter } from './routes/health.js';
import { stylesRouter } from './routes/styles.js';
import { postsRouter } from './routes/posts.js';
import { usersRouter } from './routes/users.js';
import { settingsRouter } from './routes/settings.js';
import { docsRouter } from './routes/docs.js';
import { legalRouter } from './routes/legal.js';
import { handleLegacyAction } from './legacy/gateway.js';

const app = express();
const port = Number(process.env.PORT || 3000);
const formData = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 12 * 1024 * 1024 },
}).any();

app.use(cors({ origin: process.env.CORS_ORIGIN || true }));
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

app.get('/', (_req, res) => {
  res.type('html').send(`<!doctype html><html><body style="font-family:system-ui;padding:2rem;max-width:40rem">
  <h1>Ink API (new)</h1>
  <p>New architecture: Node + MySQL + Cloudflare R2. Legacy PHP is not used for production.</p>
  <ul>
    <li><a href="/docs"><strong>Swagger docs</strong></a></li>
    <li><a href="/openapi.json">openapi.json</a></li>
    <li><a href="/privacy"><strong>מדיניות פרטיות</strong></a></li>
    <li><a href="/terms"><strong>תנאי שימוש</strong></a></li>
    <li><a href="/health">/health</a></li>
    <li><a href="/v1/styles">/v1/styles</a></li>
    <li><a href="/v1/posts?limit=10">/v1/posts</a></li>
    <li><a href="/v1/settings">/v1/settings</a></li>
    <li>Flutter gateway: <code>POST /api/</code> (action=Login, GetHomeData, …)</li>
  </ul>
  </body></html>`);
});

app.use(docsRouter);
app.use(legalRouter);
app.use(healthRouter);
app.use('/v1/styles', stylesRouter);
app.use('/v1/posts', postsRouter);
app.use('/v1/users', usersRouter);
app.use('/v1/settings', settingsRouter);

// Flutter PHP-compatible action gateway (trailing slash required by client baseUrl)
const legacyHandler = async (req, res) => {
  const payload = await handleLegacyAction(req);
  return res.json(payload);
};
app.all(['/api', '/api/'], formData, legacyHandler);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ status: 0, msg: 'Server error', data: [] });
});

const server = app.listen(port, async () => {
  const dbOk = await ping();
  console.log(`Ink API listening on http://127.0.0.1:${port}`);
  console.log(`Swagger UI: http://127.0.0.1:${port}/docs`);
  console.log(`DB ping: ${dbOk ? 'ok' : 'FAILED'}`);
  console.log(`R2 public base: ${process.env.R2_PUBLIC_BASE || '(not set — using Firebase/original URLs)'}`);
});

server.on('error', (err) => {
  console.error(err);
  process.exit(1);
});
