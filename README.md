# super_table_field

[![pub package](https://img.shields.io/pub/v/super_table_field.svg)](https://pub.dev/packages/super_table_field)
[![Flutter](https://img.shields.io/badge/Flutter-%E2%89%A53.32.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-%E2%89%A53.8.0%20%3C4.0.0-0175C2?logo=dart)](https://dart.dev)
[![license: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A generic Flutter data grid for ERP, accounting, inventory, and other
data-heavy applications.

`super_table_field` provides a single `SuperTable<R>` widget backed by a
`SuperTableController<R>`. It supports read and edit workflows, typed
columns, validation, filtering, grouping, totals, pagination, change
tracking, export, selection, runtime column configuration, keyboard
navigation, and English/Arabic localization.

<details>
<summary>Table of contents</summary>

- [super\_table\_field](#super_table_field)
  - [Features](#features)
  - [Get started](#get-started)
    - [Install](#install)
    - [Quick start](#quick-start)
  - [Core API](#core-api)
    - [SuperTableController](#supertablecontroller)
    - [SuperTable](#supertable)
    - [Rows](#rows)
    - [Columns](#columns)
  - [Combo suggestions](#combo-suggestions)
  - [Common operations](#common-operations)
  - [Localization](#localization)
  - [Examples](#examples)
  - [Documentation](#documentation)
  - [Migration guides](#migration-guides)
  - [Changelog](#changelog)
  - [License](#license)

</details>

## Features

- Generic rows for both map-backed data and typed domain models.
- Readable and editable table modes.
- Typed text, numeric, currency, enumeration, combo, date, time,
  checkbox, computed, and other column types.
- Inline editors powered by the GeniusLink form-field packages.
- Local and async combo suggestions through `SuperAutoSuggestionsBox`.
- Search, per-column filters, and advanced cross-column filters.
- Sorting, multi-level grouping, aggregates, subtotals, and grand totals.
- Page, infinite-scroll, and load-more pagination flows.
- Single-cell, multi-cell, single-row, and multi-row selection.
- Runtime column resize, reorder, pin, visibility, and saved view state.
- Validation, unique constraints, and per-cell edit locking.
- Optional change tracking for added, modified, and deleted rows.
- Clipboard, CSV/TSV/JSON export, fill operations, undo, and redo.
- Expandable rows, interaction callbacks, and conditional styling.
- Table style presets for data-heavy and financial interfaces.
- English/Arabic localization with LTR and RTL support.
- Keyboard-first desktop workflows.

## Get started

### Install

Add `super_table_field` to your `pubspec.yaml`:

```yaml
dependencies:
  super_table_field: ^3.2.2
```

Then import the package:

```dart
import 'package:super_table_field/super_table_field.dart';
```

The package keeps its public barrel focused on table-owned APIs.
Companion packages are not re-exported. If application code directly
uses their APIs, import and declare them directly.

| Dependency | Package constraint |
|---|---|
| Dart | `>=3.8.0 <4.0.0` |
| Flutter | `>=3.32.0` |
| `super_core` | `>=3.6.0 <4.0.0` |
| `super_auto_suggestion_box` | `>=1.7.0 <2.0.0` |
| `super_form_field` | `>=1.12.0 <2.0.0` |

Before upgrading between releases with API changes, review the
[migration guides](#migration-guides).

### Quick start

Create one controller for the lifetime of the table and dispose it with
the owning widget.

```dart
import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
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
          required: true,
          unique: true,
        ),
        SuperTextColumn(
          key: 'name',
          label: 'Product',
          width: 220,
        ),
        SuperNumberColumn<int>(
          key: 'quantity',
          label: 'Quantity',
          min: 0,
          agg: SuperAgg.sum,
        ),
        SuperCurrencyColumn(
          key: 'price',
          label: 'Price',
          symbol: r'$',
          min: 0,
        ),
      ],
      rows: [
        SuperRow.map({
          'sku': 'PRD-001',
          'name': 'Notebook',
          'quantity': 12,
          'price': 4.50,
        }),
        SuperRow.map({
          'sku': 'PRD-002',
          'name': 'Printer paper',
          'quantity': 4,
          'price': 8.75,
        }),
      ],
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
      appBar: AppBar(title: const Text('Products')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SuperTable<Map<String, dynamic>>(
          controller: controller,
          columnFilters: true,
          advancedFilter: true,
          showTotals: true,
        ),
      ),
    );
  }
}
```

`SuperTable` must receive bounded vertical space. In larger layouts,
place it inside `Expanded`, `Flexible`, `SizedBox`, or another widget
that supplies a height constraint.

## Core API

### SuperTableController

`SuperTableController<R>` owns the table state and data pipeline:

```text
rows
  → search
  → filters
  → sorting
  → grouping
  → pagination
  → rendered table
```

It also owns editing, validation, selection, row operations, history,
change tracking, column configuration, clipboard/export behavior, and
load-more state.

Common controller operations include:

```dart
controller.setSearch('invoice');
controller.setMode(SuperTableMode.readable);
controller.setPage(1);

controller.addRow();
controller.duplicateRow();
controller.deleteRow();

controller.undo();
controller.redo();

final csv = controller.toCsv();
final tsv = controller.toTsv();

controller.acceptChanges();
controller.rejectChanges();
```

### SuperTable

`SuperTable<R>` is the view layer. Use it to control table presentation
and optional UI surfaces while keeping state in the controller.

```dart
SuperTable<MyRow>(
  controller: controller,
  columnFilters: true,
  advancedFilter: true,
  showTotals: true,
  showFooter: true,
  groupFooters: true,
  columnManager: true,
  style: SuperTableStyle.bandedRows,
)
```

Important view options include filtering UI, totals, pagination footer,
formula bar, expandable rows, loading skeletons, interactions, runtime
column management, and table-wide styling.

### Rows

Use `SuperRow.map` for map-backed data:

```dart
final row = SuperRow.map({
  'code': '1001',
  'name': 'Cash',
  'balance': 12500.0,
});
```

Use `SuperRow.of` when the table is backed by a typed domain object:

```dart
final row = SuperRow.of(
  account,
  {
    'code': account.code,
    'name': account.name,
    'balance': account.balance,
  },
);
```

`SuperRow.fingerPrint` is a rebuild token for row-scoped editor
resources. Call `row.randomFingerPrint()` when a cell change should
invalidate dependent combo/select sources.

### Columns

| Column | Purpose |
|---|---|
| `SuperTextColumn` | Free-text values, validation, unique values, and optional bilingual cells. |
| `SuperNumberColumn` | Typed numeric values with min/max, decimals, formatting, and aggregation. |
| `SuperCurrencyColumn` | Monetary values with symbol/code formatting and aggregation. |
| `SuperEnumerationColumn` | Strict pick-only values backed by `SuperSelectFormField` sources. |
| `SuperComboColumn` | Pick-or-type values backed by `SuperAutoSuggestionsBox`. |
| `SuperProgressColumn` | Numeric progress values rendered as progress indicators. |
| `SuperColorColumn` | Color-oriented values and visual color cells. |
| `SuperDateColumn` | Date values with table editing and filtering support. |
| `SuperTimeColumn` | Time values with table editing and filtering support. |
| `SuperLinkColumn` | Link-like text values with dedicated rendering. |
| `SuperCheckboxColumn` | Boolean values rendered as checkboxes. |
| `SuperComputedColumn` | Read-only values computed from the current row. |
| `SuperReadonlyColumn` | Explicit read-only text values. |

Shared column options include width, alignment, pinning, editability,
sorting, grouping, filtering, required/unique validation, formatters,
aggregation, conditional styles, and custom read/write behavior.

## Combo suggestions

`SuperComboColumn<T>` uses `SuperAutoSuggestionsBox` for pick-or-type
editing. Static values are enough for simple cases:

```dart
SuperComboColumn<String>(
  key: 'unit',
  label: 'Unit',
  values: const ['Piece', 'Box', 'Carton'],
  allowFreeText: false,
)
```

For row-aware or remote data, build the source from the active cell:

```dart
SuperComboColumn<Account>(
  key: 'account',
  label: 'Account',
  display: (account) => account.name,
  allowFreeText: false,
  debounce: const Duration(milliseconds: 350),
  minResult: 2,
  sourceController: (context, controller, row, cell) {
    return SuperAutoSuggestionSources.async<Account>(
      (context, query) async {
        return repository.searchAccounts(query);
      },
      initialItems: cachedAccounts,
    );
  },
  suggestionBuilder: (context, items, index, account) {
    return SuperAutoSuggestionsItem<Account>(
      value: account,
      titleText: account.name,
      subtitleText: account.code,
      keywords: [account.code, account.name],
    );
  },
)
```

`SuperComboColumn` also exposes `debounce` and `minResult`. Local matches can be
shown immediately while remote work waits for the debounce window; `minResult`
controls when a small local result set should still be supplemented remotely.

Import `super_auto_suggestion_box` directly when application code
references `SuperAutoSuggestionSources`, `SuperAutoSuggestionsItem`, or
other APIs owned by that package.

## Common operations

The controller groups most table workflows into a small set of APIs:

| Workflow | Common APIs |
|---|---|
| Search and filters | `setSearch`, `setColumnFilter`, `setAdvancedFilter`, `clearColumnFilters` |
| Sorting and grouping | `sortBy`, `clearSort`, `setGroupKeys`, `toggleGroup`, `clearGroups` |
| Selection | `selectCellAt`, `selectCells`, `selectRowAt`, `selectRowsAt`, `selectAll`, `clearSelection` |
| Rows | `addRow`, `insertRow`, `duplicateRow`, `deleteRow`, `moveRow` |
| Columns | `hideColumn`, `showColumn`, `setColumnPin`, `moveColumn`, `setWidth` |
| History | `undo`, `redo` |
| Change tracking | `changes`, `acceptChanges`, `rejectChanges`, `revertCell`, `revertRow` |
| Export | `toCsv`, `toTsv`, `copyCsvToClipboard`, `copyJson` |
| Saved state | `filterState`, `viewState`, `applyFilterState`, `applyViewState` |
| Pagination | `setPagination`, `setPage`, `requestLoadMore`, `setLoadMoreState` |

For the complete signatures and available properties, use the generated
API documentation rather than duplicating every option in this README.

## Localization

The package includes English and Arabic localizations.

```dart
MaterialApp(
  localizationsDelegates:
      SuperTableLocalization.localizationsDelegates,
  supportedLocales:
      SuperTableLocalization.supportedLocales,
  home: const ProductsPage(),
)
```

Inside a table-related widget, the active localization can be read with:

```dart
final l10n = context.superTableLocalization;
```

RTL layout follows the active locale and Flutter directionality.

## Examples

The example application demonstrates the package as complete,
runnable screens:

- [Read-only report](example/lib/examples/example_1_readonly_report.dart)
- [Editable journal](example/lib/examples/example_2_editable_journal.dart)
- [Async combo suggestions](example/lib/examples/example_3_async_combo.dart)
- [Change tracking](example/lib/examples/example_7_change_tracking.dart)
- [Export](example/lib/examples/example_9_export.dart)
- [Validation views](example/lib/examples/example_15_validation_views.dart)
- [Interaction events](example/lib/examples/example_17_interaction_events.dart)
- [Runtime column configuration](example/lib/examples/example_18_column_config.dart)
- [Table styles](example/lib/examples/example_20_table_styles.dart)
- [Big data / load more](example/lib/examples/example_22_big_data_load_more.dart)
- [Enumeration select](example/lib/examples/example_23_enumeration_select.dart)
- [Browse all example screens](example/lib/examples)

Run the example application from the package's `example` directory when
you need a complete implementation rather than an isolated snippet.

## Documentation

- [Package documentation](https://geniussystems24.github.io/super_table_field)
- [API reference](https://pub.dev/documentation/super_table_field/latest/)
- [Repository](https://github.com/GeniusSystems24/super_table_field)
- [Example application](https://github.com/GeniusSystems24/super_table_field/tree/main/example)
- [Issue tracker](https://github.com/GeniusSystems24/super_table_field/issues)

The README is intentionally focused on the main workflows. Advanced API
details should live in Dart documentation, runnable examples, migration
guides, and the changelog.

## Migration guides

- [3.1.1 → 3.2.0](migration_3.1.1_to_3.2.0.md)
- [3.0.1 → 3.1.0](migration_3.0.1_to_3.1.0.md)
- [Migration index](MIGRATION.md)

## Changelog

See [`CHANGELOG.md`](CHANGELOG.md) for release notes, new features,
behavior changes, fixes, and breaking changes.

## License

`super_table_field` is available under the terms in [`LICENSE`](LICENSE).
