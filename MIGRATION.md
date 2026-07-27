# Migration to super_table_field 2.4.0

Version 2.4.0 aligns the package with `super_core 2.4.0` and
`super_auto_suggestion_box 0.9.0`.

## Requirements

```yaml
environment:
  sdk: ">=3.8.0 <4.0.0"
  flutter: ">=3.32.0"

dependencies:
  super_table_field: ^2.4.0
  # Only add these directly when your app imports them independently.
  super_core: ">=3.0.0 <4.0.0"
  super_auto_suggestion_box: 0.9.0
```

The `super_table_field` barrel continues to re-export `super_core` and
`super_auto_suggestion_box`.

## Theme setup

Use the generated Material themes instead of manually registering light and
dark theme extensions:

```dart
import 'package:super_table_field/super_table_field.dart';

MaterialApp(
  theme: SuperMaterialThemeData.light(),
  darkTheme: SuperMaterialThemeData.dark(),
  themeMode: ThemeMode.system,
);
```

`AutoSuggestionsBoxThemeData.of(context)` derives from the active
`SuperMaterialThemeData`. Add an explicit extension only for custom overrides.

## super_core 2.4.0 replacements

- Replace `SectionCard`, `SuperSection`, and `SuperCard` with
  `SuperSectionCard`.
- Replace `SectionHeader` with `SuperSectionHeader`.
- Read spacing, radii, control heights, and insets from
  `context.superTheme.spacing`.
- Read brand font families and motion from `context.superTheme.tokens`.
- Prefer `SuperScaffold` and `SuperGrid` for responsive page layouts.
- Use `color.withValues(alpha: value)` instead of `withOpacity`.

Example:

```dart
final theme = context.superTheme;
final spacing = theme.spacing;

SuperSectionCard(
  padding: spacing.cardPadding,
  child: Text(
    'Inventory',
    style: theme.textTheme.heading.copyWith(color: theme.fg1),
  ),
);
```

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

The example lockfile was removed because it referenced the previous dependency
graph. `flutter pub get` regenerates it against the migrated versions.
