import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_ar.dart';
import 'l10n_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of SuperTableLocalization
/// returned by `SuperTableLocalization.of(context)`.
///
/// Applications need to include `SuperTableLocalization.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: SuperTableLocalization.localizationsDelegates,
///   supportedLocales: SuperTableLocalization.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the SuperTableLocalization.supportedLocales
/// property.
abstract class SuperTableLocalization {
  SuperTableLocalization(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static SuperTableLocalization of(BuildContext context) {
    return Localizations.of<SuperTableLocalization>(
      context,
      SuperTableLocalization,
    )!;
  }

  static const LocalizationsDelegate<SuperTableLocalization> delegate =
      _SuperTableLocalizationDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @checked.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get checked;

  /// No description provided for @unchecked.
  ///
  /// In en, this message translates to:
  /// **'Unchecked'**
  String get unchecked;

  /// No description provided for @filterHint.
  ///
  /// In en, this message translates to:
  /// **'Filter...'**
  String get filterHint;

  /// No description provided for @valueHint.
  ///
  /// In en, this message translates to:
  /// **'value'**
  String get valueHint;

  /// No description provided for @toHint.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get toHint;

  /// No description provided for @noRows.
  ///
  /// In en, this message translates to:
  /// **'No rows'**
  String get noRows;

  /// No description provided for @totals.
  ///
  /// In en, this message translates to:
  /// **'TOTALS'**
  String get totals;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @deleteRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete row?'**
  String get deleteRowTitle;

  /// No description provided for @deleteRowBody.
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber} ({rowLabel}) will be permanently removed. This cannot be undone.'**
  String deleteRowBody(int rowNumber, String rowLabel);

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'Sort ascending'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Sort descending'**
  String get sortDescending;

  /// No description provided for @clearSort.
  ///
  /// In en, this message translates to:
  /// **'Clear sort'**
  String get clearSort;

  /// No description provided for @removeFromGrouping.
  ///
  /// In en, this message translates to:
  /// **'Remove from grouping'**
  String get removeFromGrouping;

  /// No description provided for @groupByThisColumn.
  ///
  /// In en, this message translates to:
  /// **'Group by this column'**
  String get groupByThisColumn;

  /// No description provided for @hideColumn.
  ///
  /// In en, this message translates to:
  /// **'Hide column'**
  String get hideColumn;

  /// No description provided for @showColumn.
  ///
  /// In en, this message translates to:
  /// **'Show column'**
  String get showColumn;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @pinLeft.
  ///
  /// In en, this message translates to:
  /// **'Pin start'**
  String get pinLeft;

  /// No description provided for @pinRight.
  ///
  /// In en, this message translates to:
  /// **'Pin end'**
  String get pinRight;

  /// No description provided for @unpinned.
  ///
  /// In en, this message translates to:
  /// **'Unpinned'**
  String get unpinned;

  /// No description provided for @manageColumns.
  ///
  /// In en, this message translates to:
  /// **'Manage columns'**
  String get manageColumns;

  /// No description provided for @manageColumnsDescription.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder · toggle visibility · pin to an edge'**
  String get manageColumnsDescription;

  /// No description provided for @shownOfColumns.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} shown'**
  String shownOfColumns(int shown, int total);

  /// No description provided for @copyJson.
  ///
  /// In en, this message translates to:
  /// **'Copy JSON'**
  String get copyJson;

  /// No description provided for @copyAsJson.
  ///
  /// In en, this message translates to:
  /// **'Copy as JSON'**
  String get copyAsJson;

  /// No description provided for @shortcuts.
  ///
  /// In en, this message translates to:
  /// **'Shortcuts'**
  String get shortcuts;

  /// No description provided for @keyboardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get keyboardShortcuts;

  /// No description provided for @insertRowAbove.
  ///
  /// In en, this message translates to:
  /// **'Insert row above'**
  String get insertRowAbove;

  /// No description provided for @insertRowBelow.
  ///
  /// In en, this message translates to:
  /// **'Insert row below'**
  String get insertRowBelow;

  /// No description provided for @duplicateRow.
  ///
  /// In en, this message translates to:
  /// **'Duplicate row'**
  String get duplicateRow;

  /// No description provided for @revertCell.
  ///
  /// In en, this message translates to:
  /// **'Revert cell'**
  String get revertCell;

  /// No description provided for @revertRow.
  ///
  /// In en, this message translates to:
  /// **'Revert row'**
  String get revertRow;

  /// No description provided for @revertRowRemoveAdded.
  ///
  /// In en, this message translates to:
  /// **'Revert row (remove added)'**
  String get revertRowRemoveAdded;

  /// No description provided for @moveRowUp.
  ///
  /// In en, this message translates to:
  /// **'Move row up'**
  String get moveRowUp;

