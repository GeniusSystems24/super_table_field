# Changelog

All notable changes to **super_table_field** are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning is [SemVer](https://semver.org/).

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
