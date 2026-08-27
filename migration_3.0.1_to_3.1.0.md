# Migration: super_table_field 3.0.1 → 3.1.0

Version `3.1.0` updates the select/editing integration used by
`SuperEnumerationColumn`, adopts the source-driven `SuperSelectFormField` API
from `super_form_field 1.12.0`, tightens package export boundaries, and
simplifies persistent table chrome.

## Requirements

Use `super_table_field 3.1.0` with compatible companion packages:

```yaml
dependencies:
  super_table_field: ^3.1.0
```

`super_table_field` itself requires compatible versions in these ranges:

```yaml
super_core: ">=3.6.0 <4.0.0"
super_auto_suggestion_box: ">=1.3.2 <2.0.0"
super_form_field: ">=1.12.0 <2.0.0"
```

If application code references public APIs from any companion package directly,
declare that package as a direct dependency as well.

After updating dependencies, run:

```console
flutter pub get
```

---

## 1. `SuperEnumerationColumn` now uses `SuperSelectFormField`

Enumeration cells are now edited through `SuperSelectFormField<T>` instead of
the previous generic enumeration editor implementation.

The table still owns:

- cell edit lifecycle;
- commit/cancel behavior;
- validation;
- keyboard navigation;
- row lifecycle;
- row-scoped resource caching.

`SuperSelectFormField` owns:

- option presentation;
- selection interaction;
- optional search;
- source loading;
- select controller state.

Existing local-value declarations remain valid:

```dart
SuperEnumerationColumn<String>(
  key: 'status',
  label: 'Status',
  values: const [
    'Draft',
    'Posted',
    'Cancelled',
  ],
);
```

`values` is now also the local-data shorthand used when no explicit select
sources are supplied.

### Source resolution order

`SuperEnumerationColumn` resolves selectable data in this order:

1. `sourcesController`
2. `sources`
3. `values`

This allows simple columns to remain concise while supporting static or
row-dependent source-driven values when needed.

---

## 2. Static source-driven enumeration values

Use `sources` when the column should use `SuperSelectSource<T>` instances.

Import `super_form_field` directly because `super_table_field` no longer
re-exports it:

```dart
import 'package:super_form_field/super_form_field.dart';
import 'package:super_table_field/super_table_field.dart';
```

Example:

```dart
SuperEnumerationColumn<String>(
  key: 'status',
  label: 'Status',
  sources: const [
    SuperSelectListSource<String>(
      items: [
        'Draft',
        'Posted',
        'Cancelled',
      ],
    ),
  ],
  optionBuilder: (items, index, status) => SuperOption<String>(
    value: status,
    label: status,
    description: 'Option ${index + 1} of ${items.length}',
  ),
);
```

Sources return raw domain values. `optionBuilder` converts those values to
`SuperOption<T>` presentation metadata.

Do not map repository or source results to `SuperOption<T>` before returning
them.

---

## 3. Row-dependent enumeration sources

Use `sourcesController` when available values depend on another cell in the
same row.

```dart
SuperEnumerationColumn<String>(
  key: 'bin',
  label: 'Bin',
  sourcesController: (context, controller, row, cell) {
    final warehouse = row['warehouse'] as String?;

    return [
      SuperSelectListSource<String>(
        items: binsByWarehouse[warehouse] ?? const [],
      ),
    ];
  },
  optionBuilder: (items, index, bin) => SuperOption<String>(
    value: bin,
    label: bin,
  ),
);
```

Row-scoped enumeration resources are cached using `row.fingerPrint`, following
the same lifecycle principle used by `SuperComboColumn` without copying the
combo implementation.

When a dependency changes and the available enumeration values must be rebuilt,
refresh the row fingerprint:

```dart
row.randomFingerPrint();
```

The next edit of that enumeration cell will resolve its row-scoped resources
again.

---

## 4. Row-scoped `SuperSelectFieldController`

Use `cellController` only when application code needs explicit control over the
`SuperSelectFieldController<T>` for a specific row/cell.

```dart
SuperEnumerationColumn<String>(
  key: 'status',
  label: 'Status',
  values: const ['Draft', 'Posted'],
  cellController: (context, controller, row, cell) {
    return SuperSelectFieldController<String>(
      initialValue: cell.value as String?,
    );
  },
);
```

