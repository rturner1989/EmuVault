# EmuVault

A cross-platform emulator save file manager. Allows users to sync game saves between emulators and devices (PC, iPhone, tablet, etc.) via a self-hosted web interface.

## Stack

- **Ruby on Rails 8.1** with PostgreSQL 17
- **Hotwire** (Turbo + Stimulus) for reactive UI without a JS framework
- **esbuild** for JavaScript bundling
- **Tailwind CSS v4** for styling
- **HAML** for templates (not ERB)
- **ViewComponent** for reusable UI components
- **SimpleForm** for form building
- **Enumerize** for i18n-aware enums on models (not Rails enums)
- **ActionPolicy** for authorization
- **Sidekiq** + **sidekiq-scheduler** for background jobs and recurring tasks
- **Redis** for Sidekiq queue
- **BetterErrors** + **binding_of_caller** for improved error pages in development
- **Rack::Attack** for rate limiting
- **RSpec** + FactoryBot + Capybara + Selenium + DatabaseCleaner for testing
- **RuboCop** with rubocop-rails, rubocop-rspec, rubocop-capybara, rubocop-factory_bot, rubocop-rspec_rails
- **Docker** for development environment

## Running the app

```bash
./scripts/install.sh   # first time only — generates .env, builds, creates DB, runs migrations+seeds
docker compose up      # subsequent runs
```

App runs at http://localhost:3000. Also accessible via Tailscale from any device.

## Running tests

```bash
docker compose run app bundle exec rspec
```

## Linting

```bash
bundle exec rubocop        # check
bundle exec rubocop -A     # auto-fix
```

## Key conventions

- Use HAML for all views, never ERB
- Use ViewComponent for any UI element used in more than one place
- Use SimpleForm for all forms
- Use Enumerize for model enum fields — gives i18n support
- Use ActionPolicy for any authorization logic
- Controllers are thin — logic lives in models or service objects
- Use Turbo Frames and Turbo Streams for dynamic updates, avoid full page reloads
- RSpec request specs for API/controller behaviour, system specs (Capybara) for feature flows
- FactoryBot for test data, Faker for fake values
- DatabaseCleaner handles test DB state — truncation for system/feature specs, transaction for unit specs
- Run RuboCop before committing — currently passing with 0 offences

## Environment variables

See `.env.example` for all required vars. Key ones:
- `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD`, `DB_NAME` — PostgreSQL connection
- `REDIS_URL` — Redis connection for Sidekiq
- `HUB_URL` — Selenium hub for system tests (e.g. `http://selenium-hub:4444/wd/hub`)
- `APP_HOST` — used by Capybara for system tests

## Notable config

- `config/initializers/sidekiq.rb` — Redis connection for Sidekiq
- `config/initializers/better_errors.rb` — allows BetterErrors from any IP (needed for Docker)
- `config/initializers/rack_attack.rb` — rate limiting (300 req/5min, 30 uploads/5min)
- `config/initializers/content_security_policy.rb` — CSP enabled, frame-ancestors :none
- `config/environments/production.rb` — force_ssl, assume_ssl, host_authorization enabled
- `Procfile.dev` — Puma binds to `0.0.0.0` so it's reachable inside Docker
- `scripts/install.sh` — one-command setup, generates secure DB password via openssl
- `scripts/` — attach, bash, bundle, console, migrate, rollback, run_tests, i18n, install

## Docker services

- `app` — Rails + esbuild + Tailwind (port 3000)
- `postgres` — PostgreSQL 17 (credentials from .env)
- `redis` — Redis (port 6379)
- `sidekiq` — background job worker
- `selenium-hub` + `chrome` + `edge` + `firefox` — for system tests

## Security

- DB credentials via `.env` only (gitignored), not hardcoded anywhere
- `master.key` gitignored
- CSP enabled with Turbo/esbuild-compatible settings
- `force_ssl` + `assume_ssl` in production
- Rack::Attack rate limiting
- BetterErrors restricted to development only
- No authentication yet — to be added before any public use

## Architecture intent

Distributed as a Docker image — users run `./scripts/install.sh` then `docker compose up` on their PC or home server and access from any device via browser (or Tailscale for remote access).

Users configure:
- Which emulators they use (picked from a pre-built list of profiles)
- Which games they want to sync

The app knows each emulator's save format and file location conventions. It handles format conversion (e.g. `.srm` to `.sav`) and serves a mobile-friendly web UI so any device with a browser can push or pull saves.

## Data model (planned)

- `EmulatorProfile` — pre-seeded, describes a known emulator (name, platform, save extension, default save path)
- `Game` — a game in the user's library, identified by ROM hash where possible
- `GameSave` — a specific save slot, linked to a game and emulator profile
- `SyncEvent` — history of push/pull actions with timestamps for conflict detection
- `Device` — a registered device (PC, phone, tablet) that can access the web UI

## Next step

Build the data model — start with migrations and models for EmulatorProfile and Game.
