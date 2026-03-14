# EmuVault

A self-hosted save file manager for emulators. Upload a save from one device, download it to another with the filename and extension automatically adjusted for the target emulator — no manual renaming required.

Designed to run on your own PC or home server and be accessed from any device via browser. Works great as a PWA on iPhone.

---

## Features

- **Save sync** — upload a save file from any device, download it to any other
- **Automatic filename handling** — configure per-game filenames per emulator; downloads are renamed to match what each emulator expects (e.g. `Pokemon - Emerald Version.srm` for RetroArch, `Pokemon_Emerald.sav` for Delta)
- **Save history** — every upload is versioned; previous saves are kept and can be re-downloaded
- **Save path hints** — shows the exact path to place the downloaded file based on your emulator's configured save directory
- **Multi-emulator support** — ships with profiles for RetroArch, Delta, mGBA, Dolphin, PPSSPP, melonDS, Snes9x, OpenEmu, DuckStation and more (28 profiles across Linux, Windows, macOS, iOS, Android)
- **Activity log** — every upload and download is recorded with timestamp, device type (inferred from user agent), and IP address
- **First-run setup wizard** — guided 3-step flow: account setup → choose your emulators → configure save directories
- **Notifications** — in-app notification panel with live badge updates; web push to iPhone (when installed as a home screen app) via the Web Push API
- **Mobile-first UI** — works on iPhone with safe-area insets, installable as a home screen app (PWA)
- **Single-user** — self-hosted, no accounts or cloud services

## Supported emulators (built-in profiles)

| Emulator | Platforms | Extension |
|---|---|---|
| RetroArch | Linux, Windows, macOS | `.srm` |
| Delta | iOS | `.sav` |
| mGBA | Linux, Windows, macOS, iOS, Android | `.sav` |
| Dolphin | Linux, Windows, macOS | `.gci` |
| PPSSPP | Linux, Windows, macOS, iOS, Android | `.bin` |
| melonDS | Linux, Windows, macOS | `.sav` |
| Snes9x | Linux, Windows, macOS | `.srm` |
| OpenEmu | macOS | `.sav` |
| DuckStation | Linux, Windows, macOS | `.mcr` |

---

## Requirements

- Docker and Docker Compose

That's it. Everything else runs in containers.

## Quick start

```bash
git clone <repo-url> emu-vault
cd emu-vault
./scripts/install.sh
docker compose up
```

`install.sh` handles first-time setup: generates a `.env` file with secure random credentials, generates VAPID keys for push notifications, builds containers, creates the database, runs migrations, and seeds emulator profiles.

The app runs at **http://localhost:3000**.

On subsequent runs, just:

```bash
docker compose up
```

## Accessing from other devices

The app binds to `0.0.0.0:3000`, so it's reachable from any device on your local network at `http://<your-machine-ip>:3000`.

