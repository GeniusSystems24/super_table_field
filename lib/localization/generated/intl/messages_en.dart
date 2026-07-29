// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(rowNumber, columnNumber, error) =>
      "Cell ${rowNumber}×${columnNumber}: ${error}";

  static String m1(column) => "\"${column}\" has an invalid value";

  static String m2(column) => "\"${column}\" is required";

  static String m3(column) => "\"${column}\" must be unique";

  static String m4(column, rowNumber) =>
      "\"${column}\" must be unique - duplicates row ${rowNumber}";

  static String m5(count) => "Copied ${count} rows as CSV";

  static String m6(count, pluralSuffix) =>
      "Copied ${count} row${pluralSuffix} as JSON";

  static String m7(rowNumber, rowLabel) =>
      "Row ${rowNumber} (${rowLabel}) will be permanently removed. This cannot be undone.";

  static String m8(rowCount) =>
      "${rowCount} · ↵ edit · Tab next (new row at end) · ⌘↵ insert after · ⌘C/V JSON · ⌘Z undo";

  static String m9(column, value) =>
      "\"${column}\" expects YYYY-MM-DD - got \"${value}\"";

  static String m10(column, value) =>
      "\"${column}\" expects #RRGGBB - got \"${value}\"";

  static String m11(column, value) =>
      "\"${column}\" expects a number - got \"${value}\"";

  static String m12(column, value) =>
      "\"${column}\" expects HH:mm - got \"${value}\"";

  static String m13(column, value) =>
      "\"${column}\" expects true/false - got \"${value}\"";

  static String m14(count, pluralSuffix) =>
      "Filled ${count} cell${pluralSuffix}";

  static String m15(column) => "\"${column}\" is read-only";

  static String m16(name) => "${name} is required";

  static String m17(count, pluralSuffix) => "${count} issue${pluralSuffix}";

  static String m18(name) => "${name} must be a date (YYYY-MM-DD)";

  static String m19(name) => "${name} must be a hex color (#RRGGBB)";

  static String m20(name) => "${name} must be a number";

  static String m21(column, options) =>
      "\"${column}\" must be one of: ${options}";

  static String m22(name) => "${name} must be a time (HH:mm)";

  static String m23(from, to, total) => "${from}-${to} of ${total}";

  static String m24(columnNumber) =>
      "Pasted block is wider than the table (column ${columnNumber} doesn\'t exist)";

  static String m25(rowCount, expansionHint) =>
      "${rowCount} · ⇧+arrows to range-select · right-click header for options · ⌘C copy${expansionHint}";

  static String m26(count, pluralSuffix) => "${count} row${pluralSuffix}";

  static String m27(rowNumber, error) => "Row ${rowNumber}: ${error}";

  static String m28(rowNumber) => "Row ${rowNumber} is not an object";

  static String m29(rowNumber) => "Row ${rowNumber}";

  static String m30(count) => "${count} selected";

  static String m31(sum, average, min, max, count) =>
      "Sum ${sum} · Avg ${average} · Min ${min} · Max ${max} · Count ${count}";

  static String m32(shown, total) => "${shown} of ${total} shown";

  static String m33(field) =>
      "Unknown field \"${field}\" - not a column in this table";

  static String m34(count, pluralSuffix) =>
      "${count} validation issue${pluralSuffix}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addColumn": MessageLookupByLibrary.simpleMessage("Add column"),
    "addCondition": MessageLookupByLibrary.simpleMessage("Add condition"),
    "advancedFilter": MessageLookupByLibrary.simpleMessage("Advanced filter"),
    "advancedFilterActiveEdit": MessageLookupByLibrary.simpleMessage(
      "Advanced filter active - edit",
    ),
    "advancedFilterDescription": MessageLookupByLibrary.simpleMessage(
      "All conditions must match (AND). Column filters are disabled while this is active.",
    ),
    "all": MessageLookupByLibrary.simpleMessage("All"),
    "allRowsValid": MessageLookupByLibrary.simpleMessage("All rows valid"),
    "allRowsValidBody": MessageLookupByLibrary.simpleMessage(
      "Every cell passes the type rules, unique constraints and column validators.",
    ),
    "appendNewRow": MessageLookupByLibrary.simpleMessage("Append a new row"),
    "applyFilter": MessageLookupByLibrary.simpleMessage("Apply filter"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "cancelEditing": MessageLookupByLibrary.simpleMessage("Cancel editing"),
    "cellError": m0,
    "checked": MessageLookupByLibrary.simpleMessage("Checked"),
    "clear": MessageLookupByLibrary.simpleMessage("Clear"),
    "clearAll": MessageLookupByLibrary.simpleMessage("Clear all"),
    "clearAllFilters": MessageLookupByLibrary.simpleMessage(
      "Clear all filters",
    ),
    "clearCell": MessageLookupByLibrary.simpleMessage("Clear the cell"),
    "clearSort": MessageLookupByLibrary.simpleMessage("Clear sort"),
    "clipboardInvalidJson": MessageLookupByLibrary.simpleMessage(
      "Clipboard is not valid JSON",
    ),
    "columnInvalidValue": m1,
    "columnIsRequired": m2,
    "columnMustBeUnique": m3,
    "columnMustBeUniqueDuplicate": m4,
    "commitAndMove": MessageLookupByLibrary.simpleMessage("Commit & move"),
    "copiedRowsCsv": m5,
    "copiedRowsJson": m6,
    "copyAsJson": MessageLookupByLibrary.simpleMessage("Copy as JSON"),
    "copyJson": MessageLookupByLibrary.simpleMessage("Copy JSON"),
    "copySelectionAsJson": MessageLookupByLibrary.simpleMessage(
      "Copy selection as JSON",
    ),
    "cutPasteValidated": MessageLookupByLibrary.simpleMessage(
      "Cut / paste (validated)",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteRow": MessageLookupByLibrary.simpleMessage("Delete row"),
    "deleteRowBody": m7,
    "deleteRowTitle": MessageLookupByLibrary.simpleMessage("Delete row?"),
    "done": MessageLookupByLibrary.simpleMessage("Done"),
    "duplicateRow": MessageLookupByLibrary.simpleMessage("Duplicate row"),
    "duplicateRowFillDown": MessageLookupByLibrary.simpleMessage(
      "Duplicate row · fill down",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editOrOpenSelect": MessageLookupByLibrary.simpleMessage(
      "Edit, or open a select",
    ),
    "editableStatusHint": m8,
    "expandCollapseHint": MessageLookupByLibrary.simpleMessage(
      " · ⌘⇧↓ expand · ⌘⇧↑ collapse",
    ),
    "expectsDate": m9,
    "expectsHexColor": m10,
    "expectsNumber": m11,
    "expectsTime": m12,
    "expectsTrueFalse": m13,
    "fillRightAcrossRange": MessageLookupByLibrary.simpleMessage(
      "Fill right across the range",
    ),
    "filledCells": m14,
    "filterHint": MessageLookupByLibrary.simpleMessage("Filter..."),
    "filterRows": MessageLookupByLibrary.simpleMessage("Filter rows"),
    "firstLastCell": MessageLookupByLibrary.simpleMessage("First / last cell"),
    "firstLastColumn": MessageLookupByLibrary.simpleMessage(
      "First / last column",
    ),
    "groupBy": MessageLookupByLibrary.simpleMessage("Group by"),
    "groupByThisColumn": MessageLookupByLibrary.simpleMessage(
      "Group by this column",
    ),
    "groupedBy": MessageLookupByLibrary.simpleMessage("GROUPED BY"),
    "hideColumn": MessageLookupByLibrary.simpleMessage("Hide column"),
    "insertRowAbove": MessageLookupByLibrary.simpleMessage("Insert row above"),
    "insertRowAfter": MessageLookupByLibrary.simpleMessage("Insert row after"),
    "insertRowBefore": MessageLookupByLibrary.simpleMessage(
      "Insert row before",
    ),
    "insertRowBelow": MessageLookupByLibrary.simpleMessage("Insert row below"),
    "isReadOnly": m15,
    "isRequired": m16,
    "issueCount": m17,
    "keyboardShortcuts": MessageLookupByLibrary.simpleMessage(
      "Keyboard shortcuts",
    ),
    "loadMore": MessageLookupByLibrary.simpleMessage("Load more"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "manageColumns": MessageLookupByLibrary.simpleMessage("Manage columns"),
    "manageColumnsDescription": MessageLookupByLibrary.simpleMessage(
      "Drag to reorder · toggle visibility · pin to an edge",
    ),
    "monthApr": MessageLookupByLibrary.simpleMessage("Apr"),
    "monthAug": MessageLookupByLibrary.simpleMessage("Aug"),
    "monthDec": MessageLookupByLibrary.simpleMessage("Dec"),
    "monthFeb": MessageLookupByLibrary.simpleMessage("Feb"),
    "monthJan": MessageLookupByLibrary.simpleMessage("Jan"),
    "monthJul": MessageLookupByLibrary.simpleMessage("Jul"),
    "monthJun": MessageLookupByLibrary.simpleMessage("Jun"),
    "monthMar": MessageLookupByLibrary.simpleMessage("Mar"),
    "monthMay": MessageLookupByLibrary.simpleMessage("May"),
    "monthNov": MessageLookupByLibrary.simpleMessage("Nov"),
    "monthOct": MessageLookupByLibrary.simpleMessage("Oct"),
    "monthSep": MessageLookupByLibrary.simpleMessage("Sep"),
    "moveBetweenCells": MessageLookupByLibrary.simpleMessage(
      "Move between cells",
    ),
    "moveRowDown": MessageLookupByLibrary.simpleMessage("Move row down"),
    "moveRowUp": MessageLookupByLibrary.simpleMessage("Move row up"),
    "mustBeDate": m18,
    "mustBeHexColor": m19,
    "mustBeNumber": m20,
    "mustBeOneOf": m21,
    "mustBeTime": m22,
    "navigate": MessageLookupByLibrary.simpleMessage("Navigate"),
    "nextPreviousCell": MessageLookupByLibrary.simpleMessage(
      "Next / previous cell",
    ),
    "no": MessageLookupByLibrary.simpleMessage("No"),
    "noRows": MessageLookupByLibrary.simpleMessage("No rows"),
    "opBetween": MessageLookupByLibrary.simpleMessage("between"),
    "opContains": MessageLookupByLibrary.simpleMessage("contains"),
    "opEndsWith": MessageLookupByLibrary.simpleMessage("ends with"),
    "opEquals": MessageLookupByLibrary.simpleMessage("equals"),
    "opGreaterOrEqual": MessageLookupByLibrary.simpleMessage(">= at least"),
    "opGreaterThan": MessageLookupByLibrary.simpleMessage("> greater"),
    "opIsEmpty": MessageLookupByLibrary.simpleMessage("is empty"),
    "opIsNotEmpty": MessageLookupByLibrary.simpleMessage("is not empty"),
    "opLessOrEqual": MessageLookupByLibrary.simpleMessage("<= at most"),
    "opLessThan": MessageLookupByLibrary.simpleMessage("< less"),
    "opNotEquals": MessageLookupByLibrary.simpleMessage("not equals"),
    "opStartsWith": MessageLookupByLibrary.simpleMessage("starts with"),
    "overwriteCell": MessageLookupByLibrary.simpleMessage("Overwrite the cell"),
    "pageRange": m23,
    "pageRangeEmpty": MessageLookupByLibrary.simpleMessage("0 of 0"),
    "pasteEditableOnly": MessageLookupByLibrary.simpleMessage(
      "Paste is only allowed in Editable mode",
    ),
    "pasted": MessageLookupByLibrary.simpleMessage("Pasted"),
    "pastedBlockTooWide": m24,
    "pin": MessageLookupByLibrary.simpleMessage("Pin"),
    "pinLeft": MessageLookupByLibrary.simpleMessage("Pin left"),
    "pinRight": MessageLookupByLibrary.simpleMessage("Pin right"),
    "readableStatusHint": m25,
    "removeFromGrouping": MessageLookupByLibrary.simpleMessage(
      "Remove from grouping",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "revertCell": MessageLookupByLibrary.simpleMessage("Revert cell"),
    "revertRow": MessageLookupByLibrary.simpleMessage("Revert row"),
    "revertRowRemoveAdded": MessageLookupByLibrary.simpleMessage(
      "Revert row (remove added)",
    ),
    "rowCount": m26,
    "rowError": m27,
    "rowIsNotObject": m28,
    "rowNumber": m29,
    "rowOptions": MessageLookupByLibrary.simpleMessage("Row options"),
    "rowsAndClipboard": MessageLookupByLibrary.simpleMessage(
      "Rows & clipboard",
    ),
    "selectedCount": m30,
    "selectionStats": m31,
    "shortcuts": MessageLookupByLibrary.simpleMessage("Shortcuts"),
    "showColumn": MessageLookupByLibrary.simpleMessage("Show column"),
    "shownOfColumns": m32,
    "sortAscending": MessageLookupByLibrary.simpleMessage("Sort ascending"),
    "sortDescending": MessageLookupByLibrary.simpleMessage("Sort descending"),
    "thisCell": MessageLookupByLibrary.simpleMessage("This cell"),
    "toHint": MessageLookupByLibrary.simpleMessage("to"),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "totals": MessageLookupByLibrary.simpleMessage("TOTALS"),
    "typeOrPickHint": MessageLookupByLibrary.simpleMessage("Type or pick..."),
    "typeValueHint": MessageLookupByLibrary.simpleMessage("Type a value..."),
    "unchecked": MessageLookupByLibrary.simpleMessage("Unchecked"),
    "undoRedo": MessageLookupByLibrary.simpleMessage("Undo / redo"),
    "unknownField": m33,
    "unpinned": MessageLookupByLibrary.simpleMessage("Unpinned"),
    "validationIssueCount": m34,
    "valueHint": MessageLookupByLibrary.simpleMessage("value"),
    "weekdayFri": MessageLookupByLibrary.simpleMessage("Fr"),
    "weekdayMon": MessageLookupByLibrary.simpleMessage("Mo"),
    "weekdaySat": MessageLookupByLibrary.simpleMessage("Sa"),
    "weekdaySun": MessageLookupByLibrary.simpleMessage("Su"),
    "weekdayThu": MessageLookupByLibrary.simpleMessage("Th"),
    "weekdayTue": MessageLookupByLibrary.simpleMessage("Tu"),
    "weekdayWed": MessageLookupByLibrary.simpleMessage("We"),
    "yes": MessageLookupByLibrary.simpleMessage("Yes"),
  };
}