  /// No description provided for @moveRowDown.
  ///
  /// In en, this message translates to:
  /// **'Move row down'**
  String get moveRowDown;

  /// No description provided for @deleteRow.
  ///
  /// In en, this message translates to:
  /// **'Delete row'**
  String get deleteRow;

  /// No description provided for @rowOptions.
  ///
  /// In en, this message translates to:
  /// **'Row options'**
  String get rowOptions;

  /// No description provided for @groupBy.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get groupBy;

  /// No description provided for @groupedBy.
  ///
  /// In en, this message translates to:
  /// **'GROUPED BY'**
  String get groupedBy;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @addColumn.
  ///
  /// In en, this message translates to:
  /// **'Add column'**
  String get addColumn;

  /// No description provided for @advancedFilter.
  ///
  /// In en, this message translates to:
  /// **'Advanced filter'**
  String get advancedFilter;

  /// No description provided for @advancedFilterActiveEdit.
  ///
  /// In en, this message translates to:
  /// **'Advanced filter active - edit'**
  String get advancedFilterActiveEdit;

  /// No description provided for @clearAllFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear all filters'**
  String get clearAllFilters;

  /// No description provided for @filterRows.
  ///
  /// In en, this message translates to:
  /// **'Filter rows'**
  String get filterRows;

  /// No description provided for @advancedFilterDescription.
  ///
  /// In en, this message translates to:
  /// **'All conditions must match (AND). Column filters are disabled while this is active.'**
  String get advancedFilterDescription;

  /// No description provided for @addCondition.
  ///
  /// In en, this message translates to:
  /// **'Add condition'**
  String get addCondition;

  /// No description provided for @applyFilter.
  ///
  /// In en, this message translates to:
  /// **'Apply filter'**
  String get applyFilter;

  /// No description provided for @opContains.
  ///
  /// In en, this message translates to:
  /// **'contains'**
  String get opContains;

  /// No description provided for @opEquals.
  ///
  /// In en, this message translates to:
  /// **'equals'**
  String get opEquals;

  /// No description provided for @opNotEquals.
  ///
  /// In en, this message translates to:
  /// **'not equals'**
  String get opNotEquals;

  /// No description provided for @opStartsWith.
  ///
  /// In en, this message translates to:
  /// **'starts with'**
  String get opStartsWith;

  /// No description provided for @opEndsWith.
  ///
  /// In en, this message translates to:
  /// **'ends with'**
  String get opEndsWith;

  /// No description provided for @opGreaterThan.
  ///
  /// In en, this message translates to:
  /// **'> greater'**
  String get opGreaterThan;

  /// No description provided for @opGreaterOrEqual.
  ///
  /// In en, this message translates to:
  /// **'>= at least'**
  String get opGreaterOrEqual;

  /// No description provided for @opLessThan.
  ///
  /// In en, this message translates to:
  /// **'< less'**
  String get opLessThan;

  /// No description provided for @opLessOrEqual.
  ///
  /// In en, this message translates to:
  /// **'<= at most'**
  String get opLessOrEqual;

  /// No description provided for @opBetween.
  ///
  /// In en, this message translates to:
  /// **'between'**
  String get opBetween;

  /// No description provided for @opIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'is empty'**
  String get opIsEmpty;

  /// No description provided for @opIsNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'is not empty'**
  String get opIsNotEmpty;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @rowsAndClipboard.
  ///
  /// In en, this message translates to:
  /// **'Rows & clipboard'**
  String get rowsAndClipboard;

  /// No description provided for @moveBetweenCells.
  ///
  /// In en, this message translates to:
  /// **'Move between cells'**
  String get moveBetweenCells;

  /// No description provided for @nextPreviousCell.
  ///
  /// In en, this message translates to:
  /// **'Next / previous cell'**
  String get nextPreviousCell;

  /// No description provided for @firstLastColumn.
  ///
  /// In en, this message translates to:
  /// **'First / last column'**
  String get firstLastColumn;

  /// No description provided for @firstLastCell.
  ///
  /// In en, this message translates to:
  /// **'First / last cell'**
  String get firstLastCell;

  /// No description provided for @overwriteCell.
  ///
  /// In en, this message translates to:
  /// **'Overwrite the cell'**
  String get overwriteCell;

  /// No description provided for @editOrOpenSelect.
  ///
  /// In en, this message translates to:
  /// **'Edit, or open a select'**
  String get editOrOpenSelect;

  /// No description provided for @commitAndMove.
  ///
  /// In en, this message translates to:
  /// **'Commit & move'**
  String get commitAndMove;

  /// No description provided for @appendNewRow.
  ///
  /// In en, this message translates to:
  /// **'Append a new row'**
  String get appendNewRow;

  /// No description provided for @clearCell.
  ///
  /// In en, this message translates to:
  /// **'Clear the cell'**
  String get clearCell;

