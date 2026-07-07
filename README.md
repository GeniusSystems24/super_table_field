# super_table_field

[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

A **GeniusLink design-system** Flutter package providing a generic data grid, wired to the typeahead from its companion package:

- **`SuperTable<R>`** — a generic, keyboard-first data grid with `readable` and `editable` modes, a typed column hierarchy, per-column **and** advanced (cross-column) filtering, conditional row/cell styling, multi-level grouping, totals, pagination, clipboard, and undo/redo.
- **`AutoSuggestionsBox`** — a typeahead / combobox field with local + remote sources, fuzzy matching, multi-select, free-text, and an advanced-search overlay. It now lives in the companion [`super_auto_suggestion_box`](../super_auto_suggestion_box) package, which this package **depends on and re-exports** (along with the shared GeniusLink `core` foundation).

In editable mode, the table's `combo` columns are edited **through the real `AutoSuggestionsBox`** — one keyboard model, one look, no duplicate combobox.

Light + dark themes, full LTR + RTL.

## What's new in 2.2.0

The **interaction & column-config release** — two cooperating additions, both opt-in and backward compatible:

- **Interaction events** — `SuperTable(interactions: SuperInteractions(...))` hands you a bag of optional host callbacks that fire on gestures and state changes **without changing** the grid's own behaviour: `onCellTap` / `onCellDoubleTap` / `onCellSecondaryTap` (each with a `SuperCellInteraction` — view + source index, column, row, cell, raw value, controller, tap position), `onRowTap` (gutter), `onRowActivate` (the canonical *open record*: double-tap a readable row or press Enter), `onSelectionChanged` (a `SuperSelectionSnapshot` with cursor, rows, cells, numeric stats), and `onSortChanged`. Selection + sort fire for **programmatic** changes too.
- **Runtime column config** — `showSuperColumnManager(context, controller)` opens a dialog to **drag-reorder**, **show/hide** (eye), and **pin** each column to an edge; `SuperTable(columnManager: true)` (default) also adds **Pin ▸ / Hide column / Manage columns…** to every header menu. The controller gains `setColumnPin` / `cycleColumnPin` / `pinOf`, `showColumn` / `toggleColumnVisible` / `isColumnVisible`, and `moveColumn` / `setManagedOrder` / `managedColumns`. **Pins persist in saved views** — `SuperViewState` gains a `pins` map, so `viewStateJson()` / `applyViewJson()` round-trip pin overrides alongside order / widths / visibility.

See the [CHANGELOG](CHANGELOG.md) and examples 17–19.

## What's new in 2.1.0

Five roadmap items land at once — the **forms & views release**, everything opt-in and backward compatible:

- **Validation summary** — `controller.validateAll()` runs the full pass (type rules, `unique:`, column `validator`s) over **every row** and returns `SuperValidationIssue`s; `controller.isValid` gates a *Post*; `showSuperValidationPanel(context, controller)` lists the issues with **jump-to-cell**, and the footer shows a live ⚠ issue chip. Columns take `unique: true` for natural keys (SKU, account code).
- **Saved views** — `controller.viewState()` / `viewStateJson()` snapshot column order, widths, visibility, sort, group-bys, collapsed groups, and (optionally) filters as one JSON object; restore with `applyViewState` / `applyViewJson`; `resetViewState()` returns to the declarations. Persist per user/screen.
- **Fill down / fill right** — Excel semantics: select a range, `⌘/Ctrl+D` copies the top row downward (`⌘/Ctrl+R` → rightward), honouring locks + validation, one undo step. Single cell pulls from the neighbour above/left. (`⌘D` on a single row still duplicates it.)
- **Group footers** — `SuperTable(groupFooters: true)` closes each expanded group with a **Σ subtotal row**, aggregates aligned under their columns — the in-grid UI over `groupAggregates`.
- **Per-cell / per-row revert** — with `trackChanges:` on, right-click → *Revert cell* / *Revert row* (an added row is removed); programmatic `revertCell(row, key)` / `revertRow(row)`.

Also fixed: **undo/redo now restores cell values**, not just row membership; numeric commits are stored as numbers; clearing a not-set column filter no longer deactivates the advanced filter; deleted rows release their cached combo resources. See the [CHANGELOG](CHANGELOG.md) and examples 15–16.

## What's new in 1.1.0

Aggregate **in code**, and keep the dimensions that drive those aggregates **off the screen** — two cooperating, fully backward-compatible additions:

- **Programmatic group aggregation** — `controller.groupAggregates(...)` returns a nested tree of `SuperGroupAggregate` nodes (group value, count, rows, and a per-column `aggregates` map), honouring the active filter and independent of the on-screen group headers. Plus `aggregateBy(groupKey, valueKey)` for a flat single-level roll-up, `grandTotals(...)` for the totals row in code, and `aggregateColumn(key, ...)` for one figure. Any reducer can be overridden per call.
- **Permanently-hidden columns** — `SuperColumn(hidden: true)` declares a column that is **never rendered** and can't be revealed, yet stays fully available **by key** to filtering, grouping, and aggregation. Ideal for backing dimensions (region, supplier, a normalized sort key) that steer the data without taking a slot.
- **Optional display formatter** — any column takes a `formatter: (value, row) => String` that overrides the built-in cell rendering with custom text (display-only: sorting, filtering, grouping, export and editing keep the raw value).
- **No data-type tags** — column headers no longer print the data-type label; each header shows just the column name and its sort / pin / group / drag affordances.

See the [CHANGELOG](CHANGELOG.md) and the new example 13.

## What's new in 1.0.0

The **ERP release** — everything an accounting / inventory / document grid needs to stage edits and post them to a backend:

- **Change tracking** — opt in with `SuperTableController(trackChanges: true)`. The controller captures a per-cell baseline and exposes the add / modify / delete delta through `controller.changes` (a `SuperChangeSet`), plus `hasChanges`, `isRowDirty`, `isCellDirty`, and the `acceptChanges` / `rejectChanges` pair. Dirty cells get an accent corner marker. Post only what changed.
- **Export** — `controller.toCsv()`, `toTsv()`, `toJsonRows()`, and `copyCsvToClipboard()`. Output honours the **active filter, sort, and column order**.
- **Extended + custom aggregations** — `SuperAgg.min`, `SuperAgg.max`, and `SuperAgg.custom` with a per-column `aggregator` (e.g. a quantity-weighted average). `aggLabel` renames the figure in group headers.
- **Selection statistics** — `controller.selectionStats` returns a live `Sum / Avg / Min / Max / Count` over the selected numeric cells; the grid footer shows it automatically.
- **Per-cell edit locking** — `SuperTableController(cellEditable: (col, row) => ...)` makes individual cells read-only (lock a row once it's *posted*, keep one field editable, …).
- **Manual row reordering** — `moveRow`, `moveRowUp`, `moveRowDown`, plus *Move row up / down* in the editable row menu. Reorders record undo.

This release is **backward compatible** — every new capability is opt-in. See the [CHANGELOG](CHANGELOG.md) and the [Roadmap](#roadmap).

## What's new in 0.5.0

- **`AutoSuggestionsBox` + the shared `core` foundation split into [`super_auto_suggestion_box`](../super_auto_suggestion_box).** This package now depends on it and **re-exports it**, so the single barrel import below still gives you everything (`SuperThemeData`, `AutoSuggestionsBoxThemeData`, `SuperTable`, `AutoSuggestionsBox`, …) — existing code is unchanged. Need only the typeahead? Depend on `super_auto_suggestion_box` directly.

## What's new in 0.4.0

- **Generic `SuperTable<R>`** — each row wraps a host-owned, typed backing `value` of type `R` **plus** an editable `cells` map.
- **Typed column hierarchy** — `SuperTextColumn`, `SuperNumberColumn<T>`, `SuperCurrencyColumn`, `SuperEnumerationColumn<T>`, `SuperComboColumn<T>`, `SuperProgressColumn<T>`, `SuperColorColumn<T>`, `SuperDateColumn`, `SuperTimeColumn`, `SuperLinkColumn`, `SuperCheckboxColumn`, `SuperComputedColumn<T>` — with `SuperColumn<T>` still available as a flexible base.
- **`onChange` + `validator`** per column (editable mode).
- **Advanced filter** — a cross-column filter editor with a badge in the gutter header; column filters and the advanced filter are mutually exclusive.
- **Programmatic everything** — switch mode, drive filters (and read them back as JSON), and select cells/rows from the controller.
- **Conditional styling** — `SuperRowStyle` (row-level) and `CellStyle` (cell-level) maps.

See the [CHANGELOG](CHANGELOG.md) for the full list and migration notes.

## Features

- ✅ **Two modes, one grid** — flip a `SuperTableController` between `readable` and `editable` at runtime (`setMode` / `toggleMode`).
- ✅ **Typed columns** — a dedicated class per type, each exposing only the knobs that make sense for it, plus shared `onChange` / `validator` / `styles` hooks.
- ✅ **Generic rows** — `SuperRow<R>` carries your domain object as `value` and the grid's editable view as `cells`.
- ✅ **Filtering** — per-column filters, an advanced cross-column editor, sync/async/stream filter option sources, programmatic get/set, and a JSON filter state.
- ✅ **Conditional styling** — row styles win over cell styles; first matching condition applies.
- ✅ **Sticky row-number gutter** — frozen during horizontal scroll; click to select the whole row without moving the edit cursor.
- ✅ **Grouping & aggregates** (sum / avg / count / **min / max / custom**), **totals**, **pagination** (pages / infinite / load-more).
- ✅ **Programmatic aggregation** — `groupAggregates` (nested tree), `aggregateBy`, `grandTotals`, `aggregateColumn`; all honour the active filter.
- ✅ **Hidden columns** — `hidden: true` columns drive filter / group / aggregate **by key** but never render.
- ✅ **Display formatter** — per-column `formatter` for custom cell text (display-only).
- ✅ **Change tracking** — opt-in add/modify/delete delta (`SuperChangeSet`) with dirty-cell markers and accept/reject.
- ✅ **Export** — CSV / TSV / JSON of the live (filtered + sorted) view, plus copy-to-clipboard.
- ✅ **Selection statistics** — spreadsheet-style running aggregate over selected cells.
- ✅ **Per-cell edit locking** & **manual row reordering**.
- ✅ **Combo ⇄ AutoSuggestionsBox** — with per-cell, rebuildable sources/controllers driven by the row `fingerPrint`.
- ✅ **Clipboard** (JSON / TSV), **undo/redo**, **keyboard-first** with an `onKey` escape hatch.
- ✅ **Validation** — per-column `validator` + built-in type rules + `unique:` constraints, a table-wide `validateAll()` summary with jump-to-cell, and an `isValid` posting gate (2.1.0).
- ✅ **Saved views** — one JSON snapshot of order / widths / visibility / sort / groups / filters per user (2.1.0).
- ✅ **Fill down / fill right** and **Σ group footers** (2.1.0).
- ✅ **Interaction events** — `SuperInteractions`: cell/row tap, double-tap/activate, secondary tap, selection + sort snapshots (2.2.0).
- ✅ **Runtime column config** — drag-reorder / show-hide / pin via `showSuperColumnManager` + header menus + a controller API; pins persist in saved views (2.2.0).

## Getting started

Add the dependency:

```yaml
dependencies:
  super_table_field:
    path: ../super_table_field   # or a git / hosted ref
```

Register **both** `ThemeExtension`s on your `ThemeData`:

```dart
import 'package:super_table_field/super_table_field.dart';

MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    extensions: const [SuperThemeData.light, AutoSuggestionsBoxThemeData.light],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: const [SuperThemeData.dark, AutoSuggestionsBoxThemeData.dark],
  ),
);
```

> **Fonts** — the design system uses Manrope (display), Inter (body), JetBrains Mono (numerics) and Noto Naskh Arabic. Drop the `.ttf` files under `assets/fonts/` and uncomment the `fonts:` block in `pubspec.yaml`; otherwise platform defaults are used.

## Core concepts

### `SuperRow<R>` — backing value + cells

A row wraps a host-owned, typed `value` (your domain model) **and** an editable `cells` map (the grid's view). Editing a cell mutates `cells['key'].value`; a column's `write` hook can push that back into `value`.

```dart
// Map-backed (the common path) — `value` IS the map, cells mirror its entries:
final row = SuperRow.map({'sku': 'INV-001', 'qty': 12, 'unit': 'box'});

// Typed-model-backed:
final product = Product(sku: 'INV-001', qty: 12);
final typed = SuperRow<Product>.of(product, {'sku': product.sku, 'qty': product.qty});

row['qty'];            // 12     (cell read)
row['qty'] = 20;       // set a cell
row.fingerPrint;       // rebuild token (see SuperComboColumn)
row.randomFingerPrint(); // force per-row editor resources to rebuild
```

### `SuperTable<R>` needs a bounded height

Wrap it in `Expanded` / `Flexible`, or pass `maxHeight:`.

```dart
final controller = SuperTableController<Map<String, dynamic>>(
  mode: SuperTableMode.editable,
  addRowEnabled: true,
  emptyRowValue: () => <String, dynamic>{},
  columns: [
    SuperTextColumn(key: 'sku', label: 'SKU', width: 130, mono: true),
    SuperNumberColumn<int>(key: 'qty', label: 'Qty', width: 90, agg: SuperAgg.sum),
    SuperComboColumn<String>(key: 'unit', label: 'Unit', width: 130,
        values: const ['each', 'box', 'pallet', 'kg', 'tonne']),
    SuperCurrencyColumn(key: 'price', label: 'Price', width: 120, agg: SuperAgg.sum),
  ],
  rows: [
    SuperRow.map({'sku': 'INV-SB-200', 'qty': 120, 'unit': 'each', 'price': 340.0}),
    SuperRow.map({'sku': 'INV-CM-050', 'qty': 38,  'unit': 'box',  'price': 18.5}),
  ],
);

Expanded(child: SuperTable<Map<String, dynamic>>(controller: controller));
```

## Columns

Each type is a class. Reach for `SuperColumn<T>` directly only for bespoke/custom columns.

| Class | Cell type | Notes |
|---|---|---|
| `SuperTextColumn` | `String` | `arKey:` adds a bilingual Arabic sub-line |
| `SuperNumberColumn<T extends num>` | `T` | `min` / `max` / `decimals` / `colorSign` |
| `SuperCurrencyColumn` | `num` | `symbol` / `code`, `FilterItem` filters |
| `SuperEnumerationColumn<T>` | `T` | strict dropdown; `values` + `display` |
| `SuperComboColumn<T>` | `T` | edited via `AutoSuggestionsBox` |
| `SuperProgressColumn<T extends num>` | `T` | 0…`max` bar |
| `SuperColorColumn<T>` | hex / int / `Color` | `valueMode:` |
| `SuperDateColumn` | `String` | masked `YYYY-MM-DD` + calendar |
| `SuperTimeColumn` | `String` | masked `HH:mm` |
| `SuperLinkColumn` | `String` | `onOpen` |
| `SuperCheckboxColumn` | `bool` | |
| `SuperComputedColumn<T>` | derived | `compute` + `format` |

### `onChange` and `validator` (editable mode)

```dart
SuperNumberColumn<num>(
  key: 'debit',
  label: 'Debit',
  // Pre-commit gate: may mutate sibling cells / the row fingerPrint.
  // Return true to accept the new value, false to reject it.
  onChange: (context, controller, row, cell, previousValue, newValue) {
    if (newValue > 0) row['credit'] = 0; // clear the credit on this row
    return newValue >= 0;
  },
  // Return an error code/message (or null when valid). Drives the cell badge.
  validator: (context, controller, row, cell, value) =>
      value < 0 ? 'Must be ≥ 0' : null,
);
```

### Conditional cell styles

```dart
SuperNumberColumn<int>(
  key: 'progress', label: 'Progress',
  styles: {
    (context, controller, row, cell) => (cell.value as num) >= 100:
        const CellStyle(foreground: Color(0xFF1DB88A), fontWeight: FontWeight.w700),
    (context, controller, row, cell) => (cell.value as num) == 0:
        const CellStyle(foreground: Color(0xFFEF4444)),
  },
);
```

### Display formatter

Any column accepts a `formatter` that produces the exact text shown in its cell — handy for units, masks, relative dates, or any custom rendering. It overrides the built-in type rendering (pills, bars, currency, …) and is **display-only**: sorting, filtering, grouping and export still use the raw value, and editing still edits the raw value.

```dart
SuperNumberColumn<int>(
  key: 'qty', label: 'Qty', agg: SuperAgg.sum,
  formatter: (value, row) => '${value ?? 0} ${row['unit'] ?? 'u'}',   // "120 box"
);

SuperNumberColumn<num>(
  key: 'margin', label: 'Margin',
  formatter: (value, row) => '${((value as num) * 100).toStringAsFixed(1)}%',
);
```

## Conditional row styles

Pass a `styles:` map to `SuperTable`. **Row styles take priority over cell styles**; the first matching condition wins.

```dart
SuperTable<Map<String, dynamic>>(
  controller: c,
  styles: {
    (context, controller, row) => row['status'] == 'Out of Stock':
        const SuperRowStyle(background: Color(0x14EF4444), accentBar: Color(0xFFEF4444)),
    (context, controller, row) => row['active'] == false:
        const SuperRowStyle(foreground: Color(0xFF8C92A4)),
  },
);
```

## Filtering

### Per-column + advanced

A per-column filter row renders beneath the header in `readable` mode. The **advanced filter** button lives in the row-number header; opening it lets you build cross-column clauses (AND-combined). The two are **mutually exclusive** — activating the advanced filter clears, disables and slashes the column fields and shows a red badge.

```dart
// Column filters (setting one deactivates the advanced filter)
c.setColumnFilter('cat', 'Raw Material');
c.clearColumnFilters();

// Advanced filter
c.setAdvancedFilter([
  const AdvancedFilterClause(columnKey: 'amount', op: FilterOp.greaterOrEqual, value: 500),
]);
c.clearAdvancedFilter();

// Read / restore the whole filter state as JSON
final Map<String, dynamic> json = c.filterStateJson();
c.applyFilterJson(json);
```

### Filter option sources

Enumeration / currency / color columns take typed `FilterItem`s — or a sync / async / stream source:

```dart
SuperEnumerationColumn<String>(
  key: 'priority', label: 'Priority', values: const ['Low', 'High'],
  filterItems: const [FilterItem('🟢 Low', 'Low'), FilterItem('🔴 High', 'High')],
);

// or:
filterSource: FilterValueSources.async(() => api.distinctPriorities()),
```

### Load-more receives the filter state

```dart
SuperTableController<Map<String, dynamic>>(
  pagination: SuperPagination.loadMore,
  hasMore: true,
  onLoadMore: (filter) async {              // filter is the live SuperFilterState
    final page = await api.fetch(query: filter.toJson());
    c.appendRows(page, hasMore: page.length == pageSize);
  },
);
```

## Change tracking (ERP save-delta)

Most ERP grids stage edits and then post **only the delta** to a backend. Opt in with `trackChanges: true`; the controller snapshots a per-cell baseline and tracks every add / edit / delete against it. There is **zero overhead unless you opt in**.

```dart
final c = SuperTableController<Map<String, dynamic>>(
  mode: SuperTableMode.editable,
  addRowEnabled: true,
  trackChanges: true,                       // ← capture a baseline
  emptyRowValue: () => <String, dynamic>{'sku': '', 'qty': 0, 'price': 0.0},
  columns: [ /* … */ ],
  rows: [ /* … server data … */ ],
);

// … user edits a price, Tabs in a new row, deletes a row …

if (c.hasChanges) {
  final SuperChangeSet delta = c.changes;
  delta.added;     // List<SuperRowChange> — brand-new rows
  delta.modified;  // rows with changed cells (each carries its SuperCellChange list)
  delta.deleted;   // rows removed since the baseline
  await api.post(delta.toJson());           // {added:[…], modified:[…], deleted:[…]}
  c.acceptChanges();                        // re-baseline: the grid is clean again
}

// or throw the edits away:
c.rejectChanges();                          // restores cells, re-adds deleted rows, drops new ones
```

Dirty cells render a small accent corner. Query state directly with `c.rowStateOf(row)` (`pristine` / `added` / `modified` / `deleted`), `c.isRowDirty(row)`, and `c.isCellDirty(row, 'price')`. Rows streamed in via `appendRows(…)` are treated as clean baseline data, not local edits.

## Export (CSV / TSV / JSON)

Export reflects exactly what's on screen — the **active filter, sort order, and (optionally) the on-screen column order**.

```dart
final csv  = c.toCsv();                      // header + display text, comma-separated
final tsv  = c.toTsv();                      // paste straight into Excel / Sheets
final rows = c.toJsonRows();                 // List<Map<String,Object?>> of raw values

await c.copyCsvToClipboard();                // CSV → system clipboard (fires onNotify)

// Options:
c.toCsv(includeHeader: false, visibleOnly: false); // all columns, no header
c.toDelimited(delimiter: ';');                       // any delimiter
```

## Aggregations (min / max / custom)

Beyond `sum` / `avg` / `count`, columns can aggregate with `SuperAgg.min`, `SuperAgg.max`, or `SuperAgg.custom` + an `aggregator`. The result appears in the totals row and in each group header; `aggLabel` renames it there.

```dart
// Quantity-weighted average unit cost — Σ(qty·cost) / Σ(qty):
SuperComputedColumn<num>(
  key: 'wac', label: 'WAC',
  agg: SuperAgg.custom,
  aggLabel: 'WTD AVG',
  aggregator: (rows) {
    num q = 0, v = 0;
    for (final r in rows) { q += r['qty'] as num; v += (r['qty'] as num) * (r['cost'] as num); }
    return q == 0 ? 0 : v / q;
  },
  compute: (row) => row['cost'] as num,
  format: (v, row) => '\$${(v as num).toStringAsFixed(2)}',
);

SuperCurrencyColumn(key: 'cost', label: 'Unit Cost', agg: SuperAgg.min, aggLabel: 'MIN');
```

## Programmatic aggregation & hidden columns

Aggregate from code without rendering anything, and keep the dimensions that drive those aggregates off the grid.

### Group aggregates in code

`groupAggregates` returns a nested tree of `SuperGroupAggregate` nodes over the **live, filtered** view — independent of the on-screen group headers and collapse state.

```dart
// Nested region ▸ category roll-up of qty + value:
final tree = c.groupAggregates(
  groupBy: const ['region', 'category'],     // defaults to the live groupKeys
  aggregateColumns: const ['qty', 'value'],  // defaults to every column with an agg
);
for (final region in tree) {
  region.value;                 // 'North'
  region.count;                 // rows in the group
  region.aggregate('value');    // Σ value for the region
  for (final cat in region.children) { /* one level down */ }
}

// One-level group-by → {groupValue: aggregate}, independent of the live grouping:
final byRegion = c.aggregateBy('region', 'value', agg: SuperAgg.sum);

// The totals row, in code; and a single figure:
final totals = c.grandTotals(columns: const ['qty', 'value']);  // {qty: …, value: …}
final avg    = c.aggregateColumn('value', agg: SuperAgg.avg);
```

All four honour the active filter by default (`filtered: false` to ignore it) and accept `hidden` column keys.

### Hidden columns (filter / group / aggregate only)

A column declared `hidden: true` is **never rendered** (header, body, filter row, totals, group headers), is left out of export and the column chooser, and **can't be revealed** — but it stays fully usable **by key** for filtering, grouping, and aggregation.

```dart
SuperTableController<Map<String, dynamic>>(
  columns: [
    SuperTextColumn(key: 'sku', label: 'SKU'),
    SuperCurrencyColumn(key: 'value', label: 'Stock Value', agg: SuperAgg.sum),
    SuperTextColumn(key: 'region', label: 'Region', hidden: true),  // ← never shown
  ],
  rows: [ /* … each row still carries a region … */ ],
);

c.setColumnFilter('region', 'North');   // filter by the invisible column
c.toggleGroup('region');                // group by it
c.aggregateBy('region', 'value');       // {North: …, South: …}
c.dataColumns;                          // renderable columns (no hidden)
c.hiddenColumns;                        // the hidden ones
```

## Selection statistics

In a cell-selection mode (`singleCell` / `multiCells`), `controller.selectionStats` returns a live aggregate over the selected numeric cells — the spreadsheet status-bar number. The grid footer renders it automatically when two or more numeric cells are selected; read it yourself to drive a custom status bar.

```dart
final s = c.selectionStats;                  // null when nothing numeric is selected
if (s != null && s.hasAggregate) {
  print('Σ ${s.sum} · avg ${s.average} · min ${s.min} · max ${s.max} · n=${s.numericCount}');
}
```

## Per-cell edit locking

ERP rows often freeze once posted or approved. The `cellEditable` gate runs in addition to the mode + column rules; return `false` to make a specific cell read-only.

```dart
SuperTableController(
  mode: SuperTableMode.editable,
  // Lock every cell of a posted row — except its Status, so you can re-open it.
  cellEditable: (col, row) => row['status'] == 'Draft' || col.key == 'status',
  columns: [ /* … */ ],
);
```

Locked cells won't enter edit mode, won't clear on Delete, and won't accept a paste.

## Manual row reordering

Document lines (a quotation, a delivery note, a BOM) care about order. Reorder programmatically or via the *Move row up / down* entries in the editable row menu. Moves record undo and fire `onChange`. (No-op while grouped.)

```dart
c.moveRow(fromViewIndex, toViewIndex);
c.moveRowUp();      // the focused row
c.moveRowDown();
```

## SuperComboColumn — full AutoSuggestionsBox options

`SuperComboColumn` forwards every box option. The two **rebuildable** builders (`sourceController` / `cellController`) are re-invoked whenever the cell takes edit-focus **and** the row's `fingerPrint` changed — so suggestions can depend on the rest of the row.

```dart
SuperComboColumn<String>(
  key: 'bin', label: 'Bin',
  hintText: 'Search bins…',
  advancedSearch: true,
  itemBuilder: (context, suggestion, highlighted) => /* ... */,
  // Rebuilt when the row fingerPrint changes (e.g. after the warehouse cell changes):
  sourceController: (context, controller, row, cell) =>
      SuggestionSources.async<String>((q) => api.bins(row['warehouse'], q)),
);
```

Access a cell's live box from the controller:

```dart
c.comboControllerFor(row, 'bin'); // AutoSuggestionsBoxController?
c.comboSourceFor(row, 'bin');     // AutoSuggestionsSource?
```

## Focus & selection (programmatic)

```dart
c.selectCellAt(2, 1);            // one cell
c.selectCells([CellPos(0,0), CellPos(3,2)]);
c.selectRowAt(4);                // one row
c.selectRowsAt([0, 1, 2]);       // many rows
c.clearSelection();
```

Clicking the **row-number** cell selects the whole row **without** moving the active edit cursor.

## Keyboard

| Key | Action |
|---|---|
| arrows / `Tab` | move; `Tab` at the last cell **appends a row** and focuses its first cell |
| `Enter` / `F2` / type | edit |
| `⌘`/`Ctrl` + `Enter` | insert a row **after** the focused row (focus same column) |
| `⌘`/`Ctrl` + `Shift` + `Enter` | insert a row **before** the focused row |
| `⌘`/`Ctrl` + `C` / `V` / `X` | copy / paste (validated) / cut as JSON / TSV |
| `⌘`/`Ctrl` + `Z` / `Shift+Z` | undo / redo |
| `⌘`/`Ctrl` + `D` | duplicate the focused row — or **fill down** when the selection spans rows (2.1.0) |
| `⌘`/`Ctrl` + `R` | **fill right** across the selected range (2.1.0) |

Intercept keys yourself with the controller's `onKey` (return `true` to consume):

```dart
SuperTableController(
  onKey: (context, controller, node, event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyR) {
      controller.clearColumnFilters();
      return true;
    }
    return false;
  },
);
```

## Controller actions

```dart
c.setMode(SuperTableMode.editable);  // or toggleMode()
c.appendRows(more, hasMore: false);  // load-more / streaming
c.clearTable();
c.requestLoadMore();                 // == loadMore()
c.updateRows(rows);
c.updateColumns(columns);
c.moveRowUp();                       // reorder the focused row (1.0.0)
c.acceptChanges();                   // re-baseline after a save (1.0.0)
c.rejectChanges();                   // discard edits (1.0.0)
c.copyCsvToClipboard();              // export the live view (1.0.0)
c.validateAll();                     // full validation pass → issues (2.1.0)
c.revertRow(row);                    // baseline one row back (2.1.0)
final json = c.viewStateJson();      // save the user's view (2.1.0)
c.applyViewJson(json);               // …and restore it (2.1.0)
c.fillDown();                        // Excel ⌘D over the range (2.1.0)
```

## Validation summary & unique columns (2.1.0)

Editable grids validate on commit; before **posting** you want the whole table checked at once — including rows that were never touched, and rows on other pages.

```dart
SuperTextColumn(key: 'sku', label: 'SKU', required: true, unique: true), // natural key

final issues = c.validateAll();      // type rules + unique + validators, EVERY row
if (c.isValid) {
  post(c.changes);
} else {
  await showSuperValidationPanel(context, c);  // list + jump-to-cell
}
```

Each `SuperValidationIssue` carries the row, `sourceIndex`, `columnKey` / `columnLabel`, the message, and — when the cell is on screen — a `cell` position for `selectCellAt`. `validateAll` also lights the per-cell badges (pass `markCells: false` to keep it silent); the footer shows a tappable **⚠ N issues** chip whenever badges are lit. `unique:` compares display text case-insensitively and exempts blanks.

## Saved views (2.1.0)

Everything a user personalises about a grid — column order, widths, hidden columns, sort, group-bys, collapsed groups, filters — in one JSON-serialisable snapshot. Store it per user/screen; apply it on load.

```dart
final json = c.viewStateJson();               // → persist (prefs, backend…)
c.applyViewJson(json);                        // restore later
c.resetViewState();                           // back to the column declarations
final noFilters = c.viewState(includeFilters: false);  // layout only
```

Unknown keys in a saved view (schema drift) are dropped; new columns append in natural order.

## Fill down / fill right (2.1.0)

Spreadsheet muscle memory for repetitive entry. Select a range: `⌘/Ctrl+D` copies the **top row** of the range into every row below; `⌘/Ctrl+R` copies the **left column** rightward (values are coerced to each target column's type; incompatible cells are skipped). With a single cell, the value is pulled from the neighbour above/left. Locked cells (`cellEditable`) are respected, every write is validated, and the whole fill is **one undo step**. Also available as `c.fillDown()` / `c.fillRight()`.

## Group footers (2.1.0)

```dart
SuperTable(controller: c, groupFooters: true)
```

In readable mode with grouping active, each expanded group closes with a **Σ subtotal row**: the group label in the first column and each aggregate (`agg:` / `aggregator:`) aligned **under its own column** — a ledger subtotal line, complementing the inline chips in the group header.

## Per-cell / per-row revert (2.1.0)

With `trackChanges: true`, right-click a row → **Revert cell** (the focused cell) or **Revert row**. Reverting an *added* row removes it. Programmatic: `c.revertCell(row, 'price')`, `c.revertRow(row)`. Both sync the backing object, record undo, and fire `onChange`.

## Interaction events (2.2.0)

Observe gestures and state changes to drive the surrounding screen — open a detail drawer, mirror the cursor into a preview, log an audit trail. Pass a `SuperInteractions` bag; every callback is optional and a null one costs nothing. **These never change what the grid itself does** — selection, editing, sorting and menus behave exactly as before.

```dart
SuperTable<Order>(
  controller: c,
  interactions: SuperInteractions<Order>(
    // The canonical “open this record” hook: double-tap a readable row, or Enter.
    onRowActivate: (d) => openDrawer(d.row.value),
    onCellTap: (d) => print('tapped ${d.column.label} = ${d.value} @ ${d.globalPosition}'),
    onCellSecondaryTap: (d) => showMyContextMenu(d.globalPosition, d.row),
    onRowTap: (d) => print('row ${d.rowIndex} selected from the gutter'),
    onSelectionChanged: (sel) => setState(() =>
        _sum = sel.stats?.sum),         // cursor, anchor, rows, cells, numeric stats
    onSortChanged: (s) => print(s.isSorted ? '${s.columnLabel} ${s.ascending ? '↑' : '↓'}' : 'unsorted'),
  ),
);
```

`onCellTap` fires **after** the cell is selected; `onCellDoubleTap` fires alongside the editor opening (editable) or the row activating (readable). Selection + sort callbacks are **diffed after the controller settles**, so they also report **programmatic** changes (`selectCellAt`, `sortBy`, `clearSort`). Each cell callback gets a `SuperCellInteraction` (`rowIndex` / `columnIndex` / `sourceIndex`, `column`, `row`, `cell`, `value`, `controller`, `globalPosition`); row callbacks get a `SuperRowInteraction`.

## Column config (2.2.0)

Let users reshape the grid at runtime — reorder, show/hide, and pin columns — with a ready-made dialog, header-menu entries, and a controller API. Pins, order and visibility all persist in a saved view.

```dart
// Open the manager (drag-reorder · eye show/hide · pin left/none/right):
showSuperColumnManager(context, c);

// … or drive it from code:
c.setColumnPin('code', SuperPin.left);   // freeze to an edge (overrides declaration)
c.cycleColumnPin('total');               // none → left → right → none
c.pinOf(col);                            // the effective pin
c.hideColumn('notes');                   // c.showColumn / toggleColumnVisible / isColumnVisible
c.moveColumn('region', 2);               // reorder by key
c.managedColumns;                        // full renderable set (incl. user-hidden) in manager order

// Persist the whole layout — pins included:
final json = c.viewStateJson();          // { order, widths, visible, pins, sort, groups, filters }
c.applyViewJson(json);
```

`SuperTable(columnManager: true)` (the default) also adds **Pin ▸**, **Hide column**, and **Manage columns…** to every header menu; set it false to hide those entries while keeping the programmatic API. Runtime pins differ from a column's declared `pin:` (which is just the starting value) and from absolute `hidden:` columns (which can never be shown).

## Example

A runnable gallery lives in `example/` with nineteen focused examples:

1. **Read-only report** — readable mode, typed model, conditional row styling.
2. **Editable journal** — `validator` + `onChange`, Ctrl+Enter insert, live balance.
3. **Async combo** — `SuperComboColumn.sourceController` + `fingerPrint` rebuild.
4. **Controller-driven** — `setMode`, `onLoadMore`, programmatic filters + selection.
5. **Styling & filters** — cell/row styles, `FilterItem` dropdowns, `onKey`.
6. **Playground** — the full toolbar over every mode / option.
7. **Change tracking** — `trackChanges`, dirty cells, the `changes` delta, save / revert.
8. **Selection statistics** — `multiCells` + `selectionStats` status bar.
9. **Export** — `toCsv` / `toTsv` / `toJsonRows`, reflecting the filtered view.
10. **Aggregations** — `min` / `max` / `custom` aggregator (weighted average), `aggLabel`.
11. **Cell locking** — `cellEditable` to freeze posted rows.
12. **Row reordering** — `moveRowUp` / `moveRowDown` / `moveRow` with undo.
13. **Group aggregates & hidden columns** — `groupAggregates` / `aggregateBy` / `grandTotals` over a `hidden:` dimension.
14. **Expandable rows** — `SuperRowExpansion`, multi & single mode, per-row heights, animated panels.
15. **Validation & saved views** — `validateAll` + `unique:`, the `isValid` gate, `viewStateJson` / `applyViewJson`.
16. **Fill & group footers** — `⌘D`/`⌘R` range fill, `groupFooters:` Σ subtotal rows, revert cell/row.
17. **Interaction events** — `SuperInteractions`: `onRowActivate`, cell/row taps, selection + sort snapshots.
18. **Column config** — `showSuperColumnManager`, reorder / pin / show-hide, pins persisted in a saved view.
19. **Showcase** — interactions + column manager + grouping + totals + change tracking + export in one screen.

```bash
cd example
flutter run
```

## Roadmap

Planned for upcoming releases (ordered, not committed):

- **Frozen / pinned columns at the edges** beyond the row-number gutter (left & right pins for ERP key + action columns).
- **Column-level CSV/Excel formatters** and an `.xlsx` export helper (styled headers, number formats, frozen header row).
- **Server-side data source** — a `SuperTableDataSource` interface for server-driven sort / filter / page over large datasets, with built-in debounce.
- **Fill handle** — the draggable selection-corner UI over 2.1.0's `fillDown` / `fillRight`.
- **Virtualized rows** for very large in-memory datasets.
- **Accessibility pass** — semantics for screen readers and high-contrast theming.

## Architecture

Clean Architecture, MVC-aligned, split per feature. The `SuperTableController` / `AutoSuggestionsBoxController` are `ChangeNotifier`s that own all state and domain logic; widgets observe them and forward intents; entities and usecases (sorting, grouping, formatting, matching, validation) are plain Dart. Import the single barrel:

```dart
import 'package:super_table_field/super_table_field.dart';
```

## License

Internal GeniusLink design-system package.
