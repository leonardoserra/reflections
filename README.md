# Reflections

A personal writing application built with Ruby on Rails 8.1. Supports three types of documents: **Books**, **Journals**, and **Reflections** — each with different page structures and behaviors.

---

## Stack

| Component        | Technology                              |
|------------------|-----------------------------------------|
| Framework        | Ruby on Rails 8.1.3                     |
| Ruby             | 3.4.8                                   |
| Database         | SQLite3                                 |
| Asset pipeline   | Propshaft                               |
| Frontend         | Hotwire (Turbo + Stimulus) via importmaps |
| Auth             | Custom cookie-based (no Devise)         |
| Testing          | Minitest (parallel workers, fixtures)   |
| Deploy           | Kamal + Thruster                        |

---

## Architecture

### Single-Table Inheritance (STI)

All document types share a single `documents` table via STI:

```
Document (base, app/models/document.rb)
├── Book       (type = "Book",       has_many :pages, author column)
├── Journal    (type = "Journal",    has_many :pages, page_date + place per page)
└── Reflection (type = "Reflection", has_one  :page, single-note only)
```

The `type` column determines the subclass. Controllers follow the same pattern: `BooksController < DocumentsController`, etc.

### Pages (Polymorphic)

Pages belong to documents via a polymorphic association (`pageable`):

```
Page
  belongs_to :pageable, polymorphic: true
  # pageable_id, pageable_type columns
```

| Document type | Association    | Pagination |
|---------------|----------------|------------|
| Book          | `has_many :pages` ordered by `:number` | Yes (bottom nav) |
| Journal       | `has_many :pages` ordered by `page_date DESC, number ASC` | Yes (bottom nav) |
| Reflection    | `has_one :page` (uniqueness constraint enforces single page) | No (auto-hidden) |

### Navigation

Each document tracks the user's last-visited page via a `bookmark` column (integer, defaults to 1). When viewing a document, the pagination bar shows up to 7 page links around the current page.

---

## Features

### Authentication

Custom cookie-based authentication via the `Authentication` concern (`app/controllers/concerns/authentication.rb`).

| Action | Endpoint | Auth required |
|--------|----------|---------------|
| Sign up | `GET /registrations/new` → `POST /registrations` | No |
| Sign in | `GET /session/new` → `POST /session` | No |
| Sign out | `DELETE /session` | Yes |
| Reset password | `GET /passwords/new` → `POST /passwords` → `GET /passwords/:token/edit` → `PUT /passwords/:token` | No |

Sessions are stored in the `sessions` table (not in the cookie itself — only a signed `session_id` is stored in the cookie). The `Current` attributes model (`app/models/current.rb`) provides `Current.user` and `Current.session` access throughout the request cycle.

**Rate limiting**: 10 requests per 3 minutes on session creation and document creation (disabled in test env).

### Documents CRUD

All CRUD operations are handled by `DocumentsController` with subclass overrides:

- **`DocumentsController#index`** — Lists all documents of a given type for the current user
- **`DocumentsController#show`** — Shows a single document with paginated pages. Uses `find_by` + `count` (O(2) queries, not O(N)). Updates `bookmark` only when `?page=N` param is present (no stale writes on regular navigation)
- **`DocumentsController#new`** — Renders creation form
- **`DocumentsController#create`** — Wrapped in a database transaction: creates the document and its first page atomically. Reflections use `create_page!` (singular), Books/Journals use `pages.create!` (plural)
- **`DocumentsController#edit`** — Renders edit form
- **`DocumentsController#update`** — Updates document attributes (name, and author for Books)
- **`DocumentsController#destroy`** — Deletes document (cascades to pages via `dependent: :destroy`)

**Subclass overrides**:
- `BooksController` permits additional `:author` parameter
- `JournalsController` and `ReflectionsController` only override `model` to return their respective STI class

### Inline Page Editing

Pages support click-to-edit inline editing via a Stimulus controller (`inline_edit_controller.js`):

1. Click the page body → switches to a textarea form
2. Edit the content
3. Press **Save** (button or click outside the editor) → Turbo Stream replaces the body in-place
4. Press **Cancel** → reverts to original content

**Behavior**:
- Double-submit prevented via `isSaving` guard flag
- `isSaving` reset on `turbo:submit-end` event (ensures recovery even if a request fails)
- Click-outside triggers a save (not a cancel)
- Journal pages also show editable `page_date` (datetime) and `place` fields

