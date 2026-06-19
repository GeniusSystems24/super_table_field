# SuperTableField Package Requirements and Issues

update `flutter\super_table_field` flutter package as Version 0.4.0

## SuperTable Core

> Make `SuperTable` a generic type: `SuperTable<RowValueType>`.

### SuperTableController

* Allow the table mode to be changed through the controller, from read mode to edit mode and vice versa.
* Allow table actions such as loading more data, clearing the table, and other related operations to be triggered through the controller.

### EditableMode

* Fix the row-creation behavior when pressing `Tab` on the last cell of the last row. A new row should be added, and focus should move to the first cell of the newly created row.
* Allow creating a new row after the currently focused row by pressing `Ctrl + Enter`, or before the currently focused row by pressing `Shift + Ctrl + Enter`. After the new row is created, focus should move to the same column/cell position in the new row.

### Documentation

* Update the documentation in `README.md` using pub.dev package documentation style and principles.
* Update `CHANGELOG.md`.
* Update ai skill.
* Create 3 examples demonstrating different ways to use `SuperDataFormField`.

---

## Column

### Inherited Column Types

Create a dedicated class for each column type. Each class should inherit from the base `SuperColumn` class and define its own type-specific values, as follows:

* `SuperTextColumn`.
* `SuperNumberColumn<T extends num>`.
* `SuperCurrencyColumn`.
* `SuperEnumerationColumn<T>`.
* `SuperComboColumn<T>`.
* `SuperProgressColumn<T>`.
* `SuperColorColumn<T>`, with support for defining how the value should be handled: as a number, text, or `Color`.
* `SuperDateColumn`.
* `SuperTimeColumn`.
* `SuperLinkColumn`.
* `SuperCheckboxColumn`.

Keep `SuperColumn` available as a flexible base column for custom usage.

### Column Functions

* Add an `onChange` function as follows:

```dart
SuperXColumn<T>(
// in EditableMode.
// default value is: (BuildContext context, SuperTableController<RowValueType> tableController, row, cell, previousValue, newValue) => true,
//
onChange: (BuildContext context, SuperTableController<RowValueType> tableController, SuperRow<RowValueType> row, cell, T previousValue, T newValue) {
    // can reset value of other cells
    row.cells["columnName"].value = ...; 
    // can change row's fingerPrint
    row.fingerPrint = ....;
    // or
    row.randomFingerPrint();

    // it should return a bool value: true if newValue is valid, or false if it is not.
    if (/* newValue is ... */)
        return true;
    else 
        return false;
}
)
```

* Add a `validator` function as follows:

```dart
SuperXColumn<T>(
// in EditableMode.
// default value is: (BuildContext context, SuperTableController<RowValueType> tableController, row, cell, value) => null,
//
validator: (BuildContext context, SuperTableController<RowValueType> tableController, SuperRow<RowValueType> row, cell, T value) {
    // check whether the value is invalid
    return 'error code';
}
)
```

---

## Filtering System

### Filter Source

* Add source types for filter values, such as sync, async, and stream sources.

### Advanced Table Filter

* Add an advanced filter button in the header of the row-number column. When the advanced filter is active, the column filter fields should be cleared, disabled, and visually marked with a slash `/` to indicate that they are inactive.
* When the advanced filter is active, the icon should display a red badge, or another suitable color, to indicate that filter settings are currently applied.

### Filtering System

* Allow filters to be set programmatically, whether advanced filters or column filters. When a column filter is changed, ensure that the advanced filter is not active.
* Allow the current filter state to be extracted programmatically from the controller as a structured JSON object.
* Include the current filter state in the `onLoadMore` operation so it can be used during data fetching.

### EnumerationColumn

* Make its filter values a list of `FilterItem(String display, T value)` instead of `List<String>`.

### SuperCurrencyColumn

* Make its filter values a list of `FilterItem(String display, T value)` instead of `List<String>`.

### SuperColorColumn

* Make its filter values a list of `FilterItem(String display, T value)` instead of `List<String>`.

---

## Row

### Row Style

* Add conditional row styling, allowing the row background color or text color to be determined according to a set of conditions, as follows:
* This style should take priority over the column style.

```dart
SuperTable<RowValueType>(
    // in ReadableMode
    styles: {
        conditionFun1(BuildContext context, SuperTableController<RowValueType> tableController, SuperRow<RowValueType> row) => true: SuperRowStyle(),
        conditionFun2(BuildContext context, SuperTableController<RowValueType> tableController, SuperRow<RowValueType> row) => true: SuperRowStyle(),
    }
)
```

### Row Context Menu

* Make tree options display their branches as an `overlayCard`, and allow them to expand into nested tree branches as needed.

---

## Cell

### Filter Cell

* Enhance the filter cell design.

### Cell Style

* Add conditional cell styling, allowing the cell background color or text color to be determined according to a set of conditions, as follows:

```dart
SuperXColumn<T>(
    // in ReadableMode
    styles: {
        conditionFun1(BuildContext context, SuperTableController<RowValueType> tableController, SuperRow<RowValueType> row, cell) => true: CellStyle(),
        conditionFun2(BuildContext context, SuperTableController<RowValueType> tableController, SuperRow<RowValueType> row, cell) => true: CellStyle(),
    }
)
```

---

## SuperComboColumn

* Add all `AutoSuggestionsBox` options, as follows:

```dart
SuperComboColumn<T>(
key: '...',
label: '...',
//------------------------- normal options ----------------------------------
// one for all
advancedSearch: ...,
advancedSearchBuilder: ...,
itemBuilder: ...,
loadingBuilder: ...,
emptyBuilder: ...,
hintText: ...,
onSubmitted: ...,
leading: ...,
highlightMatch: ...,
maxVisibleRows: ...,
clearButton: false,
onSelected: ...,
//------------------------- rebuildable options ----------------------------------
// this will be recalled when the cell is in editable focus and either the row's fingerPrint changes or this is the first build.
sourceController: (BuildContext context, SuperTableController<RowValueType> tableController, SuperRow<RowValueType> row, cell) {
    return AutoSuggestionsSource<T>(...);
}
cellController: (BuildContext context, SuperTableController<RowValueType> tableController, SuperRow<RowValueType> row, cell) {
    return AutoSuggestionsBoxController<T>(...);
}
)
```

* Allow access to the `AutoSuggestionsBoxController` controller and the row cell's suggestion source through `SuperTableController`.

---

## Focus System

* Allow selecting a single cell, multiple cells, a single row, or multiple rows programmatically through the controller, and allow clearing the selection.
* When clicking the row-number cell, the row should be selected without changing the focus of the currently focused cell.

---

## Loading More

* Fix the skeleton style.
* Fix the loading mechanism.

---

## Context Menus

### Column Context Menu

* Show the context menu when right-clicking the column header, not when left-clicking it. The left mouse button should be used for drag-and-drop column reordering. On touch screens, double-tap should open the context menu, while long-press should be used for drag-and-drop.

---

## Keyboard Shortcuts Function

* Add a function for handling keyboard shortcuts, as follows:

```dart
SuperTable<RowValueType>(
    // in ReadableMode
    onKey: (BuildContext context, SuperTableController<RowValueType> tableController, FocusNode node, KeyEvent e) {}   
)
```
