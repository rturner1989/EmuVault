# EmuVault

A cross-platform emulator save file manager. Allows users to sync game saves between emulators and devices (PC, iPhone, tablet, etc.) via a self-hosted web interface.

## Stack

- **Ruby on Rails 8.1** with PostgreSQL 17
- **Hotwire** (Turbo + Stimulus) for reactive UI — bundled via esbuild (npm packages `@hotwired/turbo`, `@hotwired/stimulus`)
- **a11y-dialog** for accessible modal dialogs (Stimulus `dialog` controller in `app/javascript/controllers/dialog_controller.js`)
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

## Rebuilding JS/CSS after changes

```bash
docker compose run --rm app npm run build
docker compose run --rm app npm run build:css
docker compose run --rm -u root app chown -R 1000:1000 /emu-vault/app/assets/builds
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
- Prefer Turbo Frames for partial page updates — wrap sections that change independently (e.g. form results, filtered lists) in `turbo_frame_tag`. Controllers need no changes; Turbo follows redirects and extracts the matching frame from the response.
- Avoid inline event handlers (`onchange="..."`, `onclick="..."`) — use Stimulus data-actions instead. Never add `unsafe-inline` to CSP.
- Use a11y-dialog via the Stimulus `dialog` controller for CRUD modals
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

## Stimulus controllers

All controllers in `app/javascript/controllers/`:
- `dialog` — wraps a11y-dialog for CRUD modals. Targets: `container`. Actions: `open`, `close`.
- `save-hint` — shows the suggested save file path when a download profile is selected. Targets: `select`, `hint`.

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

- `EmulatorProfile` — library of known emulators. Seeded defaults have `is_default: true` (can't be deleted, only deselected). User-activated ones have `user_selected: true`. Fields: `name`, `platform` (Enumerize), `save_extension`, `default_save_path`, `is_default`, `user_selected`.
- `Game` — a game in the user's library. Has `system` enum via Enumerize.
- `GameSave` — a save file version, linked to a game and optional emulator profile. Latest = most recent by `created_at`. No slot concept. File stored via Active Storage. Fields: `game_id`, `emulator_profile_id` (optional), `checksum`, `saved_at`.
- `SyncEvent` — passive audit log of uploads/downloads. Auto-created on every upload/download. Fields: `game_save_id`, `action` (push/pull), `status` (success/failed), `performed_at`, `ip_address`, `user_agent`. No manual device registration — device type is inferred from `user_agent` in `SyncEventDecorator`.
- `User` — has `setup_completed` boolean (false until wizard is finished).

## Activity log

`SyncEvent` records are created automatically by `GameSavesController` on every upload (`action: :push`) and download (`action: :pull`), capturing `request.remote_ip` and `request.user_agent`. No manual device management.

`SyncEventDecorator` infers device type from UA:
- iPad/Android Tablet/Kindle → `:tablet`
- Mobile/Android/iPhone/iPod → `:phone`
- Anything else → `:desktop`

Activity is exposed at `/activity` (`ActivityController#show`, singular resource with `controller: "activity"` to avoid Rails pluralising to `ActivitiesController`).

## First-run setup wizard

On first login (`setup_completed: false`), all routes redirect to `/setup`. The wizard has 3 steps:

1. **Account** (`GET/PATCH /setup`) — set email and password
2. **Emulators** (`GET /setup/profiles`, `POST /setup/select_profiles`) — pick from the seeded library
3. **Paths** (`GET /setup/configure`, `PATCH /setup/save_configuration`) — set save directory per selected profile

Uses a separate `setup` layout (`app/views/layouts/setup.html.haml`) — no nav sidebar. Shared step indicator in `app/views/setup/_wizard_shell.html.haml` rendered via `render layout: "setup/wizard_shell", locals: { current_step: N }`.

After completion: redirects to `games_path` if games exist, otherwise `new_game_path`.

### Singular resource routing gotcha

