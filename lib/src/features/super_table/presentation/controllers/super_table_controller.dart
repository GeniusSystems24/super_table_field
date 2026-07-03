// ============================================================
// features/super_table/presentation/controllers/super_table_controller.dart
// ------------------------------------------------------------
// The MVC controller for the unified SuperTable — generic over the row's
// backing type `R` (`SuperTableController<R>`). A thin View renders it and
// forwards events here. It owns:
//
//   • column resolution     — visibility ▸ pins ▸ user reorder ▸ widths
//   • the data pipeline      — search ▸ column/advanced filters ▸ sort ▸ group ▸ page
//   • selection              — cursor + anchor range, discrete cells, whole rows
//   • editing                — begin / commit / cancel, per-cell drafts, the
//                              column `onChange` + `validator` pipeline
//   • row ops                — add / insert (before/after focus) / duplicate / delete
//   • clipboard              — copy/cut as JSON, paste (validated JSON or TSV)
//   • history                — undo / redo snapshots (depth 200) capturing row
//                              membership AND per-cell values, so cell edits
//                              revert correctly (fixed in 2.1.0)
//   • mode                   — readable ⇄ editable, switchable at runtime
//   • combo registries       — the per-cell AutoSuggestions source + controller,
//                              rebuilt when a row's fingerPrint changes
//
// Rows are [SuperRow]`<R>`: a host-owned `value` of type `R` + an editable
// `cells` map. The controller emits the mutated row list through [onChange].
// ============================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show BuildContext, FocusNode;

import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart'
    show AutoSuggestionsBoxController, AutoSuggestionsSource;
import '../../domain/entities/super_column.dart';
import '../../domain/entities/super_change.dart';
import '../../domain/entities/super_filter.dart';
import '../../domain/entities/super_group.dart';
import '../../domain/entities/super_row.dart';
import '../../domain/entities/super_table_state.dart';
import '../../domain/entities/super_validation.dart';
import '../../domain/entities/super_view_state.dart';
import '../../domain/usecases/super_column_logic.dart';

/// Host hook for raw key handling (readable + editable). Return `true` to mark
/// the event handled (the table will not apply its own default for that key).
typedef SuperKeyHandler<R> = bool Function(
  BuildContext context,
  SuperTableController<R> controller,
  FocusNode node,
  KeyEvent event,
);

/// One undo/redo history entry: the row list (membership + order, by
/// reference) PLUS a per-cell value/error snapshot keyed by [SuperRow.id] —
/// cells are mutated in place during editing, so restoring membership alone
/// cannot revert a cell edit. Also carries the change-tracking deleted-row
/// log so undoing a delete removes its ghost entry from `changes.deleted`.
class _HistoryEntry<R> {
  final List<SuperRow<R>> rows;
  final Map<int, Map<String, ({Object? value, String? error})>> cells;
  final List<({int index, SuperRow<R> row})> deletedLog;
  const _HistoryEntry(this.rows, this.cells, this.deletedLog);
}

class SuperTableController<R> extends ChangeNotifier {
  SuperTableController({
    required List<SuperColumn> columns,
    required List<SuperRow<R>> rows,
    SuperTableMode mode = SuperTableMode.readable,
    SuperSelectionMode selectionMode = SuperSelectionMode.singleCell,
    this.addRowEnabled = false,
    String search = '',
    SuperPagination pagination = SuperPagination.none,
    this.pageSize = 8,
    List<String>? visibleKeys,
    this.onChange,
    this.onNotify,
    this.onVisibleChange,
    this.onLoadMore,
    this.onKey,
    bool hasMore = false,
    bool loadingMore = false,
    R Function()? emptyRowValue,
    this.trackChanges = false,
    this.cellEditable,
  })  : _rawColumns = columns,
        _rows = rows,
        _mode = mode,
        _selectionMode = selectionMode,
        _search = search,
        _visibleKeys = visibleKeys,
        _hasMore = hasMore,
        _loadingMore = loadingMore,
        _pagination = pagination,
        _emptyValue = emptyRowValue {
    _order = _midBase.map((c) => c.key).toList();
    _selRows = {0};
    _ensureCells();
    if (trackChanges) _captureBaseline();
  }

  // ── config ──
  SuperTableMode _mode;
  final bool addRowEnabled;
  SuperPagination _pagination;
  final int pageSize;
  final void Function(List<SuperRow<R>> next)? onChange;
  final void Function(SuperNotifyKind kind, String message)? onNotify;
  final void Function(List<String> next)? onVisibleChange;

  /// Host load-more hook. Receives the current [filterState] so the fetch can
  /// honor the active search / column / advanced filters.
  final void Function(SuperFilterState filter)? onLoadMore;

  /// Optional host key handler (see [SuperKeyHandler]).
  final SuperKeyHandler<R>? onKey;

  /// When true, the controller captures a per-cell baseline so [changes]
  /// returns the added/modified/deleted delta (see [SuperChangeSet]). Off by
  /// default — there is no tracking overhead unless you opt in.
  final bool trackChanges;

  /// Optional per-cell editability gate (1.0.0). Consulted in addition to the
  /// mode + column rules; return false to make a specific cell read-only (e.g.
  /// lock the cells of a row whose `posted` flag is set).
  final bool Function(SuperColumn col, SuperRow row)? cellEditable;

  final R Function()? _emptyValue;

  /// The live BuildContext of the mounted View — set by the View each build so
  /// the controller can invoke column `onChange` / `validator` (which take a
  /// context). Null before the View mounts.
  BuildContext? viewContext;

  /// Whether the render list should emit a [RenderItem.groupFooter] subtotal
  /// row after each expanded group (2.1.0). Set by the View each build from
  /// `SuperTable(groupFooters:)` — like [viewContext], not a reactive setting.
  bool groupFootersEnabled = false;

  // ── load-more paging state (host-driven) ──
  bool _hasMore;
  bool _loadingMore;
  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  List<SuperColumn> _rawColumns;
  List<SuperRow<R>> _rows;
  String _search;
  List<String>? _visibleKeys;
  SuperSelectionMode _selectionMode;

  // ── selection / cursor state ──
  CellPos _sel = const CellPos(0, 0);
  CellPos _anchor = const CellPos(0, 0);
  final Set<String> _extraCells = {}; // discrete "r:c"
  Set<int> _selRows = {0};
  final Set<int> _rowBand = {}; // full-row highlight from row-number clicks
  bool _focused = false;

  bool _advanceOnEnter = false;
  bool get advanceOnEnter => _advanceOnEnter;
  void clearAdvanceOnEnter() => _advanceOnEnter = false;

  // ── editing state ──
  CellPos? _editCell;
  String _draft = '';
  bool _committing = false;

  // ── view config state ──
  SortSpec _sort = const SortSpec();
  final Map<String, Object?> _colFilters = {}; // key → value (String contains, or option value)
  List<AdvancedFilterClause> _advanced = [];
  bool _advancedActive = false;
  final List<String> _groupKeys = [];
  final Map<String, bool> _collapsed = {};
  final Map<String, double> _widths = {};
  late List<String> _order;
  int _page = 0;

  // ── history ──
  final List<_HistoryEntry<R>> _undo = [];
  final List<_HistoryEntry<R>> _redo = [];

  /// Capture the full undo state: row membership/order, every cell's
  /// value + error, and the change-tracking deleted-row log.
  _HistoryEntry<R> _snapshot() => _HistoryEntry<R>(
        List.of(_rows),
        {
          for (final row in _rows)
            row.id: {
              for (final e in row.cells.entries)
                e.key: (value: e.value.value, error: e.value.error),
            },
        },
        List.of(_deletedRows),
      );

  /// Restore a captured [_HistoryEntry]: reinstate membership/order, write the
  /// snapshotted values back into the SAME row/cell instances (keeping row
  /// identity for selection, expansion, and combo registries), sync the
  /// backing objects, and restore the deleted-row log.
  void _restore(_HistoryEntry<R> s) {
    _rows = List.of(s.rows);
    for (final row in _rows) {
      final vals = s.cells[row.id];
      if (vals == null) continue;
      vals.forEach((key, snap) {
        final cell = row.cells[key] ??= SuperCell(columnKey: key);
        if (cell.value != snap.value) {
          cell.value = snap.value;
          colByKey(key)?.writeBacking(row.value, snap.value);
        }
        cell.error = snap.error;
      });
    }
    _deletedRows
      ..clear()
      ..addAll(s.deletedLog);
    _clampSelection();
  }

  // ── change tracking (1.0.0) ──
  final List<({int index, SuperRow<R> row})> _deletedRows = [];

  // ── combo per-cell registries (rebuilt on fingerPrint change) ──
  final Map<String, AutoSuggestionsBoxController> _comboCtrls = {};
  final Map<String, AutoSuggestionsSource> _comboSources = {};
  final Map<String, Object?> _comboFingerPrints = {};

  // ── reads ──
  SuperTableMode get mode => _mode;
  List<SuperRow<R>> get rows => _rows;
  List<SuperColumn> get rawColumns => _rawColumns;

  /// Every column that can ever render — all columns except the
  /// [SuperColumn.hidden] ones.
  List<SuperColumn> get dataColumns => _rawColumns.where((c) => !c.hidden).toList();

  /// Columns marked [SuperColumn.hidden]: present only for filtering, grouping
  /// and aggregation (by key), never rendered and never revealable.
  List<SuperColumn> get hiddenColumns => _rawColumns.where((c) => c.hidden).toList();
  SuperSelectionMode get selectionMode => _selectionMode;
  String get search => _search;
  CellPos get sel => _sel;
  CellPos get anchor => _anchor;
  Set<int> get selRows => _selRows;
  bool get focused => _focused;
  CellPos? get editCell => _editCell;
  String get draft => _draft;
  SortSpec get sort => _sort;
  List<AdvancedFilterClause> get advancedFilter => List.unmodifiable(_advanced);
  bool get advancedActive => _advancedActive;

  String columnFilter(String key) => '${_colFilters[key] ?? ''}';
  Object? columnFilterValue(String key) => _colFilters[key];
  bool get hasColumnFilters => _colFilters.values.any((v) => '$v'.trim().isNotEmpty);
  Map<String, Object?> get activeColumnFilters => {
        for (final e in _colFilters.entries)
          if ('${e.value}'.trim().isNotEmpty) e.key: e.value,
      };
  List<String> get groupKeys => List.unmodifiable(_groupKeys);
  bool get grouped => _groupKeys.isNotEmpty;
  Map<String, double> get widths => _widths;
  int get page => _page;
  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  bool isCollapsed(String path) => _collapsed[path] == true;

