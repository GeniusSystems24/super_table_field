# super_table_field

A **GeniusLink design-system** Flutter package that pairs two components and wires them together:

- **`SuperTable`** — one keyboard-first data grid with a `readable` and an `editable` mode. 13 column types, 4 selection modes, live search, **per-column filters**, multi-level grouping with aggregates, totals row, pagination, JSON/TSV clipboard, and undo/redo.
- **`AutoSuggestionsBox`** — a typeahead / combobox field: filter-as-you-type, grouped results, fuzzy or prefix/contains matching, single- or multi-select, and free-text entry.

The headline feature: in **editable mode, `combo` columns are edited through the real `AutoSuggestionsBox`** — type to filter, `↑`/`↓` to move, `Enter`/click to pick, or type a free value and commit. No second combobox implementation; the table embeds the actual component.

Faithful Dart ports of the React `super-table` and `auto-suggestion-box` tools. Light + dark themes, LTR + RTL.

---

## Install

```yaml
# pubspec.yaml
dependencies:
  super_table_field:
    path: ../super_table_field   # or a git/hosted ref
```

```dart
import 'package:super_table_field/super_table_field.dart';
```

### Register the theme extensions

Both components theme through `ThemeExtension`s. Register them once on your `ThemeData` so colors track light/dark:

```dart
MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,
    extensions: [SuperThemeData.light, AutoSuggestionsBoxThemeData.light],
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,
    extensions: [SuperThemeData.dark, AutoSuggestionsBoxThemeData.dark],
  ),
  // …
);
```

> Fonts: the design system uses Manrope (display), Inter (body), JetBrains Mono (numerics) and Noto Naskh Arabic. Drop the `.ttf` files under `assets/fonts/` and uncomment the `fonts:` block in `pubspec.yaml` to match it exactly; otherwise platform defaults are used.

---

## Quick start — SuperTable with a combo column

```dart
final controller = SuperTableController(
  columns: const [
    SuperColumn(key: 'sku',  label: 'SKU',  type: SuperColumnType.text, width: 130, mono: true),
    SuperColumn(key: 'item', label: 'Item', type: SuperColumnType.text, width: 220),
    SuperColumn(key: 'qty',  label: 'Qty',  type: SuperColumnType.number, width: 90,
                align: SuperAlign.end, agg: SuperAgg.sum),

    // ↓↓↓ a combo column — edited through AutoSuggestionsBox in editable mode
    SuperColumn(
      key: 'unit',
      label: 'Unit',
      type: SuperColumnType.combo,
      width: 130,
      opts: ['each', 'box', 'pallet', 'kg', 'tonne', 'litre'],
    ),

    SuperColumn(key: 'price', label: 'Price', type: SuperColumnType.currency, width: 120,
                align: SuperAlign.end, agg: SuperAgg.sum),
  ],
  rows: [
    {'sku': 'INV-SB-200', 'item': 'Steel Beam 200mm', 'qty': 120, 'unit': 'each',   'price': 340.0},
    {'sku': 'INV-CM-050', 'item': 'Concrete Mix 50kg', 'qty': 38,  'unit': 'box',    'price': 18.5},
  ],
  mode: SuperTableMode.editable,
);

// …in build:
SuperTable(controller: controller);
```

Double-click (or press `Enter` on) a **Unit** cell and the `AutoSuggestionsBox` opens inline:

| Key | Action |
|---|---|
| type | filter the options live |
| `↑` / `↓` | move the highlight |
| `Enter` / click | pick the highlighted option, commit, move down |
| free text + `Enter` | commit the typed value (combo allows free text), move down |
| `Tab` / `Shift+Tab` | commit and move to the next / previous cell |
| `Esc` | cancel the edit |

---

## Quick start — AutoSuggestionsBox on its own

```dart
final box = AutoSuggestionsBoxController<String>(
  source: SuggestionSources.list<String>([
    AutoSuggestion(value: 'each',   label: 'each'),
    AutoSuggestion(value: 'box',    label: 'box'),
    AutoSuggestion(value: 'pallet', label: 'pallet'),
  ]),
  allowFreeText: true,
);

AutoSuggestionsBox<String>(
  controller: box,
  hintText: 'Type or pick…',
  onSelected: (s) => debugPrint('picked ${s.value}'),
  onSubmitted: (raw) => debugPrint('free text $raw'),
);
```

`SuggestionSources` also ships `.async(...)` for debounced remote lookups and `.fuzzy(...)` for fuzzy ranking — see the source for the full set.

---

## Column types

`text` · `number` · `currency` · `percent` · `combo` · `enumeration` · `checkbox` · `date` · `time` · `color` · `progress` · `tag` · `rating`

Each `SuperColumn` accepts: `key`, `label`, `type`, `width`, `align`, `mono`, `opts` (for `combo`/`enumeration`), `min`/`max` (numeric clamp + progress range), `agg` (`sum`/`avg`/`min`/`max`/`count`), and more — see `super_column.dart`.

## Per-column filters

A filter row sits directly beneath the header (toggle with `SuperTable(columnFilters: …)`, default **on**). Each column gets the right control automatically:

- `combo` / `enumeration` → a value dropdown (`All` + the column's `opts`)
- `checkbox` → a tri-state dropdown (`All` / `Checked` / `Unchecked`)
- everything else → a contains text field with a clear button
- `color` → no filter (not meaningful)

Filters combine with **AND** across columns and with the global search. The filter icon in the row-number gutter clears them all. Drive them programmatically too:

```dart
controller.setColumnFilter('cat', 'Raw Material'); // narrow one column
controller.columnFilter('cat');                    // → 'Raw Material'
controller.hasColumnFilters;                        // → true
controller.clearColumnFilters();                    // reset
```

---

## Architecture

Clean Architecture, MVC-aligned, split per feature:

```
lib/
├── super_table_field.dart            # public barrel — import this
└── src/
    ├── core/                         # shared tokens, widgets, utils, extensions
    └── features/
        ├── auto_suggestion_box/
        │   ├── data/                 # datasources (suggestion sources), models
        │   ├── domain/               # entities, repository contracts, usecases
        │   └── presentation/         # controllers (Model), widgets + pages (View)
        └── super_table/
            ├── data/
            ├── domain/               # SuperColumn, SuperTableState, column logic
            └── presentation/
                ├── controllers/      # SuperTableController  (the Model/state)
                ├── widgets/          # SuperTable, SuperCell, overlays (the View)
                └── pages/            # SuperTableDemo
```

- **Model** — `SuperTableController` / `AutoSuggestionsBoxController` are `ChangeNotifier`s holding all state and the domain logic. They are pure of widget concerns.
- **View** — the widgets observe the controller and render; they forward intents back.
- **Domain** — entities (`SuperColumn`, `AutoSuggestion`) and usecases (sorting, grouping, formatting, filtering) are plain Dart with no Flutter import where avoidable.

---

## Example

A runnable gallery lives in `example/`:

```bash
cd example
flutter run
```

It registers both theme extensions, toggles light/dark and LTR/RTL, and links the **SuperTable** demo (switch to *Editable* and edit the *Unit* combo column) and the standalone **Auto Suggestion Box** demo.

---

## License

Internal GeniusLink design-system package.
