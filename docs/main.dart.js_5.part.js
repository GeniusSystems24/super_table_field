((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var C,A,B={
b6l(d,e,f){return"Cell "+C.f(d)+"\xd7"+C.f(e)+": "+C.f(f)},
b6u(d){return'"'+C.f(d)+'" has an invalid value'},
b73(d){return'"'+C.f(d)+'" is required'},
b7y(d){return'"'+C.f(d)+'" must be unique'},
b7C(d,e){return'"'+C.f(d)+'" must be unique - duplicates row '+C.f(e)},
b7G(d){return"Copied "+C.f(d)+" rows as CSV"},
b7K(d,e){return"Copied "+C.f(d)+" row"+C.f(e)+" as JSON"},
b7O(d,e){return"Row "+C.f(d)+" ("+C.f(e)+") will be permanently removed. This cannot be undone."},
b7S(d){return C.f(d)+" \xb7 \u21b5 edit \xb7 Tab next (new row at end) \xb7 \u2318\u21b5 insert after \xb7 \u2318C/V JSON \xb7 \u2318Z undo"},
b7W(d,e){return'"'+C.f(d)+'" expects YYYY-MM-DD - got "'+C.f(e)+'"'},
b6q(d,e){return'"'+C.f(d)+'" expects #RRGGBB - got "'+C.f(e)+'"'},
b6v(d,e){return'"'+C.f(d)+'" expects a number - got "'+C.f(e)+'"'},
b6z(d,e){return'"'+C.f(d)+'" expects HH:mm - got "'+C.f(e)+'"'},
b6D(d,e){return'"'+C.f(d)+'" expects true/false - got "'+C.f(e)+'"'},
b6H(d,e){return"Filled "+C.f(d)+" cell"+C.f(e)},
b6L(d){return'"'+C.f(d)+'" is read-only'},
b6P(d){return C.f(d)+" is required"},
b6S(d,e){return C.f(d)+" issue"+C.f(e)},
b6V(d){return C.f(d)+" must be a date (YYYY-MM-DD)"},
b6X(d){return C.f(d)+" must be a hex color (#RRGGBB)"},
b70(d){return C.f(d)+" must be a number"},
b74(d,e){return'"'+C.f(d)+'" must be one of: '+C.f(e)},
b76(d){return C.f(d)+" must be a time (HH:mm)"},
b78(d,e,f){return C.f(d)+"-"+C.f(e)+" of "+C.f(f)},
b7a(d){return"Pasted block is wider than the table (column "+C.f(d)+" doesn't exist)"},
b7c(d,e){return C.f(d)+" \xb7 \u21e7+arrows to range-select \xb7 right-click header for options \xb7 \u2318C copy"+C.f(e)},
b7e(d,e){return C.f(d)+" row"+C.f(e)},
b7g(d,e){return"Row "+C.f(d)+": "+C.f(e)},
b7i(d){return"Row "+C.f(d)+" is not an object"},
b7k(d){return"Row "+C.f(d)},
b7o(d){return C.f(d)+" selected"},
b7r(d,e,f,g,h){return"Sum "+C.f(d)+" \xb7 Avg "+C.f(e)+" \xb7 Min "+C.f(f)+" \xb7 Max "+C.f(g)+" \xb7 Count "+C.f(h)},
b7t(d,e){return C.f(d)+" of "+C.f(e)+" shown"},
b7v(d){return'Unknown field "'+C.f(d)+'" - not a column in this table'},
b7x(d,e){return C.f(d)+" validation issue"+C.f(e)},
aV2(d){return C.J(["addColumn",A.k("Add column"),"addCondition",A.k("Add condition"),"advancedFilter",A.k("Advanced filter"),"advancedFilterActiveEdit",A.k("Advanced filter active - edit"),"advancedFilterDescription",A.k("All conditions must match (AND). Column filters are disabled while this is active."),"all",A.k("All"),"allRowsValid",A.k("All rows valid"),"allRowsValidBody",A.k("Every cell passes the type rules, unique constraints and column validators."),"appendNewRow",A.k("Append a new row"),"applyFilter",A.k("Apply filter"),"cancel",A.k("Cancel"),"cancelEditing",A.k("Cancel editing"),"cellError",B.bhZ(),"checked",A.k("Checked"),"clear",A.k("Clear"),"clearAll",A.k("Clear all"),"clearAllFilters",A.k("Clear all filters"),"clearCell",A.k("Clear the cell"),"clearSort",A.k("Clear sort"),"clipboardInvalidJson",A.k("Clipboard is not valid JSON"),"columnInvalidValue",B.bi_(),"columnIsRequired",B.bia(),"columnMustBeUnique",B.bil(),"columnMustBeUniqueDuplicate",B.bir(),"commitAndMove",A.k("Commit & move"),"copiedRowsCsv",B.bis(),"copiedRowsJson",B.bit(),"copyAsJson",A.k("Copy as JSON"),"copyJson",A.k("Copy JSON"),"copySelectionAsJson",A.k("Copy selection as JSON"),"cutPasteValidated",A.k("Cut / paste (validated)"),"delete",A.k("Delete"),"deleteRow",A.k("Delete row"),"deleteRowBody",B.biu(),"deleteRowTitle",A.k("Delete row?"),"done",A.k("Done"),"duplicateRow",A.k("Duplicate row"),"duplicateRowFillDown",A.k("Duplicate row \xb7 fill down"),"edit",A.k("Edit"),"editOrOpenSelect",A.k("Edit, or open a select"),"editableStatusHint",B.biv(),"expandCollapseHint",A.k(" \xb7 \u2318\u21e7\u2193 expand \xb7 \u2318\u21e7\u2191 collapse"),"expectsDate",B.biw(),"expectsHexColor",B.bi0(),"expectsNumber",B.bi1(),"expectsTime",B.bi2(),"expectsTrueFalse",B.bi3(),"fillRightAcrossRange",A.k("Fill right across the range"),"filledCells",B.bi4(),"filterHint",A.k("Filter..."),"filterRows",A.k("Filter rows"),"firstLastCell",A.k("First / last cell"),"firstLastColumn",A.k("First / last column"),"groupBy",A.k("Group by"),"groupByThisColumn",A.k("Group by this column"),"groupedBy",A.k("GROUPED BY"),"hideColumn",A.k("Hide column"),"insertRowAbove",A.k("Insert row above"),"insertRowAfter",A.k("Insert row after"),"insertRowBefore",A.k("Insert row before"),"insertRowBelow",A.k("Insert row below"),"isReadOnly",B.bi5(),"isRequired",B.bi6(),"issueCount",B.bi7(),"keyboardShortcuts",A.k("Keyboard shortcuts"),"loadMore",A.k("Load more"),"loading",A.k("Loading..."),"manageColumns",A.k("Manage columns"),"manageColumnsDescription",A.k("Drag to reorder \xb7 toggle visibility \xb7 pin to an edge"),"monthApr",A.k("Apr"),"monthAug",A.k("Aug"),"monthDec",A.k("Dec"),"monthFeb",A.k("Feb"),"monthJan",A.k("Jan"),"monthJul",A.k("Jul"),"monthJun",A.k("Jun"),"monthMar",A.k("Mar"),"monthMay",A.k("May"),"monthNov",A.k("Nov"),"monthOct",A.k("Oct"),"monthSep",A.k("Sep"),"moveBetweenCells",A.k("Move between cells"),"moveRowDown",A.k("Move row down"),"moveRowUp",A.k("Move row up"),"mustBeDate",B.bi8(),"mustBeHexColor",B.bi9(),"mustBeNumber",B.bib(),"mustBeOneOf",B.bic(),"mustBeTime",B.bid(),"navigate",A.k("Navigate"),"nextPreviousCell",A.k("Next / previous cell"),"no",A.k("No"),"noRows",A.k("No rows"),"opBetween",A.k("between"),"opContains",A.k("contains"),"opEndsWith",A.k("ends with"),"opEquals",A.k("equals"),"opGreaterOrEqual",A.k(">= at least"),"opGreaterThan",A.k("> greater"),"opIsEmpty",A.k("is empty"),"opIsNotEmpty",A.k("is not empty"),"opLessOrEqual",A.k("<= at most"),"opLessThan",A.k("< less"),"opNotEquals",A.k("not equals"),"opStartsWith",A.k("starts with"),"overwriteCell",A.k("Overwrite the cell"),"pageRange",B.bie(),"pageRangeEmpty",A.k("0 of 0"),"pasteEditableOnly",A.k("Paste is only allowed in Editable mode"),"pasted",A.k("Pasted"),"pastedBlockTooWide",B.bif(),"pin",A.k("Pin"),"pinLeft",A.k("Pin start"),"pinRight",A.k("Pin end"),"readableStatusHint",B.big(),"removeFromGrouping",A.k("Remove from grouping"),"reset",A.k("Reset"),"revertCell",A.k("Revert cell"),"revertRow",A.k("Revert row"),"revertRowRemoveAdded",A.k("Revert row (remove added)"),"rowCount",B.bih(),"rowError",B.bii(),"rowIsNotObject",B.bij(),"rowNumber",B.bik(),"rowOptions",A.k("Row options"),"rowsAndClipboard",A.k("Rows & clipboard"),"selectedCount",B.bim(),"selectionStats",B.bin(),"shortcuts",A.k("Shortcuts"),"showColumn",A.k("Show column"),"shownOfColumns",B.bio(),"sortAscending",A.k("Sort ascending"),"sortDescending",A.k("Sort descending"),"thisCell",A.k("This cell"),"toHint",A.k("to"),"today",A.k("Today"),"totals",A.k("TOTALS"),"typeOrPickHint",A.k("Type or pick..."),"typeValueHint",A.k("Type a value..."),"unchecked",A.k("Unchecked"),"undoRedo",A.k("Undo / redo"),"unknownField",B.bip(),"unpinned",A.k("Unpinned"),"validationIssueCount",B.biq(),"valueHint",A.k("value"),"weekdayFri",A.k("Fr"),"weekdayMon",A.k("Mo"),"weekdaySat",A.k("Sa"),"weekdaySun",A.k("Su"),"weekdayThu",A.k("Th"),"weekdayTue",A.k("Tu"),"weekdayWed",A.k("We"),"yes",A.k("Yes")],y.g,y.a)},
Tb:function Tb(d){this.a=d}}
C=c[0]
A=c[7]
B=a.updateHolder(c[6],B)
B.Tb.prototype={
gBT(){return"en"},
gww(){return this.a}}
var z=a.updateTypes(["j(@)","j(@,@)","j(@,@,@)","j(@,@,@,@,@)","aN<j,eF>(@)"]);(function installTearOffs(){var x=a.installStaticTearOff,w=a._static_1,v=a._static_2
x(B,"bhZ",3,null,["$3"],["b6l"],2,0)
w(B,"bi_","b6u",0)
w(B,"bia","b73",0)
w(B,"bil","b7y",0)
v(B,"bir","b7C",1)
w(B,"bis","b7G",0)
v(B,"bit","b7K",1)
v(B,"biu","b7O",1)
w(B,"biv","b7S",0)
v(B,"biw","b7W",1)
v(B,"bi0","b6q",1)
v(B,"bi1","b6v",1)
v(B,"bi2","b6z",1)
v(B,"bi3","b6D",1)
v(B,"bi4","b6H",1)
w(B,"bi5","b6L",0)
w(B,"bi6","b6P",0)
v(B,"bi7","b6S",1)
w(B,"bi8","b6V",0)
w(B,"bi9","b6X",0)
w(B,"bib","b70",0)
v(B,"bic","b74",1)
w(B,"bid","b76",0)
x(B,"bie",3,null,["$3"],["b78"],2,0)
w(B,"bif","b7a",0)
v(B,"big","b7c",1)
v(B,"bih","b7e",1)
v(B,"bii","b7g",1)
w(B,"bij","b7i",0)
w(B,"bik","b7k",0)
w(B,"bim","b7o",0)
x(B,"bin",5,null,["$5"],["b7r"],3,0)
v(B,"bio","b7t",1)
w(B,"bip","b7v",0)
v(B,"biq","b7x",1)
w(B,"bhY","aV2",4)})();(function inheritance(){var x=a.inherit
x(B.Tb,A.iB)})()
C.a6l(b.typeUniverse,JSON.parse('{"Tb":{"iB":[]}}'))
var y={a:C.ap("eF"),g:C.ap("j")};(function lazyInitializers(){var x=a.lazyFinal
x($,"boO","b28",()=>new B.Tb(B.aV2(B.bhY())))})()};
(a=>{a["hAHYUNWlIOxhVwcJLJXVN2wXKcg="]=a.current})($__dart_deferred_initializers__);