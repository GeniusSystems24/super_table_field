((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var C,A,B={
b6F(d,e,f){return"Cell "+C.f(d)+"\xd7"+C.f(e)+": "+C.f(f)},
b6O(d){return'"'+C.f(d)+'" has an invalid value'},
b7n(d){return'"'+C.f(d)+'" is required'},
b7S(d){return'"'+C.f(d)+'" must be unique'},
b7W(d,e){return'"'+C.f(d)+'" must be unique - duplicates row '+C.f(e)},
b8_(d){return"Copied "+C.f(d)+" rows as CSV"},
b83(d,e){return"Copied "+C.f(d)+" row"+C.f(e)+" as JSON"},
b87(d,e){return"Row "+C.f(d)+" ("+C.f(e)+") will be permanently removed. This cannot be undone."},
b8b(d){return C.f(d)+" \xb7 \u21b5 edit \xb7 Tab next (new row at end) \xb7 \u2318\u21b5 insert after \xb7 \u2318C/V JSON \xb7 \u2318Z undo"},
b8f(d,e){return'"'+C.f(d)+'" expects YYYY-MM-DD - got "'+C.f(e)+'"'},
b6K(d,e){return'"'+C.f(d)+'" expects #RRGGBB - got "'+C.f(e)+'"'},
b6P(d,e){return'"'+C.f(d)+'" expects a number - got "'+C.f(e)+'"'},
b6T(d,e){return'"'+C.f(d)+'" expects HH:mm - got "'+C.f(e)+'"'},
b6X(d,e){return'"'+C.f(d)+'" expects true/false - got "'+C.f(e)+'"'},
b70(d,e){return"Filled "+C.f(d)+" cell"+C.f(e)},
b74(d){return'"'+C.f(d)+'" is read-only'},
b78(d){return C.f(d)+" is required"},
b7b(d,e){return C.f(d)+" issue"+C.f(e)},
b7e(d){return C.f(d)+" must be a date (YYYY-MM-DD)"},
b7g(d){return C.f(d)+" must be a hex color (#RRGGBB)"},
b7k(d){return C.f(d)+" must be a number"},
b7o(d,e){return'"'+C.f(d)+'" must be one of: '+C.f(e)},
b7q(d){return C.f(d)+" must be a time (HH:mm)"},
b7s(d,e,f){return C.f(d)+"-"+C.f(e)+" of "+C.f(f)},
b7u(d){return"Pasted block is wider than the table (column "+C.f(d)+" doesn't exist)"},
b7w(d,e){return C.f(d)+" \xb7 \u21e7+arrows to range-select \xb7 right-click header for options \xb7 \u2318C copy"+C.f(e)},
b7y(d,e){return C.f(d)+" row"+C.f(e)},
b7A(d,e){return"Row "+C.f(d)+": "+C.f(e)},
b7C(d){return"Row "+C.f(d)+" is not an object"},
b7E(d){return"Row "+C.f(d)},
b7I(d){return C.f(d)+" selected"},
b7L(d,e,f,g,h){return"Sum "+C.f(d)+" \xb7 Avg "+C.f(e)+" \xb7 Min "+C.f(f)+" \xb7 Max "+C.f(g)+" \xb7 Count "+C.f(h)},
b7N(d,e){return C.f(d)+" of "+C.f(e)+" shown"},
b7P(d){return'Unknown field "'+C.f(d)+'" - not a column in this table'},
b7R(d,e){return C.f(d)+" validation issue"+C.f(e)},
aVo(d){return C.J(["addColumn",A.k("Add column"),"addCondition",A.k("Add condition"),"advancedFilter",A.k("Advanced filter"),"advancedFilterActiveEdit",A.k("Advanced filter active - edit"),"advancedFilterDescription",A.k("All conditions must match (AND). Column filters are disabled while this is active."),"all",A.k("All"),"allRowsValid",A.k("All rows valid"),"allRowsValidBody",A.k("Every cell passes the type rules, unique constraints and column validators."),"appendNewRow",A.k("Append a new row"),"applyFilter",A.k("Apply filter"),"cancel",A.k("Cancel"),"cancelEditing",A.k("Cancel editing"),"cellError",B.bim(),"checked",A.k("Checked"),"clear",A.k("Clear"),"clearAll",A.k("Clear all"),"clearAllFilters",A.k("Clear all filters"),"clearCell",A.k("Clear the cell"),"clearSort",A.k("Clear sort"),"clipboardInvalidJson",A.k("Clipboard is not valid JSON"),"columnInvalidValue",B.bin(),"columnIsRequired",B.biy(),"columnMustBeUnique",B.biJ(),"columnMustBeUniqueDuplicate",B.biP(),"commitAndMove",A.k("Commit & move"),"copiedRowsCsv",B.biQ(),"copiedRowsJson",B.biR(),"copyAsJson",A.k("Copy as JSON"),"copyJson",A.k("Copy JSON"),"copySelectionAsJson",A.k("Copy selection as JSON"),"cutPasteValidated",A.k("Cut / paste (validated)"),"delete",A.k("Delete"),"deleteRow",A.k("Delete row"),"deleteRowBody",B.biS(),"deleteRowTitle",A.k("Delete row?"),"done",A.k("Done"),"duplicateRow",A.k("Duplicate row"),"duplicateRowFillDown",A.k("Duplicate row \xb7 fill down"),"edit",A.k("Edit"),"editOrOpenSelect",A.k("Edit, or open a select"),"editableStatusHint",B.biT(),"expandCollapseHint",A.k(" \xb7 \u2318\u21e7\u2193 expand \xb7 \u2318\u21e7\u2191 collapse"),"expectsDate",B.biU(),"expectsHexColor",B.bio(),"expectsNumber",B.bip(),"expectsTime",B.biq(),"expectsTrueFalse",B.bir(),"fillRightAcrossRange",A.k("Fill right across the range"),"filledCells",B.bis(),"filterHint",A.k("Filter..."),"filterRows",A.k("Filter rows"),"firstLastCell",A.k("First / last cell"),"firstLastColumn",A.k("First / last column"),"groupBy",A.k("Group by"),"groupByThisColumn",A.k("Group by this column"),"groupedBy",A.k("GROUPED BY"),"hideColumn",A.k("Hide column"),"insertRowAbove",A.k("Insert row above"),"insertRowAfter",A.k("Insert row after"),"insertRowBefore",A.k("Insert row before"),"insertRowBelow",A.k("Insert row below"),"isReadOnly",B.bit(),"isRequired",B.biu(),"issueCount",B.biv(),"keyboardShortcuts",A.k("Keyboard shortcuts"),"loadMore",A.k("Load more"),"loading",A.k("Loading..."),"manageColumns",A.k("Manage columns"),"manageColumnsDescription",A.k("Drag to reorder \xb7 toggle visibility \xb7 pin to an edge"),"monthApr",A.k("Apr"),"monthAug",A.k("Aug"),"monthDec",A.k("Dec"),"monthFeb",A.k("Feb"),"monthJan",A.k("Jan"),"monthJul",A.k("Jul"),"monthJun",A.k("Jun"),"monthMar",A.k("Mar"),"monthMay",A.k("May"),"monthNov",A.k("Nov"),"monthOct",A.k("Oct"),"monthSep",A.k("Sep"),"moveBetweenCells",A.k("Move between cells"),"moveRowDown",A.k("Move row down"),"moveRowUp",A.k("Move row up"),"mustBeDate",B.biw(),"mustBeHexColor",B.bix(),"mustBeNumber",B.biz(),"mustBeOneOf",B.biA(),"mustBeTime",B.biB(),"navigate",A.k("Navigate"),"nextPreviousCell",A.k("Next / previous cell"),"no",A.k("No"),"noRows",A.k("No rows"),"opBetween",A.k("between"),"opContains",A.k("contains"),"opEndsWith",A.k("ends with"),"opEquals",A.k("equals"),"opGreaterOrEqual",A.k(">= at least"),"opGreaterThan",A.k("> greater"),"opIsEmpty",A.k("is empty"),"opIsNotEmpty",A.k("is not empty"),"opLessOrEqual",A.k("<= at most"),"opLessThan",A.k("< less"),"opNotEquals",A.k("not equals"),"opStartsWith",A.k("starts with"),"overwriteCell",A.k("Overwrite the cell"),"pageRange",B.biC(),"pageRangeEmpty",A.k("0 of 0"),"pasteEditableOnly",A.k("Paste is only allowed in Editable mode"),"pasted",A.k("Pasted"),"pastedBlockTooWide",B.biD(),"pin",A.k("Pin"),"pinLeft",A.k("Pin start"),"pinRight",A.k("Pin end"),"readableStatusHint",B.biE(),"removeFromGrouping",A.k("Remove from grouping"),"reset",A.k("Reset"),"revertCell",A.k("Revert cell"),"revertRow",A.k("Revert row"),"revertRowRemoveAdded",A.k("Revert row (remove added)"),"rowCount",B.biF(),"rowError",B.biG(),"rowIsNotObject",B.biH(),"rowNumber",B.biI(),"rowOptions",A.k("Row options"),"rowsAndClipboard",A.k("Rows & clipboard"),"selectedCount",B.biK(),"selectionStats",B.biL(),"shortcuts",A.k("Shortcuts"),"showColumn",A.k("Show column"),"shownOfColumns",B.biM(),"sortAscending",A.k("Sort ascending"),"sortDescending",A.k("Sort descending"),"thisCell",A.k("This cell"),"toHint",A.k("to"),"today",A.k("Today"),"totals",A.k("TOTALS"),"typeOrPickHint",A.k("Type or pick..."),"typeValueHint",A.k("Type a value..."),"unchecked",A.k("Unchecked"),"undoRedo",A.k("Undo / redo"),"unknownField",B.biN(),"unpinned",A.k("Unpinned"),"validationIssueCount",B.biO(),"valueHint",A.k("value"),"weekdayFri",A.k("Fr"),"weekdayMon",A.k("Mo"),"weekdaySat",A.k("Sa"),"weekdaySun",A.k("Su"),"weekdayThu",A.k("Th"),"weekdayTue",A.k("Tu"),"weekdayWed",A.k("We"),"yes",A.k("Yes")],y.g,y.a)},
Tq:function Tq(d){this.a=d}}
C=c[0]
A=c[7]
B=a.updateHolder(c[6],B)
B.Tq.prototype={
gBY(){return"en"},
gwD(){return this.a}}
var z=a.updateTypes(["j(@)","j(@,@)","j(@,@,@)","j(@,@,@,@,@)","aN<j,eI>(@)"]);(function installTearOffs(){var x=a.installStaticTearOff,w=a._static_1,v=a._static_2
x(B,"bim",3,null,["$3"],["b6F"],2,0)
w(B,"bin","b6O",0)
w(B,"biy","b7n",0)
w(B,"biJ","b7S",0)
v(B,"biP","b7W",1)
w(B,"biQ","b8_",0)
v(B,"biR","b83",1)
v(B,"biS","b87",1)
w(B,"biT","b8b",0)
v(B,"biU","b8f",1)
v(B,"bio","b6K",1)
v(B,"bip","b6P",1)
v(B,"biq","b6T",1)
v(B,"bir","b6X",1)
v(B,"bis","b70",1)
w(B,"bit","b74",0)
w(B,"biu","b78",0)
v(B,"biv","b7b",1)
w(B,"biw","b7e",0)
w(B,"bix","b7g",0)
w(B,"biz","b7k",0)
v(B,"biA","b7o",1)
w(B,"biB","b7q",0)
x(B,"biC",3,null,["$3"],["b7s"],2,0)
w(B,"biD","b7u",0)
v(B,"biE","b7w",1)
v(B,"biF","b7y",1)
v(B,"biG","b7A",1)
w(B,"biH","b7C",0)
w(B,"biI","b7E",0)
w(B,"biK","b7I",0)
x(B,"biL",5,null,["$5"],["b7L"],3,0)
v(B,"biM","b7N",1)
w(B,"biN","b7P",0)
v(B,"biO","b7R",1)
w(B,"bil","aVo",4)})();(function inheritance(){var x=a.inherit
x(B.Tq,A.iE)})()
C.a6A(b.typeUniverse,JSON.parse('{"Tq":{"iE":[]}}'))
var y={a:C.ao("eI"),g:C.ao("j")};(function lazyInitializers(){var x=a.lazyFinal
x($,"bpb","b2v",()=>new B.Tq(B.aVo(B.bil())))})()};
(a=>{a["L9SEe0xnZYaSVZ0y/hEy+1/Dbzg="]=a.current})($__dart_deferred_initializers__);