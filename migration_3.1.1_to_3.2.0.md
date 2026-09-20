# Migration: super_table_field 3.1.1 → 3.2.0

Version `3.2.0` upgrades the combo-column integration to
`super_auto_suggestion_box 1.6.0`.

The main application-facing change is the `SuperComboColumn.suggestionBuilder`
signature. Suggestion builders now receive the active Flutter `BuildContext`
as their first parameter.

Most applications that do not provide a custom `suggestionBuilder` can upgrade
without source changes.

## Requirements

Use `super_table_field 3.2.0`:

```yaml
dependencies:
  super_table_field: ^3.2.0
```

`super_table_field` now requires:

```yaml
super_auto_suggestion_box: ">=1.6.0 <2.0.0"
```

If your application imports `super_auto_suggestion_box` directly, declare a
compatible direct dependency as well.

After updating dependencies, refresh your Flutter packages using your normal
project workflow.

---

## 1. `SuperComboColumn.suggestionBuilder` now receives `BuildContext`

`SuperComboColumn<T>.suggestionBuilder` now uses:

```dart
SuperAutoSuggestionBuilder<T>
```

instead of:

```dart
AutoSuggestionBuilder<T>
```

The builder signature changed from:

```dart
SuperAutoSuggestionsItem<T> Function(
  List<T> items,
  int index,
  T element,
)
```

to:

```dart
SuperAutoSuggestionsItem<T> Function(
  BuildContext context,
  List<T> items,
  int index,
  T element,
)
```

### Before

```dart
SuperComboColumn<Account>(
  key: 'account',
  label: 'Account',
  suggestionBuilder: (items, index, account) {
    return SuperAutoSuggestionsItem<Account>(
      value: account,
      titleText: account.name,
      descriptionText: account.code,
    );
  },
);
```

### After

```dart
SuperComboColumn<Account>(
  key: 'account',
  label: 'Account',
  suggestionBuilder: (context, items, index, account) {
    return SuperAutoSuggestionsItem<Account>(
      value: account,
      titleText: account.name,
      descriptionText: account.code,
    );
  },
);
```

If the builder does not need `context`, keep the parameter and leave it unused:

```dart
suggestionBuilder: (context, items, index, account) {
  return SuperAutoSuggestionsItem<Account>(
    value: account,
    titleText: account.name,
  );
},
```

---

## 2. Named suggestion builders must also add `BuildContext`

Named builder functions must add `BuildContext` as the first parameter.

### Before

```dart
SuperAutoSuggestionsItem<Account> buildAccountSuggestion(
  List<Account> items,
  int index,
  Account account,
) {
  return SuperAutoSuggestionsItem<Account>(
    value: account,
    titleText: account.name,
  );
}
```

### After

```dart
SuperAutoSuggestionsItem<Account> buildAccountSuggestion(
  BuildContext context,
  List<Account> items,
  int index,
  Account account,
) {
  return SuperAutoSuggestionsItem<Account>(
    value: account,
    titleText: account.name,
  );
}
```

The function can then continue to be passed normally:

```dart
SuperComboColumn<Account>(
  key: 'account',
  label: 'Account',
  suggestionBuilder: buildAccountSuggestion,
);
```

---

## 3. Rename explicit `AutoSuggestionBuilder<T>` annotations

If application code explicitly stores a builder using the old typedef, rename
it.

### Before

```dart
final AutoSuggestionBuilder<Account> accountSuggestionBuilder =
    (items, index, account) {
  return SuperAutoSuggestionsItem<Account>(
    value: account,
    titleText: account.name,
  );
};
```

### After

```dart
final SuperAutoSuggestionBuilder<Account> accountSuggestionBuilder =
    (context, items, index, account) {
  return SuperAutoSuggestionsItem<Account>(
    value: account,
    titleText: account.name,
  );
};
```

---

## 4. `BuildContext` can now be used for presentation metadata

The new parameter allows suggestion metadata to use values inherited from the
active widget tree, including theme and localization.

```dart
SuperComboColumn<Account>(
  key: 'account',
  label: 'Account',
  suggestionBuilder: (context, items, index, account) {
    final colorScheme = Theme.of(context).colorScheme;

    return SuperAutoSuggestionsItem<Account>(
      value: account,
      titleText: account.name,
      descriptionText: account.code,
      icon: Icon(
        Icons.account_balance_outlined,
        color: colorScheme.primary,
      ),
    );
  },
);
```

Use `context` for presentation and inherited UI values. Keep source loading,
queries, and domain-data access independent from widget-tree context whenever
possible.

---

## 5. Existing `SuperComboColumn.advancedSearch` usage does not need migration

`super_auto_suggestion_box 1.6.0` removed its deprecated `advancedSearch`
constructor field and uses `SuperAutoSuggestionsMode` instead.

`super_table_field 3.2.0` performs this adaptation internally.

Existing table code remains valid:

```dart
SuperComboColumn<Account>(
  key: 'account',
  label: 'Account',
  advancedSearch: true,
);
```

Internally, the table editor maps this to:

```dart
mode: SuperAutoSuggestionsMode.both
```

When `advancedSearch` is false, the embedded table editor uses:

```dart
mode: SuperAutoSuggestionsMode.textBox
```

No application change is required for `SuperComboColumn.advancedSearch`.

---

## 6. Existing `SuperComboColumn.leading` usage does not need migration

