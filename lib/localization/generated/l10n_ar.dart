// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SuperTableLocalizationAr extends SuperTableLocalization {
  SuperTableLocalizationAr([String locale = 'ar']) : super(locale);

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get clear => 'مسح';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get done => 'تم';

  @override
  String get all => 'الكل';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get checked => 'محدد';

  @override
  String get unchecked => 'غير محدد';

  @override
  String get filterHint => 'تصفية...';

  @override
  String get valueHint => 'القيمة';

  @override
  String get toHint => 'إلى';

  @override
  String get noRows => 'لا توجد صفوف';

  @override
  String get totals => 'الإجمالي';

  @override
  String get loadMore => 'تحميل المزيد';

  @override
  String get loading => 'جار التحميل...';

  @override
  String get deleteRowTitle => 'حذف الصف؟';

  @override
  String deleteRowBody(int rowNumber, String rowLabel) {
    return 'سيتم حذف الصف $rowNumber ($rowLabel) نهائياً. لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get sortAscending => 'ترتيب تصاعدي';

  @override
  String get sortDescending => 'ترتيب تنازلي';

  @override
  String get clearSort => 'مسح الترتيب';

  @override
  String get removeFromGrouping => 'إزالة من التجميع';

  @override
  String get groupByThisColumn => 'تجميع حسب هذا العمود';

  @override
  String get hideColumn => 'إخفاء العمود';

  @override
  String get showColumn => 'إظهار العمود';

  @override
  String get pin => 'تثبيت';

  @override
  String get pinLeft => 'تثبيت في البداية';

  @override
  String get pinRight => 'تثبيت في النهاية';

  @override
  String get unpinned => 'غير مثبت';

  @override
  String get manageColumns => 'إدارة الأعمدة';

  @override
  String get manageColumnsDescription =>
      'اسحب لإعادة الترتيب · بدّل الظهور · ثبّت إلى طرف';

  @override
  String shownOfColumns(int shown, int total) {
    return '$shown من $total ظاهر';
  }

  @override
  String get copyJson => 'نسخ JSON';

  @override
  String get copyAsJson => 'نسخ كـ JSON';

  @override
  String get shortcuts => 'الاختصارات';

  @override
  String get keyboardShortcuts => 'اختصارات لوحة المفاتيح';

  @override
  String get insertRowAbove => 'إدراج صف أعلى';

  @override
  String get insertRowBelow => 'إدراج صف أسفل';

  @override
  String get duplicateRow => 'تكرار الصف';

  @override
  String get revertCell => 'إرجاع الخلية';

  @override
  String get revertRow => 'إرجاع الصف';

  @override
  String get revertRowRemoveAdded => 'إرجاع الصف (إزالة المضاف)';

  @override
  String get moveRowUp => 'نقل الصف للأعلى';

  @override
  String get moveRowDown => 'نقل الصف للأسفل';

  @override
  String get deleteRow => 'حذف الصف';

  @override
  String get rowOptions => 'خيارات الصف';

  @override
  String get groupBy => 'تجميع حسب';

  @override
  String get groupedBy => 'مجمّع حسب';

  @override
  String get clearAll => 'مسح الكل';

  @override
  String get addColumn => 'إضافة عمود';

  @override
  String get advancedFilter => 'فلتر متقدم';

  @override
  String get advancedFilterActiveEdit => 'الفلتر المتقدم نشط - تعديل';

  @override
  String get clearAllFilters => 'مسح كل الفلاتر';

  @override
  String get filterRows => 'تصفية الصفوف';

  @override
  String get advancedFilterDescription =>
      'يجب أن تطابق كل الشروط (AND). يتم تعطيل فلاتر الأعمدة أثناء تفعيله.';

  @override
  String get addCondition => 'إضافة شرط';

  @override
  String get applyFilter => 'تطبيق الفلتر';

  @override
  String get opContains => 'يحتوي';

  @override
  String get opEquals => 'يساوي';

  @override
  String get opNotEquals => 'لا يساوي';

  @override
  String get opStartsWith => 'يبدأ بـ';

  @override
  String get opEndsWith => 'ينتهي بـ';

  @override
  String get opGreaterThan => '> أكبر من';

  @override
  String get opGreaterOrEqual => '>= على الأقل';

  @override
  String get opLessThan => '< أقل من';

  @override
  String get opLessOrEqual => '<= على الأكثر';

  @override
  String get opBetween => 'بين';

  @override
  String get opIsEmpty => 'فارغ';

  @override
  String get opIsNotEmpty => 'غير فارغ';

  @override
  String get navigate => 'التنقل';

  @override
  String get edit => 'التحرير';

  @override
  String get rowsAndClipboard => 'الصفوف والحافظة';

  @override
  String get moveBetweenCells => 'التنقل بين الخلايا';

  @override
  String get nextPreviousCell => 'الخلية التالية / السابقة';

  @override
  String get firstLastColumn => 'أول / آخر عمود';

  @override
  String get firstLastCell => 'أول / آخر خلية';

  @override
  String get overwriteCell => 'استبدال محتوى الخلية';

  @override
  String get editOrOpenSelect => 'تحرير أو فتح قائمة اختيار';

  @override
  String get commitAndMove => 'حفظ والانتقال';

  @override
  String get appendNewRow => 'إضافة صف جديد';

  @override
  String get clearCell => 'مسح الخلية';

  @override
  String get cancelEditing => 'إلغاء التحرير';

  @override
  String get insertRowAfter => 'إدراج صف بعد الحالي';

  @override
  String get insertRowBefore => 'إدراج صف قبل الحالي';

  @override
  String get duplicateRowFillDown => 'تكرار الصف · تعبئة للأسفل';

  @override
  String get fillRightAcrossRange => 'تعبئة يميناً عبر النطاق';

  @override
  String get copySelectionAsJson => 'نسخ التحديد كـ JSON';

  @override
  String get cutPasteValidated => 'قص / لصق مع التحقق';

  @override
  String get undoRedo => 'تراجع / إعادة';

  @override
  String get allRowsValid => 'كل الصفوف صالحة';

  @override
  String validationIssueCount(int count, String pluralSuffix) {
    return '$count مشكلة تحقق';
  }

  @override
  String get allRowsValidBody =>
      'كل الخلايا تطابق قواعد النوع والقيود الفريدة ومدققات الأعمدة.';

  @override
  String rowNumber(int rowNumber) {
    return 'صف $rowNumber';
  }

  @override
  String issueCount(int count, String pluralSuffix) {
    return '$count مشكلة';
  }

  @override
  String rowCount(int count, String pluralSuffix) {
    return '$count صف';
  }

  @override
  String editableStatusHint(String rowCount) {
    return '$rowCount · ↵ تحرير · Tab التالي (صف جديد في النهاية) · ⌘↵ إدراج بعد · ⌘C/V JSON · ⌘Z تراجع';
  }

  @override
  String readableStatusHint(String rowCount, String expansionHint) {
    return '$rowCount · ⇧+الأسهم لتحديد نطاق · زر أيمن على الهيدر للخيارات · ⌘C نسخ$expansionHint';
  }

  @override
  String get expandCollapseHint => ' · ⌘⇧↓ توسيع · ⌘⇧↑ طي';

  @override
  String selectedCount(int count) {
    return '$count محدد';
  }

  @override
  String get pageRangeEmpty => '0 من 0';

  @override
  String pageRange(int from, int to, int total) {
    return '$from-$to من $total';
  }

  @override
  String selectionStats(
    String sum,
    String average,
    String min,
    String max,
    int count,
  ) {
    return 'المجموع $sum · المتوسط $average · الأدنى $min · الأعلى $max · العدد $count';
  }

  @override
  String get typeValueHint => 'اكتب قيمة...';

  @override
  String get typeOrPickHint => 'اكتب أو اختر...';

  @override
  String get today => 'اليوم';

  @override
  String get monthJan => 'ينا';

  @override
  String get monthFeb => 'فبر';

  @override
  String get monthMar => 'مار';

  @override
  String get monthApr => 'أبر';

  @override
  String get monthMay => 'ماي';

  @override
  String get monthJun => 'يون';

  @override
  String get monthJul => 'يول';

  @override
  String get monthAug => 'أغس';

  @override
  String get monthSep => 'سبت';

  @override
  String get monthOct => 'أكت';

  @override
  String get monthNov => 'نوف';

  @override
  String get monthDec => 'ديس';

  @override
  String get weekdaySun => 'ح';

  @override
  String get weekdayMon => 'ن';

  @override
  String get weekdayTue => 'ث';

  @override
  String get weekdayWed => 'ر';

  @override
  String get weekdayThu => 'خ';

  @override
  String get weekdayFri => 'ج';

  @override
  String get weekdaySat => 'س';

  @override
  String copiedRowsCsv(int count) {
    return 'تم نسخ $count صف كـ CSV';
  }

  @override
  String filledCells(int count, String pluralSuffix) {
    return 'تمت تعبئة $count خلية';
  }

  @override
  String copiedRowsJson(int count, String pluralSuffix) {
    return 'تم نسخ $count صف كـ JSON';
  }

  @override
  String rowIsNotObject(int rowNumber) {
    return 'الصف $rowNumber ليس كائناً';
  }

  @override
  String rowError(int rowNumber, String error) {
    return 'الصف $rowNumber: $error';
  }

  @override
  String unknownField(String field) {
    return 'الحقل \"$field\" غير معروف - ليس عموداً في هذا الجدول';
  }

  @override
  String pastedBlockTooWide(int columnNumber) {
    return 'نطاق اللصق أعرض من الجدول (العمود $columnNumber غير موجود)';
  }

  @override
  String cellError(int rowNumber, int columnNumber, String error) {
    return 'الخلية $rowNumber×$columnNumber: $error';
  }

  @override
  String get pasteEditableOnly => 'اللصق مسموح فقط في وضع التحرير';

  @override
  String get clipboardInvalidJson => 'الحافظة لا تحتوي JSON صالح';

  @override
  String get pasted => 'تم اللصق';

  @override
  String columnMustBeUniqueDuplicate(String column, int rowNumber) {
    return 'يجب أن يكون \"$column\" فريداً - مكرر في الصف $rowNumber';
  }

  @override
  String columnInvalidValue(String column) {
    return '\"$column\" يحتوي قيمة غير صالحة';
  }

  @override
  String columnMustBeUnique(String column) {
    return 'يجب أن يكون \"$column\" فريداً';
  }

  @override
  String get thisCell => 'هذه الخلية';

  @override
  String isRequired(String name) {
    return '$name مطلوب';
  }

  @override
  String mustBeNumber(String name) {
    return 'يجب أن يكون $name رقماً';
  }

  @override
  String mustBeDate(String name) {
    return 'يجب أن يكون $name تاريخاً (YYYY-MM-DD)';
  }

  @override
  String mustBeTime(String name) {
    return 'يجب أن يكون $name وقتاً (HH:mm)';
  }

  @override
  String mustBeHexColor(String name) {
    return 'يجب أن يكون $name لوناً بصيغة hex (#RRGGBB)';
  }

  @override
  String isReadOnly(String column) {
    return '\"$column\" للقراءة فقط';
  }

  @override
  String columnIsRequired(String column) {
    return '\"$column\" مطلوب';
  }

  @override
  String expectsNumber(String column, String value) {
    return '\"$column\" يتوقع رقماً - القيمة \"$value\"';
  }

  @override
  String expectsTrueFalse(String column, String value) {
    return '\"$column\" يتوقع true/false - القيمة \"$value\"';
  }

  @override
  String mustBeOneOf(String column, String options) {
    return 'يجب أن يكون \"$column\" أحد القيم: $options';
  }

  @override
  String expectsDate(String column, String value) {
    return '\"$column\" يتوقع YYYY-MM-DD - القيمة \"$value\"';
  }

  @override
  String expectsTime(String column, String value) {
    return '\"$column\" يتوقع HH:mm - القيمة \"$value\"';
  }

  @override
  String expectsHexColor(String column, String value) {
    return '\"$column\" يتوقع #RRGGBB - القيمة \"$value\"';
  }
}
