# EmuVault

A cross-platform emulator save file manager. Allows users to sync game saves between emulators and devices (PC, iPhone, tablet, etc.) via a self-hosted web interface.

## Stack

- **Ruby on Rails 8.1** with PostgreSQL 17
- **Hotwire** (Turbo + Stimulus) for reactive UI — bundled via esbuild (npm packages `@hotwired/turbo`, `@hotwired/stimulus`)
- **a11y-dialog** for accessible modal dialogs (Stimulus `dialog` controller in `app/javascript/controllers/dialog_controller.js`)
- **esbuild** for JavaScript bundling
- **Tailwind CSS v4** + **DaisyUI 5** for styling and UI components
- **HAML** for templates (not ERB)
- **ViewComponent** for reusable UI components
- **SimpleForm** for form building — use `simple_form_for` for model-backed forms. For non-model forms (e.g. filters), use `form_with url: ..., method: :get`
- **Font Awesome Free 6** for icons — served from `public/fontawesome/` (copied there by the `postinstall` npm script). Use `%i.fa-solid.fa-icon-name` (solid), `%i.fa-regular.fa-icon-name` (regular). Add `fa-fw` for fixed-width icons. Linked in the layout before the app stylesheet.
- **Rails enums** for model enum fields (string-backed, with label constants in models/concerns)
- **ActiveModel::API + ActiveModel::Attributes** for form objects
- **Sidekiq** + **sidekiq-scheduler** for background jobs and recurring tasks
- **Redis** for Sidekiq queue
- **BetterErrors** + **binding_of_caller** for improved error pages in development
- **Rack::Attack** for rate limiting
- **RSpec** + FactoryBot + Capybara + Playwright + DatabaseCleaner for testing
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
- Use `simple_form_for` for model-backed forms, `form_with url:` for non-model forms (filters, search)
- Use Rails `enum` for model enum fields — string-backed with label constants (e.g. `GAME_SYSTEM_LABELS`, `PLATFORM_LABELS`)
- Use form objects (`ActiveModel::API` + `ActiveModel::Attributes`) for multi-step form logic — `app/forms/`
- Controllers are thin — logic lives in models or form objects
- Use `private def method_name` (inline) instead of a standalone `private` keyword with methods below
- Prefer Turbo Frames for partial page updates — wrap sections that change independently (e.g. form results, filtered lists) in `turbo_frame_tag`. Use `turbo_frame_tag` (not plain `%div` with `id:`) when the element is a target for `turbo_stream.update` or `turbo_stream.replace`
- For turbo_stream flash messages, append a `::Layouts::FlashComponent::Item` to `flash-container` — see FlashComponent below
- Avoid inline event handlers (`onchange="..."`, `onclick="..."`) — use Stimulus data-actions instead. Never add `unsafe-inline` to CSP.
- Use a11y-dialog via the Stimulus `dialog` controller for CRUD modals, wrapped in `ModalComponent`
- RSpec request specs for API/controller behaviour, system specs (Capybara) for feature flows
- FactoryBot for test data, Faker for fake values
- DatabaseCleaner handles test DB state — truncation for system/feature specs, transaction for unit specs
- Run RuboCop before committing — currently passing with 0 offences

## DaisyUI + theming

DaisyUI 5 provides component classes (`btn`, `input`, `select`, `badge`, `card`, etc.) and a multi-theme system. Themes are configured in `_application.tailwind.css`:

```css
@plugin "daisyui" {
  themes: dracula, night, dark, business, luxury, coffee, dim, sunset,
          light, cupcake, emerald, corporate, retro, cyberpunk, valentine,
          garden, aqua, pastel, wireframe, nord, lemonade, caramellatte;
}
```

### Theme selection