`super_auto_suggestion_box 1.6.0` removed its deprecated `leading` constructor
field and now expects leading content through `InputDecoration.prefixIcon`.

`super_table_field 3.2.0` performs this conversion internally.

Existing code remains valid:

```dart
SuperComboColumn<Account>(
  key: 'account',
  label: 'Account',
  leading: const Icon(Icons.account_balance_outlined),
);
```

The embedded suggestion box receives the equivalent configuration:

```dart
decoration: const InputDecoration(
  prefixIcon: Icon(Icons.account_balance_outlined),
)
```

No application change is required for `SuperComboColumn.leading`.

---

## 7. Direct `SuperAutoSuggestionsBox` usage must follow its 1.6.0 migration

The compatibility behavior described above applies to `SuperComboColumn`.

If your application uses `SuperAutoSuggestionsBox` directly, migrate that code
to the `super_auto_suggestion_box 1.6.0` API.

The following deprecated constructor fields were removed by
`super_auto_suggestion_box 1.6.0`:

| Removed field | Replacement |
| --- | --- |
| `label` | `decoration: InputDecoration(labelText: ...)` |
| `leading` | `decoration: InputDecoration(prefixIcon: ...)` |
| `hint` | `decoration: InputDecoration(helperText: ...)` |
| `advancedSearch` | `mode: SuperAutoSuggestionsMode.both` |

### Before

```dart
SuperAutoSuggestionsBox<Account>(
  source: source,
  suggestionBuilder: suggestionBuilder,
  label: 'Account',
  leading: const Icon(Icons.account_balance_outlined),
  hint: 'Choose an account',
  advancedSearch: true,
);
```

### After

```dart
SuperAutoSuggestionsBox<Account>(
  source: source,
  suggestionBuilder: suggestionBuilder,
  decoration: const InputDecoration(
    labelText: 'Account',
    prefixIcon: Icon(Icons.account_balance_outlined),
    helperText: 'Choose an account',
  ),
  mode: SuperAutoSuggestionsMode.both,
);
```

Also remember that its `suggestionBuilder` now receives `BuildContext` as the
first parameter.

For the complete direct-package migration, see the
`super_auto_suggestion_box` `migration_1.5.0_to_1.6.0.md` guide.

---

## 8. Source and controller APIs are otherwise unchanged

The following `SuperComboColumn` integrations remain valid in `3.2.0`:

```dart
values
display
sourceController
cellController
advancedSearch
advancedSearchBuilder
itemBuilder
loadingBuilder
emptyBuilder
hintText
leading
highlightMatch
maxVisibleRows
clearButton
onSelected
allowFreeText
```

For example, a row-dependent source remains unchanged:

```dart
SuperComboColumn<String>(
  key: 'item',
  label: 'Item',
  sourceController: (context, controller, row, cell) {
    return SuperAutoSuggestionSources.list<String>(
      itemsForRow(row),
    );
  },
);
```

Only custom suggestion metadata builders need the new leading `BuildContext`
parameter.

---

## 9. Example application localization

The example application now has its own localization resources:

```text
example/
├── l10n.yaml
└── lib/
    └── localizations/
        ├── intl_en.arb
        ├── intl_ar.arb
        └── generated/
```

The generated example localization class is:

```dart
SuperTableExampleLocalization
```

Example UI text has been moved from hard-coded strings into the English and
Arabic ARB resources.

This is an example-app change only and does not require migration in
applications using `super_table_field`.

---

## 10. Example gallery controls

The example gallery now exposes language and theme switching through
`IconButton` actions in the `AppBar`.

The previous bottom-page language and theme buttons were removed.

This does not affect the `super_table_field` public API.

---

## Migration checklist

When upgrading from `3.1.1` to `3.2.0`:

1. Update `super_table_field` to `3.2.0`.
2. If declared directly, update `super_auto_suggestion_box` to
   `>=1.6.0 <2.0.0`.
3. Rename explicit `AutoSuggestionBuilder<T>` annotations to
   `SuperAutoSuggestionBuilder<T>`.
4. Add `BuildContext context` as the first parameter of named combo suggestion
   builders.
5. Add `context` as the first parameter of inline
   `SuperComboColumn.suggestionBuilder` callbacks.
6. Keep existing `SuperComboColumn.advancedSearch` usage unchanged.
7. Keep existing `SuperComboColumn.leading` usage unchanged.
8. If using `SuperAutoSuggestionsBox` directly, migrate its removed
   `label`, `leading`, `hint`, and `advancedSearch` fields to the 1.6.0 API.
9. Run your project's normal analysis and test workflow after the migration.

## Minimal migration example

### Before — 3.1.1

```dart
SuperComboColumn<Account>(
  key: 'account',
  label: 'Account',
  advancedSearch: true,
  leading: const Icon(Icons.account_balance_outlined),
  suggestionBuilder: (items, index, account) {
    return SuperAutoSuggestionsItem<Account>(
      value: account,
      titleText: account.name,
      descriptionText: account.code,
    );
  },
);
```

### After — 3.2.0

```dart
SuperComboColumn<Account>(
  key: 'account',
  label: 'Account',
  advancedSearch: true,
  leading: const Icon(Icons.account_balance_outlined),
  suggestionBuilder: (context, items, index, account) {
    return SuperAutoSuggestionsItem<Account>(
      value: account,
      titleText: account.name,
      descriptionText: account.code,
    );
  },
);
```

Only the builder signature changes in this common `SuperComboColumn` case.
