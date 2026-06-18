---
name: super-table-field
description: >
  Use the super_table_field Flutter package to build GeniusLink design-system
  data grids and typeahead inputs — SuperTable<R> (a generic readable/editable
  keyboard-first grid with a typed column hierarchy, onChange/validator,
  per-column + advanced filtering, conditional row/cell styling, grouping,
  totals, pagination, undo/redo) and AutoSuggestionsBox (a filtering combobox).
  Apply when a Flutter app needs a themed (light/dark, LTR/RTL) table, a typeahead
  field, or an editable table whose `combo` columns are edited through the
  AutoSuggestionsBox.
---

# Super Table Field — Agent Skill

`super_table_field` provides the `SuperTable` data grid and wires it to the
`AutoSuggestionsBox` typeahead from its companion package
`super_auto_suggestion_box` (which this package depends on and re-exports). In
editable mode, the table's `combo` columns are edited through the real
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

## SuperTable<R>

`SuperTable<R>` is **generic** over the row's backing type `R`. Drive it from a
`SuperTableController<R>` (the Model) and render `SuperTable<R>` (the View).

Rows are **`SuperRow<R>`**: a host-owned, typed `value` (your domain object)
**plus** an editable `cells` map. Build them with `SuperRow.map({...})` (Map-backed,
the common path) or `SuperRow<T>.of(value, {...})` (typed-model-backed).

```dart
final controller = SuperTableController<Map<String, dynamic>>(
  mode: SuperTableMode.editable,        // or .readable; switch later via setMode()
  addRowEnabled: true,
  emptyRowValue: () => <String, dynamic>{},
  columns: [
    SuperTextColumn(key: 'sku', label: 'SKU', width: 130, mono: true),
    SuperNumberColumn<int>(key: 'qty', label: 'Qty', width: 90, agg: SuperAgg.sum),
    SuperComboColumn<String>(key: 'unit', label: 'Unit', width: 130,
        values: const ['each', 'box', 'pallet', 'kg']),
    SuperCurrencyColumn(key: 'price', label: 'Price', width: 120, agg: SuperAgg.sum),
  ],
  rows: [SuperRow.map({'sku': 'INV-SB-200', 'qty': 120, 'unit': 'each', 'price': 340.0})],
);

Expanded(child: SuperTable<Map<String, dynamic>>(controller: controller));
```

Rules:
- Use the **typed column classes** — `SuperTextColumn`, `SuperNumberColumn<T>`,
  `SuperCurrencyColumn`, `SuperEnumerationColumn<T>`, `SuperComboColumn<T>`,
  `SuperProgressColumn<T>`, `SuperColorColumn<T>`, `SuperDateColumn`,
  `SuperTimeColumn`, `SuperLinkColumn`, `SuperCheckboxColumn`,
  `SuperComputedColumn<T>`. Reach for the base `SuperColumn<T>` only for custom
  columns.
- The cell **coordinate** type is `CellPos(r, c)`. The name `SuperCell` is the
  editable **cell-data** object (`value` + `error`), reached via `row.cells['key']`.
- `combo` allows free text; `enumeration` is pick-only. Numeric columns may set
  `agg:` for the totals row and `min`/`max` to clamp (and scale `progress`).
- Read state back from the controller; call its mutators (never mutate the row
  list directly) so undo/redo + notifications stay correct.
- Switch mode at runtime with `controller.setMode(...)` / `toggleMode()`.

### onChange / validator (editable)

```dart
SuperNumberColumn<num>(
  key: 'debit', label: 'Debit', min: 0,
  onChange: (context, controller, row, cell, prev, next) {
    if (next > 0) row['credit'] = 0;   // may mutate siblings / row.fingerPrint
    return next >= 0;                   // false rejects the new value
  },
  validator: (context, controller, row, cell, value) => value < 0 ? 'Must be ≥ 0' : null,
);
```

### Conditional styling

Row styles (via `SuperTable(styles: {condition: SuperRowStyle()})`) take priority
over column cell styles (`SuperXColumn(styles: {condition: CellStyle()})`). First
matching condition wins.

## The combo ⇄ AutoSuggestionsBox integration

This is the package's reason to exist: when `mode` is `editable` and the user
edits a `SuperComboColumn` cell, an `AutoSuggestionsBox` opens inline. By default
it is seeded from the column's `values`; you may also supply the full set of box
options (`itemBuilder`, `hintText`, `advancedSearch`, …) and two **rebuildable**
builders — `sourceController` / `cellController` — which are re-invoked when the
cell takes edit-focus **and** the row's `fingerPrint` changed (so suggestions can
depend on the rest of the row). Reach a cell's live box via
`controller.comboControllerFor(row, key)` / `comboSourceFor(row, key)`.

Keyboard model inside the editor:

- type → filter options live
- `↑`/`↓` → move highlight
- `Enter` / click → pick highlighted option, **commit in place** (cell stays selected)
- `Enter` again → step down to the next row
- free text + `Enter` → commit typed value (combo allows free text), stay in place
- `Tab` / `Shift+Tab` → commit, move to next / previous cell
- `Esc` → cancel

`enumeration` cells behave the same (arrow keys navigate the dropdown), minus
free text.

