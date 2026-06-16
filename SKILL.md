---
name: super-table-field
description: >
  Use the super_table_field Flutter package to build GeniusLink design-system
  data grids and typeahead inputs — SuperTable (a readable/editable keyboard-
  first grid with 13 column types, grouping, totals, pagination, undo/redo) and
  AutoSuggestionsBox (a filtering combobox). Apply when a Flutter app needs a
  themed (light/dark, LTR/RTL) table, a typeahead field, or an editable table
  whose `combo` columns are edited through the AutoSuggestionsBox.
---

# Super Table Field — Agent Skill

`super_table_field` pairs two GeniusLink components and wires them together:
`SuperTable` (data grid) and `AutoSuggestionsBox` (typeahead). In editable
mode, the table's `combo` columns are edited through the real
`AutoSuggestionsBox`. This skill tells you how to wire them correctly.

## When to use

- Any Flutter table/grid in the GeniusLink visual language (dark-first ERP /
  accounting screens, bilingual English + Arabic).
- A standalone typeahead / combobox field with filtering, grouping, multi-select
  or free-text.
- An editable grid where one or more columns are a pick-or-type combobox.

Do **not** hand-roll a `DataTable`, a `DropdownButton`-based combobox, or a
custom autocomplete — use these components so theme, keyboard model, and RTL
come for free.

## Install & setup

```yaml
dependencies:
  super_table_field:
    path: ../super_table_field
```

```dart
import 'package:super_table_field/super_table_field.dart';
```

Register **both** theme extensions on your `ThemeData` (this is the most common
omission — without them colors fall back to defaults):

```dart
theme: ThemeData(
  brightness: Brightness.light,
  extensions: [SuperThemeData.light, AutoSuggestionsBoxThemeData.light],
),
darkTheme: ThemeData(
  brightness: Brightness.dark,
  extensions: [SuperThemeData.dark, AutoSuggestionsBoxThemeData.dark],
),
```

## SuperTable

Drive it from a `SuperTableController` (the Model) and render `SuperTable`
(the View).

```dart
final controller = SuperTableController(
  columns: const [
    SuperColumn(key: 'sku',  label: 'SKU',  type: SuperColumnType.text, width: 130, mono: true),
    SuperColumn(key: 'qty',  label: 'Qty',  type: SuperColumnType.number, width: 90,
                align: SuperAlign.end, agg: SuperAgg.sum),
    SuperColumn(key: 'unit', label: 'Unit', type: SuperColumnType.combo, width: 130,
                opts: ['each', 'box', 'pallet', 'kg']),
    SuperColumn(key: 'price', label: 'Price', type: SuperColumnType.currency, width: 120,
                align: SuperAlign.end, agg: SuperAgg.sum),
  ],
  rows: [
    {'sku': 'INV-SB-200', 'qty': 120, 'unit': 'each', 'price': 340.0},
  ],
  mode: SuperTableMode.editable, // or SuperTableMode.readable
);

SuperTable(controller: controller);
```

Rules:
- Rows are `Map<String, dynamic>` (`SuperRow`); the `key` of each column indexes
  into the row map. Keep keys stable.
- Column types: `text`, `number`, `currency`, `percent`, `combo`, `enumeration`,
  `checkbox`, `date`, `time`, `color`, `progress`, `tag`, `rating`.
- Give `combo`/`enumeration` columns an `opts:` list. `combo` allows free text;
  `enumeration` is pick-only.
- Numeric columns may set `agg:` (`sum`/`avg`/`min`/`max`/`count`) to populate
  the totals row, and `min`/`max` to clamp (and to scale `progress`).
- `mono: true` renders the cell in JetBrains Mono — use it for SKUs, serials,
  IDs, and any reference value.
- Read state back from the controller (`controller.rows`, selection, etc.); call
  its mutators rather than mutating the row list directly so undo/redo and
  notifications stay correct.

## The combo ⇄ AutoSuggestionsBox integration

This is the package's reason to exist: when `mode` is `editable` and the user
edits a `SuperColumnType.combo` cell, an `AutoSuggestionsBox` opens inline
(seeded from the column's `opts`). You do not wire anything — it is automatic.
Keyboard model inside the editor:

- type → filter options live
- `↑`/`↓` → move highlight
- `Enter` / click → pick highlighted option, commit, move down
- free text + `Enter` → commit typed value (combo allows free text), move down
- `Tab` / `Shift+Tab` → commit, move to next / previous cell
- `Esc` → cancel

The box renders in `bare` mode and its theme is derived from the live
`SuperTableSkin`, so it always matches the grid in light/dark.

## Per-column filters

A filter row renders beneath the header by default (`SuperTable(columnFilters: false)`
to hide it). The control per column is automatic: `combo`/`enumeration` → value
dropdown (`All` + `opts`), `checkbox` → tri-state (`All`/`Checked`/`Unchecked`),
others → a contains text field, `color` → none. Filters AND together and with
the global search; the filter icon in the row-number gutter clears all. Drive
them from the controller to persist or restore a filter set:
`setColumnFilter(key, value)` (blank clears), `columnFilter(key)`,
`hasColumnFilters`, `activeColumnFilters`, `clearColumnFilters()`.

## AutoSuggestionsBox (standalone)

```dart
final box = AutoSuggestionsBoxController<String>(
  source: SuggestionSources.list<String>([
    AutoSuggestion(value: 'each', label: 'each'),
    AutoSuggestion(value: 'box',  label: 'box'),
  ]),
  allowFreeText: true,   // false = pick-only
  multiSelect: false,
);

AutoSuggestionsBox<String>(
  controller: box,
  hintText: 'Type or pick…',
  onSelected: (s) => /* s.value, s.label */,
  onSubmitted: (raw) => /* free-text Enter */,
);
```

Suggestion sources: `SuggestionSources.list(...)` (static), `.fuzzy(...)`
(fuzzy-ranked), `.async(...)` (debounced remote lookup). For remote data prefer
`.async` so typing debounces network calls.

Embedding tip: set `bare: true`, pass a `fieldHeight`, and provide `onEscape` /
`onTabNext` / `onTabPrev` when you place the box inside a cell or compact toolbar
(this is exactly how `SuperTable` embeds it).

## Architecture (when extending)

Clean Architecture per feature under `lib/src/features/<feature>/`:
`data/` (datasources, models) · `domain/` (entities, usecases — pure Dart) ·
`presentation/` (`controllers/` = Model/state as `ChangeNotifier`, `widgets/` +
`pages/` = View). Shared tokens/widgets live in `lib/src/core/`. Add new column
behavior in `domain/usecases/super_column_logic.dart` and render in
`presentation/widgets/super_cell.dart`; keep the controller widget-free.

## Common mistakes

- Forgetting to register `AutoSuggestionsBoxThemeData` → combo overlay looks
  unstyled. Register both extensions.
- Mutating the rows list directly instead of via the controller → breaks
  undo/redo and skips a rebuild.
- Using `enumeration` when you meant `combo` (or vice versa): `combo` permits
  free text, `enumeration` is a closed set.
- Expecting the combo editor in `readable` mode — editing only happens in
  `SuperTableMode.editable`.
