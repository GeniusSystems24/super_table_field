# Changelog

All notable changes to **super_table_field** are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/); versioning is [SemVer](https://semver.org/).

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
