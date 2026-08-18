// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
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
  String get localeName => 'ar';

  static String m0(rowNumber, columnNumber, error) =>
      "الخلية ${rowNumber}×${columnNumber}: ${error}";

  static String m1(column) => "\"${column}\" يحتوي قيمة غير صالحة";

  static String m2(column) => "\"${column}\" مطلوب";

  static String m3(column) => "يجب أن يكون \"${column}\" فريداً";

  static String m4(column, rowNumber) =>
      "يجب أن يكون \"${column}\" فريداً - مكرر في الصف ${rowNumber}";

  static String m5(count) => "تم نسخ ${count} صف كـ CSV";

  static String m6(count, pluralSuffix) => "تم نسخ ${count} صف كـ JSON";

  static String m7(rowNumber, rowLabel) =>
      "سيتم حذف الصف ${rowNumber} (${rowLabel}) نهائياً. لا يمكن التراجع عن هذا الإجراء.";

  static String m8(rowCount) =>
      "${rowCount} · ↵ تحرير · Tab التالي (صف جديد في النهاية) · ⌘↵ إدراج بعد · ⌘C/V JSON · ⌘Z تراجع";

  static String m9(column, value) =>
      "\"${column}\" يتوقع YYYY-MM-DD - القيمة \"${value}\"";

  static String m10(column, value) =>
      "\"${column}\" يتوقع #RRGGBB - القيمة \"${value}\"";

  static String m11(column, value) =>
      "\"${column}\" يتوقع رقماً - القيمة \"${value}\"";

  static String m12(column, value) =>
      "\"${column}\" يتوقع HH:mm - القيمة \"${value}\"";

  static String m13(column, value) =>
      "\"${column}\" يتوقع true/false - القيمة \"${value}\"";

  static String m14(count, pluralSuffix) => "تمت تعبئة ${count} خلية";

  static String m15(column) => "\"${column}\" للقراءة فقط";

  static String m16(name) => "${name} مطلوب";

  static String m17(count, pluralSuffix) => "${count} مشكلة";

  static String m18(name) => "يجب أن يكون ${name} تاريخاً (YYYY-MM-DD)";

  static String m19(name) => "يجب أن يكون ${name} لوناً بصيغة hex (#RRGGBB)";

  static String m20(name) => "يجب أن يكون ${name} رقماً";

  static String m21(column, options) =>
      "يجب أن يكون \"${column}\" أحد القيم: ${options}";

  static String m22(name) => "يجب أن يكون ${name} وقتاً (HH:mm)";

  static String m23(from, to, total) => "${from}-${to} من ${total}";

  static String m24(columnNumber) =>
      "نطاق اللصق أعرض من الجدول (العمود ${columnNumber} غير موجود)";

  static String m25(rowCount, expansionHint) =>
      "${rowCount} · ⇧+الأسهم لتحديد نطاق · زر أيمن على الهيدر للخيارات · ⌘C نسخ${expansionHint}";

  static String m26(count, pluralSuffix) => "${count} صف";

  static String m27(rowNumber, error) => "الصف ${rowNumber}: ${error}";

  static String m28(rowNumber) => "الصف ${rowNumber} ليس كائناً";

  static String m29(rowNumber) => "صف ${rowNumber}";

  static String m30(count) => "${count} محدد";

  static String m31(sum, average, min, max, count) =>
      "المجموع ${sum} · المتوسط ${average} · الأدنى ${min} · الأعلى ${max} · العدد ${count}";

  static String m32(shown, total) => "${shown} من ${total} ظاهر";

  static String m33(field) =>
      "الحقل \"${field}\" غير معروف - ليس عموداً في هذا الجدول";

  static String m34(count, pluralSuffix) => "${count} مشكلة تحقق";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "addColumn": MessageLookupByLibrary.simpleMessage("إضافة عمود"),
    "addCondition": MessageLookupByLibrary.simpleMessage("إضافة شرط"),
    "advancedFilter": MessageLookupByLibrary.simpleMessage("فلتر متقدم"),
    "advancedFilterActiveEdit": MessageLookupByLibrary.simpleMessage(
      "الفلتر المتقدم نشط - تعديل",
    ),
    "advancedFilterDescription": MessageLookupByLibrary.simpleMessage(
      "يجب أن تطابق كل الشروط (AND). يتم تعطيل فلاتر الأعمدة أثناء تفعيله.",
    ),
    "all": MessageLookupByLibrary.simpleMessage("الكل"),
    "allRowsValid": MessageLookupByLibrary.simpleMessage("كل الصفوف صالحة"),
    "allRowsValidBody": MessageLookupByLibrary.simpleMessage(
      "كل الخلايا تطابق قواعد النوع والقيود الفريدة ومدققات الأعمدة.",
    ),
    "appendNewRow": MessageLookupByLibrary.simpleMessage("إضافة صف جديد"),
    "applyFilter": MessageLookupByLibrary.simpleMessage("تطبيق الفلتر"),
    "cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
    "cancelEditing": MessageLookupByLibrary.simpleMessage("إلغاء التحرير"),
    "cellError": m0,
    "checked": MessageLookupByLibrary.simpleMessage("محدد"),
    "clear": MessageLookupByLibrary.simpleMessage("مسح"),
    "clearAll": MessageLookupByLibrary.simpleMessage("مسح الكل"),
    "clearAllFilters": MessageLookupByLibrary.simpleMessage("مسح كل الفلاتر"),
    "clearCell": MessageLookupByLibrary.simpleMessage("مسح الخلية"),
    "clearSort": MessageLookupByLibrary.simpleMessage("مسح الترتيب"),
    "clipboardInvalidJson": MessageLookupByLibrary.simpleMessage(
      "الحافظة لا تحتوي JSON صالح",
    ),
    "columnInvalidValue": m1,
    "columnIsRequired": m2,
    "columnMustBeUnique": m3,
    "columnMustBeUniqueDuplicate": m4,
    "commitAndMove": MessageLookupByLibrary.simpleMessage("حفظ والانتقال"),
    "copiedRowsCsv": m5,
    "copiedRowsJson": m6,
    "copyAsJson": MessageLookupByLibrary.simpleMessage("نسخ كـ JSON"),
    "copyJson": MessageLookupByLibrary.simpleMessage("نسخ JSON"),
    "copySelectionAsJson": MessageLookupByLibrary.simpleMessage(
      "نسخ التحديد كـ JSON",
    ),
    "cutPasteValidated": MessageLookupByLibrary.simpleMessage(
      "قص / لصق مع التحقق",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("حذف"),
    "deleteRow": MessageLookupByLibrary.simpleMessage("حذف الصف"),
    "deleteRowBody": m7,
    "deleteRowTitle": MessageLookupByLibrary.simpleMessage("حذف الصف؟"),
    "done": MessageLookupByLibrary.simpleMessage("تم"),
    "duplicateRow": MessageLookupByLibrary.simpleMessage("تكرار الصف"),
    "duplicateRowFillDown": MessageLookupByLibrary.simpleMessage(
      "تكرار الصف · تعبئة للأسفل",
    ),
    "edit": MessageLookupByLibrary.simpleMessage("التحرير"),
    "editOrOpenSelect": MessageLookupByLibrary.simpleMessage(
      "تحرير أو فتح قائمة اختيار",
    ),
    "editableStatusHint": m8,
    "expandCollapseHint": MessageLookupByLibrary.simpleMessage(
      " · ⌘⇧↓ توسيع · ⌘⇧↑ طي",
    ),
    "expectsDate": m9,
    "expectsHexColor": m10,
    "expectsNumber": m11,
    "expectsTime": m12,
    "expectsTrueFalse": m13,
    "fillRightAcrossRange": MessageLookupByLibrary.simpleMessage(
      "تعبئة يميناً عبر النطاق",
    ),
    "filledCells": m14,
    "filterHint": MessageLookupByLibrary.simpleMessage("تصفية..."),
    "filterRows": MessageLookupByLibrary.simpleMessage("تصفية الصفوف"),
    "firstLastCell": MessageLookupByLibrary.simpleMessage("أول / آخر خلية"),
    "firstLastColumn": MessageLookupByLibrary.simpleMessage("أول / آخر عمود"),
    "groupBy": MessageLookupByLibrary.simpleMessage("تجميع حسب"),
    "groupByThisColumn": MessageLookupByLibrary.simpleMessage(
      "تجميع حسب هذا العمود",
    ),
    "groupedBy": MessageLookupByLibrary.simpleMessage("مجمّع حسب"),
    "hideColumn": MessageLookupByLibrary.simpleMessage("إخفاء العمود"),
    "insertRowAbove": MessageLookupByLibrary.simpleMessage("إدراج صف أعلى"),
    "insertRowAfter": MessageLookupByLibrary.simpleMessage(
      "إدراج صف بعد الحالي",
    ),
    "insertRowBefore": MessageLookupByLibrary.simpleMessage(
      "إدراج صف قبل الحالي",
    ),
    "insertRowBelow": MessageLookupByLibrary.simpleMessage("إدراج صف أسفل"),
    "isReadOnly": m15,
    "isRequired": m16,
    "issueCount": m17,
    "keyboardShortcuts": MessageLookupByLibrary.simpleMessage(
      "اختصارات لوحة المفاتيح",
    ),
    "loadMore": MessageLookupByLibrary.simpleMessage("تحميل المزيد"),
    "loading": MessageLookupByLibrary.simpleMessage("جار التحميل..."),
    "manageColumns": MessageLookupByLibrary.simpleMessage("إدارة الأعمدة"),
    "manageColumnsDescription": MessageLookupByLibrary.simpleMessage(
      "اسحب لإعادة الترتيب · بدّل الظهور · ثبّت إلى طرف",
    ),
    "monthApr": MessageLookupByLibrary.simpleMessage("أبر"),
    "monthAug": MessageLookupByLibrary.simpleMessage("أغس"),
    "monthDec": MessageLookupByLibrary.simpleMessage("ديس"),
    "monthFeb": MessageLookupByLibrary.simpleMessage("فبر"),
    "monthJan": MessageLookupByLibrary.simpleMessage("ينا"),
    "monthJul": MessageLookupByLibrary.simpleMessage("يول"),
    "monthJun": MessageLookupByLibrary.simpleMessage("يون"),
    "monthMar": MessageLookupByLibrary.simpleMessage("مار"),
    "monthMay": MessageLookupByLibrary.simpleMessage("ماي"),
    "monthNov": MessageLookupByLibrary.simpleMessage("نوف"),
    "monthOct": MessageLookupByLibrary.simpleMessage("أكت"),
    "monthSep": MessageLookupByLibrary.simpleMessage("سبت"),
    "moveBetweenCells": MessageLookupByLibrary.simpleMessage(
      "التنقل بين الخلايا",
    ),
    "moveRowDown": MessageLookupByLibrary.simpleMessage("نقل الصف للأسفل"),
    "moveRowUp": MessageLookupByLibrary.simpleMessage("نقل الصف للأعلى"),
    "mustBeDate": m18,
    "mustBeHexColor": m19,
    "mustBeNumber": m20,
    "mustBeOneOf": m21,
    "mustBeTime": m22,
    "navigate": MessageLookupByLibrary.simpleMessage("التنقل"),
    "nextPreviousCell": MessageLookupByLibrary.simpleMessage(
      "الخلية التالية / السابقة",
    ),
    "no": MessageLookupByLibrary.simpleMessage("لا"),
    "noRows": MessageLookupByLibrary.simpleMessage("لا توجد صفوف"),
    "opBetween": MessageLookupByLibrary.simpleMessage("بين"),
    "opContains": MessageLookupByLibrary.simpleMessage("يحتوي"),
    "opEndsWith": MessageLookupByLibrary.simpleMessage("ينتهي بـ"),
    "opEquals": MessageLookupByLibrary.simpleMessage("يساوي"),
    "opGreaterOrEqual": MessageLookupByLibrary.simpleMessage(">= على الأقل"),
    "opGreaterThan": MessageLookupByLibrary.simpleMessage("> أكبر من"),
    "opIsEmpty": MessageLookupByLibrary.simpleMessage("فارغ"),
    "opIsNotEmpty": MessageLookupByLibrary.simpleMessage("غير فارغ"),
    "opLessOrEqual": MessageLookupByLibrary.simpleMessage("<= على الأكثر"),
    "opLessThan": MessageLookupByLibrary.simpleMessage("< أقل من"),
    "opNotEquals": MessageLookupByLibrary.simpleMessage("لا يساوي"),
    "opStartsWith": MessageLookupByLibrary.simpleMessage("يبدأ بـ"),
    "overwriteCell": MessageLookupByLibrary.simpleMessage(
      "استبدال محتوى الخلية",
    ),
    "pageRange": m23,
    "pageRangeEmpty": MessageLookupByLibrary.simpleMessage("0 من 0"),
    "pasteEditableOnly": MessageLookupByLibrary.simpleMessage(
      "اللصق مسموح فقط في وضع التحرير",
    ),
    "pasted": MessageLookupByLibrary.simpleMessage("تم اللصق"),
    "pastedBlockTooWide": m24,
    "pin": MessageLookupByLibrary.simpleMessage("تثبيت"),
    "pinLeft": MessageLookupByLibrary.simpleMessage("تثبيت في البداية"),
    "pinRight": MessageLookupByLibrary.simpleMessage("تثبيت في النهاية"),
    "readableStatusHint": m25,
    "removeFromGrouping": MessageLookupByLibrary.simpleMessage(
      "إزالة من التجميع",
    ),
    "reset": MessageLookupByLibrary.simpleMessage("إعادة تعيين"),
    "revertCell": MessageLookupByLibrary.simpleMessage("إرجاع الخلية"),
    "revertRow": MessageLookupByLibrary.simpleMessage("إرجاع الصف"),
    "revertRowRemoveAdded": MessageLookupByLibrary.simpleMessage(
      "إرجاع الصف (إزالة المضاف)",
    ),
    "rowCount": m26,
    "rowError": m27,
    "rowIsNotObject": m28,
    "rowNumber": m29,
    "rowOptions": MessageLookupByLibrary.simpleMessage("خيارات الصف"),
    "rowsAndClipboard": MessageLookupByLibrary.simpleMessage("الصفوف والحافظة"),
    "selectedCount": m30,
    "selectionStats": m31,
    "shortcuts": MessageLookupByLibrary.simpleMessage("الاختصارات"),
    "showColumn": MessageLookupByLibrary.simpleMessage("إظهار العمود"),
    "shownOfColumns": m32,
    "sortAscending": MessageLookupByLibrary.simpleMessage("ترتيب تصاعدي"),
    "sortDescending": MessageLookupByLibrary.simpleMessage("ترتيب تنازلي"),
    "thisCell": MessageLookupByLibrary.simpleMessage("هذه الخلية"),
    "toHint": MessageLookupByLibrary.simpleMessage("إلى"),
    "today": MessageLookupByLibrary.simpleMessage("اليوم"),
    "totals": MessageLookupByLibrary.simpleMessage("الإجمالي"),
    "typeOrPickHint": MessageLookupByLibrary.simpleMessage("اكتب أو اختر..."),
    "typeValueHint": MessageLookupByLibrary.simpleMessage("اكتب قيمة..."),
    "unchecked": MessageLookupByLibrary.simpleMessage("غير محدد"),
    "undoRedo": MessageLookupByLibrary.simpleMessage("تراجع / إعادة"),
    "unknownField": m33,
    "unpinned": MessageLookupByLibrary.simpleMessage("غير مثبت"),
    "validationIssueCount": m34,
    "valueHint": MessageLookupByLibrary.simpleMessage("القيمة"),
    "weekdayFri": MessageLookupByLibrary.simpleMessage("ج"),
    "weekdayMon": MessageLookupByLibrary.simpleMessage("ن"),
    "weekdaySat": MessageLookupByLibrary.simpleMessage("س"),
    "weekdaySun": MessageLookupByLibrary.simpleMessage("ح"),
    "weekdayThu": MessageLookupByLibrary.simpleMessage("خ"),
    "weekdayTue": MessageLookupByLibrary.simpleMessage("ث"),
    "weekdayWed": MessageLookupByLibrary.simpleMessage("ر"),
    "yes": MessageLookupByLibrary.simpleMessage("نعم"),
  };
}
