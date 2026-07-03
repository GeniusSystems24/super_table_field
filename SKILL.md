---
name: super-table-field
description: >
  Use the super_table_field Flutter package to build GeniusLink design-system
  data grids and typeahead inputs — SuperTable<R> (a generic readable/editable
  keyboard-first grid with a typed column hierarchy, onChange/validator,
  per-column + advanced filtering, conditional row/cell styling, display formatters,
  grouping (with Σ group-footer subtotals), totals, pagination, change tracking
  with per-cell/per-row revert, CSV/TSV/JSON export, custom + programmatic
  aggregations, hidden filter/group columns, selection statistics, per-cell edit
  locking, row reordering, expandable row panels, fill down/right, a table-wide
  validation summary with unique columns, saved view state (order/widths/sort/
  filters as JSON), undo/redo) and AutoSuggestionsBox (a filtering combobox).
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
- Any column can set `formatter: (value, row) => String` to fully control its
  **displayed** text (overrides the built-in type rendering; display-only —
  sort / filter / group / export and editing all use the raw value). Column
  headers never show a column's data type.
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

## ERP features (1.0.0)

All opt-in; no overhead unless used.

**Change tracking (save-delta).** Pass `trackChanges: true`. The controller
snapshots a per-cell baseline; query the delta and post only what changed:

```dart
final c = SuperTableController(mode: SuperTableMode.editable, trackChanges: true, /* … */);
// … user edits …
if (c.hasChanges) {
  await api.post(c.changes.toJson());   // {added:[…], modified:[…], deleted:[…]}
  c.acceptChanges();                    // re-baseline (clean). Or c.rejectChanges() to discard.
}
c.rowStateOf(row);                      // pristine | added | modified | deleted
c.isCellDirty(row, 'price');            // dirty cells also show an accent corner
```
Streamed rows from `appendRows(...)` count as clean baseline data; `clearTable()`
records deletions. Entities: `SuperChangeSet`, `SuperRowChange`, `SuperCellChange`,
`SuperRowState`.

**Export.** `c.toCsv()` / `toTsv()` / `toJsonRows()` / `toDelimited(delimiter:)` /
`copyCsvToClipboard()` — all reflect the active filter, sort, and column order.

**Aggregations.** Beyond `sum`/`avg`/`count`, columns support `SuperAgg.min`,
`SuperAgg.max`, and `SuperAgg.custom` + `aggregator: (List<SuperRow> rows) => num?`
(e.g. a quantity-weighted average). `aggLabel:` renames the figure in group headers.

**Sort.** `c.sortBy(col, ascending)` sorts the view; `c.clearSort()` removes any
active sort. The column **header responds to left-click** with a 3-state cycle:
1st click → ascending ↑, 2nd click → descending ↓, 3rd click → clear sort.
Right-click (or touch double-tap) opens the header menu which also has
*Sort ascending* / *Sort descending* / *Clear sort* entries.

**Selection statistics.** In a cell-selection mode, `c.selectionStats` returns a
`SuperSelectionStats` (`sum`/`average`/`min`/`max`/`count`/`numericCount`) over the
selected numeric cells; the footer shows it for 2+ numeric cells.

**Per-cell edit locking.** `cellEditable: (col, row) => bool` gates editing in
addition to mode + column rules — e.g. freeze a posted row but keep its status
field editable. Also exposed as `c.canEditRow(col, row)`.

**Row reordering.** `c.moveRow(from, to)`, `c.moveRowUp([viewR])`,
`c.moveRowDown([viewR])`, plus *Move row up / down* in the editable row menu.
Records undo; no-op while grouped.

## Programmatic aggregation & hidden columns (1.1.0)

**Aggregate in code** over the live, filtered (+ sorted) view, independent of the
on-screen group headers:

```dart
// Nested group tree — defaults to the live groupKeys / all agg columns:
final tree = c.groupAggregates(groupBy: ['region', 'category'], aggregateColumns: ['qty', 'value']);
tree.first.value;              // 'North'
tree.first.aggregate('value'); // Σ value for that group; .children = next level

c.aggregateBy('region', 'value', agg: SuperAgg.sum); // flat {groupValue: num?}
c.grandTotals(columns: ['qty', 'value']);            // totals row as a map
c.aggregateColumn('value', agg: SuperAgg.avg);       // one figure over the view
```
All default to the active filter; pass `filtered: false` to ignore it, or `rows:`
to aggregate an explicit set. `SuperColumnLogic.aggregate(col, rows, {agg, aggregator})`
takes the same overrides. Returns `SuperGroupAggregate` nodes (`value` / `count` /
`rows` / `aggregates` / `children`, plus `flatten()` / `toJson()`).

**Hidden columns.** `SuperColumn(hidden: true)` — on the base column and **every**
typed subclass — declares a column that **never renders** (header, body, filter
row, totals, group headers), is excluded from export + the column chooser, and
**cannot be revealed** via `setVisibleKeys` / `hideColumn`. It stays fully usable
**by key** for filtering (`setColumnFilter`, advanced clauses), grouping
(`toggleGroup`, `setGroupKeys`, `groupBy:`) and every aggregation API above —
perfect for backing dimensions (region, supplier, a normalized sort key) that
steer the data without a visible slot. Read the partitions via `c.dataColumns`
(renderable) / `c.hiddenColumns`.