  bool get cellMode =>
      _selectionMode == SuperSelectionMode.singleCell || _selectionMode == SuperSelectionMode.multiCells;
  bool get rowMode =>
      _selectionMode == SuperSelectionMode.singleRow || _selectionMode == SuperSelectionMode.multiRows;
  bool get multiSel =>
      _selectionMode == SuperSelectionMode.multiCells || _selectionMode == SuperSelectionMode.multiRows;

  // ── filter state (programmatic get/set + JSON) ──
  /// A structured snapshot of the whole filter state.
  SuperFilterState get filterState => SuperFilterState(
        search: _search,
        columnFilters: Map.of(activeColumnFilters),
        advanced: List.of(_advanced),
        advancedActive: _advancedActive,
      );

  /// Serialise the filter state to JSON.
  Map<String, dynamic> filterStateJson() => filterState.toJson();

  /// Apply a full [SuperFilterState] (replaces search + column + advanced).
  void applyFilterState(SuperFilterState s) {
    _search = s.search;
    _colFilters
      ..clear()
      ..addAll(s.columnFilters);
    _advanced = List.of(s.advanced);
    _advancedActive = s.advancedActive;
    _page = 0;
    _clampSelection();
    notifyListeners();
  }

  /// Apply a filter state from its JSON form.
  void applyFilterJson(Map<String, dynamic> json) => applyFilterState(SuperFilterState.fromJson(json));

  // ── saved views (2.1.0) ──────────────────────────────────
  /// Snapshot everything the user personalises about this grid — column order,
  /// width overrides, the visible-keys allow-list, sort, group-bys, collapsed
  /// groups, and (by default) the whole filter state — as one
  /// [SuperViewState]. Persist `viewStateJson()` per user/screen and restore
  /// it later with [applyViewJson].
  SuperViewState viewState({bool includeFilters = true}) => SuperViewState(
        order: List.of(_order),
        widths: Map.of(_widths),
        visibleKeys: _visibleKeys == null ? null : List.of(_visibleKeys!),
        sortKey: _sort.key,
        sortAscending: _sort.ascending,
        groupKeys: List.of(_groupKeys),
        collapsedPaths: [
          for (final e in _collapsed.entries)
            if (e.value) e.key,
        ],
        filters: includeFilters ? filterState : null,
      );

  /// [viewState] as JSON.
  Map<String, dynamic> viewStateJson({bool includeFilters = true}) =>
      viewState(includeFilters: includeFilters).toJson();

  /// Apply a saved [SuperViewState]. Unknown column keys (the schema may have
  /// changed since the view was saved) are dropped; columns missing from a
  /// saved order are appended in their natural position. A null
  /// [SuperViewState.filters] leaves the live filters untouched.
  void applyViewState(SuperViewState s) {
    if (s.visibleKeys != null) {
      final valid = s.visibleKeys!.where((k) => colByKey(k) != null).toList();
      _visibleKeys = valid.isEmpty ? null : valid;
    } else {
      _visibleKeys = null;
    }
    if (s.order != null) {
      final baseKeys = _midBase.map((c) => c.key).toList();
      final kept = s.order!.where(baseKeys.contains).toList();
      _order = [...kept, ...baseKeys.where((k) => !kept.contains(k))];
    }
    _widths
      ..clear()
      ..addAll({
        for (final e in s.widths.entries)
          if (colByKey(e.key) != null) e.key: e.value.clamp(60.0, 520.0).toDouble(),
      });
    _sort = (s.sortKey != null && colByKey(s.sortKey!) != null)
        ? SortSpec(key: s.sortKey, ascending: s.sortAscending)
        : const SortSpec();
    _groupKeys
      ..clear()
      ..addAll(s.groupKeys.where((k) => colByKey(k) != null));
    _collapsed.clear();
    for (final p in s.collapsedPaths) {
      _collapsed[p] = true;
    }
    if (s.filters != null) {
      _search = s.filters!.search;
      _colFilters
        ..clear()
        ..addAll(s.filters!.columnFilters);
      _advanced = List.of(s.filters!.advanced);
      _advancedActive = s.filters!.advancedActive;
    }
    _page = 0;
    _clampSelection();
    notifyListeners();
  }

  /// Apply a saved view from its JSON form (see [viewStateJson]).
  void applyViewJson(Map<String, dynamic> json) => applyViewState(SuperViewState.fromJson(json));

  /// Reset every user personalisation back to the column declarations:
  /// natural order, declared widths, all columns visible, no sort, no groups.
  /// Pass [clearFilters] = false to keep the active search/filters.
  void resetViewState({bool clearFilters = true}) {
    _visibleKeys = null;
    _order = _midBase.map((c) => c.key).toList();
    _widths.clear();
    _sort = const SortSpec();
    _groupKeys.clear();
    _collapsed.clear();
    if (clearFilters) {
      _search = '';
      _colFilters.clear();
      _advanced = [];
      _advancedActive = false;
    }
    _page = 0;
    _clampSelection();
    notifyListeners();
  }

  // ── change tracking (1.0.0) ────────────────────────────────────
  /// Whether any row was added, modified, or deleted since the last baseline.
  /// Always false unless [trackChanges] is enabled.
  bool get hasChanges {
    if (!trackChanges) return false;
    if (_deletedRows.any((e) => !e.row.isNew)) return true;
    for (final row in _rows) {
      if (row.isNew) return true;
      if (row.cells.values.any((c) => c.isDirty)) return true;
    }
    return false;
  }

  /// The tracked state of [row] relative to the baseline.
  SuperRowState rowStateOf(SuperRow row) {
    if (!trackChanges) return SuperRowState.pristine;
    if (row.isNew) return SuperRowState.added;
    if (row.cells.values.any((c) => c.isDirty)) return SuperRowState.modified;
    return SuperRowState.pristine;
  }

  /// Whether [row] differs from its baseline (added or modified).
  bool isRowDirty(SuperRow row) => rowStateOf(row) != SuperRowState.pristine;

  /// Whether one cell of [row] differs from its baseline.
  bool isCellDirty(SuperRow row, String columnKey) => row.cells[columnKey]?.isDirty ?? false;

  /// The full add/modify/delete delta since the last baseline. Hand
  /// `changes.toJson()` to a backend, or iterate the partitions yourself.
  SuperChangeSet<R> get changes {
    if (!trackChanges) return const SuperChangeSet();
    final added = <SuperRowChange<R>>[];
    final modified = <SuperRowChange<R>>[];
    final deleted = <SuperRowChange<R>>[];
    for (final row in _rows) {
      if (row.isNew) {
        added.add(SuperRowChange<R>(state: SuperRowState.added, row: row));
        continue;
      }
      final cellChanges = <SuperCellChange>[];
      for (final cell in row.cells.values) {
        if (cell.isDirty) {
          cellChanges.add(SuperCellChange(
              columnKey: cell.columnKey, oldValue: cell.baseline, newValue: cell.value));
        }
      }
      if (cellChanges.isNotEmpty) {
        modified.add(SuperRowChange<R>(state: SuperRowState.modified, row: row, cellChanges: cellChanges));
      }
    }
    for (final e in _deletedRows) {
      if (!e.row.isNew) deleted.add(SuperRowChange<R>(state: SuperRowState.deleted, row: e.row));
    }
    return SuperChangeSet<R>(added: added, modified: modified, deleted: deleted);
  }

  /// Treat the current grid as the new clean baseline (call after a successful
  /// save). Clears the deleted-row log and re-captures every cell baseline.
  void acceptChanges() {
    if (!trackChanges) return;
    _captureBaseline();
    notifyListeners();
  }

  /// Discard every edit since the baseline: drop added rows, revert modified
  /// cells, and restore deleted rows to their recorded positions.
  void rejectChanges() {
    if (!trackChanges) return;
    final restored = <SuperRow<R>>[];
    for (final row in _rows) {
      if (row.isNew) continue;
      for (final cell in row.cells.values) {
        cell.revertToBaseline();
      }
      restored.add(row);
    }
    final dels = [..._deletedRows]..sort((a, b) => a.index.compareTo(b.index));
    for (final e in dels) {
      if (e.row.isNew) continue;
      restored.insert(e.index.clamp(0, restored.length), e.row);
    }
    _deletedRows.clear();
    _rows = restored;
    onChange?.call(_rows);
    _clampSelection();
    notifyListeners();
  }

  // ── per-cell / per-row revert (2.1.0) ──────────────────────
  /// Restore one cell of [row] to its change-tracking baseline (no-op unless
  /// [trackChanges] is on and the cell is dirty). Syncs the backing object,
  /// records undo, and fires [onChange] — the row-menu *Revert cell* action.
  void revertCell(SuperRow<R> row, String columnKey) {
    if (!trackChanges) return;
    final cell = row.cells[columnKey];
    if (cell == null || !cell.isDirty) return;
    final snap = _snapshot();
    cell.revertToBaseline();
    colByKey(columnKey)?.writeBacking(row.value, cell.value);
    _applyRows([..._rows], undoSnapshot: snap);
    notifyListeners();
  }

  /// Restore every dirty cell of [row] to its baseline. For an **added** row
  /// (no baseline exists) the row itself is removed — reverting an addition.
  /// Records undo and fires [onChange].
  void revertRow(SuperRow<R> row) {
    if (!trackChanges) return;
    if (row.isNew) {
      final idx = _rows.indexOf(row);
      if (idx < 0) return;
      final snap = _snapshot();
      _pruneCombos(row);
      _applyRows([
        for (var i = 0; i < _rows.length; i++)
          if (i != idx) _rows[i]
      ], undoSnapshot: snap);
      _clampSelection();
      notifyListeners();
      return;
    }
    if (!isRowDirty(row)) return;
    final snap = _snapshot();
    for (final cell in row.cells.values) {
      if (!cell.isDirty) continue;
      cell.revertToBaseline();
      colByKey(cell.columnKey)?.writeBacking(row.value, cell.value);
    }
    _applyRows([..._rows], undoSnapshot: snap);
    notifyListeners();
  }

