import path from 'node:path';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import express from 'express';
import { createSources } from './sources.js';
import { loadFinanceRows, readCosts, summarizeFinance, writeCosts } from './finance.js';
import { buildSpec } from './spec.js';
import { createAdminRouter } from './admin.js';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const ADMIN_DIR = path.join(ROOT, 'php-admin');
const PORT = Number(process.env.EXPLORER_PORT) || 4173;
const HOST = process.env.HOST || '127.0.0.1';
const ADMIN_PORT = Number(process.env.ADMIN_PORT) || 8080;
const ADMIN_URL = `http://${HOST}:${ADMIN_PORT}/admin/`;
const COSTS_PATH = path.join(ROOT, 'data', 'operating-costs.json');
let adminChild = null;

const sources = createSources();

const app = express();
app.disable('x-powered-by');
app.use(express.json({ limit: '200kb' }));
app.use(express.static(path.join(ROOT, 'public')));

function pickSource(req) {
  return sources.sourceOf(req.query.source === 'live' ? 'live' : 'museum');
}

async function adminReachable() {
  try {
    const res = await fetch(ADMIN_URL, { redirect: 'manual', signal: AbortSignal.timeout(4000) });
    return res.status < 500;
  } catch {
    return false;
  }
}

async function ensureAdmin() {
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
    let used = sourceId;
    try {
      const source = sources.sourceOf(sourceId);
      const rows = await loadFinanceRows(source);
      const costs = readCosts(COSTS_PATH);
      res.json({ source: used, liveConfigured: sources.liveConfigured, ...summarizeFinance({ ...rows, costs }) });
    } catch (err) {
      if (sourceId === 'live') {
        used = 'museum';
        const rows = await loadFinanceRows(sources.sourceOf('museum'));
        const costs = readCosts(COSTS_PATH);
        res.json({
          source: used,
          liveConfigured: sources.liveConfigured,
          fallbackReason: err.message,
          ...summarizeFinance({ ...rows, costs }),
        });
        return;
      }
      throw err;
    }
  } catch (err) {
    next(err);
  }
});

app.get('/api/spec', async (req, res, next) => {
  try {
    let sourceId = req.query.source === 'museum' ? 'museum' : 'live';
    try {
      const source = sources.sourceOf(sourceId);
      res.json(await buildSpec({ source, costsPath: COSTS_PATH, liveConfigured: sources.liveConfigured }));
    } catch (err) {
      if (sourceId === 'live') {
        const source = sources.sourceOf('museum');
        res.json({
          fallbackReason: err.message,
          ...(await buildSpec({ source, costsPath: COSTS_PATH, liveConfigured: sources.liveConfigured })),
        });
        return;
      }
      throw err;
    }
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

app.listen(PORT, HOST, async () => {
  const adminUp = await ensureAdmin();
  console.log(`INK Studio → http://${HOST}:${PORT}`);
  console.log(adminUp ? 'ניהול tab is ready' : 'ניהול tab: PHP admin did not start');
  console.log(sources.liveConfigured ? 'Live Railway source enabled' : 'Live Railway source not configured');
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