- Users select a theme on the Settings page (`/settings`). Stored as `User#theme` (default: `"dracula"`).
- Applied via `data-theme` attribute on `<html>` in `application.html.haml`.
- The `theme` Stimulus controller provides instant preview, revert on navigation without saving, and an a11y-dialog confirmation prompt for unsaved changes.
- Available themes are defined in `User::THEMES` (grouped into Dark and Light).

### Semantic colour classes

Use DaisyUI semantic classes instead of hardcoded Dracula colours so themes work correctly:

| Instead of (old)       | Use (new)                | Purpose                       |
|------------------------|--------------------------|-------------------------------|
| `bg-drac-bg`           | `bg-base-100`            | Card/panel backgrounds        |
| `bg-drac-surface`      | `bg-base-200`            | Page background               |
| `border-drac-current`  | `border-base-300`        | Borders, dividers             |
| `text-drac-fg`         | `text-base-content`      | Primary text                  |
| `text-drac-comment`    | `text-muted`             | Muted/secondary text          |
| `bg-drac-purple`       | `btn-primary`            | Primary actions               |
| `text-drac-red`        | `text-error`             | Error text                    |
| `bg-drac-green`        | `btn-success`            | Success actions                |

`text-muted` is a custom utility defined in `_application.tailwind.css` that uses `color-mix()` to derive 60% opacity from the current theme's `base-content` colour. This avoids HAML's `/` gotcha with Tailwind opacity modifiers.

### DaisyUI component classes used

