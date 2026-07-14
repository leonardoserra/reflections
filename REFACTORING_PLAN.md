# Refactoring Plan — Reflections

## Phase 1 — Bug Fixes (high priority)

### 1.1 Reflection nil page guard
- **File**: `app/controllers/documents_controller.rb` (`show` action)
- **What**: If `@current_page` is nil (Reflection page deleted), redirect to document with an alert
- **Done**: ✅

### 1.2 Validation error keeps form open
- **File**: `app/views/pages/update.turbo_stream.erb`, `app/views/shared/partials/_page_body.html.erb`
- **What**: On validation error, render form visible instead of hidden; preserve original body in `data-original-body`
- **Done**: ✅

### 1.3 Pagination save-failure guard
- **File**: `app/javascript/controllers/inline_edit_controller.js`
- **What**: Check `event.detail.success` before navigating after pagination click during editing
- **Done**: ✅

### 1.4 Journal header date
- **File**: `app/views/shared/partials/_document_header.html.erb`
- **What**: Use `document.created_at` instead of `current_page.created_at`
- **Done**: ✅

## Phase 2 — Missing Tests (medium priority)

### 2.1 Model tests
- **Files**: `test/models/document_test.rb`, `test/models/page_test.rb`, `test/models/user_test.rb`
- **What**: Test validations — Document `name` presence, Page `body` max length, Page number/Reflection uniqueness, User email/name presence
- **Done**: ✅

### 2.2 Controller tests (create/destroy/show/index)
- **Files**: `test/controllers/books_controller_test.rb`, `test/controllers/journals_controller_test.rb`, `test/controllers/reflections_controller_test.rb`
- **What**: Add tests for `show`, `create`, `destroy`, `index` actions
- **Done**: ✅

### 2.3 PagesController tests
- **File**: `test/controllers/pages_controller_test.rb`
- **What**: Test Turbo Stream update (success + validation error) and page creation
- **Done**: ✅

## Phase 3 — Code Quality (low priority)

### 3.1 Extract `journal_page?` helper
- **File**: `app/models/page.rb`
- **What**: Add `journal_page?` method to Page model; use in views instead of string comparisons
- **Done**: ✅

### 3.2 De-duplicate turbo_stream template
- **File**: `app/views/pages/update.turbo_stream.erb`
- **What**: Hoist common `turbo_stream.replace` out of the conditional
- **Done**: ✅

### 3.3 Remove `hello_controller.js`
- **File**: `app/javascript/controllers/hello_controller.js`
- **What**: Delete unused default controller
- **Done**: ✅

### 3.4 Fix `padding.css`
- **File**: `app/assets/stylesheets/spacing/padding.css`
- **What**: Remove unused/broken file entirely
- **Done**: ✅

### 3.5 Add `User#name` validation
- **File**: `app/models/user.rb`
- **What**: Add `validates :name, presence: true`
- **Done**: ✅
