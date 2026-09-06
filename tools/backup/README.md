# Backup & migrate Ink off the old architecture

## What we saved
- Full MySQL dump: `inkisrael_Database/inkisrael_app.sql` (imported locally as `inkisrael_app`)
- Style assets: `backups/smartweb/assets/`
- Firebase images: exporting now into `backups/firebase/` (keep this folder safe)

## New architecture (easy + cheap)
| Piece | Service | Why |
|-------|---------|-----|
| API | Node/Express in `backend/` | Simple for Flutter team, replaces PHP |
| Database | Railway MySQL | Same SQL dump, cheap managed MySQL |
| Images | Cloudflare R2 | Cheap object storage, no egress fees |

Old PHP under `api/inkapp-api-admin` is **legacy only** — use it to recover data, not for new production.

## Your next 15 minutes (accounts)
1. **Cloudflare** → R2 → create bucket `ink-media` → enable public access → copy public base URL  
2. Create R2 API token (Object Read & Write) → put into `backend/.env` (`R2_*`)  
3. Run: `node tools/backup/upload_to_r2.mjs`  
4. **Railway** → New project → MySQL → import `inkisrael_app.sql` → put DB_* into `backend/.env`  
5. Deploy `backend/` on Railway  

## Local verify
- New API: http://127.0.0.1:3000/health  
- Posts already return live Firebase image URLs from the imported DB  
