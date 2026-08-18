import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/l10n.dart';

/// Localization setup for Super Table Field.
///
/// Register [localizationsDelegates] and [supportedLocales] on the host
/// `MaterialApp` to enable English/Arabic package localization. Registration is
/// optional for English-only fallback behavior.
class SuperTableLocalizations {
  const SuperTableLocalizations._();

  static const LocalizationsDelegate<SuperTableTranslation> delegate =
      SuperTableTranslation.delegate;

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        SuperTableTranslation.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static final SuperTableTranslation _englishFallback =
      _EnglishSuperTableTranslation();

  /// Resolves the package translation from [context].
  ///
  /// If [SuperTableTranslation] is not registered in the widget tree, an
  /// explicit English implementation is returned. This avoids inheriting an
  /// unrelated process-wide `Intl.defaultLocale`.
  static SuperTableTranslation of(BuildContext context) =>
      SuperTableTranslation.maybeOf(context) ?? _englishFallback;
}

extension SuperTableLocalizationBuildContext on BuildContext {
  SuperTableTranslation get superTableTranslations =>
      SuperTableLocalizations.of(this);
}

/// Built-in English strings used when the host did not register the generated
/// [SuperTableTranslation] delegate.
///
/// Keep this implementation generated from `intl_en.arb` by the migration
/// script so every package-owned message has a deterministic fallback.
final class _EnglishSuperTableTranslation extends SuperTableTranslation {
  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get clear => 'Clear';

  @override
  String get reset => 'Reset';

  @override
  String get done => 'Done';

  @override
  String get all => 'All';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get checked => 'Checked';

  @override
  String get unchecked => 'Unchecked';

  @override
  String get filterHint => 'Filter...';

  @override
  String get valueHint => 'value';

  @override
  String get toHint => 'to';

  @override
  String get noRows => 'No rows';

  @override
  String get totals => 'TOTALS';

  @override
  String get loadMore => 'Load more';

  @override
  String get loading => 'Loading...';

  @override
  String get deleteRowTitle => 'Delete row?';

  @override
  String deleteRowBody(Object rowNumber, Object rowLabel) =>
      'Row ${rowNumber} (${rowLabel}) will be permanently removed. This cannot be undone.';

  @override
  String get sortAscending => 'Sort ascending';

  @override
  String get sortDescending => 'Sort descending';

  @override
  String get clearSort => 'Clear sort';

  @override
  String get removeFromGrouping => 'Remove from grouping';

  @override
  String get groupByThisColumn => 'Group by this column';

  @override
  String get hideColumn => 'Hide column';

  @override
  String get showColumn => 'Show column';

  @override
  String get pin => 'Pin';

  @override
  String get pinLeft => 'Pin start';

  @override
  String get pinRight => 'Pin end';

  @override
  String get unpinned => 'Unpinned';

  @override
  String get manageColumns => 'Manage columns';

  @override
  String get manageColumnsDescription =>
      'Drag to reorder · toggle visibility · pin to an edge';

  @override
  String shownOfColumns(Object shown, Object total) =>
      '${shown} of ${total} shown';

  @override
  String get copyJson => 'Copy JSON';

  @override
  String get copyAsJson => 'Copy as JSON';

  @override
  String get shortcuts => 'Shortcuts';

  @override
  String get keyboardShortcuts => 'Keyboard shortcuts';

  @override
  String get insertRowAbove => 'Insert row above';

  @override
  String get insertRowBelow => 'Insert row below';

  @override
  String get duplicateRow => 'Duplicate row';

  @override
  String get revertCell => 'Revert cell';

  @override
  String get revertRow => 'Revert row';

  @override
  String get revertRowRemoveAdded => 'Revert row (remove added)';

  @override
  String get moveRowUp => 'Move row up';

  @override
  String get moveRowDown => 'Move row down';

  @override
  String get deleteRow => 'Delete row';

  @override
  String get rowOptions => 'Row options';

  @override
  String get groupBy => 'Group by';

  @override
  String get groupedBy => 'GROUPED BY';

  @override
  String get clearAll => 'Clear all';

  @override
  String get addColumn => 'Add column';

  @override
  String get advancedFilter => 'Advanced filter';

  @override
  String get advancedFilterActiveEdit => 'Advanced filter active - edit';

  @override
  String get clearAllFilters => 'Clear all filters';

  @override
  String get filterRows => 'Filter rows';

  @override
  String get advancedFilterDescription =>
      'All conditions must match (AND). Column filters are disabled while this is active.';

  @override
  String get addCondition => 'Add condition';

  @override
  String get applyFilter => 'Apply filter';

  @override
  String get opContains => 'contains';

  @override
  String get opEquals => 'equals';

  @override
  String get opNotEquals => 'not equals';

  @override
  String get opStartsWith => 'starts with';

  @override
  String get opEndsWith => 'ends with';

  @override
  String get opGreaterThan => '> greater';

  @override
  String get opGreaterOrEqual => '>= at least';

  @override
  String get opLessThan => '< less';

  @override
  String get opLessOrEqual => '<= at most';

  @override
  String get opBetween => 'between';

  @override
  String get opIsEmpty => 'is empty';

  @override
  String get opIsNotEmpty => 'is not empty';

  @override
  String get navigate => 'Navigate';

  @override
  String get edit => 'Edit';

  @override
  String get rowsAndClipboard => 'Rows & clipboard';

  @override
  String get moveBetweenCells => 'Move between cells';

  @override
  String get nextPreviousCell => 'Next / previous cell';

  @override
  String get firstLastColumn => 'First / last column';

  @override
  String get firstLastCell => 'First / last cell';

  @override
  String get overwriteCell => 'Overwrite the cell';

  @override
  String get editOrOpenSelect => 'Edit, or open a select';

