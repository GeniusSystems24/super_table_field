((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var C,A,B={
b5k(d,e,f){return"Cell "+C.f(d)+"\xd7"+C.f(e)+": "+C.f(f)},
b5t(d){return'"'+C.f(d)+'" has an invalid value'},
b62(d){return'"'+C.f(d)+'" is required'},
b6x(d){return'"'+C.f(d)+'" must be unique'},
b6B(d,e){return'"'+C.f(d)+'" must be unique - duplicates row '+C.f(e)},
b6F(d){return"Copied "+C.f(d)+" rows as CSV"},
b6J(d,e){return"Copied "+C.f(d)+" row"+C.f(e)+" as JSON"},
b6N(d,e){return"Row "+C.f(d)+" ("+C.f(e)+") will be permanently removed. This cannot be undone."},
b6R(d){return C.f(d)+" \xb7 \u21b5 edit \xb7 Tab next (new row at end) \xb7 \u2318\u21b5 insert after \xb7 \u2318C/V JSON \xb7 \u2318Z undo"},
b6V(d,e){return'"'+C.f(d)+'" expects YYYY-MM-DD - got "'+C.f(e)+'"'},
b5p(d,e){return'"'+C.f(d)+'" expects #RRGGBB - got "'+C.f(e)+'"'},
b5u(d,e){return'"'+C.f(d)+'" expects a number - got "'+C.f(e)+'"'},
b5y(d,e){return'"'+C.f(d)+'" expects HH:mm - got "'+C.f(e)+'"'},
b5C(d,e){return'"'+C.f(d)+'" expects true/false - got "'+C.f(e)+'"'},
b5G(d,e){return"Filled "+C.f(d)+" cell"+C.f(e)},
b5K(d){return'"'+C.f(d)+'" is read-only'},
b5O(d){return C.f(d)+" is required"},
b5R(d,e){return C.f(d)+" issue"+C.f(e)},
b5U(d){return C.f(d)+" must be a date (YYYY-MM-DD)"},
b5W(d){return C.f(d)+" must be a hex color (#RRGGBB)"},
b6_(d){return C.f(d)+" must be a number"},
b63(d,e){return'"'+C.f(d)+'" must be one of: '+C.f(e)},
b65(d){return C.f(d)+" must be a time (HH:mm)"},
b67(d,e,f){return C.f(d)+"-"+C.f(e)+" of "+C.f(f)},
b69(d){return"Pasted block is wider than the table (column "+C.f(d)+" doesn't exist)"},
b6b(d,e){return C.f(d)+" \xb7 \u21e7+arrows to range-select \xb7 right-click header for options \xb7 \u2318C copy"+C.f(e)},
b6d(d,e){return C.f(d)+" row"+C.f(e)},
b6f(d,e){return"Row "+C.f(d)+": "+C.f(e)},
b6h(d){return"Row "+C.f(d)+" is not an object"},
b6j(d){return"Row "+C.f(d)},
b6n(d){return C.f(d)+" selected"},
b6q(d,e,f,g,h){return"Sum "+C.f(d)+" \xb7 Avg "+C.f(e)+" \xb7 Min "+C.f(f)+" \xb7 Max "+C.f(g)+" \xb7 Count "+C.f(h)},
b6s(d,e){return C.f(d)+" of "+C.f(e)+" shown"},
b6u(d){return'Unknown field "'+C.f(d)+'" - not a column in this table'},
b6w(d,e){return C.f(d)+" validation issue"+C.f(e)},
aU9(d){return C.K(["addColumn",A.k("Add column"),"addCondition",A.k("Add condition"),"advancedFilter",A.k("Advanced filter"),"advancedFilterActiveEdit",A.k("Advanced filter active - edit"),"advancedFilterDescription",A.k("All conditions must match (AND). Column filters are disabled while this is active."),"all",A.k("All"),"allRowsValid",A.k("All rows valid"),"allRowsValidBody",A.k("Every cell passes the type rules, unique constraints and column validators."),"appendNewRow",A.k("Append a new row"),"applyFilter",A.k("Apply filter"),"cancel",A.k("Cancel"),"cancelEditing",A.k("Cancel editing"),"cellError",B.bgX(),"checked",A.k("Checked"),"clear",A.k("Clear"),"clearAll",A.k("Clear all"),"clearAllFilters",A.k("Clear all filters"),"clearCell",A.k("Clear the cell"),"clearSort",A.k("Clear sort"),"clipboardInvalidJson",A.k("Clipboard is not valid JSON"),"columnInvalidValue",B.bgY(),"columnIsRequired",B.bh8(),"columnMustBeUnique",B.bhj(),"columnMustBeUniqueDuplicate",B.bhp(),"commitAndMove",A.k("Commit & move"),"copiedRowsCsv",B.bhq(),"copiedRowsJson",B.bhr(),"copyAsJson",A.k("Copy as JSON"),"copyJson",A.k("Copy JSON"),"copySelectionAsJson",A.k("Copy selection as JSON"),"cutPasteValidated",A.k("Cut / paste (validated)"),"delete",A.k("Delete"),"deleteRow",A.k("Delete row"),"deleteRowBody",B.bhs(),"deleteRowTitle",A.k("Delete row?"),"done",A.k("Done"),"duplicateRow",A.k("Duplicate row"),"duplicateRowFillDown",A.k("Duplicate row \xb7 fill down"),"edit",A.k("Edit"),"editOrOpenSelect",A.k("Edit, or open a select"),"editableStatusHint",B.bht(),"expandCollapseHint",A.k(" \xb7 \u2318\u21e7\u2193 expand \xb7 \u2318\u21e7\u2191 collapse"),"expectsDate",B.bhu(),"expectsHexColor",B.bgZ(),"expectsNumber",B.bh_(),"expectsTime",B.bh0(),"expectsTrueFalse",B.bh1(),"fillRightAcrossRange",A.k("Fill right across the range"),"filledCells",B.bh2(),"filterHint",A.k("Filter..."),"filterRows",A.k("Filter rows"),"firstLastCell",A.k("First / last cell"),"firstLastColumn",A.k("First / last column"),"groupBy",A.k("Group by"),"groupByThisColumn",A.k("Group by this column"),"groupedBy",A.k("GROUPED BY"),"hideColumn",A.k("Hide column"),"insertRowAbove",A.k("Insert row above"),"insertRowAfter",A.k("Insert row after"),"insertRowBefore",A.k("Insert row before"),"insertRowBelow",A.k("Insert row below"),"isReadOnly",B.bh3(),"isRequired",B.bh4(),"issueCount",B.bh5(),"keyboardShortcuts",A.k("Keyboard shortcuts"),"loadMore",A.k("Load more"),"loading",A.k("Loading..."),"manageColumns",A.k("Manage columns"),"manageColumnsDescription",A.k("Drag to reorder \xb7 toggle visibility \xb7 pin to an edge"),"monthApr",A.k("Apr"),"monthAug",A.k("Aug"),"monthDec",A.k("Dec"),"monthFeb",A.k("Feb"),"monthJan",A.k("Jan"),"monthJul",A.k("Jul"),"monthJun",A.k("Jun"),"monthMar",A.k("Mar"),"monthMay",A.k("May"),"monthNov",A.k("Nov"),"monthOct",A.k("Oct"),"monthSep",A.k("Sep"),"moveBetweenCells",A.k("Move between cells"),"moveRowDown",A.k("Move row down"),"moveRowUp",A.k("Move row up"),"mustBeDate",B.bh6(),"mustBeHexColor",B.bh7(),"mustBeNumber",B.bh9(),"mustBeOneOf",B.bha(),"mustBeTime",B.bhb(),"navigate",A.k("Navigate"),"nextPreviousCell",A.k("Next / previous cell"),"no",A.k("No"),"noRows",A.k("No rows"),"opBetween",A.k("between"),"opContains",A.k("contains"),"opEndsWith",A.k("ends with"),"opEquals",A.k("equals"),"opGreaterOrEqual",A.k(">= at least"),"opGreaterThan",A.k("> greater"),"opIsEmpty",A.k("is empty"),"opIsNotEmpty",A.k("is not empty"),"opLessOrEqual",A.k("<= at most"),"opLessThan",A.k("< less"),"opNotEquals",A.k("not equals"),"opStartsWith",A.k("starts with"),"overwriteCell",A.k("Overwrite the cell"),"pageRange",B.bhc(),"pageRangeEmpty",A.k("0 of 0"),"pasteEditableOnly",A.k("Paste is only allowed in Editable mode"),"pasted",A.k("Pasted"),"pastedBlockTooWide",B.bhd(),"pin",A.k("Pin"),"pinLeft",A.k("Pin start"),"pinRight",A.k("Pin end"),"readableStatusHint",B.bhe(),"removeFromGrouping",A.k("Remove from grouping"),"reset",A.k("Reset"),"revertCell",A.k("Revert cell"),"revertRow",A.k("Revert row"),"revertRowRemoveAdded",A.k("Revert row (remove added)"),"rowCount",B.bhf(),"rowError",B.bhg(),"rowIsNotObject",B.bhh(),"rowNumber",B.bhi(),"rowOptions",A.k("Row options"),"rowsAndClipboard",A.k("Rows & clipboard"),"selectedCount",B.bhk(),"selectionStats",B.bhl(),"shortcuts",A.k("Shortcuts"),"showColumn",A.k("Show column"),"shownOfColumns",B.bhm(),"sortAscending",A.k("Sort ascending"),"sortDescending",A.k("Sort descending"),"thisCell",A.k("This cell"),"toHint",A.k("to"),"today",A.k("Today"),"totals",A.k("TOTALS"),"typeOrPickHint",A.k("Type or pick..."),"typeValueHint",A.k("Type a value..."),"unchecked",A.k("Unchecked"),"undoRedo",A.k("Undo / redo"),"unknownField",B.bhn(),"unpinned",A.k("Unpinned"),"validationIssueCount",B.bho(),"valueHint",A.k("value"),"weekdayFri",A.k("Fr"),"weekdayMon",A.k("Mo"),"weekdaySat",A.k("Sa"),"weekdaySun",A.k("Su"),"weekdayThu",A.k("Th"),"weekdayTue",A.k("Tu"),"weekdayWed",A.k("We"),"yes",A.k("Yes")],y.g,y.a)},
SU:function SU(d){this.a=d}}
C=c[0]
A=c[7]
B=a.updateHolder(c[6],B)
B.SU.prototype={
gBO(){return"en"},
gwt(){return this.a}}
var z=a.updateTypes(["j(@)","j(@,@)","j(@,@,@)","j(@,@,@,@,@)","aO<j,ez>(@)"]);(function installTearOffs(){var x=a.installStaticTearOff,w=a._static_1,v=a._static_2
x(B,"bgX",3,null,["$3"],["b5k"],2,0)
w(B,"bgY","b5t",0)
w(B,"bh8","b62",0)
w(B,"bhj","b6x",0)
v(B,"bhp","b6B",1)
w(B,"bhq","b6F",0)
v(B,"bhr","b6J",1)
v(B,"bhs","b6N",1)
w(B,"bht","b6R",0)
v(B,"bhu","b6V",1)
v(B,"bgZ","b5p",1)
v(B,"bh_","b5u",1)
v(B,"bh0","b5y",1)
v(B,"bh1","b5C",1)
v(B,"bh2","b5G",1)
w(B,"bh3","b5K",0)
w(B,"bh4","b5O",0)
v(B,"bh5","b5R",1)
w(B,"bh6","b5U",0)
w(B,"bh7","b5W",0)
w(B,"bh9","b6_",0)
v(B,"bha","b63",1)
w(B,"bhb","b65",0)
x(B,"bhc",3,null,["$3"],["b67"],2,0)
w(B,"bhd","b69",0)
v(B,"bhe","b6b",1)
v(B,"bhf","b6d",1)
v(B,"bhg","b6f",1)
w(B,"bhh","b6h",0)
w(B,"bhi","b6j",0)
w(B,"bhk","b6n",0)
x(B,"bhl",5,null,["$5"],["b6q"],3,0)
v(B,"bhm","b6s",1)
w(B,"bhn","b6u",0)
v(B,"bho","b6w",1)
w(B,"bgW","aU9",4)})();(function inheritance(){var x=a.inherit
x(B.SU,A.iu)})()
C.a5Z(b.typeUniverse,JSON.parse('{"SU":{"iu":[]}}'))
var y={a:C.aq("ez"),g:C.aq("j")};(function lazyInitializers(){var x=a.lazyFinal
x($,"bnK","b1b",()=>new B.SU(B.aU9(B.bgW())))})()};
(a=>{a["qzUBlwCW+3+BuxX8ui3zYa3wTf8="]=a.current})($__dart_deferred_initializers__);