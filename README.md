# InkFullApp

Full Ink stack in one repo:

| Folder | What |
|--------|------|
| `client/` | Flutter mobile app (iOS/Android) |
| `backend/` | Node/Express API (Railway) |
| `admin/` | PHP admin panel + legacy API |
| `tools/` | Backup / R2 restore scripts |

## Codemagic iOS
Workflow `ios-testflight` builds `client/` and publishes to TestFlight.
