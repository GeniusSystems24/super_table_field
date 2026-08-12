# Migration to super_table_field 2.6.0

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