For remote access (e.g. from your phone when away from home), a reverse proxy or [Tailscale](https://tailscale.com) works well.

## Deploying to a NAS or home server

EmuVault is available as a Docker image on Docker Hub: `rturner1989/emuvault`

This is the recommended way to run EmuVault in production — pull the pre-built image and deploy it alongside PostgreSQL and Redis using the provided compose file.

### 1. Generate secrets

```bash
# Generate a SECRET_KEY_BASE
docker run --rm rturner1989/emuvault:latest bundle exec rails secret

# Generate VAPID keys for push notifications
docker run --rm rturner1989/emuvault:latest bundle exec rails runner "puts WebPush.generate_key.to_hash"
```

### 2. Create persistent directories

Create directories on your NAS for data persistence:

```
/path/to/emuvault/postgres   # database
/path/to/emuvault/redis      # job queue
/path/to/emuvault/storage    # save files
```

### 3. Deploy with Docker Compose

Copy `docker-compose.prod.yml` from this repo and replace the placeholder values:

- `YOUR_SECRET_KEY_BASE` — from step 1
- `YOUR_DB_PASSWORD` — choose a strong password
- `YOUR_EMAIL` / `YOUR_PASSWORD` — your login credentials
- `YOUR_VAPID_PUBLIC_KEY` / `YOUR_VAPID_PRIVATE_KEY` — from step 1
- `/path/to/...` — your persistent directory paths from step 2

Then start it:

```bash
docker compose -f docker-compose.prod.yml up -d
```

The app will create the database, run migrations, seed emulator profiles, and start. Access it at `http://<server-ip>:3000`.

### TrueNAS Scale

1. Go to **Apps > Discover Apps > Custom App**
2. Name: `emuvault`
3. Paste the contents of `docker-compose.prod.yml` with your values filled in
4. Save and deploy

### SSL

SSL is off by default. If you access EmuVault over [Tailscale](https://tailscale.com), traffic is already encrypted end-to-end — no reverse proxy needed.

To enable SSL (e.g. behind nginx or Caddy), add `FORCE_SSL: "true"` to the app and sidekiq environment variables.

### Updating

New versions are published to Docker Hub with a version tag (e.g. `rturner1989/emuvault:1.2.0`) and as `:latest`.

**Docker Compose:**
```bash
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

**TrueNAS Scale:** Stop the app, then Start — TrueNAS re-pulls `:latest` automatically on start.

The app runs `rails db:prepare` on startup so any pending migrations are applied automatically.

---

## Installing as a home screen app (iPhone)

1. Open the app in Safari
2. Tap the Share button → **Add to Home Screen**
3. The app launches full-screen with proper safe-area handling

## Push notifications

EmuVault sends a notification whenever a save is uploaded. Notifications appear in the bell icon panel in the nav. If you've installed EmuVault as a home screen app on iPhone (iOS 16.4+), you can also receive native push notifications.

To enable push notifications on a device:

1. Open **Settings** in EmuVault
2. Tap **Enable push notifications** and grant permission when prompted

VAPID keys are generated automatically during `install.sh`. If you need to regenerate them:

```bash
./scripts/generate_vapid_keys
```

Copy the output into your `.env`, then restart:

```bash
docker compose restart app sidekiq
```

## Monitoring

EmuVault includes built-in admin dashboards. All are protected by HTTP Basic Auth using your `ADMIN_EMAIL` / `ADMIN_PASSWORD` credentials.

| Dashboard | URL | Description |
|---|---|---|
| **PgHero** | `/pghero` | Database performance — slow queries, index usage, table sizes |
| **Sidekiq** | `/sidekiq` | Background job queues, failures, and throughput |

### Uptime monitoring with Uptime Kuma

[Uptime Kuma](https://github.com/louislam/uptime-kuma) is recommended for uptime monitoring. Run it as a separate app on your server (not bundled with EmuVault, so it keeps watching even if EmuVault has an issue).

```bash
docker run -d --restart=unless-stopped -p 3001:3001 \
  -v /path/to/uptime-kuma:/app/data \
  --name uptime-kuma louislam/uptime-kuma:1
```

Then add a monitor in Uptime Kuma pointing at `http://<server-ip>:3000/up`. No Docker socket access is required.

## Configuration

All configuration is via environment variables. Key variables:

| Variable | Description | Default |
|---|---|---|
| `ADMIN_EMAIL` | Login email | — |
| `ADMIN_PASSWORD` | Login password | — |
| `DB_HOST` | PostgreSQL host | `postgres` |
| `DB_USERNAME` | PostgreSQL username | — |
| `DB_PASSWORD` | PostgreSQL password | — |
| `DB_NAME` | Database name | — |
| `REDIS_URL` | Redis URL | `redis://redis:6379/0` |
| `VAPID_PUBLIC_KEY` | Web push public key | — |
| `VAPID_PRIVATE_KEY` | Web push private key | — |
| `ACTIVITY_RETENTION_DAYS` | Days to retain activity log entries | `90` |
| `FORCE_SSL` | Enable SSL redirect | `false` |

See `.env.example` for the full list.

## First-run setup wizard

On first login you'll be walked through:

1. **Account** — set your email and password
2. **Emulators** — pick which emulators you use from the built-in library
3. **Save paths** — configure where each emulator stores saves on your system (used for download path hints)

After completing setup you'll be taken to your games library.

## Usage

### Adding a game

From the Games page, click **Add Game** and enter the title and system.

### Uploading a save

On a game's page, use the **Upload** form. Optionally select which emulator the save came from (used for display and as a source hint). The file is stored as-is; the checksum is recorded for reference.

### Configuring emulator filenames

On a game's page, the **Emulator Save Filenames** section lets you set the exact filename (without extension) each emulator uses for this game's save file. This is usually the ROM filename without extension (e.g. `Pokemon - Emerald Version` for RetroArch).

If left blank, the app generates a filename from the game title.

### Downloading a save

On the game's page, select the emulator you're downloading for from the dropdown. The file will be downloaded with the correct name and extension. If you've configured a save directory for that emulator, the exact path to place the file is shown.

### Emulator profiles

Manage your active emulators at `/emulator_profiles`. You can add from the built-in library, create custom profiles, or edit save paths. Built-in profiles can be deactivated but not deleted.

### Activity log

The `/activity` page shows a full history of all uploads and downloads, including timestamp, game, device type, and IP address. Entries older than `ACTIVITY_RETENTION_DAYS` are pruned automatically each night.

---

## Development

### Running tests

```bash
docker compose run app bundle exec rspec
```

### Linting

```bash
docker compose run --rm app bundle exec rubocop        # check
docker compose run --rm app bundle exec rubocop -A     # auto-fix
```

### Rebuilding assets after changes

```bash
docker compose run --rm app npm run build              # JavaScript
docker compose run --rm app npm run build:css          # CSS
docker compose run --rm -u root app chown -R 1000:1000 /emu-vault/app/assets/builds
```

### Running migrations

```bash
docker compose run --rm app bundle exec rails db:migrate
```

### Useful scripts

Scripts in `scripts/` wrap common Docker commands:

| Script | Description |
|---|---|
| `scripts/console` | Rails console |
| `scripts/migrate` | Run pending migrations |
| `scripts/rollback` | Rollback last migration |
| `scripts/bash` | Shell inside the app container |
| `scripts/run_tests` | Run the full test suite |
| `scripts/deploy.sh <version>` | Tag and release a new version |

### Releasing a new version

```bash
./scripts/deploy.sh          # auto-increments patch (1.0.0 → 1.0.1)
./scripts/deploy.sh 1.2.0   # explicit version
```

This bumps the `VERSION` file, commits, creates a git tag, and pushes. GitHub Actions builds and pushes the Docker image automatically.

### Tech stack

- **Ruby on Rails 8.1** + PostgreSQL 17
- **Hotwire** (Turbo + Stimulus) for reactive UI
- **Tailwind CSS v4** with Dracula theme
- **HAML** templates, **ViewComponent** for UI components
- **SimpleForm**, **Enumerize**, **ActionPolicy**
- **Active Storage** for save file storage
- **Sidekiq** + Redis for background jobs
- **PgHero** for database performance monitoring
- **Rack::Attack** for rate limiting
- **RSpec** + FactoryBot + Capybara + Selenium for tests

### Docker services

| Service | Description |
|---|---|
| `app` | Rails app + esbuild + Tailwind (port 3000) |
| `postgres` | PostgreSQL 17 |
| `redis` | Redis (port 6379) |
| `sidekiq` | Background job worker |
| `selenium-hub` + browsers | For system tests |