  // ── selection statistics (1.0.0) ───────────────────────────────
  /// A running sum / average / count / min / max over the numeric cells in the
  /// current selection — the spreadsheet status-bar aggregate. Null when nothing
  /// is selected.
  SuperSelectionStats? get selectionStats {
    final cells = selectedCells();
    if (cells.isEmpty) return null;
    final theCols = cols;
    final theView = view;
    num sum = 0;
    var numeric = 0;
    num? mn;
    num? mx;
    for (final p in cells) {
      if (p.r >= theView.length || p.c >= theCols.length) continue;
      final rowEntry = theView[p.r].row;
      if (rowEntry == null) continue; // group header / non-data row
      final col = theCols[p.c];
      final isNum = col.type.isNumeric || col.type == SuperColumnType.computed;
      if (!isNum) continue;
      final raw = col.rawValue(rowEntry);
      if (raw == null || '$raw'.trim().isEmpty) continue;
      if (raw is! num && double.tryParse('$raw'.replaceAll(RegExp(r'[^0-9.\-]'), '')) == null) {
        continue;
      }
      final n = SuperColumnLogic.numVal(raw);
      sum += n;
      numeric++;
      mn = (mn == null || n < mn) ? n : mn;
      mx = (mx == null || n > mx) ? n : mx;
    }
    return SuperSelectionStats(
      count: cells.length,
      numericCount: numeric,
      sum: sum,
      average: numeric == 0 ? 0 : sum / numeric,
      min: mn,
      max: mx,
    );
  }

  // ── validation summary (2.1.0) ───────────────────────────
  /// Run the FULL validation pass over **every row** (not just the current
  /// page): built-in type rules, the `unique:` constraint, then each column's
  /// `validator`. Returns one [SuperValidationIssue] per failing cell — gate a
  /// *Post* / *Save* on [isValid] and feed the list to a summary panel with
  /// jump-to-cell (`selectCellAt(issue.cell!.r, issue.cell!.c)`).
  ///
  /// [markCells] (default true) writes each result into `cell.error`, so the
  /// per-cell badges light up, and notifies. Derived (computed / readonly)
  /// columns are skipped; hidden columns are validated (they carry data).
  List<SuperValidationIssue<R>> validateAll({bool markCells = true}) {
    final issues = <SuperValidationIssue<R>>[];
    final theCols = cols;
    final theView = view;
    final viewIndexOf = <int, int>{
      for (var i = 0; i < theView.length; i++)
        if (theView[i].row != null) theView[i].row!.id: i,
    };
    final colIndexOf = <String, int>{
      for (var i = 0; i < theCols.length; i++) theCols[i].key: i,
    };
    final uniqueSeen = <String, Map<String, int>>{};
    for (var si = 0; si < _rows.length; si++) {
      final row = _rows[si];
      for (final col in _rawColumns) {
        if (col.type.isDerived) continue;
        final cell = row.cells[col.key];
        final value = cell?.value;
        String? err = SuperColumnLogic.validateCell(col, value);
        if (err == null && col.unique) {
          final text = SuperColumnLogic.toText(col, value, row).trim().toLowerCase();
          if (text.isNotEmpty) {
            final bucket = uniqueSeen.putIfAbsent(col.key, () => <String, int>{});
            final first = bucket[text];
            if (first != null) {
              err = '“${col.label}” must be unique — duplicates row ${first + 1}';
            } else {
              bucket[text] = si;
            }
          }
        }
        if (err == null && cell != null) {
          final v = col.validator;
          final ctx = viewContext;
          if (v != null && ctx != null) {
            try {
              err = v(ctx, this, row, cell, value);
            } catch (_) {
              // A host validator with a narrower value type than the stored
              // value — report it instead of crashing the pass.
              err = '“${col.label}” has an invalid value';
            }
          }
        }
        if (markCells && cell != null) cell.error = err;
        if (err != null) {
          issues.add(SuperValidationIssue<R>(
            row: row,
            sourceIndex: si,
            viewRow: viewIndexOf[row.id],
            colIndex: colIndexOf[col.key],
            columnKey: col.key,
            columnLabel: col.label,
            message: err,
          ));
        }
      }
    }
    if (markCells) notifyListeners();
    return issues;
  }

  /// Number of cells currently holding a validation error (the red badges).
  /// Cheap enough for per-build footer chips; run [validateAll] first to
  /// populate errors table-wide.
  int get errorCount {
    var n = 0;
    for (final row in _rows) {
      for (final cell in row.cells.values) {
        if (cell.error != null) n++;
      }
    }
    return n;
  }

  /// True when [validateAll] finds no issues (does not touch cell badges).
  bool get isValid => validateAll(markCells: false).isEmpty;