The Turbo Stream response (`update.turbo_stream.erb`) handles both success and error cases:
- **Success**: Replaces the body partial + flashes a "Page updated." notice
- **Error**: Replaces the body partial + flashes validation errors in an alert

### Pagination

Bottom navigation bar rendered by the `_pagination` partial:

```
<<  <  [prev3] [prev2] [prev1] **[current]** [next1] [next2] [next3]  >  >>
```

- Shows up to 7 page links centered on the current page
- Auto-hidden when `total_pages <= 1` (always hidden for Reflections)
- First/Last links (`<<` / `>>`)
- Previous/Next links (`<` / `>`)

### Home Dashboard

The root path (`GET /`) shows a dashboard with three lists:
- **Your Journals** — with links to view and delete
- **Your Books** — with links to view and delete
- **Your Reflections** — with links to view and delete

Each section has a "NEW" button to create a new document of that type.

---

## Database Schema

### `documents`

| Column    | Type    | Notes                                      |
|-----------|---------|--------------------------------------------|
| `id`      | integer | PK                                         |
| `type`    | string  | STI discriminator: Book, Journal, Reflection |
| `name`    | string  | Document title (required)                  |
| `author`  | string  | Only used by Book                          |
| `bookmark`| integer | Last viewed page number (default: 1)       |
| `user_id` | integer | FK to users (required)                     |
| timestamps|         |                                            |

### `pages`

| Column         | Type    | Notes                                          |
|----------------|---------|------------------------------------------------|
| `id`           | integer | PK                                             |
| `body`         | text    | Page content (default: empty string)           |
| `number`       | integer | Page number (default: 1, validated >= 0)       |
| `page_date`    | datetime| Optional — used by Journal                     |
| `place`        | string  | Optional — used by Journal                     |
| `pageable_id`  | integer | Polymorphic FK to document                     |
| `pageable_type`| string  | Polymorphic type: Book, Journal, Reflection    |
| timestamps     |         |                                                |

**Indexes**:
- `[number, pageable_id]` — unique (no duplicate page numbers within a document)
- `[pageable_type, pageable_id]` — polymorphic index
- `[pageable_type, pageable_id]` — **partial unique index** where `pageable_type = 'Reflection'` (enforces single-page constraint at the DB level)

### `users`

| Column         | Type    | Notes                          |
|----------------|---------|--------------------------------|
| `id`           | integer | PK                             |
| `name`         | string  | Required                       |
| `email_address`| string  | Unique, normalized (strip+downcase) |
| `password_digest` | string | BCrypt via `has_secure_password` |
| timestamps     |         |                                |

### `sessions`

| Column     | Type    | Notes                     |
|------------|---------|---------------------------|
| `id`       | integer | PK                        |
| `user_id`  | integer | FK to users                |
| `user_agent` | string | HTTP User-Agent at login  |
| `ip_address` | string | Remote IP at login        |
| timestamps |         |                           |

---

## Models

### `Document` (base)
- `belongs_to :user`
- `validates :name, presence: true`
- Defines abstract `ordered_pages` (raises `NotImplementedError`)

### `Book < Document`
- `has_many :pages, as: :pageable, dependent: :destroy`
- `validates :author, presence: true`
- `ordered_pages` returns pages ordered by `:number`

### `Journal < Document`
- `has_many :pages, as: :pageable, dependent: :destroy`
- `ordered_pages` returns pages ordered by `page_date: :desc, number: :asc`

### `Reflection < Document`
- `has_one :page, as: :pageable, dependent: :destroy`
- `ordered_pages` returns a `Page::ActiveRecord_Relation` via `Page.where(id: page&.id)` (consistent interface for `find_by`/`count`)

### `Page`
- `belongs_to :pageable, polymorphic: true`
- `validates :number, presence: true, numericality: { greater_than_or_equal_to: 0 }`
- Conditional uniqueness: `validates :pageable_type, uniqueness: { scope: :pageable_id }` only for `Reflection` pages

### `User`
- `has_secure_password`
- `has_many :sessions, dependent: :destroy`
- `has_many :documents` (and convenience associations for each STI subclass)
- `normalizes :email_address` → strip + downcase

### `Session`
- `belongs_to :user`
- Tracks `user_agent` and `ip_address`

---

## PagesController (Inline Update)

```http
PATCH /pages/:id
```

- Finds the page with `includes(pageable: :user)` (eager loads owner for auth check)
- Verifies `page.pageable.user == current_user`
- Accepts `page[body]`, `page[page_date]`, `page[place]`
- Responds with Turbo Stream (replaces `dom_id(@page, :body)`) or HTML redirect