  /// No description provided for @cancelEditing.
  ///
  /// In en, this message translates to:
  /// **'Cancel editing'**
  String get cancelEditing;

  /// No description provided for @insertRowAfter.
  ///
  /// In en, this message translates to:
  /// **'Insert row after'**
  String get insertRowAfter;

  /// No description provided for @insertRowBefore.
  ///
  /// In en, this message translates to:
  /// **'Insert row before'**
  String get insertRowBefore;

  /// No description provided for @duplicateRowFillDown.
  ///
  /// In en, this message translates to:
  /// **'Duplicate row · fill down'**
  String get duplicateRowFillDown;

  /// No description provided for @fillRightAcrossRange.
  ///
  /// In en, this message translates to:
  /// **'Fill right across the range'**
  String get fillRightAcrossRange;

  /// No description provided for @copySelectionAsJson.
  ///
  /// In en, this message translates to:
  /// **'Copy selection as JSON'**
  String get copySelectionAsJson;

  /// No description provided for @cutPasteValidated.
  ///
  /// In en, this message translates to:
  /// **'Cut / paste (validated)'**
  String get cutPasteValidated;

  /// No description provided for @undoRedo.
  ///
  /// In en, this message translates to:
  /// **'Undo / redo'**
  String get undoRedo;

  /// No description provided for @allRowsValid.
  ///
  /// In en, this message translates to:
  /// **'All rows valid'**
  String get allRowsValid;

  /// No description provided for @validationIssueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} validation issue{pluralSuffix}'**
  String validationIssueCount(int count, String pluralSuffix);

  /// No description provided for @allRowsValidBody.
  ///
  /// In en, this message translates to:
  /// **'Every cell passes the type rules, unique constraints and column validators.'**
  String get allRowsValidBody;