`resource :foo` (singular) requires `controller: "foo"` explicitly when Rails would pluralise the controller name (e.g. `activity` → `ActivitiesController`, `setup` → `SetupsController`). Always add `controller:` for non-standard pluralisations.

Extra actions defined inside a singular resource block (no `on: :collection`) generate helpers named `{action}_foo_path` (e.g. `profiles_setup_path`), **not** `foo_{action}_path`.

## Emulator profiles

Managed at `/emulator_profiles`. Index shows only `user_selected` profiles. Edit/new via a11y-dialog modals. "Add from library" expander for unselected defaults. Seeded defaults use `is_default: true` — destroy action deselects rather than deletes them.

## Game show page

- **Current save** — latest `GameSave` by `created_at`. Shows upload date, source emulator badge, download form with profile selector.
- **Save path hint** — when a profile is selected for download, the `save-hint` Stimulus controller reads `data-path` from the option and shows the full suggested path (e.g. `~/.config/retroarch/saves/Pokemon_Emerald.srm`).
- **Upload new version** — behind a `<details>` toggle, optional source profile.
- **Previous versions** — collapsible `<details>` panel listing older saves, each downloadable.

## Environment variables

See `.env.example` for all required vars. Key ones:
- `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD`, `DB_NAME` — PostgreSQL connection
- `REDIS_URL` — Redis connection for Sidekiq
- `HUB_URL` — Selenium hub for system tests (e.g. `http://selenium-hub:4444/wd/hub`)
- `APP_HOST` — used by Capybara for system tests
- `ADMIN_EMAIL` / `ADMIN_PASSWORD` — seeded admin credentials

## Notable config

- `config/initializers/sidekiq.rb` — Sidekiq::Web protected via HTTP Basic Auth using admin credentials
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
- Single-user authentication via Rails 8 native auth (`rails generate authentication`)
  - Admin credentials seeded from `ADMIN_EMAIL` / `ADMIN_PASSWORD` env vars
  - All routes protected by default via `ApplicationController`
  - Sidekiq Web protected by HTTP Basic Auth using admin credentials
  - Password change available via Settings → `/password/edit` (no email reset — self-hosted)
  - `simple_form_for :session` nests params under `session[field]` — controller uses `params.require(:session).permit(...)`

## Architecture intent

Distributed as a Docker image — users run `./scripts/install.sh` then `docker compose up` on their PC or home server and access from any device via browser (or Tailscale for remote access). No Tailscale requirement — it's just one convenient remote access option alongside a reverse proxy.

Users configure:
- Which emulators they use (selected during setup wizard, manageable at `/emulator_profiles`)
- Which games they want to sync

The app stores one canonical save per game (the latest upload). Previous uploads are kept as history. On download, the user picks their target emulator and gets the file renamed to match that emulator's expected extension. If the profile has a save directory configured, the UI shows exactly where to put the file.

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
- [x] Stage 7 — Sync logic (push/pull, SyncEvent history)
- [x] Mobile UI redesign — card-based layouts, full-width tap targets, no tables
- [x] PWA + app icon — Dracula floppy disk SVG icon, manifest.json, iOS home screen meta tags
- [x] Save model refactor — dropped slot, one canonical save per game (latest by created_at), history preserved
- [x] Emulator profiles refactor — user_selected + is_default flags, setup wizard selects from library
- [x] Setup wizard — 3-step first-run flow (account, emulator selection, save paths), separate layout
- [x] JS stack — Hotwire + a11y-dialog wired via esbuild; Stimulus controllers: dialog, save-hint
- [x] Game show redesign — current save card, save path hint, upload toggle, history panel
- [x] Emulator profiles CRUD — index shows selected only, edit/new via a11y-dialog modals
- [x] Activity log — auto-tracked SyncEvents (ip_address + user_agent), Device model removed, UA-based device type inference in SyncEventDecorator, /activity page
- [x] Nav/settings cleanup — removed duplicate Change Password nav link, password form restyled to Dracula theme
