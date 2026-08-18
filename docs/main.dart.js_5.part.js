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
aU_(d){return C.M(["addColumn",A.k("Add column"),"addCondition",A.k("Add condition"),"advancedFilter",A.k("Advanced filter"),"advancedFilterActiveEdit",A.k("Advanced filter active - edit"),"advancedFilterDescription",A.k("All conditions must match (AND). Column filters are disabled while this is active."),"all",A.k("All"),"allRowsValid",A.k("All rows valid"),"allRowsValidBody",A.k("Every cell passes the type rules, unique constraints and column validators."),"appendNewRow",A.k("Append a new row"),"applyFilter",A.k("Apply filter"),"cancel",A.k("Cancel"),"cancelEditing",A.k("Cancel editing"),"cellError",B.bgM(),"checked",A.k("Checked"),"clear",A.k("Clear"),"clearAll",A.k("Clear all"),"clearAllFilters",A.k("Clear all filters"),"clearCell",A.k("Clear the cell"),"clearSort",A.k("Clear sort"),"clipboardInvalidJson",A.k("Clipboard is not valid JSON"),"columnInvalidValue",B.bgN(),"columnIsRequired",B.bgY(),"columnMustBeUnique",B.bh8(),"columnMustBeUniqueDuplicate",B.bhe(),"commitAndMove",A.k("Commit & move"),"copiedRowsCsv",B.bhf(),"copiedRowsJson",B.bhg(),"copyAsJson",A.k("Copy as JSON"),"copyJson",A.k("Copy JSON"),"copySelectionAsJson",A.k("Copy selection as JSON"),"cutPasteValidated",A.k("Cut / paste (validated)"),"delete",A.k("Delete"),"deleteRow",A.k("Delete row"),"deleteRowBody",B.bhh(),"deleteRowTitle",A.k("Delete row?"),"done",A.k("Done"),"duplicateRow",A.k("Duplicate row"),"duplicateRowFillDown",A.k("Duplicate row \xb7 fill down"),"edit",A.k("Edit"),"editOrOpenSelect",A.k("Edit, or open a select"),"editableStatusHint",B.bhi(),"expandCollapseHint",A.k(" \xb7 \u2318\u21e7\u2193 expand \xb7 \u2318\u21e7\u2191 collapse"),"expectsDate",B.bhj(),"expectsHexColor",B.bgO(),"expectsNumber",B.bgP(),"expectsTime",B.bgQ(),"expectsTrueFalse",B.bgR(),"fillRightAcrossRange",A.k("Fill right across the range"),"filledCells",B.bgS(),"filterHint",A.k("Filter..."),"filterRows",A.k("Filter rows"),"firstLastCell",A.k("First / last cell"),"firstLastColumn",A.k("First / last column"),"groupBy",A.k("Group by"),"groupByThisColumn",A.k("Group by this column"),"groupedBy",A.k("GROUPED BY"),"hideColumn",A.k("Hide column"),"insertRowAbove",A.k("Insert row above"),"insertRowAfter",A.k("Insert row after"),"insertRowBefore",A.k("Insert row before"),"insertRowBelow",A.k("Insert row below"),"isReadOnly",B.bgT(),"isRequired",B.bgU(),"issueCount",B.bgV(),"keyboardShortcuts",A.k("Keyboard shortcuts"),"loadMore",A.k("Load more"),"loading",A.k("Loading..."),"manageColumns",A.k("Manage columns"),"manageColumnsDescription",A.k("Drag to reorder \xb7 toggle visibility \xb7 pin to an edge"),"monthApr",A.k("Apr"),"monthAug",A.k("Aug"),"monthDec",A.k("Dec"),"monthFeb",A.k("Feb"),"monthJan",A.k("Jan"),"monthJul",A.k("Jul"),"monthJun",A.k("Jun"),"monthMar",A.k("Mar"),"monthMay",A.k("May"),"monthNov",A.k("Nov"),"monthOct",A.k("Oct"),"monthSep",A.k("Sep"),"moveBetweenCells",A.k("Move between cells"),"moveRowDown",A.k("Move row down"),"moveRowUp",A.k("Move row up"),"mustBeDate",B.bgW(),"mustBeHexColor",B.bgX(),"mustBeNumber",B.bgZ(),"mustBeOneOf",B.bh_(),"mustBeTime",B.bh0(),"navigate",A.k("Navigate"),"nextPreviousCell",A.k("Next / previous cell"),"no",A.k("No"),"noRows",A.k("No rows"),"opBetween",A.k("between"),"opContains",A.k("contains"),"opEndsWith",A.k("ends with"),"opEquals",A.k("equals"),"opGreaterOrEqual",A.k(">= at least"),"opGreaterThan",A.k("> greater"),"opIsEmpty",A.k("is empty"),"opIsNotEmpty",A.k("is not empty"),"opLessOrEqual",A.k("<= at most"),"opLessThan",A.k("< less"),"opNotEquals",A.k("not equals"),"opStartsWith",A.k("starts with"),"overwriteCell",A.k("Overwrite the cell"),"pageRange",B.bh1(),"pageRangeEmpty",A.k("0 of 0"),"pasteEditableOnly",A.k("Paste is only allowed in Editable mode"),"pasted",A.k("Pasted"),"pastedBlockTooWide",B.bh2(),"pin",A.k("Pin"),"pinLeft",A.k("Pin start"),"pinRight",A.k("Pin end"),"readableStatusHint",B.bh3(),"removeFromGrouping",A.k("Remove from grouping"),"reset",A.k("Reset"),"revertCell",A.k("Revert cell"),"revertRow",A.k("Revert row"),"revertRowRemoveAdded",A.k("Revert row (remove added)"),"rowCount",B.bh4(),"rowError",B.bh5(),"rowIsNotObject",B.bh6(),"rowNumber",B.bh7(),"rowOptions",A.k("Row options"),"rowsAndClipboard",A.k("Rows & clipboard"),"selectedCount",B.bh9(),"selectionStats",B.bha(),"shortcuts",A.k("Shortcuts"),"showColumn",A.k("Show column"),"shownOfColumns",B.bhb(),"sortAscending",A.k("Sort ascending"),"sortDescending",A.k("Sort descending"),"thisCell",A.k("This cell"),"toHint",A.k("to"),"today",A.k("Today"),"totals",A.k("TOTALS"),"typeOrPickHint",A.k("Type or pick..."),"typeValueHint",A.k("Type a value..."),"unchecked",A.k("Unchecked"),"undoRedo",A.k("Undo / redo"),"unknownField",B.bhc(),"unpinned",A.k("Unpinned"),"validationIssueCount",B.bhd(),"valueHint",A.k("value"),"weekdayFri",A.k("Fr"),"weekdayMon",A.k("Mo"),"weekdaySat",A.k("Sa"),"weekdaySun",A.k("Su"),"weekdayThu",A.k("Th"),"weekdayTue",A.k("Tu"),"weekdayWed",A.k("We"),"yes",A.k("Yes")],y.g,y.a)},
SR:function SR(d){this.a=d}}
C=c[0]
A=c[7]
B=a.updateHolder(c[6],B)
B.SR.prototype={
gBM(){return"en"},
gwr(){return this.a}}
var z=a.updateTypes(["j(@)","j(@,@)","j(@,@,@)","j(@,@,@,@,@)","aO<j,ew>(@)"]);(function installTearOffs(){var x=a.installStaticTearOff,w=a._static_1,v=a._static_2
x(B,"bgM",3,null,["$3"],["b59"],2,0)
w(B,"bgN","b5i",0)
w(B,"bgY","b5S",0)
w(B,"bh8","b6m",0)
v(B,"bhe","b6q",1)
w(B,"bhf","b6u",0)
v(B,"bhg","b6y",1)
v(B,"bhh","b6C",1)
w(B,"bhi","b6G",0)
v(B,"bhj","b6K",1)
v(B,"bgO","b5e",1)
v(B,"bgP","b5j",1)
v(B,"bgQ","b5n",1)
v(B,"bgR","b5r",1)
v(B,"bgS","b5v",1)
w(B,"bgT","b5z",0)
w(B,"bgU","b5D",0)
v(B,"bgV","b5G",1)
w(B,"bgW","b5J",0)
w(B,"bgX","b5L",0)
w(B,"bgZ","b5P",0)
v(B,"bh_","b5T",1)
w(B,"bh0","b5V",0)
x(B,"bh1",3,null,["$3"],["b5X"],2,0)
w(B,"bh2","b5Z",0)
v(B,"bh3","b60",1)
v(B,"bh4","b62",1)
v(B,"bh5","b64",1)
w(B,"bh6","b66",0)
w(B,"bh7","b68",0)
w(B,"bh9","b6c",0)
x(B,"bha",5,null,["$5"],["b6f"],3,0)
v(B,"bhb","b6h",1)
w(B,"bhc","b6j",0)
v(B,"bhd","b6l",1)
w(B,"bgL","aU_",4)})();(function inheritance(){var x=a.inherit
x(B.SR,A.it)})()
C.a5W(b.typeUniverse,JSON.parse('{"SR":{"it":[]}}'))
var y={a:C.ao("ew"),g:C.ao("j")};(function lazyInitializers(){var x=a.lazyFinal
x($,"bnz","b10",()=>new B.SR(B.aU_(B.bgL())))})()};
(a=>{a["qbPsCqehF4cuzLWsBhUqwEbFkDk="]=a.current})($__dart_deferred_initializers__);