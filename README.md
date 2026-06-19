# super_table_field

[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

A **GeniusLink design-system** Flutter package providing a generic data grid, wired to the typeahead from its companion package:

- **`SuperTable<R>`** — a generic, keyboard-first data grid with `readable` and `editable` modes, a typed column hierarchy, per-column **and** advanced (cross-column) filtering, conditional row/cell styling, multi-level grouping, totals, pagination, clipboard, and undo/redo.
- **`AutoSuggestionsBox`** — a typeahead / combobox field with local + remote sources, fuzzy matching, multi-select, free-text, and an advanced-search overlay. It now lives in the companion [`super_auto_suggestion_box`](../super_auto_suggestion_box) package, which this package **depends on and re-exports** (along with the shared GeniusLink `core` foundation).

In editable mode, the table's `combo` columns are edited **through the real `AutoSuggestionsBox`** — one keyboard model, one look, no duplicate combobox.

Light + dark themes, full LTR + RTL.

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
- ✅ **Change tracking** — opt-in add/modify/delete delta (`SuperChangeSet`) with dirty-cell markers and accept/reject.
- ✅ **Export** — CSV / TSV / JSON of the live (filtered + sorted) view, plus copy-to-clipboard.
- ✅ **Selection statistics** — spreadsheet-style running aggregate over selected cells.
- ✅ **Per-cell edit locking** & **manual row reordering**.
- ✅ **Combo ⇄ AutoSuggestionsBox** — with per-cell, rebuildable sources/controllers driven by the row `fingerPrint`.
- ✅ **Clipboard** (JSON / TSV), **undo/redo**, **keyboard-first** with an `onKey` escape hatch.

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
```

## Example

A runnable gallery lives in `example/` with twelve focused examples:

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

```bash
cd example
flutter run
```

## Roadmap

Planned for upcoming releases (ordered, not committed):

- **Frozen / pinned columns at the edges** beyond the row-number gutter (left & right pins for ERP key + action columns).
- **Column-level CSV/Excel formatters** and an `.xlsx` export helper (styled headers, number formats, frozen header row).
- **Server-side data source** — a `SuperTableDataSource` interface for server-driven sort / filter / page over large datasets, with built-in debounce.
- **Footer (group) aggregation rows** rendered inline under each group, not just in the header.
- **Cell-level change history & per-cell revert** UI (right-click → *Revert cell*), building on the 1.0.0 baseline.
- **Validation summary panel** — collect every cell error into a dismissible list with jump-to-cell.
- **Fill handle & range fill** (drag the selection corner to copy down / right).
- **Column chooser / show-hide + reorder persistence** to a saved view JSON.
- **Virtualized rows** for very large in-memory datasets.
- **Accessibility pass** — semantics for screen readers and high-contrast theming.

## Architecture

Clean Architecture, MVC-aligned, split per feature. The `SuperTableController` / `AutoSuggestionsBoxController` are `ChangeNotifier`s that own all state and domain logic; widgets observe them and forward intents; entities and usecases (sorting, grouping, formatting, matching, validation) are plain Dart. Import the single barrel:

```dart
import 'package:super_table_field/super_table_field.dart';
```

## License

Internal GeniusLink design-system package.