  @override
  String get commitAndMove => 'Commit & move';

  @override
  String get appendNewRow => 'Append a new row';

  @override
  String get clearCell => 'Clear the cell';

  @override
  String get cancelEditing => 'Cancel editing';

  @override
  String get insertRowAfter => 'Insert row after';

  @override
  String get insertRowBefore => 'Insert row before';

  @override
  String get duplicateRowFillDown => 'Duplicate row · fill down';

  @override
  String get fillRightAcrossRange => 'Fill right across the range';

  @override
  String get copySelectionAsJson => 'Copy selection as JSON';

  @override
  String get cutPasteValidated => 'Cut / paste (validated)';

  @override
  String get undoRedo => 'Undo / redo';

  @override
  String get allRowsValid => 'All rows valid';

  @override
  String validationIssueCount(Object count, Object pluralSuffix) =>
      '${count} validation issue${pluralSuffix}';

  @override
  String get allRowsValidBody =>
      'Every cell passes the type rules, unique constraints and column validators.';

  @override
  String rowNumber(Object rowNumber) => 'Row ${rowNumber}';

  @override
  String issueCount(Object count, Object pluralSuffix) =>
      '${count} issue${pluralSuffix}';

  @override
  String rowCount(Object count, Object pluralSuffix) =>
      '${count} row${pluralSuffix}';

  @override
  String editableStatusHint(Object rowCount) =>
      '${rowCount} · ↵ edit · Tab next (new row at end) · ⌘↵ insert after · ⌘C/V JSON · ⌘Z undo';

  @override
  String readableStatusHint(Object rowCount, Object expansionHint) =>
      '${rowCount} · ⇧+arrows to range-select · right-click header for options · ⌘C copy${expansionHint}';

  @override
  String get expandCollapseHint => ' · ⌘⇧↓ expand · ⌘⇧↑ collapse';

  @override
  String selectedCount(Object count) => '${count} selected';

  @override
  String get pageRangeEmpty => '0 of 0';

  @override
  String pageRange(Object from, Object to, Object total) =>
      '${from}-${to} of ${total}';

  @override
  String selectionStats(
    Object sum,
    Object average,
    Object min,
    Object max,
    Object count,
  ) => 'Sum ${sum} · Avg ${average} · Min ${min} · Max ${max} · Count ${count}';

  @override
  String get typeValueHint => 'Type a value...';

  @override
  String get typeOrPickHint => 'Type or pick...';

  @override
  String get today => 'Today';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthDec => 'Dec';

  @override
  String get weekdaySun => 'Su';

  @override
  String get weekdayMon => 'Mo';

  @override
  String get weekdayTue => 'Tu';

  @override
  String get weekdayWed => 'We';

  @override
  String get weekdayThu => 'Th';

  @override
  String get weekdayFri => 'Fr';

  @override
  String get weekdaySat => 'Sa';

  @override
  String copiedRowsCsv(Object count) => 'Copied ${count} rows as CSV';

  @override
  String filledCells(Object count, Object pluralSuffix) =>
      'Filled ${count} cell${pluralSuffix}';

  @override
  String copiedRowsJson(Object count, Object pluralSuffix) =>
      'Copied ${count} row${pluralSuffix} as JSON';

  @override
  String rowIsNotObject(Object rowNumber) =>
      'Row ${rowNumber} is not an object';

  @override
  String rowError(Object rowNumber, Object error) =>
      'Row ${rowNumber}: ${error}';

  @override
  String unknownField(Object field) =>
      'Unknown field "${field}" - not a column in this table';

  @override
  String pastedBlockTooWide(Object columnNumber) =>
      'Pasted block is wider than the table (column ${columnNumber} doesn\'t exist)';

  @override
  String cellError(Object rowNumber, Object columnNumber, Object error) =>
      'Cell ${rowNumber}×${columnNumber}: ${error}';

  @override
  String get pasteEditableOnly => 'Paste is only allowed in Editable mode';

  @override
  String get clipboardInvalidJson => 'Clipboard is not valid JSON';

  @override
  String get pasted => 'Pasted';

  @override
  String columnMustBeUniqueDuplicate(Object column, Object rowNumber) =>
      '"${column}" must be unique - duplicates row ${rowNumber}';

  @override
  String columnInvalidValue(Object column) =>
      '"${column}" has an invalid value';

  @override
  String columnMustBeUnique(Object column) => '"${column}" must be unique';

  @override
  String get thisCell => 'This cell';

  @override
  String isRequired(Object name) => '${name} is required';

  @override
  String mustBeNumber(Object name) => '${name} must be a number';

  @override
  String mustBeDate(Object name) => '${name} must be a date (YYYY-MM-DD)';

  @override
  String mustBeTime(Object name) => '${name} must be a time (HH:mm)';

  @override
  String mustBeHexColor(Object name) => '${name} must be a hex color (#RRGGBB)';

  @override
  String isReadOnly(Object column) => '"${column}" is read-only';

  @override
  String columnIsRequired(Object column) => '"${column}" is required';

  @override
  String expectsNumber(Object column, Object value) =>
      '"${column}" expects a number - got "${value}"';

  @override
  String expectsTrueFalse(Object column, Object value) =>
      '"${column}" expects true/false - got "${value}"';

  @override
  String mustBeOneOf(Object column, Object options) =>
      '"${column}" must be one of: ${options}';

  @override
  String expectsDate(Object column, Object value) =>
      '"${column}" expects YYYY-MM-DD - got "${value}"';

  @override
  String expectsTime(Object column, Object value) =>
      '"${column}" expects HH:mm - got "${value}"';

  @override
  String expectsHexColor(Object column, Object value) =>
      '"${column}" expects #RRGGBB - got "${value}"';
}
