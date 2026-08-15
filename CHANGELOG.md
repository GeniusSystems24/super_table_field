# Changelog

All notable changes to **super_table_field** are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning is [SemVer](https://semver.org/).

## [2.7.2] - 2026-08-16

### Changed

- Updated `super_auto_suggestion_box` to `>=1.1.0 <2.0.0`.
- Migrated combo integration to the 1.1.0 `Super`-prefixed APIs:
  `SuperAutoSuggestionsBox`, `SuperAutoSuggestionsController`,
  `SuperAutoSuggestionsSource`, and `SuperAutoSuggestionsItem`.
- Moved combo `source` binding to `SuperAutoSuggestionsBox` while keeping
  controller state separate, matching the 1.1.0 source/controller contract.
- Updated custom suggestion metadata fields from `label` / `description` to
  `titleText` / `descriptionText`.
- Updated README, migration guidance, skill instructions, tests, and example
  screens for the 1.1.0 API.

## [2.7.1] - 2026-08-15

### Fixed

- Editable text, numeric, and date cells now safely handle nullable focus nodes
  while requesting focus after an editor opens.

## [2.7.0] - 2026-08-12

### Added

- Added optional `SuperTable.style` support through the new `SuperTableStyle`
  API. Leaving `style` as `null` preserves the existing/default table
  appearance.
- Added theme-aware predefined styles:
  `plainMinimal`, `light`, `medium`, `dark`, `accent`, `bandedRows`,
  `bandedColumns`, `headerEmphasis`, `gridBordered`, and `subtleBorders`.
- Added `SuperTableStyleOptions`, `SuperTableAreaStyle`,
  `SuperTableBorderStyle`, and `SuperTableStylePreset` for custom table
  styling, banded rows/columns, first/last column emphasis, headers, group rows,
  group footer/subtotal rows, totals, selected, hovered, focused, and disabled
  states.
- Added a dedicated example screen, `20 - Table styles`, comparing the default
  no-style table with every predefined style using grouped ERP/accounting data,
  group footers, selected cells, and totals.
- Added focused widget tests for the opt-out contract, preset render safety,
  style-option flags, and conditional row-style precedence.

### Changed

- Table rendering now resolves selected style presets from the active
  `SuperThemeData`, `SuperTableSkin`, ambient typography, and Material color
  scheme while keeping table style independent from controller/data structure.
- Conditional `SuperRowStyle` and `CellStyle` overrides continue to take
  priority over preset body styling.

## [2.6.0] - 2026-08-10

### Changed

- Migrated the package to `super_core >=3.3.0 <4.0.0`.
- Updated `super_auto_suggestion_box` to `>=1.0.0 <2.0.0` and
  `super_form_field` to `>=1.8.1 <2.0.0`.
- Migrated combo columns to the `super_auto_suggestion_box` 1.0.0 raw-value API:
  static sources, row-scoped sources, `itemBuilder`, and `onSelected` now use
  raw `T` values while the table editor derives suggestion metadata internally.
- Added optional `SuperComboColumn.suggestionBuilder` for custom suggestion
  labels, descriptions, keywords, icons, trailing metadata, and grouping while
  keeping combo sources raw-value based.
- Updated all `SuperMaterialThemeData.light` / `.dark` examples to provide the
  now-required `SuperTextTheme` values for `textTheme` and `primaryTextTheme`.
- Migrated table body, display, and monospace font-family reads from
  `SuperThemeData.tokens` to the ambient `SuperTextTheme`, so host typography
  overrides propagate consistently into tables, overlays, editors, and demos.
- Migrated gallery typography reads away from the removed
  `SuperThemeData.textTheme` getter to `context.superTextTheme`.
- Updated README, migration guidance, example metadata, and agent skill rules for
  the `super_core 3.3.0` typography contract.

### Migration

- `SuperThemeData` no longer owns typography. Use `context.superTextTheme` (or
  `SuperMaterialThemeData.of(context).textTheme`) for branded text styles.
- `SuperMaterialThemeData.light` and `.dark` require explicit `textTheme` and
  `primaryTextTheme` values of type `SuperTextTheme`.
- Do not derive body/display/mono text families from `SuperThemeData.tokens`;
  configure them on `SuperTextTheme`.
- Combo source builders should now return raw values, for example
  `SuggestionSources.list<String>(units)` or `Future<List<String>>` from async
  sources. `SuperComboColumn.onSelected` receives the raw selected value.

## [2.5.1] - 2026-07-29

### Changed

- Editable cells now use `super_form_field` controls for text, numeric, date,
  enum/select, and boolean editors, while combo columns continue to use the real
  `AutoSuggestionsBox`.
- In editable mode, Enter opens the active cell editor; Enter inside the editor
  now commits and closes editing without moving to the next row.
- Added `super_form_field: ^1.5.0` as a direct dependency.
- Example 19 now showcases every column type plus common table/controller
  usages: grouping, totals, filters, saved views, validation, change tracking,
  row actions, fill actions, and interaction callbacks.
- Example 19 readable mode now includes a loading-mode selector for off, pages,
  load-more, and infinite-scroll pagination.
- Added `SuperTable.showCopyJsonButton`, `showUndoButton`, and `showRedoButton`
  to control the editable action-bar buttons individually.
- The shortcuts dialog is now opened with F1; the editable action-bar shortcuts
  button was removed.

### Fixed

- Typed column `validator` / `onChange` callbacks no longer throw when invoked
  through editable enum/select commits.
- Editing no longer throws when a committed cell mirrors into an immutable
  map-backed row; the cell value remains committed in `SuperRow.cells`.
- Editable boolean cells now render as a compact checkbox only, without the
  `Checked` / `Unchecked` caption.
- Editable boolean cells now stay in edit mode while Space toggles their draft
  value; Enter commits the current draft and closes the editor.
- Editable boolean cells now take keyboard focus correctly, so Space/Enter/Tab
  shortcuts work while editing.
- Space no longer starts editing from display mode; enter edit mode first with
  Enter, then use Space for boolean draft toggles.
- `SuperComboColumn.sourceController` and `cellController` no longer throw
  runtime type errors in editable mode when combo values are typed, such as
  `String`.

## [2.5.0] — 2026-07-29

### Added

- Added package-level localization for SuperTable UI strings in English (`en`)
  and Arabic (`ar`) through `flutter_localizations`, ARB files, and the exported
  `SuperTableLocalizations` helper.
- Exported `SuperTableTranslation` and `SuperTableLocalizations` from the main
  `super_table_field.dart` barrel.
- Localized table chrome, menus, filters, column manager, shortcuts dialog,
  validation panel, mini calendar labels, pagination/status text, and
  controller notification/validation messages.

### Changed

- The example app now registers
  `SuperTableLocalizations.localizationsDelegates` and
  `SuperTableLocalizations.supportedLocales`.
- `intl_utils` is used as a development dependency for generated translations.

### Migration

Register the package localization helpers on the host `MaterialApp`:

```dart
MaterialApp(
  localizationsDelegates: SuperTableLocalizations.localizationsDelegates,
  supportedLocales: SuperTableLocalizations.supportedLocales,
  // ...
)
```

---

## [2.4.0] — 2026-07-27

### Changed

- Migrated the package from `super_core` 2.4.x to `super_core ^3.0.0`.
- Updated `super_auto_suggestion_box` to exact version `0.9.0`.
- Raised the package and example minimums to Dart 3.8 and Flutter 3.32.
- Moved spacing and radius reads from `SuperTokensData` to the responsive
  `context.superTheme.spacing` bundle.
- Replaced the gallery's hand-built cards with `SuperSectionCard` and its page
  frame with `SuperScaffold`.
- Simplified example theme setup to `SuperMaterialThemeData.light()` and
  `SuperMaterialThemeData.dark()`; the suggestion-box theme derives from it.
- Replaced duplicated static font-family constants with the active
  `SuperThemeData.tokens` font families, so host font overrides propagate into
  the table.
- Replaced deprecated `Color.withOpacity` calls with `Color.withValues`.
- Removed missing asset declarations and stale generated example metadata.

### Migration

See [MIGRATION.md](MIGRATION.md) for consumer changes and validation commands.

---

## [2.3.0] — 2026-07-16

### Changed

- Upgraded to **super_core 1.1.0**. No source changes required — surfaces are
  read via `SuperThemeData.of(context)`, which `SuperMaterialThemeData` (now a
  `ThemeData` subclass) registers automatically, so palette, brightness **and**
  the responsive `SuperDeviceMode` (mobile / tablet / desktop) tokens flow
  through with no extra wiring:

  ```dart
  MaterialApp(
    theme:     SuperMaterialThemeData.light(mode: SuperDeviceMode.desktop),
    darkTheme: SuperMaterialThemeData.dark(mode: SuperDeviceMode.desktop),
  );
  ```

- Minimum raised to `dart >=3.8.0`, `flutter >=3.32.0`.
- Bumped `super_auto_suggestion_box` constraint to `^0.8.0`.

---

## [2.2.0] — 2026-07-06

The **interaction & column-config release** — two cooperating additions, both
opt-in and **fully backward compatible**: host interaction callbacks, and a
runtime column manager (reorder · show/hide · pin) with the API and saved-view
persistence behind it.

### Added — Interaction events (`SuperInteractions`)

- **`SuperTable(interactions: SuperInteractions<R>(...))`** — a bag of optional
  host callbacks the View fires in response to gestures and state changes. They
  are pure **observers**: the grid still selects, edits, sorts and opens its
  menus exactly as before; a null callback costs nothing.
  - **`onCellTap`** / **`onCellDoubleTap`** / **`onCellSecondaryTap`** — primary
    / double / right-click on a body cell. Each receives a **`SuperCellInteraction<R>`**
    (view + source index, `column`, `row`, `cell`, raw `value`, `controller`,
    and the `globalPosition` for popping a host overlay at the tap).
  - **`onRowTap`** — a row-number gutter tap (which selects the whole row).
  - **`onRowActivate`** — the canonical "open this record" hook: a double-tap on
    a readable-mode row **or** Enter with the cursor on a row in readable mode.
    (Editable mode keeps double-tap for the cell editor; activation is a no-op
    there.) Receives a **`SuperRowInteraction<R>`**.
  - **`onSelectionChanged`** — a **`SuperSelectionSnapshot<R>`** (cursor, anchor,
    selected rows, every selected `CellPos`, and the numeric `stats`).
  - **`onSortChanged`** — a **`SuperSortSnapshot`** (`columnKey` / `columnLabel`
    / `ascending`).
- Selection + sort callbacks are **diffed after the controller settles**, so
  they also fire for **programmatic** changes (`selectCellAt`, `sortBy`,
  `clearSort`, …), not just pointer/keyboard ones.
- New entities: `SuperInteractions`, `SuperCellInteraction`,
  `SuperRowInteraction`, `SuperSelectionSnapshot`, `SuperSortSnapshot`.

### Added — Runtime column config

- **`showSuperColumnManager(context, controller)`** — a dialog to **drag-reorder**
  columns, **toggle visibility** (eye), and **pin** each to an edge (left ·
  none · right), with a live *N of M shown* count and a *Reset*.
- **`SuperTable(columnManager: true)`** (default) — adds **Pin ▸**, **Hide
  column**, and **Manage columns…** entries to every header menu. Set false to
  hide the entries; the programmatic API still works.
- Controller API:
  - **`setColumnPin(key, SuperPin)`** / **`cycleColumnPin(key)`** — freeze a
    column to an edge at runtime, overriding its declaration; **`pinOf(col)`**
    reports the effective pin. Setting the pin back to the declared value drops
    the override.
  - **`showColumn(key)`** / **`toggleColumnVisible(key)`** — the inverse of the
    existing `hideColumn`; **`isColumnVisible(key)`** queries it. (User-toggled
    visibility stays distinct from absolute `hidden:` columns, which can never
    be shown.)
  - **`moveColumn(key, toIndex)`** / **`setManagedOrder(keys)`** — reorder by
    key; **`managedColumns`** is the full renderable set (including user-hidden
    columns) in manager order.
- **Pins persist in saved views.** `SuperViewState` gains a `pins` map
  (`columnKey → 'left'|'right'|'none'`); `viewStateJson()` captures runtime pin
  overrides and `applyViewJson()` restores them alongside order / widths /
  visibility. `resetViewState()` clears them.

### Changed

- Header cells now show the pin marker for **runtime** pins (`pinOf`), not only
  declared ones.
- `example/` gains **17 · Interaction events**, **18 · Column config**, and
  **19 · Showcase** (an end-to-end ERP screen combining both new features with
  grouping, totals, change tracking and export).

## [2.1.0] — 2026-07-03

The **forms & views release** — five roadmap items land at once, everything
opt-in and **fully backward compatible**, plus four correctness fixes.

### Added — Validation summary & unique columns

- **`controller.validateAll({markCells})`** — the full validation pass over
  **every row** (not just the visible page): built-in type rules, the new
  `unique:` constraint, then each column's `validator`. Returns one
  **`SuperValidationIssue`** per failing cell (row + `sourceIndex`,
  `columnKey` / `columnLabel`, message, and a `cell` view position when the
  cell is on screen). `markCells:` (default true) lights the per-cell badges.
- **`controller.isValid`** — `validateAll` with no side effects; gate a
  *Post* / *Save* on it.
- **`SuperColumn(unique: true)`** (and on all typed columns) — values must be
  unique across rows, compared as display text, case-insensitively; blanks are
  exempt. Enforced at commit time and in `validateAll`. For natural keys:
  SKU, account code, document number.
- **`showSuperValidationPanel(context, controller)`** — dialog listing every
  issue with **jump-to-cell**; empty state confirms all rows valid.
- **Footer issue chip** — editable grids show a tappable **⚠ N issues** chip
  (backed by `controller.errorCount`) whenever cell badges are lit.

### Added — Saved views (`SuperViewState`)

- **`controller.viewState({includeFilters})` / `viewStateJson()`** — snapshot
  the user's column order, width overrides, visible-keys list, sort,
  group-bys, collapsed group paths, and (by default) the whole
  `SuperFilterState`, as one JSON-serialisable **`SuperViewState`**.
- **`applyViewState` / `applyViewJson`** — restore a saved view. Unknown
  column keys (schema drift) are dropped; missing columns keep their natural
  position; widths re-clamp; a null `filters` leaves live filters untouched.
- **`resetViewState({clearFilters})`** — back to the column declarations.

### Added — Fill down / fill right

- **`controller.fillDown()` / `fillRight()`** + **`⌘/Ctrl+D`** (range spanning
  rows) and **`⌘/Ctrl+R`** — Excel semantics: copy the range's top row
  downward / leading column rightward. Values are coerced per target column
  (incompatible cells skipped), `cellEditable` locks respected, every write
  validated, **one undo step**, `onNotify` reports the fill count. With a
  single cell, pulls from the neighbour above / to the left. `⌘D` on a
  single row still **duplicates** it (unchanged since 0.3.0).

### Added — Group footers

- **`SuperTable(groupFooters: true)`** — in readable grouped mode, each
  expanded group closes with a **Σ subtotal row**: group label in the first
  column, each aggregate aligned **under its own column** (count → group row
  count; avg → 2 decimals; currency → `$`), matching the totals-row grammar.
  Render-list consumers: `RenderItem` gains `isGroupFooter` +
  `RenderItem.groupFooter(...)`; footers never enter the selectable `view`.

### Added — Per-cell / per-row revert

- **`controller.revertCell(row, columnKey)`** and **`revertRow(row)`** —
  restore dirty cells to the change-tracking baseline; reverting an **added**
  row removes it. Both sync the backing object, record undo, fire `onChange`.
- Row context menu (editable, `trackChanges:` on) gains **Revert cell** /
  **Revert row**, enabled only when dirty.

### Fixed

- **Undo/redo now restores cell values.** History entries snapshot per-cell
  values + errors (and the deleted-row log) keyed by `SuperRow.id`, instead of
  only row membership — previously undoing a cell edit was a no-op because
  cells are mutated in place. Snapshots are taken **before** each mutation;
  row identity is preserved so selection / expansion / combo caches survive.
- **Raw-draft commits coerce numerics.** Committing a number/currency cell by
  clicking another cell stored the draft **String**; it now stores a clamped
  `num`, keeping change tracking and export types clean.
- **Column-filter clear no longer disables the advanced filter.** Clearing a
  filter that was never set used to flip `advancedActive` off as a side
  effect.
- **Deleted rows release their combo resources.** `deleteRow` / `clearTable` /
  `revertRow` prune the per-cell combo registries; `updateRows` resets them
  and clears stale undo history from the previous dataset.

### Changed

- Keyboard-shortcuts dialog documents `⌘D` dual behaviour and `⌘R`.
- `example/` gains **15 · Validation & saved views** and **16 · Fill · group
  footers · revert**.

## [2.0.0] — 2026-06-30

Additive, **fully backward compatible**. Expandable row panels for Readable
Mode with configurable keyboard shortcuts.

### Added — Expandable rows (`SuperRowExpansion`)

- **`SuperTable(expansion: SuperRowExpansion(...))`** — attach animated
  expand/collapse panels to every data row in Readable Mode. Panels are built
  on demand by `SuperRowExpansionBuilder<R>` receiving the live `BuildContext`,
  controller, and `SuperRow<R>`. Has zero effect in Editable Mode.
- **`SuperRowExpansion`** — immutable configuration object:
  - `builder` — required content builder.
  - `defaultHeight` (120 px) — panel height when `heightBuilder` returns null.
  - `heightBuilder` — per-row `double?` override, so each row can declare its
    own panel size independently of others.
  - `mode` — `SuperRowExpansionMode.multi` (default, any number of rows open)
    or `SuperRowExpansionMode.single` (accordion: opening a new row collapses
    the previous one).
  - `animationDuration` (220 ms) and `animationCurve` (easeInOut).
  - `keymap` — see below.
- Animation uses `ClipRect` + `AnimatedAlign(heightFactor: 0 → 1)`, the same
  technique as Flutter's `ExpansionTile`. The pinned gutter pane mirrors the
  height via `AnimatedContainer(height: 0 → panelH)` with identical parameters,
  keeping both lists in pixel-perfect sync at every animation frame.
- Expansion state lives entirely in `_SuperTableState` (`Set<int>` of
  `SuperRow.id`). It is decoupled from the controller — data, undo/redo,
  selection, and change-tracking are unaffected.
- `itemExtent` on both body and gutter `ListView.builder`s is set to `null`
  when `expansion != null`, allowing variable-height items. `_ensureVisible`
  skips the vertical scroll calculation in this mode.

### Added — Expansion keyboard shortcuts (`SuperRowExpansionKeymap`)

- **`SuperRowExpansion(keymap: SuperRowExpansionKeymap())`** — opt in to
  keyboard control. When `keymap` is null (default) no shortcuts are registered
  and the existing navigation (arrow keys, Tab, etc.) is completely unchanged.
- **`SuperRowExpansionKeymap`** — a configurable pair of shortcuts:

  | Action | Default |
  |--------|---------|
  | Expand focused row | **Ctrl+Shift+↓** (⌘+Shift+↓ on macOS) |
  | Collapse focused row | **Ctrl+Shift+↑** (⌘+Shift+↑ on macOS) |

- **`SuperExpansionShortcut`** — declarative shortcut descriptor: `key`
  (`LogicalKeyboardKey`) + `ctrl` / `shift` / `alt` modifier flags. `ctrl:
  true` matches both ⌃ Control and ⌘ Command on macOS, consistent with the
  rest of SuperTable's key handling. Shortcuts are checked in `_onKey` before
  the arrow-key `switch`, so `Ctrl+Shift+↓/↑` never leaks to `moveSel`.
- Shortcuts respect `SuperRowExpansionMode`: expanding in `.single` mode
  auto-collapses any other open row.
- The footer status bar appends **⌘⇧↓ expand · ⌘⇧↑ collapse** hints when a
  keymap is active.

### Added — Example 14

- `example_14_expandable_rows.dart` — a journal-entry ledger with a
  `_LineItemsPanel` expansion widget, per-row heights driven by line-item
  count, runtime Multi/Single mode toggle, and `SuperRowExpansionKeymap()`
  enabled by default.

## [1.1.0] — 2026-06-27

Additive, **fully backward compatible**. Two cooperating capabilities for
report-style grids: aggregate **in code**, and keep dimensions that drive those
aggregates **off the screen**.

### Added — Programmatic group aggregation

- **`controller.groupAggregates({groupBy, aggregateColumns})`** returns a nested
  tree of **`SuperGroupAggregate`** nodes (one per group, with `children` for
  multi-level grouping). Each node carries its `rows`, `count`, and an
  `aggregates` map (`columnKey → num?`). Honours the active filter (+ sort) and
  is independent of the on-screen group headers and collapse state. `groupBy`
  defaults to the live `groupKeys`; `aggregateColumns` defaults to every column
  with an aggregate.
- **`controller.aggregateBy(groupColumnKey, valueColumnKey, {agg, aggregator, filtered})`**
  — a single-level group-by → `groupValue → aggregate` map, computed
  independently of the table's live grouping.
- **`controller.grandTotals({columns, filtered})`** — the programmatic form of
  the totals row (`columnKey → aggregate` over the whole filtered set).
- **`controller.aggregateColumn(key, {rows, agg, aggregator})`** — aggregate one
  column over any row set (defaults to the live view).
- **`SuperColumnLogic.aggregate(col, rows, {agg, aggregator})`** now accepts
  optional overrides, so any reducer can be applied to any column on demand.
- New entity: **`SuperGroupAggregate`** (`flatten()`, `aggregate(key)`,
  `toJson()`).

### Added — Permanently-hidden columns

- **`SuperColumn(hidden: true)`** (on the base column and every typed subclass).
  A hidden column is **never rendered** (header, body, filter row, totals, group
  headers), is excluded from **export** and the **column chooser**, and **cannot
  be revealed** via `setVisibleKeys` / `hideColumn` — yet it stays fully usable
  **by key** for **filtering** (`setColumnFilter` / advanced clauses),
  **grouping** (`toggleGroup` / `groupBy`), and **aggregation** (all of the APIs
  above). Use it for backing dimensions (region, supplier, normalized keys) that
  steer the data without occupying a column.
- **`controller.dataColumns`** (everything renderable) and
  **`controller.hiddenColumns`** getters.

### Added — Display formatter

- **`SuperColumn(formatter: (value, row) => String)`** on the base column and
  every typed subclass — overrides the built-in cell rendering (pills, bars,
  currency, …) with the plain text it returns. **Display-only**: sorting,
  filtering, grouping, export and editing all keep the raw value. New typedef
  **`SuperColumnFormatter`**.

### Changed — Header

- Column headers **no longer display the data-type tag** (`TEXT` / `NUMBER` / …).
  Each header now shows just the column label and its sort / pin / group / drag
  affordances, at a single flat height. **`SuperTable(showTypeTags:)` is
  deprecated and ignored** — kept for source compatibility.

### Added — Sort cycling on column header left-click

- **Left-clicking a sortable column header** now cycles through three states:
  1st click → ascending ↑ · 2nd click → descending ↓ · 3rd click → **clear sort**
  (returns to natural row order). The right-click / touch header menu gains a
  contextual **Clear sort** entry when that column is the active sort column.
- **`controller.clearSort()`** — programmatically remove any active sort.
- **`controller.setGroupKeys(List<String> keys)`** — set the active group-by
  columns in one call (replaces the current set, resets collapse state). Accepts
  **hidden column keys**: `c.setGroupKeys(['region'])` groups the table by the
  invisible `region` column and the table **immediately renders group-header rows**
  with the column label, group value, count, and visible-column aggregates — the
  column itself remains absent from the header and body.

## [1.0.0] — 2026-06-19

The **ERP release** — first stable. A focused set of additions that turn the
grid into a staging surface for backend writes, plus the operators ERP teams
expect from a DataGridView. **Fully backward compatible** — every new capability
is opt-in; existing `0.5.0` code is unchanged.

### Added — Change tracking

- **`SuperTableController(trackChanges: true)`** captures a per-cell *baseline*
  and tracks every edit against it. No tracking overhead unless you opt in.
- **`controller.changes`** returns a **`SuperChangeSet`** — `added` / `modified`
  / `deleted` partitions of `SuperRowChange`s; each modified row carries its
  `SuperCellChange` list (`columnKey`, `oldValue`, `newValue`). `toJson()` yields
  a ready-to-post `{added, modified, deleted}` payload.
- **`hasChanges`**, **`rowStateOf(row)`** (`SuperRowState.pristine|added|modified|deleted`),
  **`isRowDirty(row)`**, **`isCellDirty(row, key)`**.
- **`acceptChanges()`** re-baselines after a successful save; **`rejectChanges()`**
  reverts modified cells, restores deleted rows to their positions, and drops
  added rows.
- Dirty cells render a small accent corner marker in the grid.
- New entities: `SuperChangeSet`, `SuperRowChange`, `SuperCellChange`,
  `SuperRowState`. `SuperCell` gained `baseline` / `isDirty` / `markBaseline` /
  `revertToBaseline`; `SuperRow` gained `isNew`.

### Added — Export

- **`toCsv()`**, **`toTsv()`**, **`toDelimited(delimiter:)`**, **`toJsonRows()`**,
  and **`copyCsvToClipboard()`** on the controller. Output honours the active
  filter, sort, and (by default) the on-screen column order.

### Added — Aggregations

- **`SuperAgg.min`**, **`SuperAgg.max`**, and **`SuperAgg.custom`** with a per-column
  **`aggregator`** (`num? Function(List<SuperRow>)`) for weighted averages, running
  balances, distinct counts, etc.
- **`aggLabel`** renames the aggregate shown in group headers.

### Added — Selection statistics

- **`controller.selectionStats`** returns a **`SuperSelectionStats`**
  (`sum` / `average` / `min` / `max` / `count` / `numericCount`) over the selected
  numeric cells. The grid footer shows it automatically for 2+ numeric cells.

### Added — Editing

- **`SuperTableController(cellEditable: (col, row) => bool)`** — per-cell edit
  locking, consulted in addition to mode + column rules (e.g. freeze *posted*
  rows). Exposed as **`controller.canEditRow(col, row)`**.
- **Manual row reordering**: **`moveRow(from, to)`**, **`moveRowUp([viewR])`**,
  **`moveRowDown([viewR])`**, plus *Move row up / down* in the editable row menu.
  Moves record undo and fire `onChange`. Duplicated/blank rows are flagged as new
  when tracking is on.

### Notes

- `appendRows(...)` treats streamed-in rows as clean baseline data (not local
  edits) when `trackChanges` is on; `clearTable()` records deletions.
- Five new runnable examples (7–12), one per feature.

## [0.5.0] — 2026-06-18

### Changed

- **`AutoSuggestionsBox` and the shared `core` foundation were split out into the
  new [`super_auto_suggestion_box`](../super_auto_suggestion_box) package**
  (also `0.5.0`). `super_table_field` now **depends on** that package and
  **re-exports** it, so `import 'package:super_table_field/super_table_field.dart';`
  still exposes everything (`SuperThemeData`, `AutoSuggestionsBoxThemeData`,
  `SuperTable`, `AutoSuggestionsBox`, the `core` widgets/tokens, …) — **no source
  changes are required** for existing consumers.

### Migration

- None required for table users. If you only need the typeahead, depend on
  `super_auto_suggestion_box` directly and import
  `package:super_auto_suggestion_box/super_auto_suggestion_box.dart`.

## [0.4.0] — 2026-06-17

A large, **breaking** release: `SuperTable` is now generic, columns are a typed
class hierarchy, and the filtering / styling / focus / combo systems all gained
programmatic surfaces.

### Breaking

- **`SuperTable` → `SuperTable<R>`** and **`SuperTableController` → `SuperTableController<R>`**,
  generic over the row's backing type `R`.
- **Rows are now `SuperRow<R>`** — a host-owned, typed `value` **plus** an editable
  `cells` map (`Map<String, SuperCell>`) — not a bare `Map<String, dynamic>`.
  Build them with `SuperRow.map({...})` (Map-backed) or `SuperRow<T>.of(value, {...})`
  (typed-model-backed).
- **The cell *coordinate*** type was renamed `SuperCell` → **`CellPos`**; the name
  `SuperCell` is now the editable **cell-data** object (`value` + `error`).
- Prefer the **typed column classes** over `SuperColumn(type: …)`; `SuperColumn<T>`
  remains as a flexible base.

### Added — Columns

- **Typed column hierarchy**: `SuperTextColumn`, `SuperNumberColumn<T>`,
  `SuperCurrencyColumn`, `SuperEnumerationColumn<T>`, `SuperComboColumn<T>`,
  `SuperProgressColumn<T>`, `SuperColorColumn<T>` (number / text / `Color` value
  modes), `SuperDateColumn`, `SuperTimeColumn`, `SuperLinkColumn`,
  `SuperCheckboxColumn`, `SuperComputedColumn<T>`.
- **`onChange`** — pre-commit gate (editable). May mutate sibling cells / the row
  `fingerPrint`; returns whether the new value is accepted.
- **`validator`** — returns an error code (or null); drives the per-cell badge.
- **Conditional `styles`** per column (`CellStyle`).

### Added — SuperTable / controller

- **Mode switching through the controller** — `setMode` / `toggleMode`.
- **Table actions** — `appendRows`, `clearTable`, `requestLoadMore` / `loadMore`,
  `updateRows`, `updateColumns`, `setLoadMoreState`.
- **Conditional row styles** — `SuperTable(styles: {condition: SuperRowStyle})`;
  row styles take priority over column cell styles.
- **`onKey`** — host keyboard hook on the controller (consult-before-default).

### Added — Filtering

- **Advanced (cross-column) filter** — a button in the row-number header opens a
  clause editor; while active, column filters are cleared, disabled and slashed,
  and the button shows a red badge. Setting a column filter deactivates it.
- **Programmatic filters** — `setColumnFilter`, `setAdvancedFilter`,
  `clearAdvancedFilter`, `applyFilterState` / `applyFilterJson`.
- **JSON filter state** — `filterState` / `filterStateJson()`.
- **`onLoadMore` now receives the live `SuperFilterState`** for backend fetches.
- **Filter option sources** — sync / async / stream via `FilterValueSources`.
- **`FilterItem(display, value)`** filter values for enumeration / currency /
  color columns (replacing bare `List<String>`).

### Added — Focus & combo

- **Programmatic selection** — `selectCellAt`, `selectCells`, `selectRowAt`,
  `selectRowsAt`, `clearSelection`.
- Clicking the **row-number** cell selects the whole row **without** moving the
  edit cursor.
- **`SuperComboColumn`** forwards all `AutoSuggestionsBox` options, plus the
  rebuildable **`sourceController`** / **`cellController`** builders (re-invoked on
  `fingerPrint` change). Access them via `comboControllerFor` / `comboSourceFor`.

### Fixed

- **Tab on the last cell** now appends a new row and focuses its first cell.
- **`⌘`/`Ctrl`+Enter** inserts a row after the focused row; add **Shift** to insert
  before — focus moves to the same column in the new row.
- **Right-click** opens the column header menu (left button drags to reorder; touch
  double-tap opens the menu).
- Row context-menu submenus now open as cascading **overlayCards**.
- Load-more skeletons render at the **scroll tail** with an animated shimmer.

### Docs

- README rewritten for 0.4.0 (concepts, typed columns, filtering, styling, combo,
  focus, keyboard). SKILL guide updated. Five new examples in `example/`.

## [0.3.0] — 2026-06-17

### Added — SuperTable

- **Sticky row-number gutter** — the `#` column is now a frozen pane that stays
  put during horizontal scroll; its vertical offset is kept in lock-step with
  the body.
- **Click-to-select-row** — clicking a row number selects the entire row (lights
  every cell) in any selection mode; `Shift` / `⌘`-click extend or toggle.
- **Per-column `groupable`** — group only the columns you allow; grouping is now
  surfaced as a **Group by ▸** submenu (tree) in the row context menu.
- **Flexible, tree-capable row context menu** — `SuperTable(rowMenuBuilder:)`
  receives the row context + default entries and returns the menu to show;
  `SuperMenuEntry.children` renders an expandable nested submenu to any depth.

### Changed — SuperTable

- Per-column filters now render in **readable mode only**, sit **full-bleed**
  inside each header cell (no inset padding), and respect `SuperColumn.filterable`.
- Grouping affordances are gated to readable mode.
- Combo / enumeration cells: pressing **Enter** now commits **in place** without
  moving; a **second Enter** steps down to the next row. Arrow keys navigate the
  enumeration dropdown.

### Added — AutoSuggestionsBox

- **`SuggestionSources.remoteFallback(...)`** — local-first progressive source:
  shows local matches instantly and fetches from a remote backend only when the
  local match count is `remoteThreshold` or fewer, merging results (de-duplicated)
  behind a **“loading more”** indicator. Backed by the new
  `SuggestionsQueryResult` two-phase contract and `isLoadingMore` controller flag.
- **Advanced Search overlay** — `advancedSearch: true` opens a modal search
  surface on `Ctrl`/`⌘`+`F`; customise via `advancedSearchBuilder`.
- **Restore-on-blur** — leaving the field without picking reverts unconfirmed
  typing to the last committed value (unless nothing was ever committed);
  toggle with `restoreOnBlur`.
- **Caret-anchored query** — matching uses the text from the start up to the
  caret (`effectiveQuery`), so mid-string edits filter on the relevant prefix.

### Docs

- README rewritten in pub.dev package-documentation style (Features / Getting
  started / Usage / Architecture / Example / Additional information).
- Example gallery expanded: remote-fallback and advanced-search demos for the
  AutoSuggestionsBox; combo + grouping + filtering in the SuperTable demo.

## [0.2.0] — 2026-06-16

### Added

- **Per-column filter row** under the table header (`SuperTable(columnFilters:)`,
  default on). `combo`/`enumeration` columns get a value dropdown, `checkbox`
  columns a tri-state (`All`/`Checked`/`Unchecked`), all other types a contains
  text field; `color` is skipped. Filters combine with AND across columns and
  with the global search. New controller API: `setColumnFilter`,
  `columnFilter`, `hasColumnFilters`, `activeColumnFilters`,
  `clearColumnFilters` (the gutter filter icon clears all).

## [0.1.0] — 2026-06-16

### Added

- Initial release, extracted as a focused package from `super_toolkit`.
- **`SuperTable`** — unified keyboard-first data grid with `readable` and
  `editable` modes; 13 column types (`text`, `number`, `currency`, `percent`,
  `combo`, `enumeration`, `checkbox`, `date`, `time`, `color`, `progress`,
  `tag`, `rating`); 4 selection modes; live search; multi-level grouping with
  aggregates; totals row; pagination; JSON/TSV clipboard copy/paste; undo/redo.
- **`AutoSuggestionsBox`** — typeahead/combobox with grouped results, prefix/
  contains/fuzzy matching, single- and multi-select, free-text entry, async +
  list + fuzzy suggestion sources, and a `bare` embedding mode.
- **Combo ⇄ AutoSuggestionsBox integration** — in editable mode, `combo`
  columns are now edited through the real `AutoSuggestionsBox` (filter, arrow
  navigation, pick-to-commit, free-text Enter, Tab/Shift+Tab cell traversal,
  Esc cancel), replacing the previous inline option list. The box's theme is
  mapped from the live `SuperTableSkin` so the overlay matches the grid.
- `SuperThemeData` and `AutoSuggestionsBoxThemeData` `ThemeExtension`s with
  light + dark variants; full LTR + RTL support.
- Runnable `example/` gallery with light/dark + LTR/RTL toggles.
- `README.md` and `SKILL.md` (agent usage guide).
