# Changelog

All notable changes to this project are documented in this file.

## 0.1.1 - 2026-10-24

- Changed
  - Home index, login and registration pages adapt to mobile screens.
  - Login shows "<name> Logged in Successfully!" or "Try another email address or password." as an inline flash,
    without a full page reload.
  - Opening a document that does not exist or belongs to another user shows the 404 page.
  - Rails 8.1.3 → 8.1.4, solid_queue 1.4.0 → 1.7.0, solid_cable 4.0.0 → 4.1.0, sqlite3 2.9.5 → 2.10.1,
    thruster 0.1.22 → 0.1.27, image_processing 2.0.2 → 2.2.0, bootsnap 1.24.6 → 1.26.0, brakeman 8.0.5 → 8.1.0,
    selenium-webdriver 4.45.0 → 4.51.0.
  - Inline styles moved to shared CSS classes (`display/flex.css`).
- Fix
  - Security scan no longer reports activestorage 8.1.3 (arbitrary file read in variant processing), json 2.21.1 and
    crass 1.0.7 (GHSA-pq4g-8rxf-4g29, CSS sanitizer bypass); crass is now 1.0.8.

## 0.1.0 - 2026-07-15

- Changed
  - Documents open on a paged view with bottom pagination (`<< < 1 2 [3] 4 5 > >>`); each document remembers the last
    page viewed (bookmark) and reopens on it.
  - Page text is edited in place: click to edit, Save/Cancel, click outside or change page to save, 1500-character
    limit with a live counter.
  - Books and Journals get a "+" button to add a new page; Reflections keep a single page.
  - Books have a required author; Journal pages have a date and an optional place, edited from the page toolbar, and
    are ordered newest first.
  - Journal and Reflection headers show their creation date, in the user's time zone.
  - Documents can be edited; several documents can be deleted at once ("Delete Multi", with a confirmation modal;
    clicking a section title selects or deselects all its documents).
  - Per-type index pages removed: all documents are listed on the home page.
  - Document names are required and limited to 50 characters.
  - New layout and styling: header with centered username and logout near Home, sticky pagination, footer link, squared
    look, restyled login, registration, password and document forms.
  - Session cookie is `secure` in production and deleted signed on logout.
  - Rails 8.1.2 → 8.1.3, puma 7.2.0 → 8.0.2, kamal 2.10.1 → 2.12.0, solid_queue 1.3.2 → 1.4.0, sqlite3 2.9.1 → 2.9.5,
    thruster 0.1.19 → 0.1.22, propshaft, bcrypt, bootsnap, jbuilder, selenium-webdriver upgraded.
  - CI uses `actions/checkout` 7, `actions/cache` 6 and `nick-fields/retry` 4; the flaky system-test job is disabled.
  - All document CRUD lives in one `DocumentsController`; migrations folded into the create-table migrations.
- Fix
  - Creating a document no longer leaves an orphan document without a page: document and page are saved in one
    transaction.
  - The bookmark changes only when a page is picked explicitly (`?page=N`), not on every view.
  - A failed page save keeps the edit form open with the text typed, and pagination does not navigate away.
  - A Reflection without a page redirects home ("No pages found for this document.") instead of failing.
  - Logout no longer fails when the session is already gone.
  - "successfully" spelled correctly in flash messages.
- Tests
  - Model tests for Document, Page and User; controller tests for create, show, destroy on Books, Journals and
    Reflections; Turbo Stream tests for page update and creation.

## 0.0.2 - 2026-03-15

- Changed
  - Users see, open and delete only their own documents.
  - Documents can be deleted; creating a document also creates its first page.
  - Tailwind removed in favour of custom CSS; views split into shared partials.
  - Flash messages use `notice` and `alert`.
- Tests
  - System tests for Reflections and Journals, with retries.

## 0.0.1 - 2026-03-12

- Changed
  - Reflections, a Rails 8.1 app for personal writing: Books, Journals and Reflections, each with pages.
  - Account registration, login and password reset with cookie-based sessions.
  - Create and view Books, Journals and Reflections; document creation limited to 10 requests per 3 minutes.
  - CI on GitHub Actions: RuboCop, Brakeman, bundler-audit, importmap audit and tests.