---

## Stimulus Controllers

### `inline_edit_controller.js`
- **Targets**: `display`, `form`, `textarea`
- **Actions**: `click->inline-edit#edit`, `click@window->inline-edit#clickOutside`
- **Save**: Calls `formTarget.requestSubmit()` (submits via Turbo), guarded by `isSaving` flag
- **Cancel**: Resets all fields to originals and hides form
- **connect()**: Initializes `isSaving = false`, listens for `turbo:submit-end` to reset the flag

---

## Routes

```ruby
# Auth
resource :session
resources :passwords, param: :token
resources :registrations, only: [ :new, :create ]

# Pages
resources :pages, only: [ :update ]

# Document types (full CRUD)
resources :journals
resources :books
resources :reflections

# Health check
get "/up", to: "rails/health#show"

# Root
root "home#index"
```

---

## Views Structure

```
app/views/
├── layouts/
│   ├── application.html.erb        (main layout with flash container)
│   └── partials/
│       ├── _header.html.erb         (nav: Home, Register/Log out)
│       ├── _footer.html.erb         (logged-in user display + credit)
│       └── _flash_message.html.erb  (alert/notice display)
├── documents/
│   └── show.html.erb                (shared show view for all STI types)
├── home/
│   └── index.html.erb               (dashboard with 3 document lists)
├── books/
│   ├── index.html.erb
│   ├── new.html.erb                 (name + author fields)
│   └── edit.html.erb                (name + author fields)
├── journals/
│   ├── index.html.erb
│   ├── new.html.erb                 (name field)
│   └── edit.html.erb                (name field)
├── reflections/
│   ├── index.html.erb
│   ├── new.html.erb                 (name field)
│   └── edit.html.erb                (name field)
├── sessions/
│   └── new.html.erb                 (sign-in form)
├── registrations/
│   └── new.html.erb                 (sign-up form)
├── passwords/
│   ├── new.html.erb                 (forgot password)
│   └── edit.html.erb                (reset password)
├── pages/
│   └── update.turbo_stream.erb      (Turbo Stream response for inline edit)
├── passwords_mailer/
│   ├── reset.html.erb
│   └── reset.text.erb
├── pwa/
│   ├── manifest.json.erb
│   └── service-worker.js
└── shared/partials/
    ├── _document_header.html.erb    (title + optional author line)
    ├── _pages_container.html.erb    (page body + pagination wrapper)
    ├── _page_body.html.erb          (inline-editable page content)
    └── _pagination.html.erb         (page navigation bar)
```

---

## Commands

```sh
bin/rails server            # Dev server (port 3000)
bin/rails test              # Run model/controller/integration tests
bin/rails test:system       # Run system tests (headless Chrome)
bin/rails test test/models/foo_test.rb:12  # Single test by file:line
bin/rubocop                 # Lint
bin/ci                      # Full CI pipeline (rubocop → audit → brakeman → test → seed)
bin/setup                   # First-time project setup
bin/rails db:migrate        # Run migrations
bin/rails db:seed:replant   # Reseed test database
bin/kamal                   # Deploy commands (console, shell, logs, dbc)
```

---

## Security

- **Rate limiting**: Document creation and session creation are rate-limited to 10 requests per 3 minutes (disabled in test env)
- **Auth check in PagesController**: Verifies page ownership via `page.pageable.user == current_user`
- **Cookie security**: Session cookie uses `httponly: true`, `same_site: :lax`, `secure: Rails.env.production?`
- **Password**: BCrypt via `has_secure_password`, max length 72 characters
- **CI pipeline**: Runs rubocop, bundler-audit, brakeman, tests, and seed verification

---

## Testing

Uses Minitest with parallel workers (threshold: 50). Fixtures use ERB for BCrypt password hash.

**Test helper**: `SessionTestHelper` provides `sign_in_as(user)` / `sign_out`.

**System tests**: Require Chrome. `ApplicationSystemTestCase` disables save-password / notification popups.

**Fixtures**:
- `documents.yml` — `journal_one`, `book_one` (with author), `reflection_one`
- `pages.yml` — `book_page_one`, `book_page_two`, `journal_page_one`, `reflection_page`

---

## Deployment

Uses Kamal for Docker-based deployment with Thruster as the production server. See `config/deploy.yml` for details.

```sh
bin/kamal setup     # First-time server setup
bin/kamal deploy    # Deploy application
bin/kamal console   # Rails console on server
bin/kamal logs      # View logs
```