The table caches row-scoped enumeration sources/controllers and clears cached
resources as affected rows are removed, replaced, reverted, or cleared.

---

## 5. Enumeration search and selection callbacks

`SuperEnumerationColumn` now exposes select-specific configuration including:

```dart
searchable
searchHint
emptyLabel
searchAutofocus
optionBuilder
onSelected
sources
sourcesController
cellController
```

Example:

```dart
SuperEnumerationColumn<String>(
  key: 'warehouse',
  label: 'Warehouse',
  values: warehouses,
  searchable: true,
  searchHint: 'Search warehouses…',
  emptyLabel: 'No warehouses found',
  onSelected: (warehouse) {
    // React to the typed selected value.
  },
);
```

When `searchable` is omitted, the column can enable search automatically for
larger local lists and source-driven enumerations.

Selections remain typed values. The editor no longer needs to round-trip a
selection through a display string before committing it.

---

## 6. `super_form_field 1.12.0` select migration

`super_form_field 1.12.0` removed
`SuperSelectFormField<T>.options`.

`SuperSelectFormField<T>` now requires:

- `sources`
- `optionBuilder`

### Before

```dart
SuperSelectFormField<String>(
  options: const [
    SuperOption(
      value: 'open',
      label: 'Open',
    ),
    SuperOption(
      value: 'closed',
      label: 'Closed',
    ),
  ],
);
```

### After

```dart
SuperSelectFormField<String>(
  sources: const [
    SuperSelectListSource<String>(
      items: ['open', 'closed'],
    ),
  ],
  optionBuilder: (items, index, item) => SuperOption<String>(
    value: item,
    label: item == 'open' ? 'Open' : 'Closed',
  ),
);
```

For remote data, return raw values from the loader:

```dart
SuperSelectFormField<Warehouse>(
  sources: [
    SuperSelectRemoteSource<Warehouse>(
      loader: repository.fetchWarehouses,
    ),
  ],
  optionBuilder: (items, index, warehouse) => SuperOption<Warehouse>(
    value: warehouse,
    label: warehouse.name,
  ),
);
```

This change is handled internally for `SuperEnumerationColumn`, but
application code that directly creates `SuperSelectFormField` must also migrate
to the new API.

Upstream reference:

https://github.com/GeniusSystems24/super_form_field/blob/main/migration_1.11.1_to_1.12.0.md

---

## 7. Companion packages are no longer re-exported

`super_table_field` no longer re-exports:

- `super_core`
- `super_auto_suggestion_box`
- `super_form_field`

The main barrel only exports `super_table_field` APIs and its localization
surface.

### Before

Code may have compiled with only:

```dart
import 'package:super_table_field/super_table_field.dart';
```

while also using companion-package types indirectly exposed by that import.

### After

Import every package whose public API you use:

```dart
import 'package:super_core/super_core.dart';
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import 'package:super_form_field/super_form_field.dart';
import 'package:super_table_field/super_table_field.dart';
```

Only include the imports you actually need.

If application code uses companion APIs directly, also add those packages as
direct dependencies in `pubspec.yaml`.

For example, source-driven `SuperEnumerationColumn` declarations that mention
`SuperSelectListSource`, `SuperSelectRemoteSource`, `SuperOption`, or
`SuperSelectFieldController` require a direct `super_form_field` import.

---

## 8. `super_core 3.6.0` section components

`super_table_field 3.1.0` is compatible with `super_core >=3.6.0 <4.0.0`.

`super_core 3.6.0` removed these older section APIs:

- `SuperSectionCard`
- `SuperSectionHeader`
- `SuperSectionHeaderStyle`

If application code uses them, migrate to the numbered components.

### Before

```dart
SuperSectionCard(
  title: 'Summary',
  child: const SummaryView(),
);
```

### After

```dart
SuperSectionCard1(
  title: 'Summary',
  child: const SummaryView(),
);
```

or use `SuperSectionCard2` when its visual treatment is appropriate.

If marker colors are needed, use `accentColor` with the active Super theme
instead of the removed marker-based API.

Upstream reference:

