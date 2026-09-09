import path from 'node:path';
import { spawn } from 'node:child_process';
import { timingSafeEqual } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import express from 'express';
import { createSources } from './sources.js';
import { loadFinanceRows, readCosts, summarizeFinance, writeCosts } from './finance.js';
import { buildSpec } from './spec.js';
import { createAdminRouter } from './admin.js';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const ADMIN_DIR = path.join(ROOT, 'php-admin');
const ON_RAILWAY = Boolean(process.env.RAILWAY_ENVIRONMENT || process.env.RAILWAY_PUBLIC_DOMAIN);
const IS_PROD = process.env.NODE_ENV === 'production' || ON_RAILWAY;
const PORT = Number(process.env.PORT || process.env.EXPLORER_PORT || 4173);
const HOST = process.env.HOST || (IS_PROD ? '0.0.0.0' : '127.0.0.1');
const ADMIN_PORT = Number(process.env.ADMIN_PORT || 8080);
const ADMIN_URL = `http://${HOST}:${ADMIN_PORT}/admin/`;
const COSTS_PATH = path.join(ROOT, 'data', 'operating-costs.json');
let adminChild = null;

const sources = await createSources();

const app = express();
app.disable('x-powered-by');
app.set('trust proxy', 1);
app.use(express.json({ limit: '200kb' }));

function safeEqual(a, b) {
  const left = Buffer.from(String(a));
  const right = Buffer.from(String(b));
  if (left.length !== right.length) return false;
  return timingSafeEqual(left, right);
}

function requireStudioAuth(req, res, next) {
  if (req.path === '/health') return next();
  const user = process.env.STUDIO_USER || 'admin';
  const pass = process.env.STUDIO_PASSWORD || '';
  if (!pass) {
    if (IS_PROD) {
      res.status(503).type('text').send('STUDIO_PASSWORD is not set');
      return;
    }
    return next();
  }
  const header = String(req.headers.authorization || '');
  if (!header.startsWith('Basic ')) {
    res.set('WWW-Authenticate', 'Basic realm="INK Studio"');
    res.status(401).type('text').send('Authentication required');
    return;
  }
  const decoded = Buffer.from(header.slice(6), 'base64').toString('utf8');
  const sep = decoded.indexOf(':');
  const givenUser = sep === -1 ? decoded : decoded.slice(0, sep);
  const givenPass = sep === -1 ? '' : decoded.slice(sep + 1);
  if (!safeEqual(givenUser, user) || !safeEqual(givenPass, pass)) {
    res.set('WWW-Authenticate', 'Basic realm="INK Studio"');
    res.status(401).type('text').send('Authentication required');
    return;
  }
  next();
}

app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    liveConfigured: sources.liveConfigured,
    museumAvailable: sources.museumAvailable,
  });
});

app.use(requireStudioAuth);
app.use(express.static(path.join(ROOT, 'public')));

function pickSource(req) {
  if (req.query.source === 'museum') return sources.sourceOf('museum');
  if (req.query.source === 'live') return sources.sourceOf('live');
  return sources.sourceOf(sources.liveConfigured ? 'live' : 'museum');
}

async function adminReachable() {
  if (IS_PROD) return false;
  try {
    const res = await fetch(ADMIN_URL, { redirect: 'manual', signal: AbortSignal.timeout(4000) });
    return res.status < 500;
  } catch {
    return false;
  }
}

async function ensureAdmin() {
  if (IS_PROD) return false;
  if (await adminReachable()) return true;
  console.log('Starting the PHP admin for the Studio ניהול tab…');
  adminChild = spawn('php', ['-S', `${HOST}:${ADMIN_PORT}`, 'router.php'], {
    cwd: ADMIN_DIR,
    stdio: 'ignore',
    windowsHide: true,
  });
  adminChild.on('error', (err) => {
    console.error('Could not start PHP admin:', err.message);
  });
  for (let i = 0; i < 20; i++) {
    await new Promise((r) => setTimeout(r, 400));
    if (await adminReachable()) return true;
  }
  return false;
}

app.use('/api/admin', createAdminRouter(() => sources.getLivePool()));

app.get('/api/studio', async (_req, res) => {
  res.json({
    adminUrl: ADMIN_URL,
    adminUp: await adminReachable(),
    liveConfigured: sources.liveConfigured,
    museumAvailable: sources.museumAvailable,
    nativeAdmin: true,
  });
});

app.get('/api/overview', async (req, res, next) => {
  try {
    const data = await sources.overviewFor(pickSource(req));
    res.json(data);
  } catch (err) {
    next(err);
  }
});

app.get('/api/compare', async (_req, res, next) => {
  try {
    res.json(await sources.compare());
  } catch (err) {
    next(err);
  }
});

app.get('/api/tables/:name', async (req, res, next) => {
  try {
    const data = await sources.queryTable(pickSource(req), req.params.name, req.query);
    res.json(data);
  } catch (err) {
    next(err);
  }
});

app.get('/api/finance', async (req, res, next) => {
  try {
    let sourceId = req.query.source === 'museum' ? 'museum' : 'live';
    if (sourceId === 'museum' && !sources.museumAvailable) sourceId = 'live';
    if (sourceId === 'live' && !sources.liveConfigured && sources.museumAvailable) sourceId = 'museum';
    const source = sources.sourceOf(sourceId);
    const rows = await loadFinanceRows(source);
    const costs = readCosts(COSTS_PATH);
    res.json({ source: sourceId, liveConfigured: sources.liveConfigured, ...summarizeFinance({ ...rows, costs }) });
  } catch (err) {
    next(err);
  }
});

app.get('/api/spec', async (req, res, next) => {
  try {
    let sourceId = req.query.source === 'museum' ? 'museum' : 'live';
    if (sourceId === 'museum' && !sources.museumAvailable) sourceId = 'live';
    if (sourceId === 'live' && !sources.liveConfigured && sources.museumAvailable) sourceId = 'museum';
    const source = sources.sourceOf(sourceId);
    res.json(await buildSpec({ source, costsPath: COSTS_PATH, liveConfigured: sources.liveConfigured }));
  } catch (err) {
    next(err);
  }
});

app.get('/api/finance/costs', (_req, res) => {
  res.json(readCosts(COSTS_PATH));
});

app.put('/api/finance/costs', (req, res, next) => {
  try {
    res.json(writeCosts(COSTS_PATH, req.body || {}));
  } catch (err) {
    next(err);
  }
});

app.use((err, _req, res, _next) => {
  res.status(err.status || 500).json({ error: err.message || 'Server error' });
});

const server = app.listen(PORT, HOST, async () => {
  if (!IS_PROD) await ensureAdmin();
  console.log(`INK Studio → http://${HOST}:${PORT}`);
  console.log(sources.liveConfigured ? 'Live Railway source enabled' : 'Live Railway source not configured');
  console.log(sources.museumAvailable ? 'Museum archive enabled' : 'Museum archive skipped');
});

server.on('error', (err) => {
  console.error(err);
  process.exit(1);
});

function stopAdmin() {
  if (adminChild && !adminChild.killed) adminChild.kill();
}
process.on('exit', stopAdmin);
process.on('SIGINT', () => {
  stopAdmin();
  process.exit(0);
});
process.on('SIGTERM', () => {
  stopAdmin();
  process.exit(0);
});
