# SuperTableField package Requirements and Issues

version 0.3.0

## ميزات Table

### Inherinted Column types

قم بأنشاء كلاس لكل نوع يرث من الكلاس الاساسي SuperColumn مع القيم الخاصة به, كالتالي:

- SuperTextColumn.
- SuperNumberColumn<T extends num>.
- SuperCurrencyColumn.
- SuperEnumerationColumn<T>.
- SuperComboColumn<T>
- SuperProgressColumn<T>
- SuperColorColumn<T>, بحيث تحدد صيغة التعامل مع القيمة رقم ام نص او Color
- SuperDateColumn
- SuperTimeColumn
- SuperLinkColumn
- SuperCheckboxColumn

### Column functions

- onChange function like this:

```dart
SuperXColumn(
// in EditableMode.
// default value is, (context, tableController , row , cell , previousValue , newValue)=>true,
//
onchange: (context, tableController , row , cell , previousValue , newValue){
    // can reset  value of other cells
    row.cells["columnName"].value=...; 
    // can change row's fingerPrint
    row.fingerPrint=....;
    // or
    row.randomFingerPrint();

    // it should return bool value, true if newValue is valid or false if not.
    if(/*newValue is ...*/ )
    return true;
    else 
    return false;
}
)
```

- validator function like this:

```dart
SuperXColumn(
// in EditableMode.
// default value is, (context, tableController , row , cell , value) => null,
//
validator: (context, tableController , row , cell , value){
    // check value is not valid
    return 'error code';
}
)
```

### Filter Column

#### Cell

- enhance filter cell design.

#### Source

- add source types for filter values like sync , async , stream.

#### EnumerationColumn

- Make it's filter values is list of FilterItem(String display, T value) instead of List<String>.

#### SuperCurrencyColumn

- Make it's filter values is list of FilterItem(String display, T value) instead of List<String>.

#### SuperColorColumn

- Make it's filter values is list of FilterItem(String display, T value) instead of List<String>.

#### SuperComboColumn

- add all options of AutoSuggestionBox like this:

```dart
SuperComboColumn<T>(
key: '...',
label: '...',
//------------------------- normal options ----------------------------------
// one for all
advancedSearch:...,
advancedSearchBuilder:...,
itemBuilder:...,
loadingBuilder:...,
emptyBuilder:...,
hintText:...,
onSubmitted:...,
leading:...,
highlightMatch:...,
maxVisibleRows:...,
clearButton:false,
onSelected:...,
//------------------------- rebuildable options ----------------------------------
// this will re-call when cell is in editable foucs and (row's fingerPrint is changed or frist build).
sourceController: (context, row, cellData){
    return  AutoSuggestionsSource<T>(...);
}
cellController: (context, row, cellData){
    return AutoSuggestionsBoxController<T>(...);
}
)
```

- اتح امكانية الوصول الى المتحكم AutoSuggestionsBoxController والمصدر SuggestionSources الخاص بخلية الصف بواسطة SuperTableController.

### Advanced table Filter

- اضافة زر الفلترة المتقدمة يكون في Header of RowNo Column وعندما يكون فعال يتم تفريغ حقول الفلتر الخاصة بالاعمدة وجعلها disable وعليها خط / يؤشير الى  انها  ملغي
- عندما يكون الفلتر المتقدم فعال يجب ان يكون على الايقونة badge باللون الاحمر او لون مناسب يشير الى ان هناك اعدادات فلتره موجودة

### Filtering system

- يمكن ضبط الفلتر برمجياً سوا المتقدم او فلاتر الاعمده مع التحقق ان الفلتر المتقدم غير فعال عند التغيير على فلاتر الاعمدة
- يمكن استخراج الفلتر برمجياً من controller على صيغة json مركب
- ارفاق الفلتر مع عملية onLoadMore لكي يتم الاستفادة منه في عملية الجلب

### Focus system

- يمكن تحديد على خلية او عدة خلايا او صف او عدة صفوف برمجياً بواسطة controller او الغاء التحديد
- عند الضغط على خلية رقم الصف يتم تحديد على الصف دون تغيير التركيز على الخلية الحالية

### Column context menu

- يتم اظهار القائمة عند الضغط على راس العمود بالزر الايمن وليس الايسر , ويكون الزر الايسر للسحب  والافلات من اجل نقل الاعمدة , اما في شاشات اللمس يتم اعتماد النقر مرتين لظهور القائمة و الضغط بأستمرار للسحب والافلات

### Documentaion

- update documentation in Readme.md, use pub.dev package's documentation style and principle.
- update changelog.md
