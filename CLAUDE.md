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
- **SimpleDelegator** for decorators (no Draper gem)
- **ActiveModel::API + ActiveModel::Attributes** for form objects
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
- Use ActionPolicy for any authorization logic — all policies in `app/policies/`
- Use `ApplicationDecorator < SimpleDelegator` for view-layer decoration — `app/decorators/`
- Use form objects (`ApplicationForm` with `ActiveModel::API`) for non-trivial form handling — `app/forms/`
- Controllers are thin — logic lives in models, decorators, or form objects
- Use Turbo Frames and Turbo Streams for dynamic updates, avoid full page reloads
- RSpec request specs for API/controller behaviour, system specs (Capybara) for feature flows
- FactoryBot for test data, Faker for fake values
- DatabaseCleaner handles test DB state — truncation for system/feature specs, transaction for unit specs
- Run RuboCop before committing — currently passing with 0 offences

## HAML gotchas

### Tailwind opacity modifiers (`/10`, `/20`, etc.)
HAML dot-notation interprets `/` as a self-closing tag marker. **Never** use opacity modifier classes in dot-notation:

```haml
-# WRONG — HAML syntax error
.bg-drac-green/10.text-drac-green

-# CORRECT — use class: string attribute
%div{ class: "bg-drac-green/10 text-drac-green" }
```

### Namespaced ViewComponents
Inside view context, `Layouts::Foo` resolves as `ActionView::Layouts::Foo`. Always use `::` root prefix:

```haml
= render ::Layouts::AppShellComponent.new(...)
= render ::UI::BadgeComponent.new(...)
```

## Dracula theme

Tailwind CSS v4 custom properties defined in `app/assets/stylesheets/application.tailwind.css`:

| Token              | Hex       | Usage                        |
|--------------------|-----------|------------------------------|
| `drac-bg`          | `#282a36` | Card/panel backgrounds       |
| `drac-surface`     | `#21222c` | Page background              |
| `drac-current`     | `#44475a` | Borders, dividers            |
| `drac-fg`          | `#f8f8f2` | Primary text                 |
| `drac-comment`     | `#6272a4` | Muted/secondary text         |
| `drac-cyan`        | `#8be9fd` | Accent, windows platform     |
| `drac-green`       | `#50fa7b` | Success, macOS platform      |
| `drac-orange`      | `#ffb86c` | Warning, Android platform    |
| `drac-pink`        | `#ff79c6` | iOS platform                 |
| `drac-purple`      | `#bd93f9` | Primary action, Linux        |
| `drac-red`         | `#ff5555` | Error/destructive            |
| `drac-yellow`      | `#f1fa8c` | Highlight                    |

## ViewComponent structure

Base classes in `app/components/`:
- `ApplicationComponent < ViewComponent::Base` — provides `js_controller_name` (Stimulus controller name from class name)
- `Styleable` module — CSS class management DSL, included in ApplicationComponent

Component namespaces:
- `app/components/layouts/` — layout-level components (`AppShellComponent`, `FlashComponent`)
- `app/components/ui/` — reusable UI primitives (`BadgeComponent`, `PageHeaderComponent`, `EmptyStateComponent`)

## Decorator pattern

```ruby
# app/decorators/application_decorator.rb
class ApplicationDecorator < SimpleDelegator
  def self.decorate(record_or_collection)
    record_or_collection.respond_to?(:map) ? record_or_collection.map { new(_1) } : new(record_or_collection)
  end
  def object = __getobj__
end
```

Decorators live in `app/decorators/`. Use `DecoratorClass.decorate(@record)` in controllers.

## Form object pattern

```ruby
# app/forms/application_form.rb
class ApplicationForm
  include ActiveModel::API
  include ActiveModel::Attributes
  def self.model_name = ActiveModel::Name.new(self, nil, "ModelName")
  def self.from(record)  # builds form populated from AR record
  def persist(record)    # validates, then assigns attrs and saves
end
```

