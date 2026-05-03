# Context: Adding Table Authoring to the Airmark Visual Editor

## Background

**Airmark** (`@airmark/quiver`) is a package of Quillmark "Quill" templates that
render Markdown + YAML frontmatter into PDF Air Force / DAF official documents.
The flagship Quill is `usaf_memo`, which enforces AFH 33-337 Chapter 14
formatting (paragraph numbering, letterhead, signature blocks, indorsements).

The **VisualEditor** (this repo) is the web-facing authoring surface. It edits
Markdown that gets handed to Quillmark for PDF rendering. Quillmark itself is
the engine; Airmark is the template; VisualEditor is the editor.

## What's already true (no Quill changes needed)

Pipe-syntax Markdown tables **already render correctly** through the Airmark
`usaf_memo` Quill:

- `body.typ` captures `table` elements in its first pass and tags them
  `kind: "table"`, which excludes them from AFH 33-337 paragraph numbering.
- `render-memo-table` (in `primitives.typ`) styles them with bold headers,
  0.5pt black borders, body font (Times/Nimbus 12pt), and clean padding.
- Standard GFM alignment markers (`:---`, `---:`, `:---:`) are honored.

So **whatever valid GFM table the editor emits will render properly**. This
project does not need to change the Quill template — it needs to make
authoring pipe tables feel like Microsoft Word.

## The UX problem

Air Force memo authors are not Markdown users. They come from Word, where:

- Insert → Table → pick a grid
- Click cells, Tab between them
- Resize columns by dragging
- Never see syntax

In the current VisualEditor, typing `|col1|col2|col3|` + Enter does not
produce a visible table or any affordance that one is being created. Pipe
syntax is **powerful for people who already know it, invisible to everyone
else**. That's the discoverability gap to close.

## Reference UX from existing tools

**Obsidian + Advanced Tables plugin** — file on disk stays plain GFM pipes,
but the editor:
- Auto-formats pipe alignment as you type
- Tab/Enter navigates cells like a spreadsheet (creates rows on overflow)
- Floating toolbar inserts/deletes rows/columns, toggles alignment
- Sort by column with one click

**Notion** — tables are a structured block (not Markdown). `/table` slash
command inserts a grid; cells edit by click; columns resize by drag. Exports
to GFM pipes (lossy for advanced features).

**Typora** — type `|x|y|` + Enter, and the editor instantly converts the
line into an editable WYSIWYG grid. Underlying file remains Markdown.

## Recommended approach: two-layer UX

### Layer 1 — Discoverability (Notion-style insertion)

Give authors who don't know pipe syntax a path that doesn't require it.

- **Slash command `/table`** — opens a small picker (rows × columns), or
  defaults to 3×3.
- **Toolbar button** — same affordance, mouse-driven.
- Inserts a properly formed skeleton at the cursor:

  ```markdown
  | Header 1 | Header 2 | Header 3 |
  |----------|----------|----------|
  |          |          |          |
  |          |          |          |
  ```

- Cursor lands in the first body cell.

### Layer 2 — Power editing (Obsidian-style live formatting)

For users who *do* type pipes, or once a table exists from Layer 1:

- **Tab** = next cell (creates a new column or row at the edge)
- **Enter** = next row (creates one if at the bottom)
- **Shift+Tab** = previous cell
- Auto-pad columns on edit so pipes stay visually aligned in the source
- Right-click row/column for insert/delete/align operations
- Alignment toggle updates the `:---` markers in the source

### What Layer 1 + Layer 2 buy you

- Word-refugees discover tables via the toolbar without learning Markdown.
- Power users keep their pipe-typing flow.
- The file on disk is always portable GFM Markdown — no proprietary block format.
- Airmark renders both paths identically.

## Output contract

Whatever UI the editor exposes, the **only thing it must produce** is valid
GFM table Markdown. Airmark does the rest.

Optional but recommended:

- Support a **`Table: <caption>`** line directly above a table (Pandoc
  convention). Airmark's renderer can be extended to pick this up and emit
  an auto-numbered caption — coordinate with the Quill repo if you ship
  this UX.

Do **not** invent custom table syntax in the editor. If you need richer
tables (rowspan/colspan, multi-page, cross-referenced figures), there's a
separate planned feature on the Quill side: a `CARD: table` YAML block
(structurally similar to the existing `CARD: indorsement` pattern). The
editor might eventually offer a "structured table" mode that emits that
YAML, but that is post-MVP.

## AFH 33-337 considerations the editor should respect

- The Quill enforces font/size/borders; the editor does **not** need style
  controls (no font picker, no color, no fills). Adding them would just let
  users produce non-compliant Markdown that the Quill then ignores or
  overrides — confusing.
- Tables do **not** consume paragraph numbers. The editor should not show
  numbered paragraphs around tables in any preview.
- A live preview (if any) should mirror Quillmark output, not generic
  Markdown styling — otherwise users will be surprised by the PDF.

## Suggested implementation libraries

If the editor is built on a popular framework, mature table extensions exist:

- **TipTap / ProseMirror** → `@tiptap/extension-table` — covers Tab nav,
  insert/delete, column resize, cell merging out of the box.
- **CodeMirror 6** → no first-party table plugin; closest analog is
  reimplementing Obsidian's Advanced Tables logic.
- **Lexical** → `@lexical/table` — Notion-like block model, exports to
  Markdown via the Markdown plugin.

Pick whichever matches your existing stack rather than swapping editors
just for tables.

## Out of scope for this work

- Quill template changes (none required for basic tables).
- AFH 33-337 caption numbering (Quill-side feature, separate ticket).
- Structured `CARD: table` YAML editor mode (post-MVP).
- PDF export pipeline (already handled by Quillmark + Airmark).

## TL;DR

1. Tables already render. The renderer is solved.
2. Build a `/table` slash command + toolbar button that inserts a GFM
   skeleton — solves discoverability for Word-refugees.
3. Layer Obsidian-style Tab/Enter/auto-format on top — solves ergonomics
   for everyone.
4. Output plain GFM pipes. No custom syntax. No style controls.
5. Don't reinvent — use TipTap/Lexical/ProseMirror table extensions if your
   editor is built on those.
