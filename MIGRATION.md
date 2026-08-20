# Migration to super_table_field 3.0.0

Version 3.0.0 starts the new performance architecture. The first milestone
materializes derived controller state instead of recomputing filtering, sorting,
grouping, pagination, and column resolution from rendering getters.

## Derived collections are snapshots

`renderList`, `view`, `filteredRows`, `sortedRows`, `cols`, `dataColumns`, and
`hiddenColumns` are materialized, unmodifiable snapshots. Do not mutate these
collections directly. Use controller APIs such as `updateRows`, `appendRows`,
`updateColumns`, `setSearch`, `sortBy`, and the grouping/visibility APIs so cache
invalidation remains correct.

## Batch related mutations

Use `controller.batch(...)` when several controller mutations belong to one UI
action. Cache invalidation happens immediately, while listener delivery is
coalesced to one notification:

```dart
controller.batch(() {
  controller.setSearch('open');
  controller.sortBy(amountColumn, false);
  controller.setPage(0);
});
```

## Performance diagnostics

The v3 controller exposes `debugPipelineRebuildCount`,
`debugColumnCacheRebuildCount`, `debugRowIndexRebuildCount`, and
`resetDebugPerformanceCounters()` for regression tests and profile harnesses.
They are diagnostic APIs, not application state.

---

# Migration to super_table_field 2.8.0

Version 2.8.0 adds responsive/intrinsic column width strategies without changing
the existing default behavior.

## New width-fit enum

```dart
enum SuperColumnWidthFit {
  none,
  auto,
  maxCell,
  fit,
}
```

Existing columns require no changes because the default is
`SuperColumnWidthFit.none`.

### `none`

Uses the declared `width`, including the typed column's existing default width.

### `auto`

All auto columns receive the same share of the horizontal viewport space left
after fixed, max-cell, and fit base widths are reserved.

### `maxCell`

Measures every rendered row value through `SuperColumnLogic.toText` and sizes
the column to the widest value plus normal horizontal cell padding and a
30 px rendering allowance. Empty tables
fall back to the declared width.

### `fit`

Keeps the declared width as a base. If the viewport still has empty horizontal
space after all columns are resolved, that surplus is divided equally between
fit columns.

## Manual resize precedence

`controller.setWidth(key, px)` is an explicit fixed override and takes
precedence over `widthFit`. Call:

```dart
controller.resetWidth(key);
```

to remove the override and restore responsive sizing.

Responsive layout widths are transient and are not persisted in
`SuperViewState.widths`; only explicit user/runtime width overrides are saved.

---

# Migration to super_table_field 2.7.3

Version 2.7.3 updates combo integration to `super_auto_suggestion_box 1.2.0`.
The upstream package now validates selected raw values through `FormField<T>`,
uses `onSelectionChanged` as its single public selection callback, removes the
old text/action callbacks, and uses the `SuperAutoSuggestionSources` namespace.

## Requirements

```yaml
dependencies:
  super_table_field: ^2.7.3
  # Add directly only when importing it independently.
  super_auto_suggestion_box: ^1.2.0
```

## Suggestion source names

Use the canonical source namespace:

```dart
final source = SuperAutoSuggestionSources.list<String>(
  const ['Piece', 'Box', 'Carton'],
);
```

The concrete source implementations were also renamed:

| Before | 1.2.0 |
|---|---|
| `ListSuggestionsSource<T>` | `SuperAutoListSuggestionsSource<T>` |
| `AsyncSuggestionsSource<T>` | `SuperAutoAsyncSuggestionsSource<T>` |
| `HybridSuggestionsSource<T>` | `SuperAutoHybridSuggestionsSource<T>` |
| `RemoteFallbackSuggestionsSource<T>` | `SuperAutoRemoteFallbackSuggestionsSource<T>` |
| `PagedSuggestionsSource<T>` | `SuperAutoPagedSuggestionsSource<T>` |

## Direct SuperAutoSuggestionsBox usage

`onSelected`, `onChanged`, `onSubmitted`, `onFieldSubmitted`,
`onEditingComplete`, `onSave`, and `onValidity` are no longer widget
arguments. Observe query text from the controller and use
`onSelectionChanged` for raw selection:

```dart
final controller = SuperAutoSuggestionsController<String>();

controller.text.addListener(() {
  final query = controller.text.text;
  // Observe query text when needed.
});

SuperAutoSuggestionsBox<String>(
  controller: controller,
  source: SuperAutoSuggestionSources.list<String>(
    const ['Piece', 'Box', 'Carton'],
  ),
  suggestionBuilder: (items, index, value) => SuperAutoSuggestionsItem(
    value: value,
    titleText: value,
  ),
  onSelectionChanged: (values) {
    final selected = values.isEmpty ? null : values.last;
    // Handle the selected raw String value.
  },
);
```

For custom validation, `validator` now receives the selected raw `T?` rather
than the query string. `SuperAutoSuggestionsBox<T>` participates in the normal
Flutter `FormField<T>` lifecycle.

`SuperComboColumn` keeps its table-level compatibility callbacks. Internally the
table adapts them to the 1.2.0 controller/selection model, including free-text
Enter commits.

## Localization fallback

Registering `SuperTableLocalizations.localizationsDelegates` is still required
for Arabic. If `SuperTableTranslation` is absent from the widget tree, package
strings now use an explicit built-in English translation instead of depending
on the process-wide `Intl.defaultLocale`.

---

# Migration to super_table_field 2.7.2

Version 2.7.2 updates combo integration to `super_auto_suggestion_box 1.1.0` and
uses the non-deprecated `Super`-prefixed suggestion APIs.

