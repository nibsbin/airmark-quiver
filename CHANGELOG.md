# Changelog

## [v0.7.0] – 2026-04-30

### Bug Fixes

#### `usaf_memo` – Signature block

- **Hanging indent corrected to 0.5em** – AFH 33-337 specifies continuation lines begin under the third character; the indent was previously too wide (2em → 1em → 0.5em).
- **Auto-shift for long names** – The signature block now measures the widest line and shifts left just enough to stay within the right margin, matching the AFH 33-337 "signature block adjusted to the left" example. The block is clamped at the left margin.

#### `usaf_memo` – Blank line spacing

- **Consistent blank line height** – `blank-lines(n)` was rewritten to emit `v(leading * n)` rather than ghost lines, so each blank line occupies exactly one wrapped-line stride regardless of surrounding block spacing.
- **Subject/body gap restored** – A missing blank line between the references/subject section and the first body paragraph was added, per the AFH 33-337 requirement that body text begin on the second line below the subject element.
- **Removed legacy spacing primitives** – `spacing.vertical`, `spacing.line-height`, and the `weak` parameter on `blank-line()` were dead weight after the spacing rewrite and have been removed.

#### `usaf_memo` – Other

- **Decimal font sizes accepted** – The `font_size` field in `Quill.yaml` now accepts decimal values (e.g. `11.5`) in addition to integers; the underlying arithmetic already handled floats correctly.
- **Indorsement date omitted when blank** – Previously, leaving the `date` field empty silently inserted today's date. The date is now omitted entirely when not supplied.

### Breaking Changes

- **`auto_numbering` parameter removed** – Paragraph auto-numbering configuration has been removed and paragraph formatting simplified.
- **`BODY` field removed** – The top-level `BODY` schema field has been dropped.
