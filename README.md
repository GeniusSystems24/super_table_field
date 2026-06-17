# super_table_field

[![style: flutter_lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)

A **GeniusLink design-system** Flutter package that pairs two production components and wires them together:

- **`SuperTable`** — a keyboard-first data grid with `readable` and `editable` modes, 13 column types, per-column filters, multi-level grouping, totals, pagination, clipboard, and undo/redo.
- **`AutoSuggestionsBox`** — a typeahead / combobox field with local + remote sources, fuzzy matching, multi-select, free-text, and an advanced-search overlay.

In editable mode, the table's `combo` columns are edited **through the real `AutoSuggestionsBox`** — one keyboard model, one look, no duplicate combobox.

Light + dark themes, full LTR + RTL. Faithful Dart ports of the React `super-table` and `auto-suggestion-box` tools.

## Features

- ✅ **Two modes, one grid** — flip `SuperTableController(mode: …)` between `readable` and `editable`.
- ✅ **13 column types** — `text`, `number`, `currency`, `percent`, `combo`, `enumeration`, `checkbox`, `date`, `time`, `color`, `progress`, `tag`, `rating`.
- ✅ **Per-column filters** (readable mode) — auto-typed control per column, full-bleed in the header.
- ✅ **Sticky row-number gutter** — frozen during horizontal scroll; click to select the whole row.
- ✅ **Grouping & aggregates** — group by any `groupable` column, with `sum`/`avg`/`min`/`max`/`count` totals.
- ✅ **Tree row context menu** — flexible builder with nested submenus.
- ✅ **Combo ⇄ AutoSuggestionsBox** — filter, arrow-navigate, pick, free-text, Tab traversal.
- ✅ **Progressive remote sources** — show local rows instantly, stream remote in behind a spinner.
- ✅ **Advanced search overlay** — `Ctrl`/`⌘`+`F` opens a modal search surface.
- ✅ **Theming** — `ThemeExtension`-based; light/dark in parity; LTR/RTL mirrored.

## Getting started

Add the dependency:

```yaml
dependencies:
  super_table_field:
    path: ../super_table_field   # or a git / hosted ref
```

Register **both** `ThemeExtension`s on your `ThemeData` (omitting them leaves components unstyled):

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

## Usage

### SuperTable with a combo column

`SuperTable` needs a **bounded height** — wrap it in `Expanded`/`Flexible`, or pass `maxHeight:`.

```dart
final controller = SuperTableController(
  mode: SuperTableMode.editable,
  columns: const [
    SuperColumn(key: 'sku',  label: 'SKU',  type: SuperColumnType.text, width: 130, mono: true),
    SuperColumn(key: 'qty',  label: 'Qty',  type: SuperColumnType.number, width: 90,
                align: SuperAlign.end, agg: SuperAgg.sum),

    // combo → edited through AutoSuggestionsBox in editable mode
    SuperColumn(key: 'unit', label: 'Unit', type: SuperColumnType.combo, width: 130,
                opts: ['each', 'box', 'pallet', 'kg', 'tonne']),

    SuperColumn(key: 'price', label: 'Price', type: SuperColumnType.currency, width: 120,
                align: SuperAlign.end, agg: SuperAgg.sum),
  ],
  rows: [
    {'sku': 'INV-SB-200', 'qty': 120, 'unit': 'each', 'price': 340.0},
    {'sku': 'INV-CM-050', 'qty': 38,  'unit': 'box',  'price': 18.5},
  ],
);

Expanded(child: SuperTable(controller: controller));
```

**Editing a combo cell** (double-click, or `Enter`):

| Key | Action |
|---|---|
| type | filter the options live |
| `↑` / `↓` | move the highlight |
| `Enter` / click | pick the option and **commit in place** (cell stays selected) |
| `Enter` again | step down to the next row |
| free text + `Enter` | commit the typed value (combo allows free text), stay in place |
| `Tab` / `Shift+Tab` | commit and move to the next / previous cell |
| `Esc` | cancel the edit |

`enumeration` columns (closed set) behave the same, minus free text.

### Per-column filters (readable mode)

A filter row renders beneath the header in `readable` mode (toggle with `SuperTable(columnFilters: …)`, default **on**). The control is chosen per column — value dropdown for `combo`/`enumeration`, tri-state for `checkbox`, a full-bleed contains field otherwise; `color` is skipped, and columns can opt out with `filterable: false`. Filters combine with **AND** and with the global search:

```dart
controller.setColumnFilter('cat', 'Raw Material'); // narrow one column ('' clears)
controller.columnFilter('cat');                    // → 'Raw Material'
controller.activeColumnFilters;                     // → {'cat': 'Raw Material'}
controller.clearColumnFilters();                    // reset all
```

### Grouping (readable mode)

Right-click a row for **Group by ▸** (a submenu of every `groupable` column), or use the header menu. Opt a column out with `groupable: false`.

```dart
controller.toggleGroup('cat');   // add / remove a grouping level
controller.groupKeys;            // active grouping columns, in order
```

### Row number column

```dart
SuperTable(controller: c, numbered: true); // show the gutter (default)
```

The gutter is **frozen** during horizontal scroll. Clicking a row number selects the **entire row**; `Shift` / `⌘`-click extend or toggle the selection band.

### Custom row context menu (with submenus)

`rowMenuBuilder` receives the row context plus the default entries; return the list to show. Any entry with `children` becomes an expandable tree node.

```dart
SuperTable(
  controller: c,
  rowMenuBuilder: (ctx, defaults) => [
    ...defaults,
    SuperMenuEntry(
      icon: Icons.bolt_outlined,
      label: 'Workflow',
      separatorBefore: true,
      children: [
        SuperMenuEntry(label: 'Approve', onTap: () => approve(ctx.row)),
        SuperMenuEntry(label: 'Reject',  danger: true, onTap: () => reject(ctx.row)),
        SuperMenuEntry(
          label: 'Assign to',
          children: [
            SuperMenuEntry(label: 'Finance', onTap: () => assign(ctx.rowIndex, 'finance')),
            SuperMenuEntry(label: 'Audit',   onTap: () => assign(ctx.rowIndex, 'audit')),
          ],
        ),
      ],
    ),
  ],
);
```

### AutoSuggestionsBox on its own

```dart
AutoSuggestionsBox<String>(
  source: SuggestionSources.list<String>([
    AutoSuggestion(value: 'each', label: 'each'),
    AutoSuggestion(value: 'box',  label: 'box'),
  ]),
  hintText: 'Type or pick…',
  onSelected: (s) => debugPrint('picked ${s.value}'),
  onSubmitted: (raw) => debugPrint('free text $raw'),
);
```

Behavioural notes:

- **Restore on blur** — leaving the field without picking reverts unconfirmed typing to the last committed value (unless nothing was ever committed). Disable with `restoreOnBlur: false`.
- **Caret-anchored query** — matching uses the text from the first character **up to the caret**, so editing mid-string filters on the prefix you're actually in.

### Suggestion sources

| Factory | Use |
|---|---|
| `SuggestionSources.list(items)` | static, in-memory |
| `SuggestionSources.strings(values)` | static plain strings |
| `SuggestionSources.fuzzy(items)` | fuzzy-ranked |
| `SuggestionSources.async(fetch)` | debounced remote lookup |
| `SuggestionSources.remoteFallback(...)` | **local-first, progressive remote** |

`remoteFallback` shows local matches instantly and only calls `fetch` when the local match count is `remoteThreshold` **or fewer** — remote rows then merge in (de-duplicated) behind a *“loading more”* indicator:

```dart
AutoSuggestionsBox<String>(
  source: SuggestionSources.remoteFallback<String>(
    initialItems: localVendors,
    fetch: (q) => api.searchVendors(q),  // Future<List<AutoSuggestion<String>>>
    remoteThreshold: 3,
    remoteMinChars: 1,
  ),
);
```

### Advanced search overlay

```dart
AutoSuggestionsBox<String>(
  items: directory,
  advancedSearch: true, // focus the field, then press Ctrl/⌘+F
);
```

Opens a modal surface over the same controller (a pick there commits straight back). Supply `advancedSearchBuilder` for a custom surface.

## Architecture

Clean Architecture, MVC-aligned, split per feature:

```
lib/
├── super_table_field.dart            # public barrel — import this
└── src/
    ├── core/                         # shared tokens, widgets, utils, extensions
    └── features/
        ├── auto_suggestion_box/
        │   ├── data/                 # suggestion sources (datasources), models
        │   ├── domain/               # entities, source contract, usecases
        │   └── presentation/         # controllers (Model), widgets + pages (View)
        └── super_table/
            ├── data/
            ├── domain/               # SuperColumn, SuperTableState, column logic
            └── presentation/
                ├── controllers/      # SuperTableController (the Model/state)
                ├── widgets/          # SuperTable, SuperCell, overlays (the View)
                └── pages/            # SuperTableDemo
```

- **Model** — `SuperTableController` / `AutoSuggestionsBoxController` are `ChangeNotifier`s that own all state and domain logic, free of widget concerns.
- **View** — widgets observe the controller and forward intents back.
- **Domain** — entities and usecases (sorting, grouping, formatting, matching) are plain Dart.

## Example

A runnable gallery lives in `example/`:

```bash
cd example
flutter run
```

It registers both theme extensions, toggles light/dark and LTR/RTL, and links the **SuperTable** demo (switch to *Editable*, edit the *Unit* combo column, group/filter in *Readable*) and the **Auto Suggestion Box** demo (single/multi/fuzzy, remote fallback, advanced search).

## Additional information

- **Bounded height** — `SuperTable` scrolls internally; give it a bounded height (`Expanded`, `Flexible`, or `maxHeight:`).
- **Theme parity** — when embedding the box yourself, register `AutoSuggestionsBoxThemeData` or the overlay will fall back to defaults.
- See `SKILL.md` for an agent-oriented usage guide.

## License

Internal GeniusLink design-system package.