  /// No description provided for @rowNumber.
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}'**
  String rowNumber(int rowNumber);

  /// No description provided for @issueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} issue{pluralSuffix}'**
  String issueCount(int count, String pluralSuffix);

  /// No description provided for @rowCount.
  ///
  /// In en, this message translates to:
  /// **'{count} row{pluralSuffix}'**
  String rowCount(int count, String pluralSuffix);

  /// No description provided for @editableStatusHint.
  ///
  /// In en, this message translates to:
  /// **'{rowCount} · ↵ edit · Tab next (new row at end) · ⌘↵ insert after · ⌘C/V JSON · ⌘Z undo'**
  String editableStatusHint(String rowCount);

  /// No description provided for @readableStatusHint.
  ///
  /// In en, this message translates to:
  /// **'{rowCount} · ⇧+arrows to range-select · right-click header for options · ⌘C copy{expansionHint}'**
  String readableStatusHint(String rowCount, String expansionHint);

  /// No description provided for @expandCollapseHint.
  ///
  /// In en, this message translates to:
  /// **' · ⌘⇧↓ expand · ⌘⇧↑ collapse'**
  String get expandCollapseHint;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @pageRangeEmpty.
  ///
  /// In en, this message translates to:
  /// **'0 of 0'**
  String get pageRangeEmpty;

  /// No description provided for @pageRange.
  ///
  /// In en, this message translates to:
  /// **'{from}-{to} of {total}'**
  String pageRange(int from, int to, int total);

  /// No description provided for @selectionStats.
  ///
  /// In en, this message translates to:
  /// **'Sum {sum} · Avg {average} · Min {min} · Max {max} · Count {count}'**
  String selectionStats(
    String sum,
    String average,
    String min,
    String max,
    int count,
  );

  /// No description provided for @typeValueHint.
  ///
  /// In en, this message translates to:
  /// **'Type a value...'**
  String get typeValueHint;

  /// No description provided for @typeOrPickHint.
  ///
  /// In en, this message translates to:
  /// **'Type or pick...'**
  String get typeOrPickHint;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get monthDec;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Su'**
  String get weekdaySun;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mo'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tu'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'We'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Th'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fr'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sa'**
  String get weekdaySat;

  /// No description provided for @copiedRowsCsv.
  ///
  /// In en, this message translates to:
  /// **'Copied {count} rows as CSV'**
  String copiedRowsCsv(int count);

  /// No description provided for @filledCells.
  ///
  /// In en, this message translates to:
  /// **'Filled {count} cell{pluralSuffix}'**
  String filledCells(int count, String pluralSuffix);

  /// No description provided for @copiedRowsJson.
  ///
  /// In en, this message translates to:
  /// **'Copied {count} row{pluralSuffix} as JSON'**
  String copiedRowsJson(int count, String pluralSuffix);

  /// No description provided for @rowIsNotObject.
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber} is not an object'**
  String rowIsNotObject(int rowNumber);

  /// No description provided for @rowError.
  ///
  /// In en, this message translates to:
  /// **'Row {rowNumber}: {error}'**
  String rowError(int rowNumber, String error);

  /// No description provided for @unknownField.
  ///
  /// In en, this message translates to:
  /// **'Unknown field \"{field}\" - not a column in this table'**
  String unknownField(String field);

  /// No description provided for @pastedBlockTooWide.
  ///
  /// In en, this message translates to:
  /// **'Pasted block is wider than the table (column {columnNumber} doesn\'\'t exist)'**
  String pastedBlockTooWide(int columnNumber);

  /// No description provided for @cellError.
  ///
  /// In en, this message translates to:
  /// **'Cell {rowNumber}×{columnNumber}: {error}'**
  String cellError(int rowNumber, int columnNumber, String error);

  /// No description provided for @pasteEditableOnly.
  ///
  /// In en, this message translates to:
  /// **'Paste is only allowed in Editable mode'**
  String get pasteEditableOnly;

  /// No description provided for @clipboardInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is not valid JSON'**
  String get clipboardInvalidJson;

  /// No description provided for @pasted.
  ///
  /// In en, this message translates to:
  /// **'Pasted'**
  String get pasted;

  /// No description provided for @columnMustBeUniqueDuplicate.
  ///
  /// In en, this message translates to:
  /// **'\"{column}\" must be unique - duplicates row {rowNumber}'**
  String columnMustBeUniqueDuplicate(String column, int rowNumber);

  /// No description provided for @columnInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'\"{column}\" has an invalid value'**
  String columnInvalidValue(String column);

  /// No description provided for @columnMustBeUnique.
  ///
  /// In en, this message translates to:
  /// **'\"{column}\" must be unique'**
  String columnMustBeUnique(String column);

  /// No description provided for @thisCell.
  ///
  /// In en, this message translates to:
  /// **'This cell'**
  String get thisCell;

  /// No description provided for @isRequired.
  ///
  /// In en, this message translates to:
  /// **'{name} is required'**
  String isRequired(String name);

  /// No description provided for @mustBeNumber.
  ///
  /// In en, this message translates to:
  /// **'{name} must be a number'**
  String mustBeNumber(String name);

  /// No description provided for @mustBeDate.
  ///
  /// In en, this message translates to:
  /// **'{name} must be a date (YYYY-MM-DD)'**
  String mustBeDate(String name);

  /// No description provided for @mustBeTime.
  ///
  /// In en, this message translates to:
  /// **'{name} must be a time (HH:mm)'**
  String mustBeTime(String name);

  /// No description provided for @mustBeHexColor.
  ///
  /// In en, this message translates to:
  /// **'{name} must be a hex color (#RRGGBB)'**
  String mustBeHexColor(String name);

  /// No description provided for @isReadOnly.
  ///
  /// In en, this message translates to:
  /// **'\"{column}\" is read-only'**
  String isReadOnly(String column);

  /// No description provided for @columnIsRequired.
  ///
  /// In en, this message translates to:
  /// **'\"{column}\" is required'**
  String columnIsRequired(String column);

  /// No description provided for @expectsNumber.
  ///
  /// In en, this message translates to:
  /// **'\"{column}\" expects a number - got \"{value}\"'**
  String expectsNumber(String column, String value);

  /// No description provided for @expectsTrueFalse.
  ///
  /// In en, this message translates to:
  /// **'\"{column}\" expects true/false - got \"{value}\"'**
  String expectsTrueFalse(String column, String value);

  /// No description provided for @mustBeOneOf.
  ///
  /// In en, this message translates to:
  /// **'\"{column}\" must be one of: {options}'**
  String mustBeOneOf(String column, String options);

  /// No description provided for @expectsDate.
  ///
  /// In en, this message translates to:
  /// **'\"{column}\" expects YYYY-MM-DD - got \"{value}\"'**
  String expectsDate(String column, String value);

  /// No description provided for @expectsTime.
  ///
  /// In en, this message translates to:
  /// **'\"{column}\" expects HH:mm - got \"{value}\"'**
  String expectsTime(String column, String value);

  /// No description provided for @expectsHexColor.
  ///
  /// In en, this message translates to:
  /// **'\"{column}\" expects #RRGGBB - got \"{value}\"'**
  String expectsHexColor(String column, String value);
}

class _SuperTableLocalizationDelegate
    extends LocalizationsDelegate<SuperTableLocalization> {
  const _SuperTableLocalizationDelegate();

  @override
  Future<SuperTableLocalization> load(Locale locale) {
    return SynchronousFuture<SuperTableLocalization>(
      lookupSuperTableLocalization(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SuperTableLocalizationDelegate old) => false;
}

SuperTableLocalization lookupSuperTableLocalization(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SuperTableLocalizationAr();
    case 'en':
      return SuperTableLocalizationEn();
  }

  throw FlutterError(
    'SuperTableLocalization.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
