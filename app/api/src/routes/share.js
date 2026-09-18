import { Router } from 'express';

export const shareRouter = Router();

const IOS_APP_ID = '6447420384';
const IOS_BUNDLE = 'com.itapp2u.inkapp.ios';
const IOS_TEAM = 'D6F46ZX5U6';
const ANDROID_PACKAGE = 'com.itapp2u.ink';

function storeLinks() {
  return {
    ios: `https://apps.apple.com/app/id${IOS_APP_ID}`,
    android: `https://play.google.com/store/apps/details?id=${ANDROID_PACKAGE}`,
  };
}

function shareHtml({ action, pid }) {
  const stores = storeLinks();
  const appUri = `inkapp://share?action=${encodeURIComponent(action)}&pid=${encodeURIComponent(pid)}`;
  const title =
    action === 'mainprofile' ||
    action === 'businessUserProfile' ||
    action === 'businessStudioProfile'
      ? 'פרופיל באינק'
      : 'פוסט באינק';
  return `<!doctype html>
<html lang="he" dir="rtl">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>${title}</title>
  <style>
    body { font-family: "Segoe UI", Arial, sans-serif; margin: 0; background: #16121a; color: #fff;
      min-height: 100vh; display: flex; align-items: center; justify-content: center; text-align: center; }
    .card { padding: 2rem 1.4rem; max-width: 22rem; }
    a { display: inline-block; margin: .4rem .2rem 0; padding: .7rem 1.1rem; border-radius: 999px;
      background: #e8c39a; color: #16121a; text-decoration: none; font-weight: 700; }
    .muted { color: #b9b3ad; font-size: .95rem; }
  </style>
</head>
<body>
  <div class="card">
    <h1>${title}</h1>
    <p class="muted">פותחים את האפליקציה… אם היא לא מותקנת, הורידו מ־App Store או Google Play.</p>
    <p>
      <a href="${appUri}">פתח באינק</a>
      <a href="${stores.ios}">App Store</a>
      <a href="${stores.android}">Google Play</a>
    </p>
  </div>
  <script>
    setTimeout(function () { window.location = ${JSON.stringify(appUri)}; }, 80);
  </script>
</body>
</html>`;
}

shareRouter.get(['/.well-known/apple-app-site-association', '/apple-app-site-association'], (_req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.json({
    applinks: {
      apps: [],
      details: [
        {
          appID: `${IOS_TEAM}.${IOS_BUNDLE}`,
          paths: ['/share', '/share/*'],
        },
      ],
    },
  });
});

shareRouter.get('/.well-known/assetlinks.json', (_req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.json([
    {
      relation: ['delegate_permission/common.handle_all_urls'],
      target: {
        namespace: 'android_app',
        package_name: ANDROID_PACKAGE,
      },
    },
  ]);
});

shareRouter.get(['/share', '/share/'], (req, res) => {
  const action = String(req.query.action || 'POST').trim() || 'POST';
  const pid = String(req.query.pid || '').trim();
  res.type('html').send(shareHtml({ action, pid }));
});
