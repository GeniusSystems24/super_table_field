# super_table_field

[![pub package](https://img.shields.io/pub/v/super_table_field.svg)](https://pub.dev/packages/super_table_field)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.32.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.8.0-0175C2?logo=dart)](https://dart.dev)
[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)
[![license: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A keyboard-first, generic Flutter data grid for ERP, accounting, inventory, and other data-heavy applications.

`super_table_field` provides a single `SuperTable<R>` widget for readable and editable workflows, backed by a `SuperTableController<R>`. It includes typed columns, validation, filtering, grouping, totals, pagination, change tracking, export, clipboard operations, undo/redo, expandable rows, runtime column configuration, and English/Arabic localization.

The package also re-exports [`super_core`](https://pub.dev/packages/super_core) and [`super_auto_suggestion_box`](https://pub.dev/packages/super_auto_suggestion_box), so the main barrel import is sufficient for the table, design-system theme, and suggestion-box APIs.

```dart
import 'package:super_table_field/super_table_field.dart';
```

## Features

- Generic rows through `SuperRow<R>` with support for map-backed and typed domain models.
- Readable and editable modes that can be changed at runtime.
- Thirteen column types, including text, number, currency, enum, combo, date, checkbox, computed, and read-only columns.
- Inline editors based on `super_form_field`; combo cells use `SuperAutoSuggestionsBox`.
- Single-cell, multi-cell, single-row, and multi-row selection modes.
- Search, per-column filters, and advanced cross-column filters.
- Multi-level grouping, group aggregates, group footers, and grand totals.
- Page, infinite-scroll, and load-more pagination modes.
- Column sorting, resizing, pinning, visibility, and runtime reordering.
- Table-wide validation, unique constraints, and jump-to-cell issue panels.
- Optional change tracking for added, modified, and deleted rows.
- CSV, TSV, JSON, clipboard, fill-down, fill-right, undo, and redo operations.
- Conditional row and cell styling.
- Optional `SuperTableStyle` presets for calm ERP/accounting table styling.
- Expandable detail rows.
- Interaction callbacks for cells, rows, selections, and sorting.
- English and Arabic localization with LTR and RTL support.
- Light and dark themes through `SuperMaterialThemeData`.

## Requirements

| Requirement | Minimum version |
|---|---|---
| Dart SDK | `3.8.0` |
| Flutter SDK | `3.32.0` |
| `super_core` | `3.3.0` |
| `super_auto_suggestion_box` | `1.2.0` |
| `super_form_field` | `1.8.2` |

## Installation

Add the package to `pubspec.yaml`:

```yaml
dependencies:
  super_table_field: ^3.0.0
```

Then install the dependency:

```bash
flutter pub get
```

For local package development:

```yaml
dependencies:
  super_table_field:
    path: ../super_table_field
```

## Application setup

Register the package localization delegates and use the `super_core` Material themes:

```dart
import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = SuperTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates:
          SuperTableLocalizations.localizationsDelegates,
      supportedLocales: SuperTableLocalizations.supportedLocales,
      theme: SuperMaterialThemeData.light(
        textTheme: typography,
        primaryTextTheme: typography,
      ),
      darkTheme: SuperMaterialThemeData.dark(
        textTheme: typography,
        primaryTextTheme: typography,
      ),
      themeMode: ThemeMode.system,
      home: const InventoryTablePage(),
    );
  }
}
```

`super_core 3.3.0` requires explicit `SuperTextTheme` values for both
`textTheme` and `primaryTextTheme`. `SuperThemeData` no longer exposes
`textTheme`; read the branded typography through `context.superTextTheme` or
`SuperMaterialThemeData.of(context).textTheme`. The table follows the ambient
`SuperTextTheme` body/display/mono font families.

`SuperTableLocalizations` includes the package translation delegate together with Flutter's Material, Cupertino, and Widgets delegates. Registering it enables Arabic; if `SuperTableTranslation` is absent from the widget tree, package-owned strings use the built-in English fallback. The package currently supports:

```dart
const Locale('en');
const Locale('ar');
```

## Quick start

Create the controller once, dispose it with the widget lifecycle, and place `SuperTable` inside a bounded layout such as `Expanded`, `Flexible`, `SizedBox`, or a widget with `maxHeight`.

```dart
import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class InventoryTablePage extends StatefulWidget {
  const InventoryTablePage({super.key});

  @override
  State<InventoryTablePage> createState() => _InventoryTablePageState();
}

class _InventoryTablePageState extends State<InventoryTablePage> {
  late final SuperTableController<Map<String, dynamic>> controller;

  @override
  void initState() {
    super.initState();

    controller = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.editable,
      selectionMode: SuperSelectionMode.multiCells,
      addRowEnabled: true,
      trackChanges: true,
      emptyRowValue: () => <String, dynamic>{},
      columns: [
        SuperTextColumn(
          key: 'sku',
          label: 'SKU',
          width: 140,
          required: true,
          unique: true,
          mono: true,
        ),
        SuperTextColumn(
          key: 'name',
          label: 'Product',
          width: 220,
          required: true,
        ),
        SuperNumberColumn<int>(
          key: 'quantity',
          label: 'Quantity',
          width: 110,
          min: 0,
          agg: SuperAgg.sum,
        ),
        SuperComboColumn<String>(
          key: 'unit',
          label: 'Unit',
          width: 120,
          values: const ['Piece', 'Box', 'Carton'],
          allowFreeText: false,
        ),
        SuperCurrencyColumn(
          key: 'price',
          label: 'Unit price',
          width: 130,
          symbol: 'ر.ي',
          code: 'YER',
          min: 0,
          agg: SuperAgg.sum,
        ),
        SuperComputedColumn<num>(
          key: 'total',
          label: 'Total',
          width: 140,
          align: SuperAlign.end,
          agg: SuperAgg.sum,
          compute: (row) {
            final quantity = row['quantity'] as num? ?? 0;
            final price = row['price'] as num? ?? 0;
            return quantity * price;
          },
          format: (value, row) =>
              '${(value as num? ?? 0).toStringAsFixed(2)} YER',
        ),
        SuperCheckboxColumn(
          key: 'active',
          label: 'Active',
          width: 90,
        ),
      ],
      rows: [
        SuperRow.map({
          'sku': 'PRD-001',
          'name': 'Notebook',
          'quantity': 12,
          'unit': 'Piece',
          'price': 850.0,
          'active': true,
        }),
        SuperRow.map({
          'sku': 'PRD-002',
          'name': 'Printer paper',
          'quantity': 4,
          'unit': 'Box',
          'price': 6200.0,
          'active': true,
        }),
      ],
      onChange: (rows) {
        // Persist or synchronize the changed rows in the host application.
      },
      onNotify: (kind, message) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            tooltip: 'Toggle table mode',
            onPressed: controller.toggleMode,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SuperTable<Map<String, dynamic>>(
                controller: controller,
                columnFilters: true,
                advancedFilter: true,
                showTotals: true,
                showFooter: true,
                groupFooters: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Core concepts

### `SuperTableController<R>`

The controller owns the table state and data pipeline:

```text
rows
  → search
  → column or advanced filters
  → sorting
  → grouping
  → pagination
  → rendered table
```

It also manages selection, editing, validation, row operations, clipboard operations, history, change tracking, column configuration, and load-more state.

Create the controller in `initState`, keep it stable across rebuilds, and call `dispose()` from the owning `State` object.

### `SuperRow<R>`

Each row contains:

- `value`: the host-owned backing model.
- `cells`: editable table values keyed by column key.
- `id`: stable row identity.
- `fingerPrint`: a rebuild token for per-row editor resources.

Use a map-backed row for simple data:

```dart
final row = SuperRow.map({
  'code': '1001',
  'name': 'Cash',
  'balance': 25000,
});

final balance = row['balance'];
row['balance'] = 30000;
```

Use `SuperRow.of` for a typed domain model:

```dart
class Product {
  Product({required this.id, required this.name, required this.quantity});

  final int id;
  String name;
  int quantity;
}

final product = Product(id: 1, name: 'Notebook', quantity: 12);

final row = SuperRow<Product>.of(product, {
  'name': product.name,
  'quantity': product.quantity,
});
```

Use column `read` and `write` callbacks when values must be projected between cells and a typed backing model:

```dart
SuperTextColumn(
  key: 'name',
  label: 'Name',
  read: (value) => (value as Product).name,
  write: (value, next) => (value as Product).name = next,
);
```

### `SuperTable<R>`

`SuperTable` is the view. It observes the controller and renders headers, filters, rows, editors, totals, pagination, overlays, and status information.

The table must receive bounded vertical space:

```dart
Expanded(
  child: SuperTable<Map<String, dynamic>>(
    controller: controller,
  ),
);
```

Or pass an explicit height constraint:

```dart
SuperTable<Map<String, dynamic>>(
  controller: controller,
  maxHeight: 520,
);
```

## Column types

Use the typed column classes whenever possible. Instantiate `SuperColumn<T>` directly only for custom behavior that is not covered by the standard types.

| Column | Value type | Main use |
|---|---|---|---
| `SuperTextColumn` | `String` | General text and bilingual text through `arKey` |
| `SuperNumberColumn<T>` | `int`, `double`, or `num` | Quantities, rates, percentages, and numeric aggregates |
| `SuperCurrencyColumn` | `num` | Monetary values with symbol and optional code |
| `SuperEnumerationColumn<T>` | Any typed value | Strict pick-only selection |
| `SuperComboColumn<T>` | Any typed value | Suggestions with optional free text |
| `SuperProgressColumn<T>` | Numeric | Progress bar on a configurable range |
| `SuperColorColumn<T>` | Hex, integer, or `Color` | Color values and swatches |
| `SuperDateColumn` | `String` | `YYYY-MM-DD` date values |
| `SuperTimeColumn` | `String` | `HH:mm` time values |
| `SuperLinkColumn` | `String` | Clickable links |
| `SuperCheckboxColumn` | `bool` | Boolean values |
| `SuperComputedColumn<T>` | Derived | Read-only value computed from a row |
| `SuperReadonlyColumn` | `String` | Locked display value |

### Shared column options

Common options include:

```dart
SuperTextColumn(
  key: 'accountCode',
  label: 'Account code',
  width: 160,
  align: SuperAlign.start,
  pin: SuperPin.start,
  editable: true,
  sortable: true,
  groupable: true,
  filterable: true,
  required: true,
  unique: true,
  hidden: false,
  mono: true,
);
```

Important behaviors:

- `hidden: true` keeps the column available for filtering, grouping, and aggregation, but never renders or exports it.
- `editable: null` inherits the table mode; `true` or `false` overrides it.
- `unique: true` validates non-empty values across all rows case-insensitively.
- `formatter` changes displayed text only; sorting, filtering, grouping, and editing still use the raw value.
- `read` and `write` map table values to typed backing objects.

## Editing and validation

Switch modes at runtime:

```dart
controller.setMode(SuperTableMode.editable);
controller.setMode(SuperTableMode.readable);
controller.toggleMode();
```

### Column validation

Use `validator` for column-specific rules:

```dart
SuperNumberColumn<num>(
  key: 'quantity',
  label: 'Quantity',
  min: 0,
  validator: (context, controller, row, cell, value) {
    if (value < 0) return 'Quantity cannot be negative';
    return null;
  },
);
```

Use `onChange` as a pre-commit hook. Return `true` to accept the new value and `false` to reject it:

```dart
SuperNumberColumn<num>(
  key: 'debit',
  label: 'Debit',
  onChange: (context, controller, row, cell, previous, next) {
    if (next > 0) row['credit'] = 0;
    return next >= 0;
  },
);
```

### Table-wide validation

```dart
final issues = controller.validateAll();

if (issues.isEmpty) {
  // Submit or post the rows.
}
```

Use the side-effect-free validity getter when only a boolean is needed:

```dart
final canSubmit = controller.isValid;
```

Show the built-in validation panel:

```dart
await showSuperValidationPanel(context, controller);
```

The panel lists every issue and allows the user to jump to the affected cell.

### Per-cell edit locking

Use `cellEditable` to lock individual cells based on row state:

```dart
final controller = SuperTableController<Map<String, dynamic>>(
  columns: columns,
  rows: rows,
  mode: SuperTableMode.editable,
  cellEditable: (column, row) {
    final posted = row['posted'] as bool? ?? false;
    return !posted;
  },
);
```

## Change tracking

Enable change tracking when the host needs an add/modify/delete delta:

```dart
final controller = SuperTableController<Map<String, dynamic>>(
  columns: columns,
  rows: rows,
  trackChanges: true,
);
```

Read the current delta:

```dart
final SuperChangeSet<Map<String, dynamic>> changes = controller.changes;

final addedRows = changes.added;
final modifiedRows = changes.modified;
final deletedRows = changes.deleted;
```

Manage the baseline:

```dart
controller.acceptChanges(); // The current rows become the new baseline.
controller.rejectChanges(); // Restore the captured baseline.
```

Revert a single value or row:

```dart
controller.revertCell(row, 'quantity');
controller.revertRow(row);
```

## Filtering and search

### Search

```dart
controller.setSearch('notebook');
```

### Column filters

```dart
controller.setColumnFilter('active', true);
controller.setColumnFilter('status', 'Open');
controller.clearColumnFilters();
```

### Advanced filter

```dart
controller.setAdvancedFilter([
  const AdvancedFilterClause(
    columnKey: 'quantity',
    op: FilterOp.greaterOrEqual,
    value: 10,
  ),
  const AdvancedFilterClause(
    columnKey: 'active',
    op: FilterOp.equals,
    value: true,
  ),
]);
```

Column filters and the advanced filter are mutually exclusive. Activating one deactivates the other.

Persist or restore filter state:

```dart
final json = controller.filterStateJson();
controller.applyFilterJson(json);
```

### Filter option sources

Enum, currency, and color columns can receive static, asynchronous, or streaming filter options:

```dart
SuperEnumerationColumn<String>(
  key: 'status',
  label: 'Status',
  values: const ['Draft', 'Posted', 'Cancelled'],
  filterSource: FilterValueSource.async(() async {
    return const [
      FilterItem('Draft', 'Draft'),
      FilterItem('Posted', 'Posted'),
      FilterItem('Cancelled', 'Cancelled'),
    ];
  }),
);
```

## Grouping and aggregates

Declare an aggregate on a numeric column:

```dart
SuperNumberColumn<num>(
  key: 'amount',
  label: 'Amount',
  agg: SuperAgg.sum,
);
```

Available reducers:

```dart
SuperAgg.none
SuperAgg.sum
SuperAgg.avg
SuperAgg.count
SuperAgg.min
SuperAgg.max
SuperAgg.custom
```

For a custom aggregate:

```dart
SuperNumberColumn<num>(
  key: 'weightedRate',
  label: 'Weighted rate',
  agg: SuperAgg.custom,
  aggregator: (rows) {
    // Return the custom aggregate for the supplied rows.
    return rows.length.toDouble();
  },
);
```

Control grouping programmatically:

```dart
controller.setGroupKeys(['category', 'status']);
controller.toggleGroup('warehouse');
controller.clearGroups();
```

Read aggregate values:

```dart
final quantityTotal = controller.aggregateColumn('quantity');
final totals = controller.grandTotals();
final totalsByCategory = controller.aggregateBy(
  'category',
  'amount',
  agg: SuperAgg.sum,
);
final groupTree = controller.groupAggregates();
```

Enable visual group subtotal rows:

```dart
SuperTable<Map<String, dynamic>>(
  controller: controller,
  groupFooters: true,
);
```

## Pagination and loading

Select a pagination mode when creating the controller:

```dart
final controller = SuperTableController<Map<String, dynamic>>(
  columns: columns,
  rows: rows,
  pagination: SuperPagination.pages,
  pageSize: 25,
);
```

Available modes:

```dart
SuperPagination.none
SuperPagination.pages
SuperPagination.infinite
SuperPagination.loadMore
```

Change the mode or page programmatically:

```dart
controller.setPagination(SuperPagination.pages);
controller.setPage(2);
```

For remote loading, provide `onLoadMore` and update loading state after the request:

```dart
final controller = SuperTableController<Map<String, dynamic>>(
  columns: columns,
  rows: rows,
  pagination: SuperPagination.loadMore,
  hasMore: true,
  onLoadMore: (filterState) async {
    controller.setLoadMoreState(loadingMore: true);

    try {
      final nextRows = await repository.loadMore(filterState);
      controller.appendRows(nextRows, hasMore: nextRows.isNotEmpty);
    } finally {
      controller.setLoadMoreState(loadingMore: false);
    }
  },
);
```

The active `SuperFilterState` is passed to `onLoadMore`, allowing the remote request to honor search and filter criteria.

## Selection and interactions

Choose a selection mode:

```dart
controller.setSelectionMode(SuperSelectionMode.multiRows);
```

Available modes:

```dart
SuperSelectionMode.singleCell
SuperSelectionMode.multiCells
SuperSelectionMode.singleRow
SuperSelectionMode.multiRows
```

Programmatic selection:

```dart
controller.selectCellAt(0, 1);
controller.selectCells(const [CellPos(0, 0), CellPos(0, 1)]);
controller.selectRowAt(2);
controller.selectRowsAt([1, 2, 3]);
controller.selectAll();
controller.clearSelection();
```

Read spreadsheet-style statistics for numeric selected cells:

```dart
final SuperSelectionStats? stats = controller.selectionStats;
```

Observe user and programmatic interactions:

```dart
SuperTable<Map<String, dynamic>>(
  controller: controller,
  interactions: SuperInteractions<Map<String, dynamic>>(
    onCellTap: (details) {
      debugPrint('Cell: ${details.column.key}');
    },
    onRowActivate: (details) {
      openDetails(details.row.value);
    },
    onSelectionChanged: (selection) {
      debugPrint('Selected cells: ${selection.cells.length}');
    },
    onSortChanged: (sort) {
      debugPrint('Sort key: ${sort.columnKey}');
    },
  ),
);
```

Interaction callbacks are observers. They do not replace the table's built-in selection, editing, sorting, or menu behavior.

## Column management

The column manager is enabled by default in header menus:

```dart
SuperTable<Map<String, dynamic>>(
  controller: controller,
  columnManager: true,
);
```

Open it directly:

```dart
await showSuperColumnManager(context, controller);
```

Programmatic operations:

```dart
controller.setColumnPin('sku', SuperPin.start);
controller.cycleColumnPin('price');
controller.hideColumn('internalId');
controller.showColumn('internalId');
controller.toggleColumnVisible('status');
controller.moveColumn('price', 1);
controller.setManagedOrder(['sku', 'name', 'price', 'quantity']);
```

## Saved views

A saved view can include column order, widths, visibility, runtime pins, sorting, grouping, collapsed groups, and optionally filters.

```dart
final Map<String, dynamic> json = controller.viewStateJson();

// Persist json per user and screen.

controller.applyViewJson(json);
```

Reset personalization:

```dart
controller.resetViewState();
```

Keep active filters while resetting columns and grouping:

```dart
controller.resetViewState(clearFilters: false);
```

## Expandable rows

Add a detail panel below readable rows:

```dart
SuperTable<Map<String, dynamic>>(
  controller: controller,
  expansion: SuperRowExpansion<Map<String, dynamic>>(
    mode: SuperRowExpansionMode.single,
    defaultHeight: 140,
    builder: (context, controller, row) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text('Details for ${row['name']}'),
      );
    },
  ),
);
```

Use `SuperRowExpansionMode.multi` to allow multiple open rows. A `heightBuilder` can return a different expanded height per row.

## Conditional styling

### Cell styles

The first matching condition wins:

```dart
SuperNumberColumn<num>(
  key: 'balance',
  label: 'Balance',
  colorSign: true,
  styles: {
    (context, controller, row, cell) => (cell.value as num? ?? 0) < 0:
        const CellStyle(
          foreground: Color(0xFFD32F2F),
          fontWeight: FontWeight.w700,
        ),
  },
);
```

### Row styles

Pass row conditions to `SuperTable`:

```dart
SuperTable<Map<String, dynamic>>(
  controller: controller,
  styles: {
    (context, controller, row) => row['cancelled'] == true:
        const SuperRowStyle(
          foreground: Color(0xFF8A8A8A),
        ),
  },
);
```

Row styles take priority over cell styles.

## Combo columns and suggestions

A static combo column:

```dart
SuperComboColumn<String>(
  key: 'unit',
  label: 'Unit',
  values: const ['Piece', 'Box', 'Carton'],
  allowFreeText: false,
  clearButton: true,
);
```

`SuperComboColumn` follows `super_auto_suggestion_box` 1.2.0: suggestion data
and row-scoped sources use raw `T` values. Metadata is derived from optional
`suggestionBuilder`, then the column's `display` callback. Custom rows can
read the built `SuperAutoSuggestionsItem<T>` from `itemBuilder`.

The 1.2.0 suggestion box exposes selection through `onSelectionChanged` and
observes query text through `SuperAutoSuggestionsController.text`. The table
adapts these APIs internally while preserving `SuperComboColumn`'s table-level
selection/free-text behavior. Sources stay bound to
`SuperAutoSuggestionsBox`, while controller instances own field state.

```dart
SuperComboColumn<String>(
  key: 'account',
  label: 'Account',
  values: const ['1010 · Cash', '4000 · Revenue'],
  suggestionBuilder: (items, index, account) => SuperAutoSuggestionsItem<String>(
    value: account,
    titleText: account.split(' · ').last,
    descriptionText: account.split(' · ').first,
    keywords: [account],
  ),
);
```

For suggestions that depend on the current row, provide `sourceController` or `cellController`. Update `row.fingerPrint` when dependent row data changes so the per-cell resources are rebuilt the next time the cell enters edit mode:

```dart
row.randomFingerPrint();
```

## Rows and editing operations

```dart
controller.addRow();
controller.insertRowAfterFocus();
controller.insertRowBeforeFocus();
controller.duplicateRow();
controller.deleteRow();
controller.moveRowUp();
controller.moveRowDown();
controller.moveRow(0, 3);
```

Replace or append data:

```dart
controller.updateRows(nextRows);
controller.appendRows(nextRows);
controller.clearTable();
```

Replace the declared columns:

```dart
controller.updateColumns(nextColumns);
```

## Clipboard, export, and history

Export the current filtered and sorted view:

```dart
final csv = controller.toCsv();
final tsv = controller.toTsv();
final jsonRows = controller.toJsonRows();
```

Copy data:

```dart
await controller.copyCsvToClipboard();
await controller.copyJson();
```

Spreadsheet operations:

```dart
controller.fillDown();
controller.fillRight();
controller.cutRange();
await controller.paste();
```

History operations:

```dart
if (controller.canUndo) controller.undo();
if (controller.canRedo) controller.redo();
```

## Custom row menus

Extend the default row menu instead of replacing its standard actions:

```dart
SuperTable<Map<String, dynamic>>(
  controller: controller,
  rowMenuBuilder: (context, defaults) {
    return [
      ...defaults,
      SuperMenuEntry(
        label: 'Open details',
        separatorBefore: true,
        icon: Icons.open_in_new,
        onTap: () => openDetails(context.row.value),
      ),
    ];
  },
);
```

## Table appearance

Common view options:

```dart
SuperTable<Map<String, dynamic>>(
  controller: controller,
  density: SuperDensity.compact,
  numbered: true,
  showTotals: true,
  showFooter: true,
  formulaBar: true,
  showCopyJsonButton: true,
  showRedoUndoButtons: true,
  columnFilters: true,
  advancedFilter: true,
  columnManager: true,
  loading: false,
  skeletonRows: 8,
);
```

Available density modes:

```dart
SuperDensity.comfortable
SuperDensity.compact
```

The visual system derives its colors, typography, spacing, and component behavior from the active `SuperMaterialThemeData` supplied by `super_core`.

## Table styles

`SuperTableStyle` is optional. When `style` is `null`, no predefined table style is applied and the table keeps its existing/default appearance.

```dart
SuperTable<Map<String, dynamic>>(
  controller: controller,
  style: null,
);
```

Apply a predefined style explicitly:

```dart
SuperTable<Map<String, dynamic>>(
  controller: controller,
  style: SuperTableStyle.medium,
  groupFooters: true,
  showTotals: true,
);
```

Available presets:

```dart
SuperTableStyle.plainMinimal
SuperTableStyle.light
SuperTableStyle.medium
SuperTableStyle.dark
SuperTableStyle.accent
SuperTableStyle.bandedRows
SuperTableStyle.bandedColumns
SuperTableStyle.headerEmphasis
SuperTableStyle.gridBordered
SuperTableStyle.subtleBorders
```

Use `SuperTableStyle.presets` when building style pickers or comparison screens.

Style options mirror common office-table switches without changing table structure:

```dart
final style = SuperTableStyle.accent.copyWith(
  options: const SuperTableStyleOptions(
    showHeaderRow: true,
    showFooterRow: true,
    showTotalRow: true,
    showGroupRows: true,
    bandedRows: true,
    bandedColumns: false,
    emphasizeFirstColumn: true,
    emphasizeLastColumn: true,
  ),
);
```

`showFooterRow` styles the existing group footer/subtotal rows rendered by `SuperTable(groupFooters: true)`. `showTotalRow` styles the existing totals row rendered by `showTotals: true`. These options do not create rows, group data, or enable totals by themselves.

Custom styles can start from a preset and override selected areas:

```dart
final customLedgerStyle = SuperTableStyle.subtleBorders.copyWith(
  name: 'Ledger review',
  headerStyle: const SuperTableAreaStyle(
    background: Color(0xFFEFF4F8),
    foreground: Color(0xFF1F2937),
    fontWeight: FontWeight.w800,
  ),
  totalRowStyle: const SuperTableAreaStyle(
    background: Color(0xFFE7EEF6),
    fontWeight: FontWeight.w800,
  ),
  borderStyle: const SuperTableBorderStyle(
    dividerColor: Color(0xFFD7DEE8),
    strongDividerColor: Color(0xFFB9C4D2),
  ),
);
```

Interaction styles for selected, hovered, focused, and disabled cells are resolved by the table renderer. Conditional `SuperRowStyle` and `CellStyle` overrides still take priority over preset body styling.

## Localization and RTL

Set the application locale normally:

```dart
final typography = SuperTextTheme(isArabic: true);

MaterialApp(
  locale: const Locale('ar'),
  localizationsDelegates:
      SuperTableLocalizations.localizationsDelegates,
  supportedLocales: SuperTableLocalizations.supportedLocales,
  theme: SuperMaterialThemeData.light(
    textTheme: typography,
    primaryTextTheme: typography,
  ),
  darkTheme: SuperMaterialThemeData.dark(
    textTheme: typography,
    primaryTextTheme: typography,
  ),
  home: const InventoryTablePage(),
);
```

Flutter automatically applies RTL layout for Arabic. Table menus, filters, validation messages, pagination labels, column management, shortcut help, and status text use the package localization delegate. Without that delegate, package-owned strings fall back to deterministic English.

Read package translations directly from a widget context when needed:

```dart
final translations = context.superTableTranslations;
```

## Keyboard behavior

The table is designed for desktop and keyboard-heavy workflows. It supports cursor navigation, range selection, editing, clipboard operations, undo/redo, row operations, fill actions, and a shortcuts dialog.

Press `F1` while the table is focused to open the built-in shortcut reference.

Use the controller's `onKey` callback to intercept application-specific shortcuts before the table applies its default behavior:

```dart
final controller = SuperTableController<Map<String, dynamic>>(
  columns: columns,
  rows: rows,
  onKey: (context, controller, node, event) {
    // Return true when the application handled the event.
    return false;
  },
);
```

## Public API overview

### Main types

| API | Purpose |
|---|---|---
| `SuperTable<R>` | Table view |
| `SuperTableController<R>` | State, data pipeline, editing, and commands |
| `SuperRow<R>` | Backing value and editable cells |
| `SuperCell` | Individual cell value and error state |
| `SuperColumn<T>` | Flexible base column |
| `SuperInteractions<R>` | Host interaction callbacks |
| `SuperRowExpansion<R>` | Expandable row configuration |
| `SuperTableStyle` | Optional table-wide style preset or custom style |
| `SuperTableStyleOptions` | Office-style switches for header, totals, banding, and column emphasis |
| `SuperTableAreaStyle` | Background, foreground, and weight for one table area |
| `SuperTableBorderStyle` | Outer border and divider styling |
| `SuperFilterState` | Search and filter state |
| `SuperViewState` | Persistable user view configuration |
| `SuperChangeSet<R>` | Added, modified, and deleted row delta |
| `SuperValidationIssue<R>` | Table-wide validation result |
| `SuperSelectionStats` | Numeric selection statistics |
| `SuperGroupAggregate<R>` | Programmatic grouping result |

### Enums

| Enum | Values |
|---|---|---
| `SuperTableMode` | `readable`, `editable` |
| `SuperSelectionMode` | `singleCell`, `multiCells`, `singleRow`, `multiRows` |
| `SuperPagination` | `none`, `pages`, `infinite`, `loadMore` |
| `SuperDensity` | `comfortable`, `compact` |
| `SuperAlign` | `start`, `center`, `end` |
| `SuperPin` | `none`, `left`, `right` |
| `SuperAgg` | `none`, `sum`, `avg`, `count`, `min`, `max`, `custom` |
| `FilterOp` | Text, equality, comparison, range, and empty operators |
| `SuperColorValue` | `hex`, `number`, `color` |
| `SuperRowExpansionMode` | `single`, `multi` |
| `SuperTableStylePreset` | `plainMinimal`, `light`, `medium`, `dark`, `accent`, `bandedRows`, `bandedColumns`, `headerEmphasis`, `gridBordered`, `subtleBorders` |

### Built-in overlays

| Function | Purpose |
|---|---|---
| `showSuperMenu` | Display a table-style menu |
| `showSuperConfirm` | Display a confirmation dialog |
| `showSuperAdvancedFilter` | Display the advanced filter editor |
| `showSuperShortcuts` | Display the keyboard shortcut reference |
| `showSuperValidationPanel` | Display validation issues with jump-to-cell |
| `showSuperColumnManager` | Reorder, show/hide, and pin columns |

## Best practices

- Create and dispose `SuperTableController` with the widget lifecycle.
- Keep the controller instance stable; do not recreate it from `build`.
- Give `SuperTable` bounded height.
- Use typed column classes instead of the generic base class when possible.
- Keep domain persistence and remote synchronization outside the widget; use controller callbacks and change sets to connect them.
- Use `SuperRow.of` with `read` and `write` callbacks for typed domain models.
- Validate all rows before posting or saving.
- Persist `viewStateJson()` per user and screen when column personalization is enabled.
- Use `onLoadMore` with the supplied `SuperFilterState` for remote pagination.
- Dispose external streams, repositories, and suggestion sources in their owning application layer.

## Additional documentation

- [Changelog](CHANGELOG.md)
- [Issue tracker](https://github.com/GeniusSystems24/super_table_field/issues)
- [Repository](https://github.com/GeniusSystems24/super_table_field)
- [Package homepage](https://geniussystems24.github.io/super_table_field)

## License

This package is available under the [MIT License](LICENSE).

## Column width fitting (2.8.0)

Every column accepts `widthFit`:

```dart
SuperTextColumn(
  key: 'sku',
  label: 'SKU',
  width: 130,
  widthFit: SuperColumnWidthFit.none,
);

SuperTextColumn(
  key: 'description',
  label: 'Description',
  widthFit: SuperColumnWidthFit.maxCell,
);

SuperNumberColumn<int>(
  key: 'qty',
  label: 'Qty',
  widthFit: SuperColumnWidthFit.auto,
);

SuperTextColumn(
  key: 'notes',
  label: 'Notes',
  width: 180,
  widthFit: SuperColumnWidthFit.fit,
);
```

`SuperColumnWidthFit.none` keeps the declared (or typed default) width.
`auto` columns share the viewport width left after fixed/intrinsic/base widths
are reserved. `maxCell` measures the widest rendered row value, includes the
normal cell padding, and adds 30 px of measurement allowance to
avoid edge clipping/ellipsis. `fit` keeps its base width and shares any genuinely empty
viewport space with other fit columns.

A runtime `controller.setWidth(key, px)` override always wins and behaves as a
fixed width. Call `controller.resetWidth(key)` to restore the column's declared
`widthFit` behavior.

When `auto` and `fit` are mixed, `auto` resolves its equal viewport share first;
`fit` receives only surplus that is still empty afterward. If the resolved
columns are wider than the viewport, the existing horizontal scrolling behavior
is preserved.
