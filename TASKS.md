# Coding Tasks

Two self-contained coding tasks for the **GOV.UK Forms Admin** application (Ruby on Rails 8,
PostgreSQL). Each is scoped to fit comfortably within a single ~2 hour session, including writing
tests and getting a green build.

Before starting either task:

```bash
./bin/setup                 # install dependencies and prepare the database
bundle exec rspec           # confirm a green baseline
bundle exec rubocop         # confirm a clean lint baseline
```

Both tasks should follow the existing conventions in the repo (RSpec for tests, RuboCop GOV.UK for
style, i18n for user-facing strings).

---

## Task 1 (Small) — Make report CSV download filenames filesystem-safe

**Type:** Bug fix / small code change
**Estimated effort:** 30–45 minutes
**Primary file:** `app/controllers/reports_controller.rb`

### Background

The reports section lets an admin download report data as CSV. The download filename is built by the
private `csv_filename` helper in `ReportsController`:

```ruby
def csv_filename(base_name)
  "#{base_name}-#{Time.zone.now}.csv"
end
```

`Time.zone.now` interpolates to a string like `2026-07-08 16:28:00 +0100`, so the generated filename
becomes something like:

```
live_forms_report-2026-07-08 16:28:00 +0100.csv
```

That filename contains **spaces and colons**. Colons are invalid in filenames on Windows/macOS and
the spaces can be awkward to handle in shells and download managers. The timestamp should be
formatted into a safe, sortable form instead.

### Goal

Produce a clean, unambiguous, filesystem-safe timestamp in every report CSV filename, e.g.:

```
live_forms_report-20260708-162800.csv
```

### Suggested approach

1. Update `csv_filename` to format the timestamp deterministically, for example
   `Time.zone.now.strftime("%Y%m%d-%H%M%S")` (or `.utc.iso8601` with `:`/`+` stripped — pick one and
   be consistent). Avoid characters that are invalid or awkward in filenames: spaces, `:`, `+`.
2. Confirm the change flows through everywhere `csv_filename` is used — the feature report
   downloads (`questions_feature_report`, `forms_feature_report`), the answer-type questions
   download (`questions_csv_filename`), and the `live_forms_csv` / `live_questions_csv` actions.

### Acceptance criteria

- [ ] Report CSV filenames contain no spaces, colons, or `+` characters.
- [ ] The filename still includes the report base name and a timestamp so downloads remain
      distinguishable and sortable.
- [ ] A request/controller spec asserts the `Content-Disposition` filename matches a safe pattern
      (e.g. `live_forms_report-YYYYMMDD-HHMMSS.csv`). Freeze time in the spec so the assertion is
      deterministic.
- [ ] `bundle exec rspec spec/requests` (reports specs) and `bundle exec rubocop` both pass.

### Where to look

- `app/controllers/reports_controller.rb` — `csv_filename`, `questions_csv_filename`,
  `live_forms_csv`, `live_questions_csv`, `questions_feature_report`, `forms_feature_report`.
- Existing report specs under `spec/requests/` and `spec/controllers/` for the pattern to copy.

### Commit & push

```bash
git checkout -b fix/report-csv-filename
git add -A
git commit -m "Make report CSV download filenames filesystem-safe"
git push -u origin fix/report-csv-filename
gh pr create --fill --base main
```

---

## Task 2 (Medium) — Remove duplication in `ReportsController` feature-report actions

**Type:** Refactor (with optional small feature extension)
**Estimated effort:** 1.5–2 hours
**Primary file:** `app/controllers/reports_controller.rb`

### Background

`ReportsController` has grown a large family of near-identical "feature report" actions. Almost every
one repeats the same four lines, differing only by which method is called on
`Reports::FeatureReportService`:

