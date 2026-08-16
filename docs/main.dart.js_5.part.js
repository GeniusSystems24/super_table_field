((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var C,A,B={
b59(d,e,f){return"Cell "+C.f(d)+"\xd7"+C.f(e)+": "+C.f(f)},
b5i(d){return'"'+C.f(d)+'" has an invalid value'},
b5S(d){return'"'+C.f(d)+'" is required'},
b6m(d){return'"'+C.f(d)+'" must be unique'},
b6q(d,e){return'"'+C.f(d)+'" must be unique - duplicates row '+C.f(e)},
b6u(d){return"Copied "+C.f(d)+" rows as CSV"},
b6y(d,e){return"Copied "+C.f(d)+" row"+C.f(e)+" as JSON"},
b6C(d,e){return"Row "+C.f(d)+" ("+C.f(e)+") will be permanently removed. This cannot be undone."},
b6G(d){return C.f(d)+" \xb7 \u21b5 edit \xb7 Tab next (new row at end) \xb7 \u2318\u21b5 insert after \xb7 \u2318C/V JSON \xb7 \u2318Z undo"},
b6K(d,e){return'"'+C.f(d)+'" expects YYYY-MM-DD - got "'+C.f(e)+'"'},
b5e(d,e){return'"'+C.f(d)+'" expects #RRGGBB - got "'+C.f(e)+'"'},
b5j(d,e){return'"'+C.f(d)+'" expects a number - got "'+C.f(e)+'"'},
b5n(d,e){return'"'+C.f(d)+'" expects HH:mm - got "'+C.f(e)+'"'},
b5r(d,e){return'"'+C.f(d)+'" expects true/false - got "'+C.f(e)+'"'},
b5v(d,e){return"Filled "+C.f(d)+" cell"+C.f(e)},
b5z(d){return'"'+C.f(d)+'" is read-only'},
b5D(d){return C.f(d)+" is required"},
b5G(d,e){return C.f(d)+" issue"+C.f(e)},
b5J(d){return C.f(d)+" must be a date (YYYY-MM-DD)"},
b5L(d){return C.f(d)+" must be a hex color (#RRGGBB)"},
b5P(d){return C.f(d)+" must be a number"},
b5T(d,e){return'"'+C.f(d)+'" must be one of: '+C.f(e)},
b5V(d){return C.f(d)+" must be a time (HH:mm)"},
b5X(d,e,f){return C.f(d)+"-"+C.f(e)+" of "+C.f(f)},
b5Z(d){return"Pasted block is wider than the table (column "+C.f(d)+" doesn't exist)"},
b60(d,e){return C.f(d)+" \xb7 \u21e7+arrows to range-select \xb7 right-click header for options \xb7 \u2318C copy"+C.f(e)},
b62(d,e){return C.f(d)+" row"+C.f(e)},
b64(d,e){return"Row "+C.f(d)+": "+C.f(e)},
b66(d){return"Row "+C.f(d)+" is not an object"},
b68(d){return"Row "+C.f(d)},
b6c(d){return C.f(d)+" selected"},
b6f(d,e,f,g,h){return"Sum "+C.f(d)+" \xb7 Avg "+C.f(e)+" \xb7 Min "+C.f(f)+" \xb7 Max "+C.f(g)+" \xb7 Count "+C.f(h)},
b6h(d,e){return C.f(d)+" of "+C.f(e)+" shown"},
b6j(d){return'Unknown field "'+C.f(d)+'" - not a column in this table'},
b6l(d,e){return C.f(d)+" validation issue"+C.f(e)},
aTZ(d){return C.M(["addColumn",A.k("Add column"),"addCondition",A.k("Add condition"),"advancedFilter",A.k("Advanced filter"),"advancedFilterActiveEdit",A.k("Advanced filter active - edit"),"advancedFilterDescription",A.k("All conditions must match (AND). Column filters are disabled while this is active."),"all",A.k("All"),"allRowsValid",A.k("All rows valid"),"allRowsValidBody",A.k("Every cell passes the type rules, unique constraints and column validators."),"appendNewRow",A.k("Append a new row"),"applyFilter",A.k("Apply filter"),"cancel",A.k("Cancel"),"cancelEditing",A.k("Cancel editing"),"cellError",B.bgL(),"checked",A.k("Checked"),"clear",A.k("Clear"),"clearAll",A.k("Clear all"),"clearAllFilters",A.k("Clear all filters"),"clearCell",A.k("Clear the cell"),"clearSort",A.k("Clear sort"),"clipboardInvalidJson",A.k("Clipboard is not valid JSON"),"columnInvalidValue",B.bgM(),"columnIsRequired",B.bgX(),"columnMustBeUnique",B.bh7(),"columnMustBeUniqueDuplicate",B.bhd(),"commitAndMove",A.k("Commit & move"),"copiedRowsCsv",B.bhe(),"copiedRowsJson",B.bhf(),"copyAsJson",A.k("Copy as JSON"),"copyJson",A.k("Copy JSON"),"copySelectionAsJson",A.k("Copy selection as JSON"),"cutPasteValidated",A.k("Cut / paste (validated)"),"delete",A.k("Delete"),"deleteRow",A.k("Delete row"),"deleteRowBody",B.bhg(),"deleteRowTitle",A.k("Delete row?"),"done",A.k("Done"),"duplicateRow",A.k("Duplicate row"),"duplicateRowFillDown",A.k("Duplicate row \xb7 fill down"),"edit",A.k("Edit"),"editOrOpenSelect",A.k("Edit, or open a select"),"editableStatusHint",B.bhh(),"expandCollapseHint",A.k(" \xb7 \u2318\u21e7\u2193 expand \xb7 \u2318\u21e7\u2191 collapse"),"expectsDate",B.bhi(),"expectsHexColor",B.bgN(),"expectsNumber",B.bgO(),"expectsTime",B.bgP(),"expectsTrueFalse",B.bgQ(),"fillRightAcrossRange",A.k("Fill right across the range"),"filledCells",B.bgR(),"filterHint",A.k("Filter..."),"filterRows",A.k("Filter rows"),"firstLastCell",A.k("First / last cell"),"firstLastColumn",A.k("First / last column"),"groupBy",A.k("Group by"),"groupByThisColumn",A.k("Group by this column"),"groupedBy",A.k("GROUPED BY"),"hideColumn",A.k("Hide column"),"insertRowAbove",A.k("Insert row above"),"insertRowAfter",A.k("Insert row after"),"insertRowBefore",A.k("Insert row before"),"insertRowBelow",A.k("Insert row below"),"isReadOnly",B.bgS(),"isRequired",B.bgT(),"issueCount",B.bgU(),"keyboardShortcuts",A.k("Keyboard shortcuts"),"loadMore",A.k("Load more"),"loading",A.k("Loading..."),"manageColumns",A.k("Manage columns"),"manageColumnsDescription",A.k("Drag to reorder \xb7 toggle visibility \xb7 pin to an edge"),"monthApr",A.k("Apr"),"monthAug",A.k("Aug"),"monthDec",A.k("Dec"),"monthFeb",A.k("Feb"),"monthJan",A.k("Jan"),"monthJul",A.k("Jul"),"monthJun",A.k("Jun"),"monthMar",A.k("Mar"),"monthMay",A.k("May"),"monthNov",A.k("Nov"),"monthOct",A.k("Oct"),"monthSep",A.k("Sep"),"moveBetweenCells",A.k("Move between cells"),"moveRowDown",A.k("Move row down"),"moveRowUp",A.k("Move row up"),"mustBeDate",B.bgV(),"mustBeHexColor",B.bgW(),"mustBeNumber",B.bgY(),"mustBeOneOf",B.bgZ(),"mustBeTime",B.bh_(),"navigate",A.k("Navigate"),"nextPreviousCell",A.k("Next / previous cell"),"no",A.k("No"),"noRows",A.k("No rows"),"opBetween",A.k("between"),"opContains",A.k("contains"),"opEndsWith",A.k("ends with"),"opEquals",A.k("equals"),"opGreaterOrEqual",A.k(">= at least"),"opGreaterThan",A.k("> greater"),"opIsEmpty",A.k("is empty"),"opIsNotEmpty",A.k("is not empty"),"opLessOrEqual",A.k("<= at most"),"opLessThan",A.k("< less"),"opNotEquals",A.k("not equals"),"opStartsWith",A.k("starts with"),"overwriteCell",A.k("Overwrite the cell"),"pageRange",B.bh0(),"pageRangeEmpty",A.k("0 of 0"),"pasteEditableOnly",A.k("Paste is only allowed in Editable mode"),"pasted",A.k("Pasted"),"pastedBlockTooWide",B.bh1(),"pin",A.k("Pin"),"pinLeft",A.k("Pin left"),"pinRight",A.k("Pin right"),"readableStatusHint",B.bh2(),"removeFromGrouping",A.k("Remove from grouping"),"reset",A.k("Reset"),"revertCell",A.k("Revert cell"),"revertRow",A.k("Revert row"),"revertRowRemoveAdded",A.k("Revert row (remove added)"),"rowCount",B.bh3(),"rowError",B.bh4(),"rowIsNotObject",B.bh5(),"rowNumber",B.bh6(),"rowOptions",A.k("Row options"),"rowsAndClipboard",A.k("Rows & clipboard"),"selectedCount",B.bh8(),"selectionStats",B.bh9(),"shortcuts",A.k("Shortcuts"),"showColumn",A.k("Show column"),"shownOfColumns",B.bha(),"sortAscending",A.k("Sort ascending"),"sortDescending",A.k("Sort descending"),"thisCell",A.k("This cell"),"toHint",A.k("to"),"today",A.k("Today"),"totals",A.k("TOTALS"),"typeOrPickHint",A.k("Type or pick..."),"typeValueHint",A.k("Type a value..."),"unchecked",A.k("Unchecked"),"undoRedo",A.k("Undo / redo"),"unknownField",B.bhb(),"unpinned",A.k("Unpinned"),"validationIssueCount",B.bhc(),"valueHint",A.k("value"),"weekdayFri",A.k("Fr"),"weekdayMon",A.k("Mo"),"weekdaySat",A.k("Sa"),"weekdaySun",A.k("Su"),"weekdayThu",A.k("Th"),"weekdayTue",A.k("Tu"),"weekdayWed",A.k("We"),"yes",A.k("Yes")],y.g,y.a)},
SM:function SM(d){this.a=d}}
C=c[0]
A=c[7]
B=a.updateHolder(c[6],B)
B.SM.prototype={
gBI(){return"en"},
gws(){return this.a}}
var z=a.updateTypes(["j(@)","j(@,@)","j(@,@,@)","j(@,@,@,@,@)","aO<j,ev>(@)"]);(function installTearOffs(){var x=a.installStaticTearOff,w=a._static_1,v=a._static_2
x(B,"bgL",3,null,["$3"],["b59"],2,0)
w(B,"bgM","b5i",0)
w(B,"bgX","b5S",0)
w(B,"bh7","b6m",0)
v(B,"bhd","b6q",1)
w(B,"bhe","b6u",0)
v(B,"bhf","b6y",1)
v(B,"bhg","b6C",1)
w(B,"bhh","b6G",0)
v(B,"bhi","b6K",1)
v(B,"bgN","b5e",1)
v(B,"bgO","b5j",1)
v(B,"bgP","b5n",1)
v(B,"bgQ","b5r",1)
v(B,"bgR","b5v",1)
w(B,"bgS","b5z",0)
w(B,"bgT","b5D",0)
v(B,"bgU","b5G",1)
w(B,"bgV","b5J",0)
w(B,"bgW","b5L",0)
w(B,"bgY","b5P",0)
v(B,"bgZ","b5T",1)
w(B,"bh_","b5V",0)
x(B,"bh0",3,null,["$3"],["b5X"],2,0)
w(B,"bh1","b5Z",0)
v(B,"bh2","b60",1)
v(B,"bh3","b62",1)
v(B,"bh4","b64",1)
w(B,"bh5","b66",0)
w(B,"bh6","b68",0)
w(B,"bh8","b6c",0)
x(B,"bh9",5,null,["$5"],["b6f"],3,0)
v(B,"bha","b6h",1)
w(B,"bhb","b6j",0)
v(B,"bhc","b6l",1)
w(B,"bgK","aTZ",4)})();(function inheritance(){var x=a.inherit
x(B.SM,A.is)})()
C.a5P(b.typeUniverse,JSON.parse('{"SM":{"is":[]}}'))
var y={a:C.an("ev"),g:C.an("j")};(function lazyInitializers(){var x=a.lazyFinal
x($,"bnw","b10",()=>new B.SM(B.aTZ(B.bgK())))})()};
(a=>{a["FmBdoj+aJyaMkdZ6+mdEQSJ2Dm0="]=a.current})($__dart_deferred_initializers__);