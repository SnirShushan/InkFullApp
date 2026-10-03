# New Ink backend (Node + Railway MySQL + Cloudflare R2)

## Why this exists
The old PHP API + dead `inkisrael.co.il` host is being replaced with:
- **MySQL data** on Railway (imported from `data/inkisrael_app.sql`)
- **Images** on Cloudflare R2 (backed up from Firebase Storage + smartweb assets)
- **API** as a small Node/Express service in this folder

## Local (already set up)
1. Docker MySQL has database `inkisrael_app` imported from the dump.
2. Copy env: `cp .env.example .env`
3. `npm install && npm run dev`
4. Open http://127.0.0.1:3000/docs (Swagger) or http://127.0.0.1:3000/health

## Backup images (do this before anything dies)
```bash
cd ../tools/backup
npm install
node export_firebase_storage.mjs
php ../backup/mirror_smartweb_assets.php   # or from repo root: php tools/backup/mirror_smartweb_assets.php
```

## Upload backups to Cloudflare R2
1. Create R2 bucket `ink-media` and a public URL.
2. Create R2 API token (Object Read & Write).
3. Fill `R2_*` in `app/api/.env`.
4. `node tools/backup/upload_to_r2.mjs`

## Daily Telegram report (Railway cron)

A second Railway service, from this same folder, runs `src/jobs/daily-telegram-report.js` and sends a Hebrew PDF of the previous Israel calendar day: signups, logins, active users, screens, actions, posts, tattoo requests, follows, subscriptions, errors, devices, and app versions, plus five improvement ideas chosen from that day's numbers. Each figure is compared with the day before.

Railway cron is UTC. The schedule `0 3,4 * * *` fires at both 03:00 and 04:00 UTC. The script sends only when the clock in `Asia/Jerusalem` is 06:00, so daylight saving does not move the report.

1. In the API project, add a service from this repo with root directory `app/api`.
2. Set the config file path to `railway.cron.json`.
3. Copy the API database variables (`DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASS`, `DB_NAME`) onto the cron service.
4. Add `TELEGRAM_BOT_TOKEN` and `TELEGRAM_CHAT_ID`. Separate several recipients with commas, for example `1322344263,911222055`. Each person must open the bot once and tap Start, otherwise Telegram rejects that chat.
5. Deploy. To send a report immediately, run the service with `FORCE_REPORT=1` or locally: `FORCE_REPORT=1 npm run report:daily`.

## Railway MySQL
1. New Railway project → Add MySQL.
2. Import `data/inkisrael_app.sql` (Railway UI or `mysql < dump.sql`).
3. Put Railway DB credentials into `app/api/.env`.
4. Deploy this `app/api/` service on Railway.

## Flutter
Point the client at the Railway host:

- `baseUrl` = `https://ink-api-production-2e1d.up.railway.app/api/`
- `baseAssets` = `https://pub-feef9d9f566147738bf9ecf90eb22fbd.r2.dev/assets/`

The Node service exposes a PHP-compatible gateway at `POST /api/` for Flutter actions
(`Login`, `GetHomeData`, `GetHomePostsNew`, `GetPostsNew`, `StartupImage`, …).

Develop mode in the Flutter app (`WebService.developerMode = true`) auto-logs in as
`0544466912` and opens Home without OTP.