The box renders in `bare` mode and its theme is derived from the live
`SuperTableSkin`, so it always matches the grid in light/dark.

## Filtering (per-column + advanced)

A per-column filter row renders beneath the header in **readable mode** by
default (`SuperTable(columnFilters: false)` to hide it). The control per column
is automatic: `combo`/`enumeration` → value dropdown, `checkbox` → tri-state,
others → a full-bleed contains field, `color` → none. Enumeration / currency /
color columns take typed `FilterItem(display, value)` filter values, or a
`FilterValueSources.sync/async/stream(...)` source.

An **advanced (cross-column) filter** button sits in the row-number header.
While active it clears, disables and slashes the column fields and shows a red
badge; setting a column filter deactivates it. Drive both programmatically:

```dart
c.setColumnFilter('cat', 'Raw Material');   // '' clears; deactivates advanced
c.setAdvancedFilter([
  const AdvancedFilterClause(columnKey: 'amount', op: FilterOp.greaterOrEqual, value: 500),
]);
c.clearAdvancedFilter();
final json = c.filterStateJson();           // extract; c.applyFilterJson(json) to restore
```

`onLoadMore: (SuperFilterState filter) {...}` receives the live filter state so a
backend fetch can honor it; append results with `c.appendRows(more, hasMore: ...)`.

## Focus & selection

Programmatic: `selectCellAt(r,c)`, `selectCells([CellPos(...)])`, `selectRowAt(r)`,
`selectRowsAt([...])`, `clearSelection()`. Clicking the **row-number** cell
selects the whole row **without** moving the edit cursor.

## Grouping & the row context menu (readable mode)

Group by any column whose `groupable` is true (default). **Right-click** a row
for a **Group by ▸** submenu (left-click is for selection; column header menus
open on right-click / touch double-tap, with left-drag reordering columns).
Toggle from the controller: `toggleGroup(key)`, `groupKeys`. Customise the row
menu with `SuperTable(rowMenuBuilder:)` — it receives
`(SuperRowMenuContext<R> ctx, List<SuperMenuEntry> defaults)` and returns the
entries to show. Give a `SuperMenuEntry` a `children:` list to make it a
cascading **overlayCard** submenu (nests to any depth). Return `[]` to suppress.

## Row-number gutter

`SuperTable(numbered: true)` (default) shows the `#` gutter. It is **frozen**
during horizontal scroll and **clicking a row number selects the whole row**
(`Shift`/`⌘`-click extend or toggle).

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

Suggestion sources: `SuggestionSources.list(...)` / `.strings(...)` (static),
`.fuzzy(...)` (fuzzy-ranked), `.async(...)` (debounced remote), and
`.remoteFallback(...)` (local-first progressive). Prefer **`remoteFallback`** for
“mostly local, occasionally remote” data: it shows local matches instantly and
only calls `fetch` when local matches ≤ `remoteThreshold`, merging remote rows
in behind a *loading more* indicator (`controller.isLoadingMore`). Use `.async`
for purely-remote search.

More behaviour to know:
- **Advanced search**: `advancedSearch: true` opens a modal search surface on
  `Ctrl`/`⌘`+`F` (override with `advancedSearchBuilder`).
- **Restore on blur**: leaving without picking reverts unconfirmed typing to the
  last committed value (unless none); disable with `restoreOnBlur: false`.
- **Caret-anchored query**: matching uses text from the start to the caret
  (`controller.effectiveQuery`).

Embedding tip: set `bare: true`, pass a `fieldHeight`, and provide `onEscape` /
`onTabNext` / `onTabPrev` when you place the box inside a cell or compact toolbar
(this is exactly how `SuperTable` embeds it).

## Architecture (when extending)

Clean Architecture per feature under `lib/src/features/<feature>/`:
`data/` (datasources, models) · `domain/` (entities, usecases — pure Dart) ·
`presentation/` (`controllers/` = Model/state as `ChangeNotifier`, `widgets/` +
`pages/` = View). The shared tokens/widgets (`core`) and the `AutoSuggestionsBox`
live in the `super_auto_suggestion_box` dependency, re-exported through this
package's barrel. Add new column behavior in
`domain/usecases/super_column_logic.dart` and render in
`presentation/widgets/super_cell.dart`; keep the controller widget-free.

## Common mistakes

- Forgetting to register `AutoSuggestionsBoxThemeData` → combo overlay looks
  unstyled. Register both extensions.
- Mutating the rows list directly instead of via the controller → breaks
  undo/redo and skips a rebuild.
- Using `SuperColumnType.combo` directly instead of the typed `SuperComboColumn`
  (or `enumeration` when you meant `combo`): `combo` permits free text,
  `enumeration` is a closed set.
- Confusing `CellPos` (a coordinate) with `SuperCell` (cell data: `value`+`error`).
- Forgetting `emptyRowValue:` for a non-Map `R` when `addRowEnabled` is true.
- Expecting the combo editor — or filters / grouping — in the wrong mode:
  editing happens only in `SuperTableMode.editable`; per-column filters and
  grouping affordances show only in `SuperTableMode.readable`.
- Placing `SuperTable` in an unbounded-height parent → it scrolls internally and
  needs bounded height (`Expanded`/`Flexible`/`maxHeight:`).