https://github.com/GeniusSystems24/super_core/blob/main/migeration_3.5.1_to_3.6.0.md

---

## 9. Persistent bottom status strip removed

The persistent bottom table strip has been removed.

It previously displayed information such as:

- row count and interaction hints;
- keyboard shortcut hints;
- selection aggregates (`Sum`, `Avg`, `Min`, `Max`, `Count`);
- selected-row count;
- validation/status indicators.

No replacement strip is rendered automatically.

### Selection statistics remain available

`SuperTableController.selectionStats` remains available for application-owned
UI:

```dart
final stats = controller.selectionStats;

if (stats != null) {
  Text(
    'Sum ${stats.sum} · '
    'Avg ${stats.avg} · '
    'Min ${stats.min} · '
    'Max ${stats.max} · '
    'Count ${stats.count}',
  );
}
```

Use this API when the application needs its own status card, toolbar, footer, or
summary panel.

### `showFooter` behavior

`showFooter` still controls footer functionality such as pagination and
load-more controls.

It no longer adds the removed always-visible table status strip.

### Validation

Validation remains available through the controller and validation APIs,
including:

```dart
controller.validateAll();
controller.errorCount;
showSuperValidationPanel(context, controller);
```

---

## 10. Column-header three-dot icon removed

The vertical three-dot action icon is no longer rendered in column headers.

The column header context menu itself remains available through the existing
header interactions:

- right-click with a mouse;
- double-tap on touch input.

No API migration is required for this change.

Sorting, resizing, pin/group indicators, column configuration, and existing
header-menu actions remain separate from the removed visual affordance.

---

## 11. Example updates

The example application now demonstrates `SuperEnumerationColumn` using the
new select integration, including:

- local `values`;
- explicit `SuperSelectListSource`;
- `optionBuilder`;
- searchable enumeration fields;
- row-dependent `sourcesController`;
- fingerprint-driven source refresh.

The gallery imports companion packages directly rather than relying on
`super_table_field` re-exports.

The selection-statistics example now demonstrates how to build application-owned
statistics UI with `controller.selectionStats` instead of relying on the removed
persistent table strip.

---

## Upgrade checklist

1. Update `super_table_field` to `^3.1.0`.
2. Run `flutter pub get`.
3. Ensure no dependency override pins `super_form_field` below `1.12.0`.
4. If application code directly uses `SuperSelectFormField`, replace `options`
   with `sources` plus `optionBuilder`.
5. Keep source loaders returning raw `List<T>` domain values.
6. Existing local `SuperEnumerationColumn(values: ...)` declarations can remain
   unchanged.
7. Use `sources` for source-driven enumeration values.
8. Use `sourcesController` for row-dependent enumeration values.
9. Call `row.randomFingerPrint()` when a dependency change should rebuild
   row-scoped enumeration resources.
10. Add direct imports/dependencies for `super_core`,
    `super_auto_suggestion_box`, or `super_form_field` when application code
    references their public APIs.
11. Replace removed `super_core` `SuperSectionCard` / `SuperSectionHeader` APIs
    if application code still uses them.
12. Move any UI that depended on the old bottom statistics strip to
    application-owned UI backed by `controller.selectionStats`.
13. Do not depend on the removed column-header three-dot affordance; use the
    existing right-click or double-tap header interaction for the context menu.
14. Run:

```console
dart format .
flutter analyze
flutter test
```

15. Run the application and verify:
    - enumeration selection and search;
    - row-dependent enumeration refresh;
    - keyboard edit/commit/cancel navigation;
    - pagination/load-more footer behavior;
    - custom selection-statistics UI, if used;
    - column-header context-menu access.

---

## Summary of compatibility impact

### Existing code that should continue to work

- `SuperEnumerationColumn(values: ...)`
- typed enumeration values and display mapping
- table selection behavior
- `SuperTableController.selectionStats`
- pagination and load-more footer controls
- column header context-menu actions

### Code that may require changes

- direct `SuperSelectFormField(options: ...)` usage;
- code relying on companion packages being re-exported by
  `super_table_field.dart`;
- code using removed `super_core 3.5.x` section APIs;
- UI expectations that depend on the old persistent bottom status strip;
- user guidance that tells users to click the removed three-dot header icon.
