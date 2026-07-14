# AGENTS.md — Reflections

## Stack
- **Ruby 3.4.8**, **Rails 8.1**, **SQLite3**, **Propshaft** (asset pipeline)
- **Hotwire** (Turbo + Stimulus) via importmaps, no Node/Webpack
- **Minitest** (default Rails), parallel workers, fixtures
- **Kamal** for Docker-based deploy, **Thruster** for prod server

## Architecture
- **STI**: `Document` base model; `Book`, `Journal`, `Reflection` subclasses (`type` column). All share the `documents` table.
- **Book**: has `author` column (string), `has_many :pages`, pagination at bottom
- **Journal**: `has_many :pages`, each page has `page_date` (datetime) + optional `place` (string), pagination at bottom
- **Reflection**: `has_one :page` (single note), no pagination
- **Pages**: polymorphic (`Page` belongs_to `pageable`). `Book`/`Journal` have `has_many :pages`; `Reflection` has `has_one :page` — validated with a uniqueness constraint on `[pageable_type, pageable_id]` when type is `Reflection`
- **Model method**: `ordered_pages` returns ordered page collection (ActiveRecord relation for Book/Journal, array for Reflection)
- **Controllers**: `BooksController < DocumentsController`, same for `Journal`/`Reflection`. All CRUD lives in `DocumentsController`; subclasses only override `model` to return the STI class. BooksController also overrides `create_params`/`update_params` to permit `:author`.
- **PagesController**: standalone controller for page body editing (PATCH `/pages/:id`). Verifies ownership via `page.pageable.user == current_user`. Responds with Turbo Stream for inline updates.
- **Inline editing**: Stimulus controller `inline_edit_controller.js` handles click-to-edit, save/cancel buttons, and click-outside-to-save. The `_page_body` partial renders the editable center-side with display/form toggle. Turbo Stream replaces `dom_id(@page, :body)` on successful update.
- **Pagination**: bottom nav bar (`_pagination` partial) with `<< < [prev3] [prev2] [prev1] **[current]** [next1] [next2] [next3] > >>`. Current page tracked via `bookmark` column + `?page=N` query param. Auto-hidden for Reflection (total_pages <= 1).
- **Show view**: shared `documents/show.html.erb` inherited by all subclass controllers. Per-type show files removed (DRY via STI).
- Views reuse shared partials under `app/views/shared/partials/`

## Auth
- **Custom cookie-based**, no Devise
- `Authentication` concern (before_action `:require_authentication`), `Session` model, `Current` attributes (`app/models/current.rb`)
- `allow_unauthenticated_access` skip for public pages
- Test helper: `sign_in_as(user)` / `sign_out` in `SessionTestHelper`

## Commands
```sh
bin/rails server            # dev server (port 3000)
bin/rails test              # run model/controller/integration tests (parallel)
bin/rails test:system       # run system tests (headless Chrome)
bin/rails test test/models/foo_test.rb:12  # single test by file:line
bin/rubocop                 # lint
bin/ci                      # full CI pipeline (rubocop → audit → brakeman → test → seed)
bin/setup                   # first-time project setup
bin/rails db:migrate        # migrate
bin/rails db:seed:replant   # seed test DB
bin/kamal                   # deploy commands (console, shell, logs, dbc)
```

## Important details
- **System tests** require Chrome. Disable save-password / notification bubbles in `ApplicationSystemTestCase`
- **Rate limiting** on document create: 10 req / 3 min (disabled in test env)
- `config/ci.rb` defines the CI pipeline; run `bin/ci` locally to reproduce
- `bin/rails test` runs non-system tests only (comment in `config/ci.rb` toggles system tests)
- Fixtures use ERB for BCrypt password hash (`<% password_hash = BCrypt::Password.create("password") %>`)
- Page number must be non-negative (validated by `before_create :check_number`)