## Requirements

```yaml
dependencies:
  super_table_field: ^2.7.2
  # Add directly only when importing it independently.
  super_auto_suggestion_box: ">=1.1.0 <2.0.0"
```

## Suggestion API migration

`SuperComboColumn<T>` continues to expose raw `T` values for sources and
selection. Custom suggestion metadata now uses `SuperAutoSuggestionsItem<T>`:

```dart
SuperComboColumn<String>(
  key: 'account',
  label: 'Account',
  values: const ['1010 · Cash', '2000 · Payable'],
  suggestionBuilder: (items, index, account) {
    final parts = account.split(' · ');
    return SuperAutoSuggestionsItem<String>(
      value: account,
      titleText: parts.last,
      descriptionText: parts.first,
      keywords: parts,
    );
  },
);
```

When using the suggestion box directly, configure `source` and
`suggestionBuilder` on `SuperAutoSuggestionsBox`; the controller owns state only:

```dart
final controller = SuperAutoSuggestionsController<String>(
  allowFreeText: true,
);

SuperAutoSuggestionsBox<String>(
  controller: controller,
  source: SuggestionSources.list<String>(const ['Piece', 'Box', 'Carton']),
  suggestionBuilder: (items, index, value) => SuperAutoSuggestionsItem(
    value: value,
    titleText: value,
  ),
);
```

For row-scoped table combos, `sourceController` returns a
`SuperAutoSuggestionsSource<T>` and `cellController` returns a
`SuperAutoSuggestionsController<T>`. The table passes the resolved source to the
widget, matching the 1.1.0 contract.

---

# Previous migration: super_table_field 2.6.0

Version 2.6.0 aligns the package with the explicit typography API introduced in
`super_core 3.3.0`, together with the raw-value suggestion API in
`super_auto_suggestion_box 1.0.0` and `super_form_field 1.8.1+`.

## Requirements

```yaml
environment:
  sdk: ">=3.8.0 <4.0.0"
  flutter: ">=3.32.0"

dependencies:
  super_table_field: ^2.6.0
  # Add these directly only when your app imports them independently.
  super_core: ">=3.3.0 <4.0.0"
  super_auto_suggestion_box: ">=1.0.0 <2.0.0"
  super_form_field: ">=1.8.1 <2.0.0"
```

The `super_table_field` barrel continues to re-export `super_core` and
`super_auto_suggestion_box`.

## Combo column migration

`super_auto_suggestion_box` 1.0.0 uses raw `T` values at the public API
boundary. `SuperComboColumn<T>` follows that contract:

```dart
SuperComboColumn<String>(
  key: 'unit',
  label: 'Unit',
  values: const ['Piece', 'Box', 'Carton'],
  onSelected: (unit) {
    // unit is the raw String value.
  },
  sourceController: (context, controller, row, cell) {
    return SuggestionSources.list<String>(['Piece', 'Box', 'Carton']);
  },
);
```

Do not wrap `values`, `SuggestionSources.*` items, async fetch results, or
`onSelected` values in `AutoSuggestion<T>`. The table editor now builds
suggestion metadata from `SuperComboColumn.suggestionBuilder` when provided,
otherwise from each column's `display` callback.

## Theme setup

`SuperMaterialThemeData.light` and `.dark` now require explicit
`SuperTextTheme` values for both Material typography slots:

```dart
import 'package:super_table_field/super_table_field.dart';

final typography = SuperTextTheme();

MaterialApp(
  theme: SuperMaterialThemeData.light(
    textTheme: typography,
    primaryTextTheme: typography,
  ),
  darkTheme: SuperMaterialThemeData.dark(
    textTheme: typography,
    primaryTextTheme: typography,
  ),
  themeMode: ThemeMode.system,
);
```

Use `SuperTextTheme(isArabic: true)` for an Arabic-first typography ramp. For
desktop density, use `SuperTextTheme(isDesktop: true)` or derive the flag from
the same `SuperDeviceMode` used to build the Material theme.

`AutoSuggestionsBoxThemeData.of(context)` continues to derive its defaults from
the active `SuperMaterialThemeData`. Register an explicit extension only when
overriding the component theme.

## Typography migration

`SuperThemeData` no longer exposes `textTheme`. Replace old reads:

```dart
// Before
final theme = context.superTheme;
Text('Inventory', style: theme.textTheme.heading);

// After
final theme = context.superTheme;
final typography = context.superTextTheme;
Text(
  'Inventory',
  style: typography.heading.copyWith(color: theme.fg1),
);
```

Do not use these patterns in new code:

```dart
context.superTheme.textTheme
SuperThemeData.of(context).textTheme
context.superTheme.tokens.bodyFont
context.superTheme.tokens.displayFont
context.superTheme.tokens.monoFont
```

For text rendering, use the corresponding `SuperTextTheme` family instead:

```dart
context.superTextTheme.body.fontFamily
context.superTextTheme.h1.fontFamily
context.superTextTheme.mono.fontFamily
```

`SuperMaterialThemeData` no longer infers token font metadata from the supplied
`SuperTextTheme`. Configure body/display faces through
`SuperTextTheme(bodyFont:, otherFont:)`; pass `fontFamily` to
`SuperMaterialThemeData` only when a token-level override is intentionally
required.

Spacing, radii, colors, motion, and semantic tokens remain available from
`context.superTheme`.

## Validation

Run from the package root:

```bash
flutter pub get
dart format .
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

cd example
flutter pub get
flutter analyze
```

Regenerate lockfiles with `flutter pub get` after upgrading the dependency
graph.