Form objects live in `app/forms/`. Views use `url:` explicitly (don't rely on polymorphic routing).

## Data model

- `EmulatorProfile` — pre-seeded, read-only. Describes a known emulator (name, platform, save extension, default save path). Managed via seeds.
- `Game` — a game in the user's library, identified by ROM hash where possible. Has system (platform) enum via Enumerize.
- `GameSave` — a specific save file, linked to a game and emulator profile. File stored via Active Storage.
- `SyncEvent` — history of push/pull actions with timestamps for conflict detection.
- `Device` — a registered device (PC, phone, tablet) with name, device_type, and identifier.

## Environment variables

See `.env.example` for all required vars. Key ones:
- `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD`, `DB_NAME` — PostgreSQL connection
- `REDIS_URL` — Redis connection for Sidekiq
- `HUB_URL` — Selenium hub for system tests (e.g. `http://selenium-hub:4444/wd/hub`)
- `APP_HOST` — used by Capybara for system tests
- `ADMIN_EMAIL` / `ADMIN_PASSWORD` — seeded admin credentials
- `api_token` on `User` — 64-char hex token auto-generated on user create; viewable/regeneratable at `/settings`

## Notable config

- `config/initializers/sidekiq.rb` — Sidekiq::Web protected via HTTP Basic Auth using admin credentials
- `config/initializers/better_errors.rb` — allows BetterErrors from any IP (needed for Docker)
- `config/initializers/rack_attack.rb` — rate limiting (300 req/5min, 30 uploads/5min)
- `config/initializers/content_security_policy.rb` — CSP enabled, frame-ancestors :none
- `config/environments/production.rb` — force_ssl, assume_ssl, host_authorization enabled
- `Procfile.dev` — Puma binds to `0.0.0.0` so it's reachable inside Docker
- `scripts/install.sh` — one-command setup, generates secure DB password via openssl
- `scripts/sync_agent` — executable Ruby polling agent for PC auto-sync (compares checksums, pulls changed saves to configured local paths)
- `scripts/sync_agent.yml.example` — config template for sync agent (server_url, api_token, mappings of profile→local path)
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
- API Bearer token auth via `Authorization: Bearer <token>` header or `?token=` query param (no session required)
- Single-user authentication via Rails 8 native auth (`rails generate authentication`)
  - Admin credentials seeded from `ADMIN_EMAIL` / `ADMIN_PASSWORD` env vars
  - All routes protected by default via `ApplicationController`
  - Sidekiq Web protected by HTTP Basic Auth using admin credentials
  - Password change available at `/password/edit` (no email reset — self-hosted)
  - `simple_form_for :session` nests params under `session[field]` — controller uses `params.require(:session).permit(...)`

## Architecture intent

Distributed as a Docker image — users run `./scripts/install.sh` then `docker compose up` on their PC or home server and access from any device via browser (or Tailscale for remote access).

Users configure:
- Which emulators they use (picked from a pre-built list of profiles)
- Which games they want to sync

The app knows each emulator's save format and file location conventions. It handles format conversion (rename-only — raw save bytes are identical across emulators for the same game; only the extension and filename differ) and serves a mobile-friendly web UI so any device with a browser can push or pull saves.

## REST API

Base path: `/api/`

Authentication: `Authorization: Bearer <token>` or `?token=<token>` query param.

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/game_saves` | List all game saves (with game and profile info) |
| GET | `/api/game_saves/:id` | Show a single game save |
| GET | `/api/game_saves/:id/file` | Download save file; pass `?target_profile_id=N` for converted filename |

The `scripts/sync_agent` polls this API, compares SHA-256 checksums, and writes updated saves to configured local paths automatically.

## Inflection gotchas

- `ui/` directory → Zeitwerk resolves as `Ui` not `UI`. Fixed with `inflect.acronym "UI"` in `config/initializers/inflections.rb`.
- `game_saves` → Rails singularizes `saves` as `safe` by default. Fixed with `inflect.irregular "game_save", "game_saves"` in inflections.rb.

## Active Storage checksum

When computing a file's SHA-256 before saving (for conflict detection), read from the raw uploaded tempfile, **not** from Active Storage after save:

```ruby
# CORRECT — read from UploadedFile before save
uploaded = params_hash[:file]
uploaded.rewind
checksum = Digest::SHA256.hexdigest(uploaded.read)

# WRONG — ActiveStorage::FileNotFoundError (file not in storage yet)
checksum = Digest::SHA256.hexdigest(record.file.download)
```

## SimpleForm error styling

SimpleForm generates `<span class="error">` inside a `.field_with_errors` wrapper. Tailwind won't include these classes via scanning. Add explicit rules in `application.tailwind.css`:

```css
.input span.error { @apply text-xs text-drac-red mt-1 block; }
.field_with_errors input, .field_with_errors select { @apply border-drac-red; }
```

## Progress

- [x] Stage 1 — App setup (Rails 8.1, Docker, Tailwind v4, Dracula theme, Hotwire, RuboCop)
- [x] Stage 2 — Data model (EmulatorProfile, Game, GameSave, SyncEvent, Device migrations)
- [x] Stage 3 — Authentication (Rails 8 native auth, single-user, seeded admin)
- [x] Stage 4 — Seeds (28 EmulatorProfile records across RetroArch, Delta, mGBA, Dolphin, PPSSPP, melonDS, Snes9x, OpenEmu, DuckStation)
- [x] Stage 5 — Core UI (ViewComponents, Dracula theme, controllers, views, ActionPolicy, decorators, form objects)
- [x] Stage 6 — Save file upload/download (Active Storage, GameSave management)
- [x] Stage 7 — Sync logic (push/pull, conflict detection, SyncEvent history)
- [x] Stage 8 — REST API + PC sync agent + Settings page
- [x] Mobile UI redesign — card-based layouts, full-width tap targets, no tables
- [x] PWA + app icon — Dracula floppy disk SVG icon, manifest.json, iOS home screen meta tags