```ruby
def forms_with_payments
  tag = params[:tag]
  forms = Reports::FormDocumentsService.form_documents(tag:)
  forms = Reports::FeatureReportService.new(forms).forms_with_payments

  forms_feature_report(tag, params[:action], forms)
end

def forms_with_exit_pages
  tag = params[:tag]
  forms = Reports::FormDocumentsService.form_documents(tag:)
  forms = Reports::FeatureReportService.new(forms).forms_with_exit_pages

  forms_feature_report(tag, params[:action], forms)
end
# ...and roughly a dozen more of exactly this shape
```

The `selection_questions_with_*` actions follow the same pattern via
`questions_feature_report(..., type: :selection_questions)`. This duplication makes the controller
long, noisy, and error-prone: adding a new report means copy-pasting boilerplate, and a mistake in
one copy is easy to miss.

### Goal

Collapse the repeated boilerplate so that each report is described by *data* (its feature-service
method name and its render `type`) rather than a hand-written method, while keeping every existing
route, URL, template, and CSV download working exactly as before. **This is a behaviour-preserving
refactor** — no user-visible change.

### Suggested approach

Pick whichever of these fits the codebase's style best (investigate first, then decide):

- **Option A — a private dispatcher.** Introduce a small private helper such as
  `render_feature_report(feature_method, kind:, type:)` that performs the shared
  `form_documents` → `FeatureReportService` → `forms_feature_report`/`questions_feature_report`
  sequence. Each public action becomes a one-liner delegating to it.
- **Option B — declarative definitions.** Define a constant mapping (action ⇒ `{ feature_method,
  kind, type }`) and metaprogram the actions with `define_method`, or drive a single generic action.
  Only choose this if it stays readable and Rubocop-clean; a wall of `define_method` can be worse
  than the duplication it removes.

Whichever route you take:

1. Preserve the exact `params[:action]`-based report name passed into the CSV filename and template
   locals — several downstream strings depend on it, so the report name must stay identical.
2. Keep the `forms` vs `questions` distinction (they render different templates and CSV columns).
3. Keep the `type:` argument for the specialised cases (`:forms_with_routes`,
   `:selection_questions`, `:selection_questions_with_none_of_the_above`).
4. Leave the non-boilerplate actions alone (`users`, `add_another_answer`, `last_signed_in_at`,
   `selection_questions_summary`, `contact_for_research`, `index`, `features`).

### Optional feature extension (only if time allows)

Add CSV download support to one report that currently lacks it, reusing
`Reports::FormsCsvReportService` / `Reports::QuestionsCsvReportService` and the existing
`?format=csv` branch in `forms_feature_report` / `questions_feature_report`. This demonstrates that
the refactor makes adding a new capability a one-line change rather than a copy-paste.

### Acceptance criteria

- [ ] All existing report routes and named path helpers (see `config/routes.rb`, the `/reports`
      scope) continue to resolve and render the same templates.
- [ ] CSV downloads (`?format=csv`) still return the same data with the same filename shape.
- [ ] The controller has materially less duplicated code (roughly a dozen boilerplate actions
      collapsed).
- [ ] Existing report specs still pass unchanged; add specs for any new dispatcher/mapping so the
      indirection is covered.
- [ ] `bundle exec rspec` and `bundle exec rubocop` both pass.

### Where to look

- `app/controllers/reports_controller.rb` — the repeated `forms_with_*` /
  `selection_questions_with_*` actions and the private `forms_feature_report` /
  `questions_feature_report` helpers.
- `config/routes.rb` — the `/reports` scope (lines defining `report_*` routes).
- `app/services/reports/` — `FormDocumentsService`, `FeatureReportService`, and the CSV report
  services these actions call.
- `spec/requests/` / `spec/controllers/` — existing report coverage to run and extend.

### Commit & push

```bash
git checkout -b refactor/reports-controller-feature-actions
git add -A
git commit -m "Remove duplication in ReportsController feature-report actions"
git push -u origin refactor/reports-controller-feature-actions
gh pr create --fill --base main
```
