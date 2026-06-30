# Changelog

All notable changes to **super_table_field** are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning is [SemVer](https://semver.org/).

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
