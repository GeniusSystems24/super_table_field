// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class SuperTableTranslation {
  SuperTableTranslation();

  static SuperTableTranslation? _current;

  static SuperTableTranslation get current {
    assert(
      _current != null,
      'No instance of SuperTableTranslation was loaded. Try to initialize the SuperTableTranslation delegate before accessing SuperTableTranslation.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<SuperTableTranslation> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = SuperTableTranslation();
      SuperTableTranslation._current = instance;

      return instance;
    });
  }

  static SuperTableTranslation of(BuildContext context) {
    final instance = SuperTableTranslation.maybeOf(context);
    assert(
      instance != null,
      'No instance of SuperTableTranslation present in the widget tree. Did you add SuperTableTranslation.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static SuperTableTranslation? maybeOf(BuildContext context) {
    return Localizations.of<SuperTableTranslation>(
      context,
      SuperTableTranslation,
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Delete`
  String get delete {
    return Intl.message('Delete', name: 'delete', desc: '', args: []);
  }

  /// `Clear`
  String get clear {
    return Intl.message('Clear', name: 'clear', desc: '', args: []);
  }

  /// `Reset`
  String get reset {
    return Intl.message('Reset', name: 'reset', desc: '', args: []);
  }

  /// `Done`
  String get done {
    return Intl.message('Done', name: 'done', desc: '', args: []);
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Yes`
  String get yes {
    return Intl.message('Yes', name: 'yes', desc: '', args: []);
  }

  /// `No`
  String get no {
    return Intl.message('No', name: 'no', desc: '', args: []);
  }

  /// `Checked`
  String get checked {
    return Intl.message('Checked', name: 'checked', desc: '', args: []);
  }

  /// `Unchecked`
  String get unchecked {
    return Intl.message('Unchecked', name: 'unchecked', desc: '', args: []);
  }

  /// `Filter...`
  String get filterHint {
    return Intl.message('Filter...', name: 'filterHint', desc: '', args: []);
  }

  /// `value`
  String get valueHint {
    return Intl.message('value', name: 'valueHint', desc: '', args: []);
  }

  /// `to`
  String get toHint {
    return Intl.message('to', name: 'toHint', desc: '', args: []);
  }

  /// `No rows`
  String get noRows {
    return Intl.message('No rows', name: 'noRows', desc: '', args: []);
  }

  /// `TOTALS`
  String get totals {
    return Intl.message('TOTALS', name: 'totals', desc: '', args: []);
  }

  /// `Load more`
  String get loadMore {
    return Intl.message('Load more', name: 'loadMore', desc: '', args: []);
  }

  /// `Loading...`
  String get loading {
    return Intl.message('Loading...', name: 'loading', desc: '', args: []);
  }

  /// `Delete row?`
  String get deleteRowTitle {
    return Intl.message(
      'Delete row?',
      name: 'deleteRowTitle',
      desc: '',
      args: [],
    );
  }

  /// `Row {rowNumber} ({rowLabel}) will be permanently removed. This cannot be undone.`
  String deleteRowBody(Object rowNumber, Object rowLabel) {
    return Intl.message(
      'Row $rowNumber ($rowLabel) will be permanently removed. This cannot be undone.',
      name: 'deleteRowBody',
      desc: '',
      args: [rowNumber, rowLabel],
    );
  }

  /// `Sort ascending`
  String get sortAscending {
    return Intl.message(
      'Sort ascending',
      name: 'sortAscending',
      desc: '',
      args: [],
    );
  }

  /// `Sort descending`
  String get sortDescending {
    return Intl.message(
      'Sort descending',
      name: 'sortDescending',
      desc: '',
      args: [],
    );
  }

  /// `Clear sort`
  String get clearSort {
    return Intl.message('Clear sort', name: 'clearSort', desc: '', args: []);
  }

  /// `Remove from grouping`
  String get removeFromGrouping {
    return Intl.message(
      'Remove from grouping',
      name: 'removeFromGrouping',
      desc: '',
      args: [],
    );
  }

  /// `Group by this column`
  String get groupByThisColumn {
    return Intl.message(
      'Group by this column',
      name: 'groupByThisColumn',
      desc: '',
      args: [],
    );
  }

  /// `Hide column`
  String get hideColumn {
    return Intl.message('Hide column', name: 'hideColumn', desc: '', args: []);
  }

  /// `Show column`
  String get showColumn {
    return Intl.message('Show column', name: 'showColumn', desc: '', args: []);
  }

  /// `Pin`
  String get pin {
    return Intl.message('Pin', name: 'pin', desc: '', args: []);
  }

  /// `Pin start`
  String get pinLeft {
    return Intl.message('Pin start', name: 'pinLeft', desc: '', args: []);
  }

  /// `Pin end`
  String get pinRight {
    return Intl.message('Pin end', name: 'pinRight', desc: '', args: []);
  }

  /// `Unpinned`
  String get unpinned {
    return Intl.message('Unpinned', name: 'unpinned', desc: '', args: []);
  }

  /// `Manage columns`
  String get manageColumns {
    return Intl.message(
      'Manage columns',
      name: 'manageColumns',
      desc: '',
      args: [],
    );
  }

  /// `Drag to reorder · toggle visibility · pin to an edge`
  String get manageColumnsDescription {
    return Intl.message(
      'Drag to reorder · toggle visibility · pin to an edge',
      name: 'manageColumnsDescription',
      desc: '',
      args: [],
    );
  }

  /// `{shown} of {total} shown`
  String shownOfColumns(Object shown, Object total) {
    return Intl.message(
      '$shown of $total shown',
      name: 'shownOfColumns',
      desc: '',
      args: [shown, total],
    );
  }

  /// `Copy JSON`
  String get copyJson {
    return Intl.message('Copy JSON', name: 'copyJson', desc: '', args: []);
  }

  /// `Copy as JSON`
  String get copyAsJson {
    return Intl.message('Copy as JSON', name: 'copyAsJson', desc: '', args: []);
  }

  /// `Shortcuts`
  String get shortcuts {
    return Intl.message('Shortcuts', name: 'shortcuts', desc: '', args: []);
  }

  /// `Keyboard shortcuts`
  String get keyboardShortcuts {
    return Intl.message(
      'Keyboard shortcuts',
      name: 'keyboardShortcuts',
      desc: '',
      args: [],
    );
  }

  /// `Insert row above`
  String get insertRowAbove {
    return Intl.message(
      'Insert row above',
      name: 'insertRowAbove',
      desc: '',
      args: [],
    );
  }

  /// `Insert row below`
  String get insertRowBelow {
    return Intl.message(
      'Insert row below',
      name: 'insertRowBelow',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate row`
  String get duplicateRow {
    return Intl.message(
      'Duplicate row',
      name: 'duplicateRow',
      desc: '',
      args: [],
    );
  }

  /// `Revert cell`
  String get revertCell {
    return Intl.message('Revert cell', name: 'revertCell', desc: '', args: []);
  }

  /// `Revert row`
  String get revertRow {
    return Intl.message('Revert row', name: 'revertRow', desc: '', args: []);
  }

  /// `Revert row (remove added)`
  String get revertRowRemoveAdded {
    return Intl.message(
      'Revert row (remove added)',
      name: 'revertRowRemoveAdded',
      desc: '',
      args: [],
    );
  }

  /// `Move row up`
  String get moveRowUp {
    return Intl.message('Move row up', name: 'moveRowUp', desc: '', args: []);
  }

  /// `Move row down`
  String get moveRowDown {
    return Intl.message(
      'Move row down',
      name: 'moveRowDown',
      desc: '',
      args: [],
    );
  }

  /// `Delete row`
  String get deleteRow {
    return Intl.message('Delete row', name: 'deleteRow', desc: '', args: []);
  }

  /// `Row options`
  String get rowOptions {
    return Intl.message('Row options', name: 'rowOptions', desc: '', args: []);
  }

  /// `Group by`
  String get groupBy {
    return Intl.message('Group by', name: 'groupBy', desc: '', args: []);
  }

  /// `GROUPED BY`
  String get groupedBy {
    return Intl.message('GROUPED BY', name: 'groupedBy', desc: '', args: []);
  }

  /// `Clear all`
  String get clearAll {
    return Intl.message('Clear all', name: 'clearAll', desc: '', args: []);
  }

  /// `Add column`
  String get addColumn {
    return Intl.message('Add column', name: 'addColumn', desc: '', args: []);
  }

  /// `Advanced filter`
  String get advancedFilter {
    return Intl.message(
      'Advanced filter',
      name: 'advancedFilter',
      desc: '',
      args: [],
    );
  }

  /// `Advanced filter active - edit`
  String get advancedFilterActiveEdit {
    return Intl.message(
      'Advanced filter active - edit',
      name: 'advancedFilterActiveEdit',
      desc: '',
      args: [],
    );
  }

  /// `Clear all filters`
  String get clearAllFilters {
    return Intl.message(
      'Clear all filters',
      name: 'clearAllFilters',
      desc: '',
      args: [],
    );
  }

  /// `Filter rows`
  String get filterRows {
    return Intl.message('Filter rows', name: 'filterRows', desc: '', args: []);
  }

  /// `All conditions must match (AND). Column filters are disabled while this is active.`
  String get advancedFilterDescription {
    return Intl.message(
      'All conditions must match (AND). Column filters are disabled while this is active.',
      name: 'advancedFilterDescription',
      desc: '',
      args: [],
    );
  }

  /// `Add condition`
  String get addCondition {
    return Intl.message(
      'Add condition',
      name: 'addCondition',
      desc: '',
      args: [],
    );
  }

  /// `Apply filter`
  String get applyFilter {
    return Intl.message(
      'Apply filter',
      name: 'applyFilter',
      desc: '',
      args: [],
    );
  }

  /// `contains`
  String get opContains {
    return Intl.message('contains', name: 'opContains', desc: '', args: []);
  }

  /// `equals`
  String get opEquals {
    return Intl.message('equals', name: 'opEquals', desc: '', args: []);
  }

  /// `not equals`
  String get opNotEquals {
    return Intl.message('not equals', name: 'opNotEquals', desc: '', args: []);
  }

  /// `starts with`
  String get opStartsWith {
    return Intl.message(
      'starts with',
      name: 'opStartsWith',
      desc: '',
      args: [],
    );
  }

  /// `ends with`
  String get opEndsWith {
    return Intl.message('ends with', name: 'opEndsWith', desc: '', args: []);
  }

  /// `> greater`
  String get opGreaterThan {
    return Intl.message('> greater', name: 'opGreaterThan', desc: '', args: []);
  }

  /// `>= at least`
  String get opGreaterOrEqual {
    return Intl.message(
      '>= at least',
      name: 'opGreaterOrEqual',
      desc: '',
      args: [],
    );
  }

  /// `< less`
  String get opLessThan {
    return Intl.message('< less', name: 'opLessThan', desc: '', args: []);
  }

  /// `<= at most`
  String get opLessOrEqual {
    return Intl.message(
      '<= at most',
      name: 'opLessOrEqual',
      desc: '',
      args: [],
    );
  }

  /// `between`
  String get opBetween {
    return Intl.message('between', name: 'opBetween', desc: '', args: []);
  }

  /// `is empty`
  String get opIsEmpty {
    return Intl.message('is empty', name: 'opIsEmpty', desc: '', args: []);
  }

  /// `is not empty`
  String get opIsNotEmpty {
    return Intl.message(
      'is not empty',
      name: 'opIsNotEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Navigate`
  String get navigate {
    return Intl.message('Navigate', name: 'navigate', desc: '', args: []);
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Rows & clipboard`
  String get rowsAndClipboard {
    return Intl.message(
      'Rows & clipboard',
      name: 'rowsAndClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Move between cells`
  String get moveBetweenCells {
    return Intl.message(
      'Move between cells',
      name: 'moveBetweenCells',
      desc: '',
      args: [],
    );
  }

  /// `Next / previous cell`
  String get nextPreviousCell {
    return Intl.message(
      'Next / previous cell',
      name: 'nextPreviousCell',
      desc: '',
      args: [],
    );
  }

  /// `First / last column`
  String get firstLastColumn {
    return Intl.message(
      'First / last column',
      name: 'firstLastColumn',
      desc: '',
      args: [],
    );
  }

  /// `First / last cell`
  String get firstLastCell {
    return Intl.message(
      'First / last cell',
      name: 'firstLastCell',
      desc: '',
      args: [],
    );
  }

  /// `Overwrite the cell`
  String get overwriteCell {
    return Intl.message(
      'Overwrite the cell',
      name: 'overwriteCell',
      desc: '',
      args: [],
    );
  }

  /// `Edit, or open a select`
  String get editOrOpenSelect {
    return Intl.message(
      'Edit, or open a select',
      name: 'editOrOpenSelect',
      desc: '',
      args: [],
    );
  }

  /// `Commit & move`
  String get commitAndMove {
    return Intl.message(
      'Commit & move',
      name: 'commitAndMove',
      desc: '',
      args: [],
    );
  }

  /// `Append a new row`
  String get appendNewRow {
    return Intl.message(
      'Append a new row',
      name: 'appendNewRow',
      desc: '',
      args: [],
    );
  }

  /// `Clear the cell`
  String get clearCell {
    return Intl.message(
      'Clear the cell',
      name: 'clearCell',
      desc: '',
      args: [],
    );
  }

  /// `Cancel editing`
  String get cancelEditing {
    return Intl.message(
      'Cancel editing',
      name: 'cancelEditing',
      desc: '',
      args: [],
    );
  }

  /// `Insert row after`
  String get insertRowAfter {
    return Intl.message(
      'Insert row after',
      name: 'insertRowAfter',
      desc: '',
      args: [],
    );
  }

  /// `Insert row before`
  String get insertRowBefore {
    return Intl.message(
      'Insert row before',
      name: 'insertRowBefore',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate row · fill down`
  String get duplicateRowFillDown {
    return Intl.message(
      'Duplicate row · fill down',
      name: 'duplicateRowFillDown',
      desc: '',
      args: [],
    );
  }

  /// `Fill right across the range`
  String get fillRightAcrossRange {
    return Intl.message(
      'Fill right across the range',
      name: 'fillRightAcrossRange',
      desc: '',
      args: [],
    );
  }

  /// `Copy selection as JSON`
  String get copySelectionAsJson {
    return Intl.message(
      'Copy selection as JSON',
      name: 'copySelectionAsJson',
      desc: '',
      args: [],
    );
  }

  /// `Cut / paste (validated)`
  String get cutPasteValidated {
    return Intl.message(
      'Cut / paste (validated)',
      name: 'cutPasteValidated',
      desc: '',
      args: [],
    );
  }

  /// `Undo / redo`
  String get undoRedo {
    return Intl.message('Undo / redo', name: 'undoRedo', desc: '', args: []);
  }

  /// `All rows valid`
  String get allRowsValid {
    return Intl.message(
      'All rows valid',
      name: 'allRowsValid',
      desc: '',
      args: [],
    );
  }

  /// `{count} validation issue{pluralSuffix}`
  String validationIssueCount(Object count, Object pluralSuffix) {
    return Intl.message(
      '$count validation issue$pluralSuffix',
      name: 'validationIssueCount',
      desc: '',
      args: [count, pluralSuffix],
    );
  }

  /// `Every cell passes the type rules, unique constraints and column validators.`
  String get allRowsValidBody {
    return Intl.message(
      'Every cell passes the type rules, unique constraints and column validators.',
      name: 'allRowsValidBody',
      desc: '',
      args: [],
    );
  }

  /// `Row {rowNumber}`
  String rowNumber(Object rowNumber) {
    return Intl.message(
      'Row $rowNumber',
      name: 'rowNumber',
      desc: '',
      args: [rowNumber],
    );
  }

  /// `{count} issue{pluralSuffix}`
  String issueCount(Object count, Object pluralSuffix) {
    return Intl.message(
      '$count issue$pluralSuffix',
      name: 'issueCount',
      desc: '',
      args: [count, pluralSuffix],
    );
  }

  /// `{count} row{pluralSuffix}`
  String rowCount(Object count, Object pluralSuffix) {
    return Intl.message(
      '$count row$pluralSuffix',
      name: 'rowCount',
      desc: '',
      args: [count, pluralSuffix],
    );
  }

  /// `{rowCount} · ↵ edit · Tab next (new row at end) · ⌘↵ insert after · ⌘C/V JSON · ⌘Z undo`
  String editableStatusHint(Object rowCount) {
    return Intl.message(
      '$rowCount · ↵ edit · Tab next (new row at end) · ⌘↵ insert after · ⌘C/V JSON · ⌘Z undo',
      name: 'editableStatusHint',
      desc: '',
      args: [rowCount],
    );
  }

  /// `{rowCount} · ⇧+arrows to range-select · right-click header for options · ⌘C copy{expansionHint}`
  String readableStatusHint(Object rowCount, Object expansionHint) {
    return Intl.message(
      '$rowCount · ⇧+arrows to range-select · right-click header for options · ⌘C copy$expansionHint',
      name: 'readableStatusHint',
      desc: '',
      args: [rowCount, expansionHint],
    );
  }

  /// ` · ⌘⇧↓ expand · ⌘⇧↑ collapse`
  String get expandCollapseHint {
    return Intl.message(
      ' · ⌘⇧↓ expand · ⌘⇧↑ collapse',
      name: 'expandCollapseHint',
      desc: '',
      args: [],
    );
  }

  /// `{count} selected`
  String selectedCount(Object count) {
    return Intl.message(
      '$count selected',
      name: 'selectedCount',
      desc: '',
      args: [count],
    );
  }

  /// `0 of 0`
  String get pageRangeEmpty {
    return Intl.message('0 of 0', name: 'pageRangeEmpty', desc: '', args: []);
  }

  /// `{from}-{to} of {total}`
  String pageRange(Object from, Object to, Object total) {
    return Intl.message(
      '$from-$to of $total',
      name: 'pageRange',
      desc: '',
      args: [from, to, total],
    );
  }

  /// `Sum {sum} · Avg {average} · Min {min} · Max {max} · Count {count}`
  String selectionStats(
    Object sum,
    Object average,
    Object min,
    Object max,
    Object count,
  ) {
    return Intl.message(
      'Sum $sum · Avg $average · Min $min · Max $max · Count $count',
      name: 'selectionStats',
      desc: '',
      args: [sum, average, min, max, count],
    );
  }

  /// `Type a value...`
  String get typeValueHint {
    return Intl.message(
      'Type a value...',
      name: 'typeValueHint',
      desc: '',
      args: [],
    );
  }

  /// `Type or pick...`
  String get typeOrPickHint {
    return Intl.message(
      'Type or pick...',
      name: 'typeOrPickHint',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message('Today', name: 'today', desc: '', args: []);
  }

  /// `Jan`
  String get monthJan {
    return Intl.message('Jan', name: 'monthJan', desc: '', args: []);
  }

  /// `Feb`
  String get monthFeb {
    return Intl.message('Feb', name: 'monthFeb', desc: '', args: []);
  }

  /// `Mar`
  String get monthMar {
    return Intl.message('Mar', name: 'monthMar', desc: '', args: []);
  }

  /// `Apr`
  String get monthApr {
    return Intl.message('Apr', name: 'monthApr', desc: '', args: []);
  }

  /// `May`
  String get monthMay {
    return Intl.message('May', name: 'monthMay', desc: '', args: []);
  }

  /// `Jun`
  String get monthJun {
    return Intl.message('Jun', name: 'monthJun', desc: '', args: []);
  }

  /// `Jul`
  String get monthJul {
    return Intl.message('Jul', name: 'monthJul', desc: '', args: []);
  }

  /// `Aug`
  String get monthAug {
    return Intl.message('Aug', name: 'monthAug', desc: '', args: []);
  }

  /// `Sep`
  String get monthSep {
    return Intl.message('Sep', name: 'monthSep', desc: '', args: []);
  }

  /// `Oct`
  String get monthOct {
    return Intl.message('Oct', name: 'monthOct', desc: '', args: []);
  }

  /// `Nov`
  String get monthNov {
    return Intl.message('Nov', name: 'monthNov', desc: '', args: []);
  }

  /// `Dec`
  String get monthDec {
    return Intl.message('Dec', name: 'monthDec', desc: '', args: []);
  }

  /// `Su`
  String get weekdaySun {
    return Intl.message('Su', name: 'weekdaySun', desc: '', args: []);
  }

  /// `Mo`
  String get weekdayMon {
    return Intl.message('Mo', name: 'weekdayMon', desc: '', args: []);
  }

  /// `Tu`
  String get weekdayTue {
    return Intl.message('Tu', name: 'weekdayTue', desc: '', args: []);
  }

  /// `We`
  String get weekdayWed {
    return Intl.message('We', name: 'weekdayWed', desc: '', args: []);
  }

  /// `Th`
  String get weekdayThu {
    return Intl.message('Th', name: 'weekdayThu', desc: '', args: []);
  }

  /// `Fr`
  String get weekdayFri {
    return Intl.message('Fr', name: 'weekdayFri', desc: '', args: []);
  }

  /// `Sa`
  String get weekdaySat {
    return Intl.message('Sa', name: 'weekdaySat', desc: '', args: []);
  }

  /// `Copied {count} rows as CSV`
  String copiedRowsCsv(Object count) {
    return Intl.message(
      'Copied $count rows as CSV',
      name: 'copiedRowsCsv',
      desc: '',
      args: [count],
    );
  }

  /// `Filled {count} cell{pluralSuffix}`
  String filledCells(Object count, Object pluralSuffix) {
    return Intl.message(
      'Filled $count cell$pluralSuffix',
      name: 'filledCells',
      desc: '',
      args: [count, pluralSuffix],
    );
  }

  /// `Copied {count} row{pluralSuffix} as JSON`
  String copiedRowsJson(Object count, Object pluralSuffix) {
    return Intl.message(
      'Copied $count row$pluralSuffix as JSON',
      name: 'copiedRowsJson',
      desc: '',
      args: [count, pluralSuffix],
    );
  }

  /// `Row {rowNumber} is not an object`
  String rowIsNotObject(Object rowNumber) {
    return Intl.message(
      'Row $rowNumber is not an object',
      name: 'rowIsNotObject',
      desc: '',
      args: [rowNumber],
    );
  }

  /// `Row {rowNumber}: {error}`
  String rowError(Object rowNumber, Object error) {
    return Intl.message(
      'Row $rowNumber: $error',
      name: 'rowError',
      desc: '',
      args: [rowNumber, error],
    );
  }

  /// `Unknown field "{field}" - not a column in this table`
  String unknownField(Object field) {
    return Intl.message(
      'Unknown field "$field" - not a column in this table',
      name: 'unknownField',
      desc: '',
      args: [field],
    );
  }

  /// `Pasted block is wider than the table (column {columnNumber} doesn't exist)`
  String pastedBlockTooWide(Object columnNumber) {
    return Intl.message(
      'Pasted block is wider than the table (column $columnNumber doesn\'t exist)',
      name: 'pastedBlockTooWide',
      desc: '',
      args: [columnNumber],
    );
  }

  /// `Cell {rowNumber}×{columnNumber}: {error}`
  String cellError(Object rowNumber, Object columnNumber, Object error) {
    return Intl.message(
      'Cell $rowNumber×$columnNumber: $error',
      name: 'cellError',
      desc: '',
      args: [rowNumber, columnNumber, error],
    );
  }

  /// `Paste is only allowed in Editable mode`
  String get pasteEditableOnly {
    return Intl.message(
      'Paste is only allowed in Editable mode',
      name: 'pasteEditableOnly',
      desc: '',
      args: [],
    );
  }

  /// `Clipboard is not valid JSON`
  String get clipboardInvalidJson {
    return Intl.message(
      'Clipboard is not valid JSON',
      name: 'clipboardInvalidJson',
      desc: '',
      args: [],
    );
  }

  /// `Pasted`
  String get pasted {
    return Intl.message('Pasted', name: 'pasted', desc: '', args: []);
  }

  /// `"{column}" must be unique - duplicates row {rowNumber}`
  String columnMustBeUniqueDuplicate(Object column, Object rowNumber) {
    return Intl.message(
      '"$column" must be unique - duplicates row $rowNumber',
      name: 'columnMustBeUniqueDuplicate',
      desc: '',
      args: [column, rowNumber],
    );
  }

  /// `"{column}" has an invalid value`
  String columnInvalidValue(Object column) {
    return Intl.message(
      '"$column" has an invalid value',
      name: 'columnInvalidValue',
      desc: '',
      args: [column],
    );
  }

  /// `"{column}" must be unique`
  String columnMustBeUnique(Object column) {
    return Intl.message(
      '"$column" must be unique',
      name: 'columnMustBeUnique',
      desc: '',
      args: [column],
    );
  }

  /// `This cell`
  String get thisCell {
    return Intl.message('This cell', name: 'thisCell', desc: '', args: []);
  }

  /// `{name} is required`
  String isRequired(Object name) {
    return Intl.message(
      '$name is required',
      name: 'isRequired',
      desc: '',
      args: [name],
    );
  }

  /// `{name} must be a number`
  String mustBeNumber(Object name) {
    return Intl.message(
      '$name must be a number',
      name: 'mustBeNumber',
      desc: '',
      args: [name],
    );
  }

  /// `{name} must be a date (YYYY-MM-DD)`
  String mustBeDate(Object name) {
    return Intl.message(
      '$name must be a date (YYYY-MM-DD)',
      name: 'mustBeDate',
      desc: '',
      args: [name],
    );
  }

  /// `{name} must be a time (HH:mm)`
  String mustBeTime(Object name) {
    return Intl.message(
      '$name must be a time (HH:mm)',
      name: 'mustBeTime',
      desc: '',
      args: [name],
    );
  }

  /// `{name} must be a hex color (#RRGGBB)`
  String mustBeHexColor(Object name) {
    return Intl.message(
      '$name must be a hex color (#RRGGBB)',
      name: 'mustBeHexColor',
      desc: '',
      args: [name],
    );
  }

  /// `"{column}" is read-only`
  String isReadOnly(Object column) {
    return Intl.message(
      '"$column" is read-only',
      name: 'isReadOnly',
      desc: '',
      args: [column],
    );
  }

  /// `"{column}" is required`
  String columnIsRequired(Object column) {
    return Intl.message(
      '"$column" is required',
      name: 'columnIsRequired',
      desc: '',
      args: [column],
    );
  }

  /// `"{column}" expects a number - got "{value}"`
  String expectsNumber(Object column, Object value) {
    return Intl.message(
      '"$column" expects a number - got "$value"',
      name: 'expectsNumber',
      desc: '',
      args: [column, value],
    );
  }

  /// `"{column}" expects true/false - got "{value}"`
  String expectsTrueFalse(Object column, Object value) {
    return Intl.message(
      '"$column" expects true/false - got "$value"',
      name: 'expectsTrueFalse',
      desc: '',
      args: [column, value],
    );
  }

  /// `"{column}" must be one of: {options}`
  String mustBeOneOf(Object column, Object options) {
    return Intl.message(
      '"$column" must be one of: $options',
      name: 'mustBeOneOf',
      desc: '',
      args: [column, options],
    );
  }

  /// `"{column}" expects YYYY-MM-DD - got "{value}"`
  String expectsDate(Object column, Object value) {
    return Intl.message(
      '"$column" expects YYYY-MM-DD - got "$value"',
      name: 'expectsDate',
      desc: '',
      args: [column, value],
    );
  }

  /// `"{column}" expects HH:mm - got "{value}"`
  String expectsTime(Object column, Object value) {
    return Intl.message(
      '"$column" expects HH:mm - got "$value"',
      name: 'expectsTime',
      desc: '',
      args: [column, value],
    );
  }

  /// `"{column}" expects #RRGGBB - got "{value}"`
  String expectsHexColor(Object column, Object value) {
    return Intl.message(
      '"$column" expects #RRGGBB - got "$value"',
      name: 'expectsHexColor',
      desc: '',
      args: [column, value],
    );
  }
}

class AppLocalizationDelegate
    extends LocalizationsDelegate<SuperTableTranslation> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<SuperTableTranslation> load(Locale locale) =>
      SuperTableTranslation.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
