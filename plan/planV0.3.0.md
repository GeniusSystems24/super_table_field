# SuperTableField package Requirements and Issues

Version 0.3.0

## ميزات Table

> Make SuperTable a generic type SuperTable<RowValueType>.

### Row

#### Row style

* إضافة conditional style استايل شرطي، بحيث يتم تحديد لون خلفية الصف أو لون النص بحسب مجموعة من الشروط كالتالي:
* هذا الاستايل له الأولوية على الـ column style

```dart
SuperTable<RowValueType>(
    // in ReadableMode
    styles:{
        conditionFun1(BuildContext context,SuperTableController<RowValueType> tableController ,SuperRow<RowValueType> row)=>true: SuperRowStyle(),
        conditionFun2(BuildContext context,SuperTableController<RowValueType> tableController ,SuperRow<RowValueType> row)=>true: SuperRowStyle(),
    }
)
```

### Loading more

* Fix skeleton style.
* Fix loading mechanism.

### Column

#### Inherited Column types

قم بإنشاء كلاس لكل نوع يرث من الكلاس الأساسي SuperColumn مع القيم الخاصة به، كالتالي:

* SuperTextColumn.
* SuperNumberColumn<T extends num>.
* SuperCurrencyColumn.
* SuperEnumerationColumn<T>.
* SuperComboColumn<T>
* SuperProgressColumn<T>
* SuperColorColumn<T>, بحيث تحدد صيغة التعامل مع القيمة: رقم أم نص أم Color
* SuperDateColumn
* SuperTimeColumn
* SuperLinkColumn
* SuperCheckboxColumn

أبقِ على SuperColumn كما هو قابلًا للاستخدام الحر

#### Column functions

* onChange function like this:

```dart
SuperXColumn<T>(
// in EditableMode.
// default value is: (BuildContext context,SuperTableController<RowValueType> tableController , row , cell , previousValue , newValue)=>true,
//
onChange: (BuildContext context,SuperTableController<RowValueType> tableController ,SuperRow<RowValueType> row , cell ,T previousValue ,T newValue){
    // can reset value of other cells
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

* validator function like this:

```dart
SuperXColumn<T>(
// in EditableMode.
// default value is: (BuildContext context,SuperTableController<RowValueType> tableController , row , cell , value) => null,
//
validator: (BuildContext context,SuperTableController<RowValueType> tableController ,SuperRow<RowValueType> row , cell ,T value){
    // check if value is not valid
    return 'error code';
}
)
```

#### Cell

* Enhance filter cell design.

#### Filter Source

* Add source types for filter values like sync, async, and stream.

#### EnumerationColumn

* Make its filter values a list of FilterItem(String display, T value) instead of List<String>.

#### SuperCurrencyColumn

* Make its filter values a list of FilterItem(String display, T value) instead of List<String>.

#### SuperColorColumn

* Make its filter values a list of FilterItem(String display, T value) instead of List<String>.

#### SuperComboColumn

* Add all options of AutoSuggestionsBox like this:

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
// this will be recalled when the cell is in editable focus and (row's fingerPrint is changed or first build).
sourceController: (BuildContext context,SuperTableController<RowValueType> tableController ,SuperRow<RowValueType> row, cell){
    return  AutoSuggestionsSource<T>(...);
}
cellController: (BuildContext context,SuperTableController<RowValueType> tableController ,SuperRow<RowValueType> row, cell){
    return AutoSuggestionsBoxController<T>(...);
}
)
```

* أتِح إمكانية الوصول إلى المتحكم AutoSuggestionsBoxController والمصدر SuggestionSources الخاص بخلية الصف بواسطة SuperTableController.

#### Cell style

* إضافة conditional style استايل شرطي، بحيث يتم تحديد لون خلفية الخلية أو لون النص بحسب مجموعة من الشروط كالتالي:

```dart
SuperXColumn<T>(
    // in ReadableMode
    styles:{
        conditionFun1(BuildContext context,SuperTableController<RowValueType> tableController ,SuperRow<RowValueType> row, cell)=>true: CellStyle(),
        conditionFun2(BuildContext context,SuperTableController<RowValueType> tableController ,SuperRow<RowValueType> row, cell)=>true: CellStyle(),
    }
)
```

### Advanced table Filter

* إضافة زر الفلترة المتقدمة يكون في Header of RowNo Column، وعندما يكون فعالًا يتم تفريغ حقول الفلتر الخاصة بالأعمدة وجعلها disabled وعليها خط / يشير إلى أنها ملغاة
* عندما يكون الفلتر المتقدم فعالًا، يجب أن يكون على الأيقونة badge باللون الأحمر أو لون مناسب يشير إلى أن هناك إعدادات فلترة موجودة

### Filtering system

* يمكن ضبط الفلتر برمجيًا، سواء المتقدم أو فلاتر الأعمدة، مع التحقق من أن الفلتر المتقدم غير فعال عند التغيير على فلاتر الأعمدة
* يمكن استخراج الفلتر برمجيًا من controller على صيغة json مركب
* إرفاق الفلتر مع عملية onLoadMore لكي يتم الاستفادة منه في عملية الجلب

### Focus system

* يمكن التحديد على خلية أو عدة خلايا أو صف أو عدة صفوف برمجيًا بواسطة controller أو إلغاء التحديد
* عند الضغط على خلية رقم الصف، يتم التحديد على الصف دون تغيير التركيز على الخلية الحالية

### Column context menu

* يتم إظهار القائمة عند الضغط على رأس العمود بالزر الأيمن وليس الأيسر، ويكون الزر الأيسر للسحب والإفلات من أجل نقل الأعمدة، أما في شاشات اللمس فيتم اعتماد النقر مرتين لظهور القائمة والضغط باستمرار للسحب والإفلات

### Row context menu

* اجعل الخيارات الشجرية تعرض تفرعاتها كـ overlayCard واجعلها قابلة للتمدد إلى أشجار تفرعية كما نريد.

### Keyboard shortcuts function

* دالة لإضافة الاختصارات كالتالي

```dart
SuperTable<RowValueType>(
    // in ReadableMode
    onKey: (BuildContext context,SuperTableController<RowValueType> tableController, FocusNode node, KeyEvent e){}   
)
```

### SuperTableController

* أتِح إمكانية تعديل mode من خلال المتحكم من قراءة إلى تعديل والعكس.
* أتِح إمكانية تحميل المزيد أو تنظيف الجدول أو غيره من خلال المتحكم

### Documentation

* Update documentation in Readme.md, use pub.dev package's documentation style and principles.
* Update changelog.md
* Create 5 examples for using SuperTable in different ways.
