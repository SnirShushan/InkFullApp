# InkFullApp

Canonical repo for the full Ink stack. Do not split this project across other remotes.

| Folder | What |
|--------|------|
| `app/client/` | Flutter mobile app (iOS/Android) |
| `app/api/` | Node/Express API (Railway + Cloudflare R2) |
| `studio/` | INK Studio — admin, tables, finance |
| `studio/php-admin/` | Legacy PHP admin (backup UI inside Studio) |
| `tools/backup/` | Backup / R2 restore scripts |

## Run locally

```bash
# API
cd app/api
cp .env.example .env
npm install && npm run dev

# Studio
cd studio
npm install && npm start
```

- API docs: http://127.0.0.1:3000/docs
- Studio: http://127.0.0.1:4173

## Codemagic iOS

Workflow `ios-testflight` builds `app/client/` and publishes to TestFlight.