Grouping by a hidden column **does show group-header rows** in the table — the
column's label and group value still appear in the header stripe; only the
column slot itself is absent. Set one or more group keys at once (including
hidden column keys) with:

```dart
c.setGroupKeys(['region', 'category']);  // replaces current groups; resets collapse
c.setGroupKeys([]);                      // clear all groups
```

## Expandable rows (2.0.0)

Readable mode only: pass `SuperTable(expansion: SuperRowExpansion(builder: (ctx,
controller, row) => …))` to give every data row an animated expand/collapse
panel (gutter chevron). Options: `defaultHeight` / per-row `heightBuilder`,
`mode: SuperRowExpansionMode.multi | .single` (accordion), animation duration/
curve, and an opt-in `keymap: SuperRowExpansionKeymap()` (⌘⇧↓ expand · ⌘⇧↑
collapse). Zero effect in editable mode.

## Forms & views (2.1.0)

All opt-in and additive.

**Validation summary + unique columns.** Every typed column takes
`unique: true` (natural keys — SKU, account code): enforced at commit and in the
full pass, comparing display text case-insensitively, blanks exempt.

```dart
final issues = c.validateAll();   // EVERY row: type rules + unique + validators
if (!c.isValid) {                 // silent variant (no badge changes)
  await showSuperValidationPanel(context, c);   // list + jump-to-cell dialog
  return;                         // gate the Post/Save on isValid
}
```

`SuperValidationIssue` carries `row`, `sourceIndex`, `columnKey`/`columnLabel`,
`message`, and `cell` (a `CellPos?` — null when filtered/paged off screen; use
it with `selectCellAt`). `validateAll` lights the per-cell badges
(`markCells: false` to skip); when badges are lit the footer shows a tappable
**⚠ N issues** chip (`c.errorCount`). Column `validator`s run only after the
View has mounted (they receive its `BuildContext`).

**Saved views.** One JSON snapshot of the user's grid personalisation:

```dart
final json = c.viewStateJson();   // order, widths, visibility, sort, groups,
c.applyViewJson(json);            //   collapsed paths, filters (opt-out:
c.resetViewState();               //   viewState(includeFilters: false))
```

Restores drop unknown column keys (schema drift) and leave filters untouched
when the snapshot has none. Entity: `SuperViewState` (`toJson`/`fromJson`).

**Fill down / fill right.** Excel semantics in editable cell modes:
`⌘/Ctrl+D` with a range spanning rows copies the top row downward; `⌘/Ctrl+R`
copies the leading column rightward (values coerced per target column,
incompatible cells skipped). Single cell pulls from the neighbour above/left.
Respects `cellEditable`, validates every write, records **one** undo step.
Programmatic: `c.fillDown()` / `c.fillRight()`. `⌘D` on a single row still
**duplicates** the row.

**Group footers.** `SuperTable(groupFooters: true)` closes each expanded group
with a Σ subtotal row — the group label in the first column, each column's
`agg:`/`aggregator:` figure aligned under its own column. Readable grouped mode
only; render-list consumers see `RenderItem.isGroupFooter` items (they never
enter the selectable `view`).

**Per-cell / per-row revert.** Requires `trackChanges: true`. Right-click a row
→ *Revert cell* (the focused cell) / *Revert row*; reverting an **added** row
removes it. Programmatic: `c.revertCell(row, 'price')` / `c.revertRow(row)` —
both sync the backing value, record undo, and fire `onChange`.

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
- Expecting a `changes` delta without `trackChanges: true` → it's off by default;
  `c.changes` is empty and `c.hasChanges` is false until you opt in.
- Reading `selectionStats` in a row-selection mode → it aggregates *cell*
  selections; use `singleCell`/`multiCells`. It also ignores non-numeric cells.
- Expecting a `hidden: true` column to appear when added to `setVisibleKeys` →
  `hidden` is absolute and never renders; it exists for filter / group /
  aggregate **by key** only. (User-toggleable show/hide is a *separate* concern —
  use the visible-keys allow-list for that.)
- Passing `showTypeTags: true` to `SuperTable` and expecting a data-type label in
  the header → the prop is **deprecated and ignored** as of 1.1.0; column headers
  never display the data type. Remove it from existing call-sites.
- Confusing `formatter:` with the older `format:` field. `format:` is the
  computed-column display string (a specialised output of `SuperComputedColumn`);
  `formatter:` is the new 1.1.0 per-column display override that works on **any**
  column type and is display-only. Both are `(value, row) → String` callbacks but
  they serve different roles — `formatter` takes priority in cell rendering.
- Expecting `groupFooters:` subtotal rows in editable mode or without grouping →
  they render only in **readable** mode while group keys are active (and only
  for expanded groups).
- Calling `revertCell` / `revertRow` (or expecting the row-menu revert entries)
  without `trackChanges: true` → there is no baseline to revert to; they no-op.
- Treating `viewStateJson()` as a data snapshot → it captures **view
  personalisation only** (order/widths/visibility/sort/groups/filters), never
  rows. Persist data separately.
- Expecting `unique:` to compare raw values → it compares **display text**,
  case-insensitively, and exempts blanks (use `required: true` alongside it for
  a mandatory natural key).