  // ── export (1.0.0) ─────────────────────────────────────────────
  String _csvEscape(String s, String delimiter) {
    if (s.contains(delimiter) || s.contains('"') || s.contains('\n') || s.contains('\r')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  /// Serialise the **current view** (post-search/filter/sort) to a delimited
  /// string. [visibleOnly] uses the on-screen, reordered columns; pass false to
  /// export every renderable column. Values use each column's display text.
  /// [SuperColumn.hidden] columns are never exported.
  String toDelimited({String delimiter = ',', bool includeHeader = true, bool visibleOnly = true}) {
    final columns = visibleOnly ? cols : dataColumns;
    final buf = StringBuffer();
    if (includeHeader) {
      buf.writeln(columns.map((col) => _csvEscape(col.label, delimiter)).join(delimiter));
    }
    for (final row in sortedRows) {
      buf.writeln(columns
          .map((col) => _csvEscape(SuperColumnLogic.toText(col, col.rawValue(row), row), delimiter))
          .join(delimiter));
    }
    return buf.toString();
  }

  /// The current view as CSV text (respects the active filter + sort).
  String toCsv({bool includeHeader = true, bool visibleOnly = true}) =>
      toDelimited(delimiter: ',', includeHeader: includeHeader, visibleOnly: visibleOnly);

  /// The current view as TSV text (paste-into-Excel friendly).
  String toTsv({bool includeHeader = true, bool visibleOnly = true}) =>
      toDelimited(delimiter: '\t', includeHeader: includeHeader, visibleOnly: visibleOnly);

  /// The current view as a list of `{columnKey: rawValue}` maps.
  List<Map<String, Object?>> toJsonRows({bool visibleOnly = true}) {
    final columns = visibleOnly ? cols : dataColumns;
    return [
      for (final row in sortedRows) {for (final col in columns) col.key: col.rawValue(row)}
    ];
  }

  /// Convenience: copy the current view as CSV onto the system clipboard.
  Future<void> copyCsvToClipboard() async {
    await Clipboard.setData(ClipboardData(text: toCsv()));
    onNotify?.call(SuperNotifyKind.ok, 'Copied ${sortedRows.length} rows as CSV');
  }

  // ── programmatic aggregation (1.1.0) ───────────────────────────
  /// Resolve which columns to aggregate. Explicit [keys] are looked up in the
  /// **full** column set (so [SuperColumn.hidden] columns are eligible); when
  /// null, every column that declares an aggregate (`agg != none`) is used —
  /// hidden columns included.
  List<SuperColumn> _aggColumns(Iterable<String>? keys) {
    if (keys != null) return keys.map(colByKey).whereType<SuperColumn>().toList();
    return _rawColumns.where((c) => c.agg != SuperAgg.none).toList();
  }

  /// Aggregate one column over a set of [rows] (defaults to the whole live,
  /// filtered + sorted view). Optionally override the column's declared [agg] /
  /// [aggregator] — e.g. read a `sum` off a column that declares no aggregate.
  /// Works for [SuperColumn.hidden] columns too. Returns null for an unknown
  /// column or a no-op aggregate.
  num? aggregateColumn(
    String columnKey, {
    Iterable<SuperRow<R>>? rows,
    SuperAgg? agg,
    SuperAggregator? aggregator,
  }) {
    final col = colByKey(columnKey);
    if (col == null) return null;
    final list = (rows ?? _sorted).toList();
    return SuperColumnLogic.aggregate(col, list, agg: agg, aggregator: aggregator);
  }

  /// Grand totals over the entire data set: `columnKey → aggregate`. Honours the
  /// active filter (+ sort) by default and covers every column with an
  /// aggregate; pass [columns] to pick specific keys (hidden allowed), or
  /// [filtered] = false to total the raw, unfiltered rows. The programmatic
  /// form of the on-screen totals row.
  Map<String, num?> grandTotals({Iterable<String>? columns, bool filtered = true}) {
    final source = filtered ? _sorted : _rows;
    return {
      for (final col in _aggColumns(columns)) col.key: SuperColumnLogic.aggregate(col, source),
    };
  }

  /// Bucket the rows by [groupColumnKey] and aggregate [valueColumnKey] within
  /// each bucket — a single-level group-by computed **programmatically**,
  /// independent of the table's live grouping. Either column may be
  /// [SuperColumn.hidden]. Override the value column's reducer with [agg] /
  /// [aggregator]; pass [filtered] = false to bucket the raw rows. Returns
  /// `groupValue → aggregate`, preserving first-seen group order.
  Map<String, num?> aggregateBy(
    String groupColumnKey,
    String valueColumnKey, {
    SuperAgg? agg,
    SuperAggregator? aggregator,
    bool filtered = true,
  }) {
    final gcol = colByKey(groupColumnKey);
    final vcol = colByKey(valueColumnKey);
    if (gcol == null || vcol == null) return const {};
    final source = filtered ? _sorted : _rows;
    final buckets = <String, List<SuperRow<R>>>{};
    for (final row in source) {
      final v = SuperColumnLogic.toText(gcol, gcol.rawValue(row), row);
      buckets.putIfAbsent(v, () => <SuperRow<R>>[]).add(row);
    }
    return {
      for (final e in buckets.entries)
        e.key: SuperColumnLogic.aggregate(vcol, e.value, agg: agg, aggregator: aggregator),
    };
  }

  /// A nested tree of group aggregates honouring the active filter (+ sort).
  /// [groupBy] defaults to the table's live [groupKeys]; each level buckets its
  /// parent's rows, and every node carries an `aggregates` map for the requested
  /// [aggregateColumns] (default: all columns with an aggregate, **including
  /// hidden** ones). Independent of collapse state — every group is included.
  /// Returns an empty list when there is nothing to group by.
  List<SuperGroupAggregate<R>> groupAggregates({
    Iterable<String>? groupBy,
    Iterable<String>? aggregateColumns,
  }) {
    final keys =
        (groupBy?.toList() ?? _groupKeys).map(colByKey).whereType<SuperColumn>().toList();
    if (keys.isEmpty) return <SuperGroupAggregate<R>>[];
    final aggCols = _aggColumns(aggregateColumns);

    List<SuperGroupAggregate<R>> rec(List<SuperRow<R>> items, int depth, String prefix) {
      final col = keys[depth];
      final buckets = <String, List<SuperRow<R>>>{};
      for (final row in items) {
        final v = SuperColumnLogic.toText(col, col.rawValue(row), row);
        buckets.putIfAbsent(v, () => <SuperRow<R>>[]).add(row);
      }
      final out = <SuperGroupAggregate<R>>[];
      buckets.forEach((value, groupItems) {
        final path = '$prefix/$depth:$value';
        out.add(SuperGroupAggregate<R>(
          columnKey: col.key,
          columnLabel: col.label,
          value: value,
          depth: depth,
          path: path,
          count: groupItems.length,
          rows: groupItems,
          aggregates: {
            for (final ac in aggCols) ac.key: SuperColumnLogic.aggregate(ac, groupItems),
          },
          children:
              depth + 1 < keys.length ? rec(groupItems, depth + 1, path) : <SuperGroupAggregate<R>>[],
        ));
      });
      return out;
    }

    return rec(_sorted, 0, '');
  }

  // ── cell scaffolding ──
  Object? _defaultFor(SuperColumn col) {
    switch (col.type) {
      case SuperColumnType.checkbox:
        return false;
      case SuperColumnType.color:
        return SuperColumnLogic.colorFromHex(col, '#4A7CFF');
      case SuperColumnType.enumeration:
        if (col.optValues != null && col.optValues!.isNotEmpty) return col.optValues!.first;
        if (col.opts != null && col.opts!.isNotEmpty) return col.opts!.first;
        return '';
      case SuperColumnType.number:
      case SuperColumnType.currency:
      case SuperColumnType.progress:
        return 0;
      default:
        return '';
    }
  }

  /// Ensure every row has a [SuperCell] for every column (reads the backing
  /// object via the column's `read` hook, else a sane default).
  void _ensureCells() {
    for (final row in _rows) {
      for (final col in _rawColumns) {
        if (!row.cells.containsKey(col.key)) {
          final v = col.readBacking(row.value) ?? _defaultFor(col);
          final cell = SuperCell(columnKey: col.key, value: v);
          // A column added to an already-baselined row is itself pristine.
          if (trackChanges && !row.isNew) cell.markBaseline();
          row.cells[col.key] = cell;
        }
      }
    }
  }

  // ── change tracking baseline helpers ──
  /// Capture (or re-capture) the baseline for every current row: mark each cell,
  /// flag every row as persisted, and drop the deleted-row log.
  void _captureBaseline() {
    _deletedRows.clear();
    for (final row in _rows) {
      row.isNew = false;
      for (final cell in row.cells.values) {
        cell.markBaseline();
      }
    }
  }

  /// Treat [rows] as freshly-persisted (pristine) data — used when the host
  /// streams in server rows via [appendRows].
  void _baselineRows(Iterable<SuperRow<R>> rows) {
    for (final row in rows) {
      row.isNew = false;
      for (final cell in row.cells.values) {
        cell.markBaseline();
      }
    }
  }

  // ── mode switching (controller-driven) ──
  /// Switch between readable and editable at runtime. Cancels any open editor.
  void setMode(SuperTableMode m) {
    if (_mode == m) return;
    _mode = m;
    _editCell = null;
    _advanceOnEnter = false;
    notifyListeners();
  }

  void toggleMode() =>
      setMode(_mode == SuperTableMode.readable ? SuperTableMode.editable : SuperTableMode.readable);

  /// The current pagination strategy.
  SuperPagination get pagination => _pagination;

  /// Change the pagination strategy at runtime (resets to the first page).
  void setPagination(SuperPagination p) {
    if (_pagination == p) return;
    _pagination = p;
    _page = 0;
    notifyListeners();
  }

  // ── host updates / table actions ──
  void updateRows(List<SuperRow<R>> rows) {
    _rows = rows;
    _ensureCells();
    if (trackChanges) _captureBaseline();
    // A wholesale replace invalidates history + per-row combo resources.
    _undo.clear();
    _redo.clear();
    _comboCtrls.clear();
    _comboSources.clear();
    _comboFingerPrints.clear();
    _clampSelection();
    notifyListeners();
  }

  /// Append more rows (load-more / infinite). Optionally update [hasMore] and
  /// clear the loading flag in one step.
  void appendRows(List<SuperRow<R>> more, {bool? hasMore, bool loadingDone = true}) {
    _rows = [..._rows, ...more];
    _ensureCells();
    // Streamed-in rows are persisted data, not local edits.
    if (trackChanges) _baselineRows(more);
    if (hasMore != null) _hasMore = hasMore;
    if (loadingDone) _loadingMore = false;
    notifyListeners();
  }

  /// Remove every row (keeps columns + view config). Records undo.
  void clearTable() {
    if (_rows.isEmpty) return;
    final snap = _snapshot(); // BEFORE the deleted-row log gains entries
    if (trackChanges) {
      for (var i = 0; i < _rows.length; i++) {
        _deletedRows.add((index: i, row: _rows[i]));
      }
    }
    for (final row in _rows) {
      _pruneCombos(row);
    }
    _applyRows(<SuperRow<R>>[], undoSnapshot: snap);
    _clampSelection();
    notifyListeners();
  }

  void updateColumns(List<SuperColumn> columns) {
    _rawColumns = columns;
    final keys = _midBase.map((c) => c.key).toList();
    final kept = _order.where(keys.contains).toList();
    final added = keys.where((k) => !kept.contains(k)).toList();
    _order = [...kept, ...added];
    _ensureCells();
    notifyListeners();
  }

  void setVisibleKeys(List<String>? keys) {
    _visibleKeys = keys;
    notifyListeners();
  }

  bool get canHideColumns => onVisibleChange != null || _visibleKeys != null;
  int get visibleColumnCount => _baseCols.length;

  void hideColumn(String key) {
    final cur = _visibleKeys ?? dataColumns.map((c) => c.key).toList();
    final next = cur.where((k) => k != key).toList();
    if (next.isEmpty) return;
    onVisibleChange?.call(next);
    _visibleKeys = next;
    notifyListeners();
  }

  void setLoadMoreState({bool? hasMore, bool? loadingMore}) {
    if (hasMore != null) _hasMore = hasMore;
    if (loadingMore != null) _loadingMore = loadingMore;
    notifyListeners();
  }

  /// Ask the host to append the next page (no-op while loading / done). Marks
  /// loading and hands the host the current [filterState].
  void requestLoadMore() {
    if (_loadingMore || !_hasMore) return;
    _loadingMore = true;
    notifyListeners();
    onLoadMore?.call(filterState);
  }

  /// Alias for [requestLoadMore] (action-style name).
  void loadMore() => requestLoadMore();

  void setSearch(String q) {
    _search = q;
    _page = 0;
    _clampSelection();
    notifyListeners();
  }

  /// Set (or clear, when blank) a per-column filter. Setting a column filter
  /// **deactivates** the advanced filter (the two are mutually exclusive).
  void setColumnFilter(String key, Object? value) {
    final blank = value == null || '$value'.trim().isEmpty;
    if (blank) {
      // Clearing a filter that isn't set is a no-op (2.1.0 fix: it used to
      // deactivate the advanced filter as a side effect).
      if (!_colFilters.containsKey(key)) return;
      _colFilters.remove(key);
    } else {
      _colFilters[key] = value;
    }
    _advancedActive = false;
    _page = 0;
    _clampSelection();
    notifyListeners();
  }

  void clearColumnFilters() {
    if (_colFilters.isEmpty) return;
    _colFilters.clear();
    _page = 0;
    _clampSelection();
    notifyListeners();
  }

  // ── advanced (cross-column) filter ──
  /// Replace the advanced filter clauses. When [active] (default true) it
  /// becomes the active filter and per-column filters are cleared + disabled.
  void setAdvancedFilter(List<AdvancedFilterClause> clauses, {bool active = true}) {
    _advanced = List.of(clauses);
    _advancedActive = active && clauses.isNotEmpty;
    if (_advancedActive) _colFilters.clear();
    _page = 0;
    _clampSelection();
    notifyListeners();
  }

  /// Toggle whether the advanced filter is the active one.
  void setAdvancedActive(bool active) {
    if (_advancedActive == active) return;
    _advancedActive = active && _advanced.isNotEmpty;
    if (_advancedActive) _colFilters.clear();
    _page = 0;
    _clampSelection();
    notifyListeners();
  }

  void clearAdvancedFilter() {
    if (_advanced.isEmpty && !_advancedActive) return;
    _advanced = [];
    _advancedActive = false;
    _page = 0;
    _clampSelection();
    notifyListeners();
  }

  void setSelectionMode(SuperSelectionMode m) {
    _selectionMode = m;
    _extraCells.clear();
    _selRows = {_sel.r};
    _anchor = _sel;
    notifyListeners();
  }

  void setFocused(bool v) {
    if (_focused == v) return;
    _focused = v;
    notifyListeners();
  }

  // ── column resolution ──
  /// The columns eligible to render: never the [SuperColumn.hidden] ones, and —
  /// when a visible-key allow-list is set — only the keys it includes.
  List<SuperColumn> get _baseCols =>
      _rawColumns.where((c) => !c.hidden && (_visibleKeys == null || _visibleKeys!.contains(c.key))).toList();
  List<SuperColumn> get _leftPins => _baseCols.where((c) => c.pin == SuperPin.left).toList();
  List<SuperColumn> get _rightPins => _baseCols.where((c) => c.pin == SuperPin.right).toList();
  List<SuperColumn> get _midBase => _baseCols.where((c) => c.pin == SuperPin.none).toList();
  List<SuperColumn> get midCols {
    final base = _midBase;
    return _order
        .map((k) => base.cast<SuperColumn?>().firstWhere((c) => c!.key == k, orElse: () => null))
        .whereType<SuperColumn>()
        .toList();
  }

  List<SuperColumn> get cols => [..._leftPins, ...midCols, ..._rightPins];
  int get nCols => cols.length;

  SuperColumn? colByKey(String k) =>
      _rawColumns.cast<SuperColumn?>().firstWhere((c) => c!.key == k, orElse: () => null);

  double widthOf(SuperColumn c) => _widths[c.key] ?? c.width;
  List<SuperColumn> get leftPins => _leftPins;
  List<SuperColumn> get rightPins => _rightPins;

  // ── data pipeline ──
  List<SuperRow<R>> get _filtered {
    final q = _search.trim().toLowerCase();
    final c = cols;

    // Advanced filter takes precedence and ignores per-column filters.
    if (_advancedActive && _advanced.isNotEmpty) {
      bool matchesGlobal(SuperRow<R> r) {
        if (q.isEmpty) return true;
        for (final col in c) {
          if (SuperColumnLogic.toText(col, col.rawValue(r), r).toLowerCase().contains(q)) return true;
          if (SuperColumnLogic.arText(col, r).toLowerCase().contains(q)) return true;
        }
        return false;
      }

      bool matchesAdvanced(SuperRow<R> r) {
        for (final clause in _advanced) {
          final col = colByKey(clause.columnKey);
          if (col == null) continue;
          if (!SuperColumnLogic.matchesClause(col, r, clause)) return false;
        }
        return true;
      }

      return _rows.where((r) => matchesGlobal(r) && matchesAdvanced(r)).toList();
    }

    final active = activeColumnFilters;
    if (q.isEmpty && active.isEmpty) return _rows;

    final colFilters = <SuperColumn, String>{};
    active.forEach((key, value) {
      final col = colByKey(key);
      if (col != null) colFilters[col] = '$value'.trim().toLowerCase();
    });

    bool matchesGlobal(SuperRow<R> r) {
      if (q.isEmpty) return true;
      for (final col in c) {
        if (SuperColumnLogic.toText(col, col.rawValue(r), r).toLowerCase().contains(q)) return true;
        if (SuperColumnLogic.arText(col, r).toLowerCase().contains(q)) return true;
      }
      return false;
    }

    bool matchesColumns(SuperRow<R> r) {
      for (final entry in colFilters.entries) {
        final col = entry.key;
        final needle = entry.value;
        final hay = SuperColumnLogic.toText(col, col.rawValue(r), r).toLowerCase();
        final arHay = SuperColumnLogic.arText(col, r).toLowerCase();
        if (!hay.contains(needle) && !arHay.contains(needle)) return false;
      }
      return true;
    }

    return _rows.where((r) => matchesGlobal(r) && matchesColumns(r)).toList();
  }

  List<SuperRow<R>> get _sorted {
    final f = _filtered;
    if (_sort.key == null) return f;
    final c = colByKey(_sort.key!);
    if (c == null) return f;
    final out = [...f];
    out.sort((a, b) => SuperColumnLogic.compare(c, c.rawValue(a), c.rawValue(b)) * (_sort.ascending ? 1 : -1));
    return out;
  }

  int get pageCount {
    if (_pagination != SuperPagination.pages || grouped) return 1;
    final n = _sorted.length;
    return n == 0 ? 1 : ((n + pageSize - 1) ~/ pageSize);
  }

  List<RenderItem<R>> _renderCache = [];
  List<RenderItem<R>> _dataView = [];

  void _rebuildRenderList() {
    final sorted = _sorted;
    final list = <RenderItem<R>>[];
    final view = <RenderItem<R>>[];

    if (!grouped) {
      final arr = _pagination == SuperPagination.pages
          ? sorted.skip(_page * pageSize).take(pageSize).toList()
          : sorted;
      for (var i = 0; i < arr.length; i++) {
        final item = RenderItem<R>.data(row: arr[i], dataIndex: i, sourceIndex: _rows.indexOf(arr[i]));
        view.add(item);
        list.add(item);
      }
      _renderCache = list;
      _dataView = view;
      return;
    }

    final keys = _groupKeys.map(colByKey).whereType<SuperColumn>().toList();
    void rec(List<SuperRow<R>> items, int depth, String prefix) {
      final col = keys[depth];
      final map = <String, List<SuperRow<R>>>{};
      for (final row in items) {
        final v = SuperColumnLogic.toText(col, col.rawValue(row), row);
        map.putIfAbsent(v, () => []).add(row);
      }
      map.forEach((value, groupItems) {
        final path = '$prefix/$depth:$value';
        list.add(RenderItem<R>.group(
          groupCol: col,
          groupValue: value,
          groupCount: groupItems.length,
          depth: depth,
          path: path,
          groupRows: groupItems,
        ));
        if (isCollapsed(path)) return;
        if (depth + 1 < keys.length) {
          rec(groupItems, depth + 1, path);
        } else {
          for (final row in groupItems) {
            final di = view.length;
            final item = RenderItem<R>.data(row: row, dataIndex: di, sourceIndex: _rows.indexOf(row));
            view.add(item);
            list.add(item);
          }
        }
        if (groupFootersEnabled) {
          list.add(RenderItem<R>.groupFooter(
            groupCol: col,
            groupValue: value,
            groupCount: groupItems.length,
            depth: depth,
            path: path,
            groupRows: groupItems,
          ));
        }
      });
    }

    rec(sorted, 0, '');
    _renderCache = list;
    _dataView = view;
  }

  List<RenderItem<R>> get renderList {
    _rebuildRenderList();
    return _renderCache;
  }

  List<RenderItem<R>> get view {
    _rebuildRenderList();
    return _dataView;
  }

  int get nRows => view.length;
  List<SuperRow<R>> get sortedRows => _sorted;

  // ── sort ──
  void sortBy(SuperColumn c, bool ascending) {
    if (c.sortable == false) return;
    _sort = SortSpec(key: c.key, ascending: ascending);
    notifyListeners();
  }

  /// Remove any active sort, returning the table to its natural row order.
  void clearSort() {
    _sort = const SortSpec();
    notifyListeners();
  }

  // ── grouping ──
  /// Replace the current group-by set with [keys] in one call. Accepts hidden
  /// column keys — the table renders a group header row for each group even
  /// when the grouping column is never visible. Pass an empty list to clear all
  /// groups (equivalent to [clearGroups]). Resets the collapse state.
  void setGroupKeys(List<String> keys) {
    _groupKeys
      ..clear()
      ..addAll(keys);
    _collapsed.clear();
    notifyListeners();
  }

  void toggleGroup(String key) {
    if (_groupKeys.contains(key)) {
      _groupKeys.remove(key);
    } else {
      _groupKeys.add(key);
    }
    notifyListeners();
  }

  void clearGroups() {
    _groupKeys.clear();
    _collapsed.clear();
    notifyListeners();
  }

  void toggleCollapse(String path) {
    _collapsed[path] = !(_collapsed[path] ?? false);
    notifyListeners();
  }

  // ── pages ──
  void setPage(int p) {
    _page = p.clamp(0, pageCount - 1);
    notifyListeners();
  }

  // ── widths / reorder ──
  void setWidth(String key, double w) {
    _widths[key] = w.clamp(60.0, 520.0).toDouble();
    notifyListeners();
  }

  void resetWidth(String key) {
    _widths.remove(key);
    notifyListeners();
  }

  void reorder(int fromSlot, int toSlot) {
    if (fromSlot < 0 || fromSlot >= _order.length) return;
    var to = toSlot;
    if (to > fromSlot) to -= 1;
    to = to.clamp(0, _order.length - 1);
    final k = _order.removeAt(fromSlot);
    _order.insert(to, k);
    notifyListeners();
  }

  int slotOfKey(String key) => _order.indexOf(key);

  // ── selection helpers ──
  void _clampSelection() {
    _rebuildRenderList();
    final n = _dataView.length;
    _sel = CellPos(_sel.r.clamp(0, n == 0 ? 0 : n - 1), _sel.c.clamp(0, nCols == 0 ? 0 : nCols - 1));
  }

  bool _inRange(int r, int c) {
    final r0 = _anchor.r < _sel.r ? _anchor.r : _sel.r;
    final r1 = _anchor.r > _sel.r ? _anchor.r : _sel.r;
    final c0 = _anchor.c < _sel.c ? _anchor.c : _sel.c;
    final c1 = _anchor.c > _sel.c ? _anchor.c : _sel.c;
    return r >= r0 && r <= r1 && c >= c0 && c <= c1;
  }

  bool isCellSelected(int r, int c) {
    if (_rowBand.contains(r)) return true;
    if (rowMode) return _selRows.contains(r);
    if (_selectionMode == SuperSelectionMode.singleCell) return false;
    return _inRange(r, c) || _extraCells.contains('$r:$c');
  }

  Set<int> get rowBand => _rowBand;

  /// Select a whole row from the row-number gutter. Per 0.4.0, this does NOT
  /// move the active edit cursor — it only lights the row band (cell modes) or
  /// updates the row selection (row modes).
  void selectGutterRow(int r, {bool shift = false, bool meta = false}) {
    if (rowMode) {
      _rowBand.clear();
      if (_selectionMode == SuperSelectionMode.singleRow) {
        _selRows = {r};
        _anchor = CellPos(r, _sel.c);
      } else if (shift) {
        final lo = _min(_anchor.r, r);
        final hi = _max(_anchor.r, r);
        _selRows = {for (var i = lo; i <= hi; i++) i};
      } else if (meta) {
        _selRows = {..._selRows};
        _selRows.contains(r) ? _selRows.remove(r) : _selRows.add(r);
        _anchor = CellPos(r, _sel.c);
      } else {
        _selRows = {r};
        _anchor = CellPos(r, _sel.c);
      }
      notifyListeners();
      return;
    }
    // cell modes: light a full-row band WITHOUT touching the edit cursor (_sel).
    if (meta && multiSel) {
      _rowBand.contains(r) ? _rowBand.remove(r) : _rowBand.add(r);
    } else if (shift && multiSel) {
      final lo = _min(_sel.r, r);
      final hi = _max(_sel.r, r);
      _rowBand
        ..clear()
        ..addAll([for (var i = lo; i <= hi; i++) i]);
    } else {
      _rowBand
        ..clear()
        ..add(r);
    }
    notifyListeners();
  }

  bool get hasRange => _anchor.r != _sel.r || _anchor.c != _sel.c;

  void pick(int r, int c, {bool shift = false, bool meta = false}) {
    _rowBand.clear();
    _advanceOnEnter = false;
    if (rowMode) {
      if (_selectionMode == SuperSelectionMode.singleRow) {
        _selRows = {r};
        _anchor = CellPos(r, c);
      } else if (shift) {
        final lo = _anchor.r < r ? _anchor.r : r;
        final hi = _anchor.r > r ? _anchor.r : r;
        _selRows = {for (var i = lo; i <= hi; i++) i};
      } else if (meta) {
        _selRows = {..._selRows};
        _selRows.contains(r) ? _selRows.remove(r) : _selRows.add(r);
        _anchor = CellPos(r, c);
      } else {
        _selRows = {r};
        _anchor = CellPos(r, c);
      }
      _sel = CellPos(r, c);
    } else {
      if (_selectionMode == SuperSelectionMode.multiCells && meta) {
        for (var rr = _min(_anchor.r, _sel.r); rr <= _max(_anchor.r, _sel.r); rr++) {
          for (var cc = _min(_anchor.c, _sel.c); cc <= _max(_anchor.c, _sel.c); cc++) {
            _extraCells.add('$rr:$cc');
          }
        }
        final tok = '$r:$c';
        _extraCells.contains(tok) ? _extraCells.remove(tok) : _extraCells.add(tok);
        _sel = CellPos(r, c);
        _anchor = CellPos(r, c);
      } else if (_selectionMode == SuperSelectionMode.multiCells && shift) {
        _sel = CellPos(r, c);
      } else {
        _sel = CellPos(r, c);
        _anchor = CellPos(r, c);
        _extraCells.clear();
      }
    }
    notifyListeners();
  }

  int _min(int a, int b) => a < b ? a : b;
  int _max(int a, int b) => a > b ? a : b;

  // ── programmatic selection API ──
  /// Select a single cell (and park the cursor there).
  void selectCellAt(int r, int c, {bool focus = true}) {
    _rowBand.clear();
    _extraCells.clear();
    final rr = r.clamp(0, nRows == 0 ? 0 : nRows - 1);
    final cc = c.clamp(0, nCols == 0 ? 0 : nCols - 1);
    _sel = CellPos(rr, cc);
    _anchor = _sel;
    _selRows = {rr};
    if (focus) _focused = true;
    notifyListeners();
  }

  /// Select a discrete set of cells (multiCells mode recommended).
  void selectCells(Iterable<CellPos> cells, {bool focus = true}) {
    _rowBand.clear();
    _extraCells
      ..clear()
      ..addAll([for (final p in cells) '${p.r}:${p.c}']);
    if (cells.isNotEmpty) {
      final first = cells.first;
      _sel = first;
      _anchor = first;
    }
    if (focus) _focused = true;
    notifyListeners();
  }

  /// Select a single row.
  void selectRowAt(int r, {bool focus = true}) => selectRowsAt([r], focus: focus);

  /// Select a set of whole rows.
  void selectRowsAt(Iterable<int> rows, {bool focus = true}) {
    _rowBand
      ..clear()
      ..addAll(rows.map((r) => r.clamp(0, nRows == 0 ? 0 : nRows - 1)));
    if (rowMode) _selRows = Set.of(_rowBand);
    if (_rowBand.isNotEmpty) {
      _sel = CellPos(_rowBand.first, _sel.c);
      _anchor = _sel;
    }
    if (focus) _focused = true;
    notifyListeners();
  }

  /// Clear every selection (cells, rows, band) but keep the cursor position.
  void clearSelection() {
    _extraCells.clear();
    _rowBand.clear();
    _selRows = {_sel.r};
    _anchor = _sel;
    notifyListeners();
  }

  List<CellPos> selectedCells() {
    final out = <CellPos>[];
    if (rowMode) {
      final rs = _selRows.toList()..sort();
      for (final r in rs) {
        for (var c = 0; c < nCols; c++) {
          out.add(CellPos(r, c));
        }
      }
      return out;
    }
    final set = {..._extraCells};
    for (var r = _min(_anchor.r, _sel.r); r <= _max(_anchor.r, _sel.r); r++) {
      for (var c = _min(_anchor.c, _sel.c); c <= _max(_anchor.c, _sel.c); c++) {
        set.add('$r:$c');
      }
    }
    if (_selectionMode == SuperSelectionMode.singleCell) {
      set
        ..clear()
        ..add('${_sel.r}:${_sel.c}');
    }
    final parsed = set.map((s) {
      final p = s.split(':');
      return CellPos(int.parse(p[0]), int.parse(p[1]));
    }).toList()
      ..sort((a, b) => a.r != b.r ? a.r - b.r : a.c - b.c);
    return parsed;
  }

  // ── cursor movement ──
  void setCursor(CellPos t, {bool extend = false}) {
    _rowBand.clear();
    _advanceOnEnter = false;
    final n = nRows;
    t = CellPos(t.r.clamp(0, n == 0 ? 0 : n - 1), t.c.clamp(0, nCols == 0 ? 0 : nCols - 1));
    _sel = t;
    if (extend && multiSel) {
      if (rowMode) {
        final lo = _min(_anchor.r, t.r);
        final hi = _max(_anchor.r, t.r);
        _selRows = {for (var i = lo; i <= hi; i++) i};
      }
    } else {
      _anchor = t;
      if (rowMode) {
        _selRows = {t.r};
      } else {
        _extraCells.clear();
      }
    }
    notifyListeners();
  }

  void moveSel(int dr, int dc, {bool extend = false}) {
    var r = _sel.r + dr;
    var c = _sel.c + dc;
    if (c < 0) {
      c = nCols - 1;
      r -= 1;
    }
    if (c >= nCols) {
      c = 0;
      r += 1;
    }
    setCursor(CellPos(r, c), extend: extend);
  }

  /// Tab: next cell → wrap → **append a new row and focus its first cell**
  /// (editable only). Fixes the prior behaviour that did not move focus.
  void tabMove({bool back = false}) {
    var c = _sel.c + (back ? -1 : 1);
    var r = _sel.r;
    if (c < 0) {
      c = nCols - 1;
      r -= 1;
    }
    if (c >= nCols) {
      c = 0;
      r += 1;
    }
    if (r >= nRows) {
      if (_mode == SuperTableMode.editable && addRowEnabled && !grouped) {
        _applyRows([..._rows, _blankRow()]);
        _rebuildRenderList();
        final t = CellPos(nRows - 1, 0); // first cell of the freshly-added row
        _sel = t;
        _anchor = t;
        _selRows = {t.r};
        _extraCells.clear();
        _rowBand.clear();
        notifyListeners();
        return;
      }
      r = nRows - 1;
      c = nCols - 1;
    }
    if (r < 0) {
      r = 0;
      c = 0;
    }
    setCursor(CellPos(r, c));
  }

  // ── history ──
  /// Commit [next] as the new row list. When [record] is true an undo entry is
  /// pushed — [undoSnapshot] lets mutation sites that change cell values
  /// in place capture the state BEFORE the mutation (a snapshot taken here
  /// would already contain the new values and undo would be a no-op).
  void _applyRows(List<SuperRow<R>> next, {bool record = true, _HistoryEntry<R>? undoSnapshot}) {
    if (record) {
      _undo.add(undoSnapshot ?? _snapshot());
      if (_undo.length > 200) _undo.removeAt(0);
      _redo.clear();
    }
    _rows = next;
    onChange?.call(next);
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(_snapshot());
    _restore(_undo.removeLast());
    onChange?.call(_rows);
    notifyListeners();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(_snapshot());
    _restore(_redo.removeLast());
    onChange?.call(_rows);
    notifyListeners();
  }

  // ── editing ──
  bool canEdit(SuperColumn? c) =>
      _mode == SuperTableMode.editable &&
      c != null &&
      c.editable != false &&
      c.type != SuperColumnType.computed &&
      c.type != SuperColumnType.readonly;

  /// Row-aware editability: [canEdit] plus the optional [cellEditable] gate
  /// (1.0.0). The View consults this so locked rows render read-only.
  bool canEditRow(SuperColumn? col, SuperRow row) {
    if (!canEdit(col)) return false;
    final gate = cellEditable;
    return gate == null || gate(col!, row);
  }

  SuperRow<R> _blankRow() {
    final R backing = _emptyValue != null ? _emptyValue!() : (<String, dynamic>{} as R);
    final cells = <String, SuperCell>{};
    for (final col in _rawColumns) {
      var v = col.readBacking(backing);
      v ??= _defaultFor(col);
      cells[col.key] = SuperCell(columnKey: col.key, value: v);
      if (backing is Map && backing[col.key] == null) backing[col.key] = v;
    }
    return SuperRow<R>(value: backing, cells: cells, isNew: trackChanges);
  }

  void beginEdit({String? initial, int? r, int? c}) {
    final rr = r ?? _sel.r;
    final cc = c ?? _sel.c;
    final col = cc < cols.length ? cols[cc] : null;
    if (!canEdit(col)) return;
    final entry = rr < view.length ? view[rr] : null;
    if (entry?.row != null && !canEditRow(col, entry!.row!)) return;
    final cur = entry?.row?.cells[col!.key]?.value;
    _draft = initial ?? (cur == null ? '' : SuperColumnLogic.toText(col!, cur, entry!.row!));
    _editCell = CellPos(rr, cc);
    notifyListeners();
  }

  void setDraft(String v) {
    _draft = v;
  }

  /// Validate [value] for [col] in [row]/[cell]: built-in type rules, then the
  /// column's [SuperColumn.validator]. Returns an error code or null.
  String? _validate(SuperColumn col, SuperRow<R> row, SuperCell cell, Object? value) {
    final builtin = SuperColumnLogic.validateCell(col, value);
    if (builtin != null) return builtin;
    if (col.unique) {
      final u = _uniqueError(col, row, value);
      if (u != null) return u;
    }
    final v = col.validator;
    final ctx = viewContext;
    if (v != null && ctx != null) return v(ctx, this, row, cell, value);
    return null;
  }

  /// The `unique:` constraint for one candidate [value] of [col] in [row]:
  /// case-insensitive display-text comparison against every OTHER row.
  /// Blank values are exempt.
  String? _uniqueError(SuperColumn col, SuperRow<R> row, Object? value) {
    final text = SuperColumnLogic.toText(col, value, row).trim().toLowerCase();
    if (text.isEmpty) return null;
    for (final other in _rows) {
      if (identical(other, row)) continue;
      final t = SuperColumnLogic
          .toText(col, other.cells[col.key]?.value, other)
          .trim()
          .toLowerCase();
      if (t == text) return '“${col.label}” must be unique';
    }
    return null;
  }

  /// Run the column [SuperColumn.onChange] gate. Returns whether to accept.
  bool _runOnChange(SuperColumn col, SuperRow<R> row, SuperCell cell, Object? prev, Object? next) {
    final cb = col.onChange;
    final ctx = viewContext;
    if (cb == null || ctx == null) return true;
    return cb(ctx, this, row, cell, prev, next);
  }

  /// Write a committed value into a cell (used by Delete-clear + paste + the
  /// editor commit). Runs validation + onChange; updates `cell.error`; syncs the
  /// backing object via the column's `write` hook.
  void writeCell(int viewR, SuperColumn col, Object? val) {
    if (viewR >= view.length) return;
    final entry = view[viewR];
    final row = entry.row!;
    if (!canEditRow(col, row)) return;
    final cell = row.cells[col.key] ??= SuperCell(columnKey: col.key);
    final prev = cell.value;

    final snap = _snapshot(); // BEFORE validation/onChange (which may mutate siblings)
    final err = _validate(col, row, cell, val);
    if (!_runOnChange(col, row, cell, prev, val)) {
      cell.error = err;
      notifyListeners();
      return;
    }
    cell.value = val;
    cell.error = err;
    col.writeBacking(row.value, val);
    _applyRows([..._rows], undoSnapshot: snap); // record undo + notify host
    notifyListeners();
  }

  /// Commit the cell in edit, optionally moving the cursor by [move].
  void commit({CellPos? move, Object? override}) {
    if (_committing) return;
    _committing = true;
    final ec = _editCell;
    var armAdvance = false;
    if (ec != null) {
      final col = ec.c < cols.length ? cols[ec.c] : null;
      final entry = ec.r < view.length ? view[ec.r] : null;
      if (entry != null && col != null && canEditRow(col, entry.row!)) {
        final row = entry.row!;
        final cell = row.cells[col.key] ??= SuperCell(columnKey: col.key);
        final prev = cell.value;
        Object? val = override ?? _draft;
        // The editors commit typed overrides; the raw-draft fallback (e.g.
        // committing by clicking another cell) coerces numerics here so the
        // stored value keeps its type (change tracking stays clean).
        if (override == null && col.type.isNumeric) {
          final s = '$val'.trim();
          val = s.isEmpty ? '' : SuperColumnLogic.clampNum(SuperColumnLogic.numVal(s), col);
        }
        final snap = _snapshot(); // BEFORE the in-place mutation (undo correctness)
        final err = _validate(col, row, cell, val);
        final accepted = _runOnChange(col, row, cell, prev, val);
        if (accepted) {
          cell.value = val;
          cell.error = err;
          col.writeBacking(row.value, val);
          _applyRows([..._rows], undoSnapshot: snap);
        } else {
          cell.error = err;
        }
      }
      armAdvance = move == null &&
          (col?.type == SuperColumnType.combo || col?.type == SuperColumnType.enumeration);
    }
    _editCell = null;
    _advanceOnEnter = armAdvance;
    final baseR = ec?.r ?? _sel.r;
    final baseC = ec?.c ?? _sel.c;
    if (move != null) {
      var r = baseR + move.r;
      var cc = baseC + move.c;
      if (cc < 0) {
        cc = nCols - 1;
        r -= 1;
      }
      if (cc >= nCols) {
        cc = 0;
        r += 1;
      }
      if (r < 0) {
        r = 0;
        cc = 0;
      }
      if (r >= nRows) {
        if (addRowEnabled && !grouped) {
          _applyRows([..._rows, _blankRow()]);
          _rebuildRenderList();
          r = nRows - 1;
          cc = 0;
        } else {
          r = nRows - 1;
        }
      }
      final t = CellPos(r.clamp(0, nRows == 0 ? 0 : nRows - 1), cc.clamp(0, nCols == 0 ? 0 : nCols - 1));
      _sel = t;
      _anchor = t;
      _selRows = {t.r};
      _extraCells.clear();
      _rowBand.clear();
    }
    _committing = false;
    notifyListeners();
  }

  void cancelEdit() {
    _editCell = null;
    notifyListeners();
  }

  // ── row ops ──
  void addRow() {
    if (!addRowEnabled) return;
    _applyRows([..._rows, _blankRow()]);
    _rebuildRenderList();
    final at = nRows - 1;
    _sel = CellPos(at, 0);
    _anchor = _sel;
    _selRows = {at};
    notifyListeners();
  }

  void insertRow(int viewR, {required bool after}) {
    final entry = viewR < view.length ? view[viewR] : null;
    final next = [..._rows];
    final at = entry != null ? entry.sourceIndex + (after ? 1 : 0) : _rows.length;
    next.insert(at, _blankRow());
    _applyRows(next);
    _rebuildRenderList();
    _sel = CellPos((viewR + (after ? 1 : 0)).clamp(0, nRows == 0 ? 0 : nRows - 1), _sel.c);
    _anchor = _sel;
    notifyListeners();
  }

  /// Insert a fresh row immediately AFTER the focused row and move focus to the
  /// same column in the new row (Ctrl+Enter).
  void insertRowAfterFocus() {
    if (!canEditMode || grouped) return;
    final col = _sel.c;
    insertRow(_sel.r, after: true);
    _sel = CellPos((_sel.r).clamp(0, nRows == 0 ? 0 : nRows - 1), col);
    _anchor = _sel;
    _selRows = {_sel.r};
    notifyListeners();
  }

  /// Insert a fresh row immediately BEFORE the focused row and move focus to the
  /// same column in the new row (Shift+Ctrl+Enter).
  void insertRowBeforeFocus() {
    if (!canEditMode || grouped) return;
    final col = _sel.c;
    final at = _sel.r;
    insertRow(at, after: false);
    _sel = CellPos(at.clamp(0, nRows == 0 ? 0 : nRows - 1), col);
    _anchor = _sel;
    _selRows = {_sel.r};
    notifyListeners();
  }

  bool get canEditMode => _mode == SuperTableMode.editable;

  void duplicateRow([int? viewR]) {
    final vr = viewR ?? _sel.r;
    final entry = vr < view.length ? view[vr] : null;
    if (entry == null) return;
    final dup = entry.row!.copy();
    if (trackChanges) dup.isNew = true;
    final next = [..._rows];
    next.insert(entry.sourceIndex + 1, dup);
    _applyRows(next);
    _rebuildRenderList();
    _sel = CellPos((vr + 1).clamp(0, nRows == 0 ? 0 : nRows - 1), _sel.c);
    _anchor = _sel;
    notifyListeners();
  }

  void deleteRow([int? viewR]) {
    final vr = viewR ?? _sel.r;
    final entry = vr < view.length ? view[vr] : null;
    if (entry == null) return;
    final snap = _snapshot(); // BEFORE the deleted-row log gains an entry
    if (trackChanges) _deletedRows.add((index: entry.sourceIndex, row: entry.row!));
    _pruneCombos(entry.row!);
    _applyRows([
      for (var i = 0; i < _rows.length; i++)
        if (i != entry.sourceIndex) _rows[i]
    ], undoSnapshot: snap);
    final n = nRows;
    _sel = CellPos(_sel.r.clamp(0, n == 0 ? 0 : n - 1), _sel.c);
    _anchor = _sel;
    notifyListeners();
  }

  // ── manual row reordering (1.0.0) ──
  /// Move the row at view index [fromView] so it lands at view index [toView].
  /// No-op while grouped. Records undo and fires [onChange].
  void moveRow(int fromView, int toView) {
    if (grouped) return;
    final n = view.length;
    if (fromView < 0 || fromView >= n) return;
    final clampedTo = toView.clamp(0, n - 1);
    if (fromView == clampedTo) return;
    final fromSrc = view[fromView].sourceIndex;
    final toSrc = view[clampedTo].sourceIndex;
    final next = [..._rows];
    final row = next.removeAt(fromSrc);
    next.insert(toSrc.clamp(0, next.length), row);
    _applyRows(next);
    _rebuildRenderList();
    _sel = CellPos(clampedTo, _sel.c);
    _anchor = _sel;
    _selRows = {clampedTo};
    _rowBand
      ..clear()
      ..add(clampedTo);
    notifyListeners();
  }

  /// Move a row one position earlier (defaults to the focused row).
  void moveRowUp([int? viewR]) {
    final vr = viewR ?? _sel.r;
    if (vr > 0) moveRow(vr, vr - 1);
  }

  /// Move a row one position later (defaults to the focused row).
  void moveRowDown([int? viewR]) {
    final vr = viewR ?? _sel.r;
    if (vr < view.length - 1) moveRow(vr, vr + 1);
  }

  // ── fill down / fill right (2.1.0) ─────────────────────────
  /// Excel-style **fill down** (⌘/Ctrl+D): copy the top row of the selected
  /// range into every row below it, column by column. With a single cell
  /// selected, copies the cell directly above into it. Editable cell modes
  /// only; respects [cellEditable] locks, validates each write, skips
  /// `onChange` (like paste), and records ONE undo step.
  void fillDown() => _fill(vertical: true);

  /// Excel-style **fill right** (⌘/Ctrl+R): copy the leading column of the
  /// selected range into the columns to its right, row by row (values are
  /// coerced to each target column's type; incompatible cells are skipped).
  /// With a single cell selected, copies the cell to its left.
  void fillRight() => _fill(vertical: false);

  void _fill({required bool vertical}) {
    if (_mode != SuperTableMode.editable || !cellMode || nRows == 0) return;
    var r0 = _min(_anchor.r, _sel.r);
    final r1 = _max(_anchor.r, _sel.r);
    var c0 = _min(_anchor.c, _sel.c);
    final c1 = _max(_anchor.c, _sel.c);
    if (vertical && r0 == r1) {
      if (r0 == 0) return;
      r0 -= 1; // single row: pull from the row above
    }
    if (!vertical && c0 == c1) {
      if (c0 == 0) return;
      c0 -= 1; // single column: pull from the column to the left
    }
    final theCols = cols;
    final theView = view;
    final snap = _snapshot(); // ONE undo step for the whole fill
    var changed = 0;

    void writeInto(SuperColumn col, SuperRow<R> row, Object? v) {
      final cell = row.cells[col.key] ??= SuperCell(columnKey: col.key);
      if (cell.value == v) return;
      cell.value = v;
      cell.error = _validate(col, row, cell, v);
      col.writeBacking(row.value, v);
      changed++;
    }

    if (vertical) {
      final src = r0 < theView.length ? theView[r0].row : null;
      if (src == null) return;
      for (var cc = c0; cc <= c1 && cc < theCols.length; cc++) {
        final col = theCols[cc];
        if (!canEdit(col)) continue;
        final v = src.cells[col.key]?.value;
        for (var rr = r0 + 1; rr <= r1 && rr < theView.length; rr++) {
          final row = theView[rr].row!;
          if (!canEditRow(col, row)) continue;
          writeInto(col, row, v);
        }
      }
    } else {
      final srcCol = c0 < theCols.length ? theCols[c0] : null;
      if (srcCol == null) return;
      for (var rr = r0; rr <= r1 && rr < theView.length; rr++) {
        final row = theView[rr].row!;
        final v = row.cells[srcCol.key]?.value;
        for (var cc = c0 + 1; cc <= c1 && cc < theCols.length; cc++) {
          final col = theCols[cc];
          if (!canEditRow(col, row)) continue;
          final res = SuperColumnLogic.coercePaste(col, v);
          if (!res.ok) continue; // incompatible target type — skip the cell
          writeInto(col, row, res.value);
        }
      }
    }

    if (changed == 0) return;
    _applyRows([..._rows], undoSnapshot: snap);
    onNotify?.call(SuperNotifyKind.ok, 'Filled $changed cell${changed == 1 ? '' : 's'}');
    notifyListeners();
  }

  // ── clipboard ──
  List<Map<String, Object?>>? _buildSelectionJson() {
    final cells = selectedCells();
    if (cells.isEmpty) return null;
    final byRow = <int, Map<String, Object?>>{};
    for (final cell in cells) {
      final entry = cell.r < view.length ? view[cell.r] : null;
      final col = cell.c < cols.length ? cols[cell.c] : null;
      if (entry == null || col == null) continue;
      byRow.putIfAbsent(cell.r, () => {})[col.key] = col.rawValue(entry.row!);
    }
    final rs = byRow.keys.toList()..sort();
    return [for (final r in rs) byRow[r]!];
  }

  Future<void> copyJson() async {
    if (nRows == 0) return;
    final data = _buildSelectionJson();
    if (data == null) return;
    await Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data)));
    onNotify?.call(SuperNotifyKind.ok, 'Copied ${data.length} row${data.length == 1 ? '' : 's'} as JSON');
  }

  Future<void> copyRowsJson(List<int> viewRows) async {
    final data = <Map<String, Object?>>[];
    for (final vr in viewRows) {
      final entry = vr < view.length ? view[vr] : null;
      if (entry == null) continue;
      final o = <String, Object?>{};
      for (final c in cols) {
        o[c.key] = c.rawValue(entry.row!);
      }
      data.add(o);
    }
    if (data.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(data)));
    onNotify?.call(SuperNotifyKind.ok, 'Copied ${data.length} row${data.length == 1 ? '' : 's'} as JSON');
  }

  void cutRange() {
    if (_mode != SuperTableMode.editable || nRows == 0) return;
    copyJson();
    final snap = _snapshot(); // BEFORE the in-place cell clears
    final cells = selectedCells();
    var changed = false;
    for (final cell in cells) {
      final entry = cell.r < view.length ? view[cell.r] : null;
      final col = cell.c < cols.length ? cols[cell.c] : null;
      if (entry != null && col != null && canEditRow(col, entry.row!)) {
        final c = entry.row!.cells[col.key] ??= SuperCell(columnKey: col.key);
        c.value = '';
        c.error = SuperColumnLogic.validateCell(col, '');
        col.writeBacking(entry.row!.value, '');
        changed = true;
      }
    }
    if (changed) _applyRows([..._rows], undoSnapshot: snap);
    notifyListeners();
  }

  String? _applyJsonRows(List<dynamic> data) {
    final keyOf = {for (final c in cols) c.key: c};
    for (var i = 0; i < data.length; i++) {
      final obj = data[i];
      if (obj is! Map) return 'Row ${i + 1} is not an object';
      for (final field in obj.keys) {
        final col = keyOf[field];
        if (col == null) return 'Unknown field “$field” — not a column in this table';
        final res = SuperColumnLogic.coercePaste(col, obj[field]);
        if (!res.ok) return 'Row ${i + 1}: ${res.error}';
      }
    }
    final snap = _snapshot(); // BEFORE pasted values mutate cells in place
    final next = [..._rows];
    for (var i = 0; i < data.length; i++) {
      final obj = data[i] as Map;
      final vr = _sel.r + i;
      final entry = vr < view.length ? view[vr] : null;
      SuperRow<R> target;
      if (entry != null) {
        target = next[entry.sourceIndex];
      } else if (addRowEnabled && !grouped) {
        target = _blankRow();
        next.add(target);
      } else {
        continue;
      }
      for (final field in obj.keys) {
        final col = keyOf[field]!;
        final res = SuperColumnLogic.coercePaste(col, obj[field]);
        if (res.ok) {
          (target.cells[col.key] ??= SuperCell(columnKey: col.key)).value = res.value;
          col.writeBacking(target.value, res.value);
        }
      }
    }
    _applyRows(next, undoSnapshot: snap);
    return null;
  }

  String? _applyTsv(List<List<String>> grid) {
    final startC = _sel.c;
    for (var ri = 0; ri < grid.length; ri++) {
      for (var ci = 0; ci < grid[ri].length; ci++) {
        final col = (startC + ci) < cols.length ? cols[startC + ci] : null;
        if (col == null) return 'Pasted block is wider than the table (column ${startC + ci + 1} doesn\'t exist)';
        final res = SuperColumnLogic.coercePaste(col, grid[ri][ci]);
        if (!res.ok) return 'Cell ${ri + 1}×${ci + 1}: ${res.error}';
      }
    }
    final snap = _snapshot(); // BEFORE pasted values mutate cells in place
    final next = [..._rows];
    for (var ri = 0; ri < grid.length; ri++) {
      final vr = _sel.r + ri;
      final entry = vr < view.length ? view[vr] : null;
      SuperRow<R> target;
      if (entry != null) {
        target = next[entry.sourceIndex];
      } else if (addRowEnabled && !grouped) {
        target = _blankRow();
        next.add(target);
      } else {
        continue;
      }
      for (var ci = 0; ci < grid[ri].length; ci++) {
        final col = cols[startC + ci];
        final res = SuperColumnLogic.coercePaste(col, grid[ri][ci]);
        if (res.ok) {
          (target.cells[col.key] ??= SuperCell(columnKey: col.key)).value = res.value;
          col.writeBacking(target.value, res.value);
        }
      }
    }
    _applyRows(next, undoSnapshot: snap);
    return null;
  }

  Future<void> paste() async {
    if (_mode != SuperTableMode.editable) {
      onNotify?.call(SuperNotifyKind.error, 'Paste is only allowed in Editable mode');
      return;
    }
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (text.trim().isEmpty) return;
    final trimmed = text.trim();
    String? err;
    if (trimmed.startsWith('[') || trimmed.startsWith('{')) {
      dynamic parsed;
      try {
        parsed = jsonDecode(trimmed);
      } catch (_) {
        onNotify?.call(SuperNotifyKind.error, 'Clipboard is not valid JSON');
        return;
      }
      final list = parsed is List ? parsed : [parsed];
      err = _applyJsonRows(list);
    } else {
      final grid = text
          .replaceAll('\r', '')
          .replaceAll(RegExp(r'\n+$'), '')
          .split('\n')
          .map((l) => l.split('\t'))
          .toList();
      err = _applyTsv(grid);
    }
    if (err != null) {
      onNotify?.call(SuperNotifyKind.error, err);
    } else {
      onNotify?.call(SuperNotifyKind.ok, 'Pasted');
    }
    notifyListeners();
  }

  /// First-column text of a view row, for the delete-confirm message.
  String firstColText(int viewR) {
    if (cols.isEmpty || viewR >= view.length) return '';
    final entry = view[viewR];
    return SuperColumnLogic.toText(cols.first, cols.first.rawValue(entry.row!), entry.row!);
  }

  void selectAll() {
    if (rowMode) {
      _selRows = {for (var i = 0; i < nRows; i++) i};
    } else {
      _anchor = const CellPos(0, 0);
      _sel = CellPos(nRows - 1, nCols - 1);
      _extraCells.clear();
    }
    notifyListeners();
  }

  // ── combo per-cell registries ─────────────────────────────────
  String _comboKey(SuperRow row, String colKey) => '${row.id}:$colKey';

  /// The cached AutoSuggestions source for a cell (built by the View; rebuilt
  /// when the row's fingerPrint changes). Null until first edit-focus.
  AutoSuggestionsSource? comboSourceFor(SuperRow row, String colKey) =>
      _comboSources[_comboKey(row, colKey)];

  /// The cached AutoSuggestionsBoxController for a cell. Null until first
  /// edit-focus. Use this to drive the cell's box from outside (open/close,
  /// inspect the selection, etc.).
  AutoSuggestionsBoxController? comboControllerFor(SuperRow row, String colKey) =>
      _comboCtrls[_comboKey(row, colKey)];

  /// Whether a cell's combo resources are stale w.r.t. the row's fingerPrint
  /// (or have never been built). The View calls this to decide whether to
  /// rebuild them from the column's `sourceController` / `cellController`.
  bool comboNeedsRebuild(SuperRow row, String colKey) =>
      _comboFingerPrints[_comboKey(row, colKey)] != row.fingerPrint ||
      !_comboCtrls.containsKey(_comboKey(row, colKey));

  /// Register the freshly-built combo resources for a cell (called by the View).
  void registerCombo(
    SuperRow row,
    String colKey, {
    AutoSuggestionsSource? source,
    AutoSuggestionsBoxController? controller,
  }) {
    final k = _comboKey(row, colKey);
    if (source != null) _comboSources[k] = source;
    if (controller != null) _comboCtrls[k] = controller;
    _comboFingerPrints[k] = row.fingerPrint;
  }

  /// Drop a cell's cached combo resources (e.g. when the row is removed).
  void disposeCombo(SuperRow row, String colKey) {
    final k = _comboKey(row, colKey);
    _comboSources.remove(k);
    _comboCtrls.remove(k);
    _comboFingerPrints.remove(k);
  }

  /// Drop EVERY cached combo resource of [row] — called when the row leaves
  /// the table (delete / clear / revert-added) so the registries don't grow
  /// unbounded in long editing sessions.
  void _pruneCombos(SuperRow<R> row) {
    final prefix = '${row.id}:';
    _comboSources.removeWhere((k, _) => k.startsWith(prefix));
    _comboCtrls.removeWhere((k, _) => k.startsWith(prefix));
    _comboFingerPrints.removeWhere((k, _) => k.startsWith(prefix));
  }

  @override
  void dispose() {
    _comboCtrls.clear();
    _comboSources.clear();
    _comboFingerPrints.clear();
    super.dispose();
  }
}