- **Buttons**: `btn btn-primary`, `btn btn-error`, `btn btn-info`, `btn btn-ghost`, `btn btn-outline`, `btn-sm`, `btn-xs`
- **Inputs**: `input input-bordered`, `select select-bordered`, `checkbox checkbox-primary`
- **Cards/containers**: `bg-base-100 border border-base-300 rounded-lg`
- **File inputs**: Custom file picker with hidden `file_field` + styled `<label>` + `file-picker` Stimulus controller (DaisyUI `file-input` class doesn't render consistently on iOS Safari)

### SimpleForm + DaisyUI gotcha

SimpleForm's `config.button_class = 'btn'` prepends `btn` to submit buttons. To ensure consistent sizing, prefer plain `<button>` tags over `f.button :submit` inside modals:

```haml
-# Prefer this for consistent btn-sm sizing
%button.btn.btn-primary.btn-sm{ type: "submit" } Save

-# Avoid — SimpleForm may interfere with size classes
= f.button :submit, "Save", class: "btn btn-primary btn-sm"
```

## HAML gotchas

### Tailwind opacity modifiers and fractions (`/10`, `w-3/4`, etc.)
HAML dot-notation interprets `/` as a self-closing tag marker. **Never** use classes containing `/` in dot-notation:

```haml
-# WRONG — HAML syntax error
.bg-base-content/10
.w-3/4

-# CORRECT — use class: string attribute
%div{ class: "bg-base-content/10" }
%div{ class: "w-3/4" }
```

### Namespaced ViewComponents
Inside view context, `Layouts::Foo` resolves as `ActionView::Layouts::Foo`. Always use `::` root prefix:

```haml
= render ::Layouts::AppShellComponent.new(...)
= render ::UI::BadgeComponent.new(...)
```

## Mobile UI

### Bottom sheet modals
On mobile (`max-width: 1023px`), all modals render as bottom sheets that slide up from the bottom, not full-screen takeovers. This is handled purely in CSS — the mobile media query overrides `.dialog-content` to use `align-items: flex-end` with slide-up animation (`translateY(100%)` → `translateY(0)`). No component changes needed. Desktop keeps centred modals. Dialog card footers include `padding-bottom: max(1.5rem, env(safe-area-inset-bottom))` for iPhone safe-area clearance.

### Quick sync
The Quick Sync bottom sheet uses `ModalComponent` with `variant: :bottom_sheet` and `container_data: { "quick-sync-target": "container" }`. Triggered from the mobile nav's centre button via the `quick-sync` Stimulus controller. The quick sync content is wrapped in `turbo_frame_tag :quick_sync_content` so it can be updated via `turbo_stream.update(:quick_sync_content)` when the current game changes.

### Scroll lock
`app/javascript/controllers/scroll_lock.js` provides `lockScroll()`/`unlockScroll()` for dialogs and panels. Uses `overflow: hidden` on html+body with `touch-action: none` and `overscroll-behavior: none`. Supports nested locks via a counter.

### Bottom nav
Fixed bottom nav on mobile with 5 items: Dashboard, Games, Quick Sync (centre floating button), Activity, Settings. Safe-area padding via `env(safe-area-inset-bottom)`.

## ViewComponent structure

Base classes in `app/components/`:
- `ApplicationComponent < ViewComponent::Base` — provides `js_controller_name` (Stimulus controller name from class name)

Component namespaces:
- `app/components/layouts/` — layout-level components (`AppShellComponent`, `FlashComponent`)
- `app/components/ui/` — reusable UI primitives (`BadgeComponent`, `PageHeaderComponent`, `EmptyStateComponent`, `ModalComponent`, `ConfirmComponent`, `ActionComponent`, `CardComponent`, `IconComponent`, `LogoComponent`)

### FlashComponent

Container for flash messages. Always renders `#flash-container` (even when empty) so turbo_stream can target it. Inner class `FlashComponent::Item` renders individual flash alerts with auto-dismiss. Used in two ways:
- **Page load**: `FlashComponent.new(flash: flash)` in the layout iterates `@flash` and renders Items
- **Turbo stream**: `turbo_stream.append("flash-container", ::Layouts::FlashComponent::Item.new(type: :notice, message: "..."))` to show flashes without a page reload

### ModalComponent

Wraps a11y-dialog. Accepts `id:`, `title:`, `subtitle:`, `variant:` (`:default` or `:bottom_sheet`), `container_data:`. Renders trigger (slot), overlay, close button, body (slot), and footer (slot). Slots: `trigger`, `body`, `footer`, `footer_actions`, `page_content`.

**Auto Cancel button**: When a footer is provided, ModalComponent automatically appends a Cancel button. Views should only render their primary action(s) in the footer slot — no need for manual Cancel buttons.

**Two modes**:
- **Managed** (default, `container_data` empty): wraps in `data-controller="dialog"`, Cancel uses `dialog#close`
- **Unmanaged** (`container_data` provided): no dialog controller wrapper, overlay/close use `data-a11y-dialog-hide`. Used when an external Stimulus controller manages the dialog (e.g. `push-subscription`, `theme`, `quick-sync`). No auto Cancel in this mode — the view provides its own close buttons.

### ConfirmComponent

Wraps ModalComponent for destructive confirmations. Accepts `id:`, `title:`, `message:`, `url:`, `method:`, `trigger_label:`, `confirm_label:`, `size:`, `params:`, `trigger_variant:`, `trigger_icon:`, `trigger_class:`. Cancel button is auto-added by ModalComponent.

### ActionComponent

Renders a `<button>` or `<a>` with DaisyUI button classes. Accepts `content_text:`, `href:`, `variant:`, `size:`, plus any HTML options. Supports `leading_icon` and `trailing_icon` slots.

## Stimulus controllers

All controllers in `app/javascript/controllers/`:
- `auto-submit` — submits the parent form on change events.
- `dialog` — wraps a11y-dialog for CRUD modals. Targets: `container`. Actions: `open`, `close`.
- `file-picker` — custom file input display. Hidden `<input type="file">` inside a styled `<label>`. Targets: `input`, `filename`. Actions: `update`.
- `flash` — auto-dismiss flash notifications.
- `notifications` — slide-in notification panel with backdrop. Targets: `backdrop`, `overlay`, `panel`, `frame`. Actions: `open`, `close`, `markAllRead`.
- `onboarding` — first-run guided tour.
- `push-subscription` — web push notification subscription.
- `quick-sync` — bottom sheet for quick sync (mobile nav centre button).
- `save-hint` — shows suggested save file path on download profile selection. Targets: `select`, `hint`, `note`, `copyBtn`.
- `theme` — live theme preview with revert on navigation. Targets: `dialog`. Values: `current`.

## Form object pattern

```ruby
# app/forms/game_save_form.rb
class GameSaveForm
  include ActiveModel::API
  include ActiveModel::Attributes
  def self.model_name = ActiveModel::Name.new(self, nil, "GameSave")
  def save(game:, request:)  # validates, builds record, records sync event
end
```

Form objects live in `app/forms/`. Used for multi-step logic (checksum computation, sync event creation) that doesn't belong on the model.

## Data model

- `EmulatorProfile` — library of known emulators. Seeded defaults have `is_default: true` (can't be deleted, only deselected). User-activated ones have `user_selected: true`. Fields: `name`, `platform` (enum), `save_extension`, `default_save_path`, `is_default`, `user_selected`.
- `Game` — a game in the user's library. Has `system` enum (string-backed).
- `GameSave` — a save file version, linked to a game and optional emulator profile. Latest = most recent by `created_at`. No slot concept. File stored via Active Storage. Fields: `game_id`, `emulator_profile_id` (optional), `checksum`, `saved_at`.
- `SyncEvent` — passive audit log of uploads/downloads. Auto-created on every upload/download. Fields: `game_save_id`, `action` (push/pull), `status` (success/failed), `performed_at`, `ip_address`, `user_agent`. No manual device registration — device type is inferred from `user_agent` via `SyncEvent#device_type`.
- `User` — has `setup_completed` boolean (false until wizard is finished), `theme` string (default `"dracula"`), `current_game_id` for quick sync.

## Activity log

`SyncEvent` records are created automatically by `GameSavesController` on every upload (`action: :push`) and download (`action: :pull`), capturing `request.remote_ip` and `request.user_agent`. No manual device management.

`SyncEvent#device_type` infers device type from UA:
- iPad/Android Tablet/Kindle → `:tablet`
- Mobile/Android/iPhone/iPod → `:phone`
- Anything else → `:desktop`

Activity is exposed at `/activity` (`ActivityController#show`, singular resource with `controller: "activity"` to avoid Rails pluralising to `ActivitiesController`).

## First-run setup wizard

On first load with no users, the app shows a registration page to create an account (username + password). After registration, and on subsequent logins when `setup_completed: false`, all routes redirect to `/setup`. The wizard has 3 steps:

1. **Emulators** (`GET /setup/profiles`, `POST /setup/select_profiles`) — pick from the seeded library
2. **Paths** (`GET /setup/configure`, `PATCH /setup/save_configuration`) — set save directory per selected profile
3. **Library** (`GET /setup/library`, `PATCH /setup/save_library`) — configure scan paths and auto-scan

Uses a separate `setup` layout (`app/views/layouts/setup.html.haml`) — no nav sidebar. Shared step indicator in `app/views/setup/_wizard_shell.html.haml` rendered via `render layout: "setup/wizard_shell", locals: { current_step: N }`.

After completion: redirects to `games_path` if games exist, otherwise `new_game_path`.

### Singular resource routing gotcha

`resource :foo` (singular) requires `controller: "foo"` explicitly when Rails would pluralise the controller name (e.g. `activity` → `ActivitiesController`, `setup` → `SetupsController`). Always add `controller:` for non-standard pluralisations.

Extra actions defined inside a singular resource block (no `on: :collection`) generate helpers named `{action}_foo_path` (e.g. `profiles_setup_path`), **not** `foo_{action}_path`.

## Emulator profiles

Managed at `/emulator_profiles`. Index shows only `user_selected` profiles. Edit/new via a11y-dialog modals. "Add from library" expander for unselected defaults. Seeded defaults use `is_default: true` — destroy action deselects rather than deletes them.

## Games

### Index page
- Game list rendered via `_game_list` partial inside `turbo_frame_tag "games-list"`
- Each card has: link to show page (`data-turbo-frame: "_top"` to break out of frame), set-as-current button (rotate icon), and delete button (trash icon with ConfirmComponent)
- Set/clear current game uses `turbo_stream.update` on both the games list and quick sync content, with flash message
- Delete uses `turbo_stream.update` to remove the game from the list inline (when `source: "index"`)
- Filters (system, sort) hidden when only 1 game

### Show page
- **Header** — title, system badge, "Set as current"/"Now Playing" toggle, Edit modal, Remove confirm. Header is replaced via `turbo_stream.replace("game_header")` on edit/current-game changes
- **Current save** — latest `GameSave` by `created_at`. Shows upload date, source emulator badge, download form with profile selector.
- **Save path hint** — when a profile is selected for download, the `save-hint` Stimulus controller reads `data-path` from the option and shows the full suggested path (e.g. `~/.config/retroarch/saves/Pokemon_Emerald.srm`).
- **Upload new version** — inline form with custom file picker and optional source profile.
- **Previous versions** — list of older saves, "View all" opens a modal if more than 5.
- **Emulator save filenames** — per-profile filename configuration for downloads.

## Environment variables

See `.env.example` for all required vars. Key ones:
- `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD`, `DB_NAME` — PostgreSQL connection
- `REDIS_URL` — Redis connection for Sidekiq

## Notable config

- `config/initializers/sidekiq.rb` — Sidekiq server + client Redis config, scheduler setup
- `config/initializers/better_errors.rb` — allows BetterErrors from any IP (needed for Docker)
- `config/initializers/rack_attack.rb` — rate limiting (300 req/5min, 30 uploads/5min)
- `config/initializers/content_security_policy.rb` — CSP enabled, frame-ancestors :none
- `config/initializers/simple_form.rb` — `generate_additional_classes_for = []` prevents type-based classes conflicting with DaisyUI
- `config/environments/production.rb` — SSL controlled via `FORCE_SSL` env var (off by default for Tailscale)
- `Procfile.dev` — Puma binds to `0.0.0.0` so it's reachable inside Docker
- `scripts/install.sh` — one-command setup, generates secure DB password via openssl
- `scripts/` — attach, bash, bundle, console, migrate, rollback, run_tests, i18n, install

## Docker services (development)

- `app` — Rails + esbuild + Tailwind (port 3000)
- `postgres` — PostgreSQL 17 (credentials from .env)
- `redis` — Redis (port 6379)
- `sidekiq` — background job worker

## Production deployment

Distributed as a Docker image on Docker Hub: `rturner1989/emuvault:latest`

### Building and pushing

```bash
docker build -f Dockerfile.prod -t rturner1989/emuvault:latest .
docker push rturner1989/emuvault:latest
```

### Dockerfile.prod

Multi-stage build:
- **Stage 1 (build)**: Ruby + Node.js, installs gems (without dev/test), yarn packages, precompiles JS/CSS/assets
- **Stage 2 (runtime)**: `ruby:3.4.8-slim`, copies gems + app code, no Node.js in production

### Production compose (`docker-compose.prod.yml`)

4 services: `app`, `sidekiq`, `postgres`, `redis`. All env vars are inline (no `.env` file) — suitable for TrueNAS Scale custom apps or any Docker host.

Required environment variables:
- `SECRET_KEY_BASE` — generate with `bundle exec rails secret`
- `DB_PASSWORD` — shared between app/sidekiq/postgres
- `VAPID_PUBLIC_KEY` / `VAPID_PRIVATE_KEY` — web push notifications

Volume mounts (bind to host paths):
- `/path/to/storage` → `/emu-vault/storage` (Active Storage save files)
- `/path/to/postgres` → `/var/lib/postgresql/data`
- `/path/to/redis` → `/data`

### SSL

SSL is off by default (`FORCE_SSL` env var). Tailscale encrypts traffic end-to-end, so no reverse proxy or SSL termination is needed when accessing via Tailscale IP.

### First run

The app command runs `rails db:prepare` before starting Puma, which creates the database, runs migrations, and seeds emulator profiles. On first load, the user creates their account via the registration page, then the setup wizard begins.

## Security

- DB credentials via `.env` only (gitignored), not hardcoded anywhere
- `master.key` gitignored
- CSP enabled with Turbo/esbuild-compatible settings
- `force_ssl` + `assume_ssl` controlled via `FORCE_SSL` env var (off by default for Tailscale)
- Rack::Attack rate limiting
- BetterErrors restricted to development only
- Single-user authentication via Rails 8 native auth (`has_secure_password`)
  - First-time registration page when no users exist (`RegistrationsController`)
  - All routes protected by default via `ApplicationController`
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

SimpleForm generates `<span class="error">` inside a `.field_with_errors` wrapper. Tailwind won't include these classes via scanning. Add explicit rules in `_application.tailwind.css`:

```css
.input span.error { @apply text-xs text-error mt-1 block; }
.field_with_errors input, .field_with_errors select { @apply border-error; }
```

## Progress

- [x] Stage 1 — App setup (Rails 8.1, Docker, Tailwind v4, Dracula theme, Hotwire, RuboCop)
- [x] Stage 2 — Data model (EmulatorProfile, Game, GameSave, SyncEvent, Device migrations)
- [x] Stage 3 — Authentication (Rails 8 native auth, single-user, seeded admin)
- [x] Stage 4 — Seeds (28 EmulatorProfile records across RetroArch, Delta, mGBA, Dolphin, PPSSPP, melonDS, Snes9x, OpenEmu, DuckStation)
- [x] Stage 5 — Core UI (ViewComponents, Dracula theme, controllers, views, form objects)
- [x] Stage 6 — Save file upload/download (Active Storage, GameSave management)
- [x] Stage 7 — Sync logic (push/pull, SyncEvent history)
- [x] Mobile UI redesign — card-based layouts, full-width tap targets, no tables
- [x] PWA + app icon — Dracula floppy disk SVG icon, manifest.json, iOS home screen meta tags
- [x] Save model refactor — dropped slot, one canonical save per game (latest by created_at), history preserved
- [x] Emulator profiles refactor — user_selected + is_default flags, setup wizard selects from library
- [x] Setup wizard — 3-step first-run flow (emulator selection, save paths, library scan), separate layout
- [x] JS stack — Hotwire + a11y-dialog wired via esbuild; Stimulus controllers: dialog, save-hint
- [x] Game show redesign — current save card, save path hint, upload toggle, history panel
- [x] Emulator profiles CRUD — index shows selected only, edit/new via a11y-dialog modals
- [x] Activity log — auto-tracked SyncEvents (ip_address + user_agent), Device model removed, UA-based device type inference in SyncEvent model, /activity page
- [x] Nav/settings cleanup — removed duplicate Change Password nav link, password form restyled
- [x] Notifications — real-time badge via ActionCable, slide-in panel, click-to-read, mark all read, web push (VAPID)
- [x] Production deployment — Dockerfile.prod, docker-compose.prod.yml, Docker Hub image, TrueNAS Scale support
- [x] DaisyUI migration — replaced custom Dracula CSS with DaisyUI 5 component classes and semantic theme colours
- [x] Theme system — user-selectable themes (22 DaisyUI themes), persisted to DB, live preview with revert
- [x] Mobile bottom sheets — all modals render as slide-up bottom sheets on mobile instead of full-screen
- [x] Custom file picker — hidden file input + styled label + Stimulus controller for cross-platform consistency (iOS Safari)
