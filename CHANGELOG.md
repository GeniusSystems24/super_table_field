# Changelog

All notable changes to **super_table_field** are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning is [SemVer](https://semver.org/).

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
