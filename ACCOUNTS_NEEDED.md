# Cloud setup status

## Folder map
- `app/client` — Flutter
- `app/api` — Node API (Railway)
- `data` — SQL dumps (old + current)
- `assets` — old uploaded files
- `studio` — INK Studio (ניהול + טבלאות + כספים)
- `studio/php-admin` — ממשק PHP ישן, נשאר כגיבוי תחת Studio → ניהול → ממשק PHP ישן
- ניהול חדש רץ ב-Node מתוך Studio (משתמשים, דיווחים, בקשות, הגדרות)

## Done
- Railway MySQL + API live
- Cloudflare R2 bucket `ink-media` live
- 944 objects uploaded (firebase + styles)
- Post image URLs rewritten to R2

## Public bases
- API: https://ink-api-production-2e1d.up.railway.app
- Docs: https://ink-api-production-2e1d.up.railway.app/docs
- R2: https://pub-feef9d9f566147738bf9ecf90eb22fbd.r2.dev

## Flutter client
- Folder: `app/client/`
- `WebService.developerMode = true` → skips OTP, auto-login `0544466912`, opens Home
- Images load from R2; API gateway actions live under `POST /api/`
- While Railway redeploy is pending, develop mode can use local Node: `http://10.0.2.2:3000/api/` (`useLocalNewApiInDev`)

## Security
Rotate Railway + Cloudflare tokens that were shared in chat.
