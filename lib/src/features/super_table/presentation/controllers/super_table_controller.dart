// ============================================================
// features/super_table/presentation/controllers/super_table_controller.dart
// ------------------------------------------------------------
// The MVC controller for the unified SuperTable — the single source of truth a
// thin View renders and forwards events to. It is a faithful port of the React
// component's hook state, holding:
//
//   • column resolution     — visibility ▸ pins ▸ user reorder ▸ widths
//   • the data pipeline      — search filter ▸ sort ▸ multi-level group ▸ paginate
//   • selection              — cursor + anchor range, discrete cells, whole rows
//                              across 4 selection modes
//   • editing                — begin / commit (+move) / cancel, per-cell drafts
//   • row ops                — add / insert / duplicate / delete
//   • clipboard              — copy & cut as JSON, paste (validated JSON or TSV)
//   • history                — undo / redo snapshots (depth 200)
//
// Rows are `Map<String,dynamic>`; the host passes them in and receives mutated
// copies through [onChange]. The controller never imports a widget.
// ============================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/super_column.dart';
import '../../domain/entities/super_table_state.dart';
import '../../domain/usecases/super_column_logic.dart';

class SuperTableController extends ChangeNotifier {
  SuperTableController({
    required List<SuperColumn> columns,
    required List<SuperRow> rows,
    this.mode = SuperTableMode.readable,
    SuperSelectionMode selectionMode = SuperSelectionMode.singleCell,
    this.addRowEnabled = false,
    this.search = '',
    this.pagination = SuperPagination.none,
    this.pageSize = 8,
    List<String>? visibleKeys,
    this.onChange,
    this.onNotify,
    this.onVisibleChange,
    this.onLoadMore,
    bool hasMore = false,
    bool loadingMore = false,
    SuperRow Function()? emptyRow,
  })  : _rawColumns = columns,
        _rows = rows,
        _selectionMode = selectionMode,
        _visibleKeys = visibleKeys,
        _hasMore = hasMore,
        _loadingMore = loadingMore,
        _emptyRow = emptyRow {
    _order = _midBase.map((c) => c.key).toList();
    _selRows = {0};
  }

  // ── config ──
  final SuperTableMode mode;
  final bool addRowEnabled;
  final SuperPagination pagination;
  final int pageSize;
  final void Function(List<SuperRow> next)? onChange;
  final void Function(SuperNotifyKind kind, String message)? onNotify;
  final void Function(List<String> next)? onVisibleChange;
  final void Function()? onLoadMore;
  final SuperRow Function()? _emptyRow;

  // ── infinite / load-more paging state (host-driven) ──
  bool _hasMore;
  bool _loadingMore;
  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  List<SuperColumn> _rawColumns;
  List<SuperRow> _rows;
  String search;
  List<String>? _visibleKeys;
  SuperSelectionMode _selectionMode;

  // ── selection / cursor state ──
  SuperCell _sel = const SuperCell(0, 0);
  SuperCell _anchor = const SuperCell(0, 0);
  final Set<String> _extraCells = {}; // discrete "r:c"
  Set<int> _selRows = {0};
  bool _focused = false;

  // ── editing state ──
  SuperCell? _editCell;
  String _draft = '';
  bool _committing = false;

  // ── view config state ──
  SortSpec _sort = const SortSpec();
  final Map<String, String> _colFilters = {}; // key → filter query (contains)
  final List<String> _groupKeys = [];
  final Map<String, bool> _collapsed = {};
  final Map<String, double> _widths = {};
  late List<String> _order;
  int _page = 0;

  // ── history ──
  final List<List<SuperRow>> _undo = [];
  final List<List<SuperRow>> _redo = [];

  // ── reads ──
  List<SuperRow> get rows => _rows;
  List<SuperColumn> get rawColumns => _rawColumns;
  SuperSelectionMode get selectionMode => _selectionMode;
  SuperCell get sel => _sel;
  SuperCell get anchor => _anchor;
  Set<int> get selRows => _selRows;
  bool get focused => _focused;
  SuperCell? get editCell => _editCell;
  String get draft => _draft;
  SortSpec get sort => _sort;

  /// The active per-column filter query for [key] (empty when unset).
  String columnFilter(String key) => _colFilters[key] ?? '';

  /// Whether any column filter is currently narrowing the view.
  bool get hasColumnFilters => _colFilters.values.any((v) => v.trim().isNotEmpty);

  /// Snapshot of active (non-empty) column filters, keyed by column key.
  Map<String, String> get activeColumnFilters => {
        for (final e in _colFilters.entries)
          if (e.value.trim().isNotEmpty) e.key: e.value,
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

  // ── host updates ──
  void updateRows(List<SuperRow> rows) {
    _rows = rows;
    _clampSelection();
    notifyListeners();
  }

  void updateColumns(List<SuperColumn> columns) {
    _rawColumns = columns;
    final keys = _midBase.map((c) => c.key).toList();
    final kept = _order.where(keys.contains).toList();
    final added = keys.where((k) => !kept.contains(k)).toList();
    _order = [...kept, ...added];
    notifyListeners();
  }

  void setVisibleKeys(List<String>? keys) {
    _visibleKeys = keys;
    notifyListeners();
  }

  /// Whether the header menu can offer “Hide column” (host wired or local keys).
  bool get canHideColumns => onVisibleChange != null || _visibleKeys != null;

  /// Count of currently-visible base columns (gates the last “Hide column”).
  int get visibleColumnCount => _baseCols.length;

  /// Hide one column — reports the next visible-key set to the host (and keeps a
  /// local copy so it reflects even without a host round-trip). Never hides the
  /// final column.
  void hideColumn(String key) {
    final cur = _visibleKeys ?? _rawColumns.map((c) => c.key).toList();
    final next = cur.where((k) => k != key).toList();
    if (next.isEmpty) return;
    onVisibleChange?.call(next);
    _visibleKeys = next;
    notifyListeners();
  }

  /// Update host-driven load-more flags (infinite scroll / Load more button).
  void setLoadMoreState({bool? hasMore, bool? loadingMore}) {
    if (hasMore != null) _hasMore = hasMore;
    if (loadingMore != null) _loadingMore = loadingMore;
    notifyListeners();
  }

  /// Ask the host to append the next page (no-op while already loading / done).
  void requestLoadMore() {
    if (_loadingMore || !_hasMore) return;
    onLoadMore?.call();
  }

  void setSearch(String q) {
    search = q;
    _page = 0;
    _clampSelection();
    notifyListeners();
  }

  /// Set (or clear, when [value] is blank) the contains-filter for one column.
  /// Filters combine with AND across columns and with the global [search].
  void setColumnFilter(String key, String value) {
    final v = value;
    if (v.trim().isEmpty) {
      if (!_colFilters.containsKey(key)) return;
      _colFilters.remove(key);
    } else {
      if (_colFilters[key] == v) return;
      _colFilters[key] = v;
    }
    _page = 0;
    _clampSelection();
    notifyListeners();
  }

  /// Clear every per-column filter at once.
  void clearColumnFilters() {
    if (_colFilters.isEmpty) return;
    _colFilters.clear();
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
  List<SuperColumn> get _baseCols =>
      _rawColumns.where((c) => _visibleKeys == null || _visibleKeys!.contains(c.key)).toList();
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

  /// The fully-resolved, ordered visible columns: left pins ▸ mid ▸ right pins.
  List<SuperColumn> get cols => [..._leftPins, ...midCols, ..._rightPins];
  int get nCols => cols.length;

  SuperColumn? colByKey(String k) =>
      _rawColumns.cast<SuperColumn?>().firstWhere((c) => c!.key == k, orElse: () => null);

  double widthOf(SuperColumn c) => _widths[c.key] ?? c.width;

  List<SuperColumn> get leftPins => _leftPins;
  List<SuperColumn> get rightPins => _rightPins;

  // ── data pipeline ──
  List<SuperRow> get _filtered {
    final q = search.trim().toLowerCase();
    final active = activeColumnFilters; // key → raw query
    if (q.isEmpty && active.isEmpty) return _rows;
    final c = cols;
    // Resolve column objects once for the active per-column filters.
    final colFilters = <SuperColumn, String>{};
    active.forEach((key, value) {
      final col = colByKey(key);
      if (col != null) colFilters[col] = value.trim().toLowerCase();
    });
    bool matchesGlobal(SuperRow r) {
      if (q.isEmpty) return true;
      for (final col in c) {
        if (SuperColumnLogic.toText(col, col.rawValue(r), r).toLowerCase().contains(q)) return true;
        if (col.arKey != null && '${r[col.arKey] ?? ''}'.toLowerCase().contains(q)) return true;
      }
      return false;
    }
    bool matchesColumns(SuperRow r) {
      for (final entry in colFilters.entries) {
        final col = entry.key;
        final needle = entry.value;
        final hay = SuperColumnLogic.toText(col, col.rawValue(r), r).toLowerCase();
        final arHay = col.arKey != null ? '${r[col.arKey] ?? ''}'.toLowerCase() : '';
        if (!hay.contains(needle) && !arHay.contains(needle)) return false;
      }
      return true;
    }
    return _rows.where((r) => matchesGlobal(r) && matchesColumns(r)).toList();
  }

  List<SuperRow> get _sorted {
    final f = _filtered;
    if (_sort.key == null) return f;
    final c = colByKey(_sort.key!);
    if (c == null) return f;
    final out = [...f];
    out.sort((a, b) => SuperColumnLogic.compare(c, c.rawValue(a), c.rawValue(b)) * (_sort.ascending ? 1 : -1));
    return out;
  }

  int get pageCount {
    if (pagination != SuperPagination.pages || grouped) return 1;
    final n = _sorted.length;
    return n == 0 ? 1 : ((n + pageSize - 1) ~/ pageSize);
  }

  /// Cache of the current view (data rows in render order).
  List<RenderItem> _renderCache = [];
  List<RenderItem> _dataView = [];

  void _rebuildRenderList() {
    final sorted = _sorted;
    final list = <RenderItem>[];
    final view = <RenderItem>[];

    if (!grouped) {
      final arr = pagination == SuperPagination.pages
          ? sorted.skip(_page * pageSize).take(pageSize).toList()
          : sorted;
      for (var i = 0; i < arr.length; i++) {
        final item = RenderItem.data(row: arr[i], dataIndex: i, sourceIndex: _rows.indexOf(arr[i]));
        view.add(item);
        list.add(item);
      }
      _renderCache = list;
      _dataView = view;
      return;
    }

    final keys = _groupKeys.map(colByKey).whereType<SuperColumn>().toList();
    void rec(List<SuperRow> items, int depth, String prefix) {
      final col = keys[depth];
      final map = <String, List<SuperRow>>{};
      for (final row in items) {
        final v = SuperColumnLogic.toText(col, col.rawValue(row), row);
        map.putIfAbsent(v, () => []).add(row);
      }
      map.forEach((value, groupItems) {
        final path = '$prefix/$depth:$value';
        list.add(RenderItem.group(
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
            final item = RenderItem.data(row: row, dataIndex: di, sourceIndex: _rows.indexOf(row));
            view.add(item);
            list.add(item);
          }
        }
      });
    }

    rec(sorted, 0, '');
    _renderCache = list;
    _dataView = view;
  }

  List<RenderItem> get renderList {
    _rebuildRenderList();
    return _renderCache;
  }

  List<RenderItem> get view {
    _rebuildRenderList();
    return _dataView;
  }

  int get nRows => view.length;
  List<SuperRow> get sortedRows => _sorted;

  // ── sort ──
  void sortBy(SuperColumn c, bool ascending) {
    if (c.sortable == false) return;
    _sort = SortSpec(key: c.key, ascending: ascending);
    notifyListeners();
  }

  // ── grouping ──
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
    _widths[key] = w.clamp(60.0, 520.0);
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
    _sel = SuperCell(_sel.r.clamp(0, n == 0 ? 0 : n - 1), _sel.c.clamp(0, nCols == 0 ? 0 : nCols - 1));
  }

  bool _inRange(int r, int c) {
    final r0 = _anchor.r < _sel.r ? _anchor.r : _sel.r;
    final r1 = _anchor.r > _sel.r ? _anchor.r : _sel.r;
    final c0 = _anchor.c < _sel.c ? _anchor.c : _sel.c;
    final c1 = _anchor.c > _sel.c ? _anchor.c : _sel.c;
    return r >= r0 && r <= r1 && c >= c0 && c <= c1;
  }

  /// Whether a body cell is visually selected under the current mode.
  bool isCellSelected(int r, int c) {
    if (rowMode) return _selRows.contains(r);
    if (_selectionMode == SuperSelectionMode.singleCell) return false;
    return _inRange(r, c) || _extraCells.contains('$r:$c');
  }

  bool get hasRange => _anchor.r != _sel.r || _anchor.c != _sel.c;

  /// Unified pointer selection honoring [shift] (range) / [meta] (discrete).
  void pick(int r, int c, {bool shift = false, bool meta = false}) {
    if (rowMode) {
      if (_selectionMode == SuperSelectionMode.singleRow) {
        _selRows = {r};
        _anchor = SuperCell(r, c);
      } else if (shift) {
        final lo = _anchor.r < r ? _anchor.r : r;
        final hi = _anchor.r > r ? _anchor.r : r;
        _selRows = {for (var i = lo; i <= hi; i++) i};
      } else if (meta) {
        _selRows = {..._selRows};
        if (_selRows.contains(r)) {
          _selRows.remove(r);
        } else {
          _selRows.add(r);
        }
        _anchor = SuperCell(r, c);
      } else {
        _selRows = {r};
        _anchor = SuperCell(r, c);
      }
      _sel = SuperCell(r, c);
    } else {
      if (_selectionMode == SuperSelectionMode.multiCells && meta) {
        for (var rr = _min(_anchor.r, _sel.r); rr <= _max(_anchor.r, _sel.r); rr++) {
          for (var cc = _min(_anchor.c, _sel.c); cc <= _max(_anchor.c, _sel.c); cc++) {
            _extraCells.add('$rr:$cc');
          }
        }
        final tok = '$r:$c';
        if (_extraCells.contains(tok)) {
          _extraCells.remove(tok);
        } else {
          _extraCells.add(tok);
        }
        _sel = SuperCell(r, c);
        _anchor = SuperCell(r, c);
      } else if (_selectionMode == SuperSelectionMode.multiCells && shift) {
        _sel = SuperCell(r, c);
      } else {
        _sel = SuperCell(r, c);
        _anchor = SuperCell(r, c);
        _extraCells.clear();
      }
    }
    notifyListeners();
  }

  int _min(int a, int b) => a < b ? a : b;
  int _max(int a, int b) => a > b ? a : b;

  /// Every selected cell as (r,c), in row→col order.
  List<SuperCell> selectedCells() {
    final out = <SuperCell>[];
    if (rowMode) {
      final rs = _selRows.toList()..sort();
      for (final r in rs) {
        for (var c = 0; c < nCols; c++) {
          out.add(SuperCell(r, c));
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
      return SuperCell(int.parse(p[0]), int.parse(p[1]));
    }).toList()
      ..sort((a, b) => a.r != b.r ? a.r - b.r : a.c - b.c);
    return parsed;
  }

  // ── cursor movement ──
  void setCursor(SuperCell t, {bool extend = false}) {
    final n = nRows;
    t = SuperCell(t.r.clamp(0, n == 0 ? 0 : n - 1), t.c.clamp(0, nCols == 0 ? 0 : nCols - 1));
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
    setCursor(SuperCell(r, c), extend: extend);
  }

  /// Tab: next cell → wrap → append a new row at the very end (editable only).
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
      if (mode == SuperTableMode.editable && addRowEnabled && !grouped) {
        _applyRows([..._rows, _blankRow()]);
        final t = SuperCell(nRows, 0);
        _sel = t;
        _anchor = t;
        _selRows = {nRows};
        _extraCells.clear();
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
    setCursor(SuperCell(r, c));
  }

  // ── history ──
  void _applyRows(List<SuperRow> next, {bool record = true}) {
    if (record) {
      _undo.add(_rows);
      if (_undo.length > 200) _undo.removeAt(0);
      _redo.clear();
    }
    _rows = next;
    onChange?.call(next);
  }

  void undo() {
    if (_undo.isEmpty) return;
    _redo.add(_rows);
    _rows = _undo.removeLast();
    onChange?.call(_rows);
    notifyListeners();
  }

  void redo() {
    if (_redo.isEmpty) return;
    _undo.add(_rows);
    _rows = _redo.removeLast();
    onChange?.call(_rows);
    notifyListeners();
  }

  // ── editing ──
  bool canEdit(SuperColumn? c) =>
      mode == SuperTableMode.editable &&
      c != null &&
      c.editable != false &&
      c.type != SuperColumnType.computed &&
      c.type != SuperColumnType.readonly;

  SuperRow _blankRow() {
    if (_emptyRow != null) return _emptyRow!();
    final r = <String, dynamic>{};
    for (final c in _rawColumns) {
      r[c.key] = c.type == SuperColumnType.enumeration && c.opts != null && c.opts!.isNotEmpty
          ? c.opts!.first
          : c.type == SuperColumnType.checkbox
              ? false
              : c.type == SuperColumnType.color
                  ? '#4A7CFF'
                  : '';
    }
    return r;
  }

  void beginEdit({String? initial, int? r, int? c}) {
    final rr = r ?? _sel.r;
    final cc = c ?? _sel.c;
    final col = cc < cols.length ? cols[cc] : null;
    if (!canEdit(col)) return;
    final cur = rr < view.length ? view[rr].row![col!.key] : '';
    _draft = initial ?? (cur == null ? '' : '$cur');
    _editCell = SuperCell(rr, cc);
    notifyListeners();
  }

  void setDraft(String v) {
    _draft = v;
  }

  void writeCell(int viewR, SuperColumn c, Object? val) {
    if (viewR >= view.length) return;
    final entry = view[viewR];
    _applyRows([
      for (var i = 0; i < _rows.length; i++)
        if (i == entry.sourceIndex) {..._rows[i], c.key: val} else _rows[i]
    ]);
    notifyListeners();
  }

  /// Commit the cell in edit, optionally moving the cursor by [move].
  void commit({SuperCell? move, Object? override}) {
    if (_committing) return;
    _committing = true;
    final ec = _editCell;
    var next = _rows;
    if (ec != null) {
      final col = ec.c < cols.length ? cols[ec.c] : null;
      final entry = ec.r < view.length ? view[ec.r] : null;
      final val = override ?? _draft;
      if (entry != null && col != null && canEdit(col)) {
        next = [
          for (var i = 0; i < _rows.length; i++)
            if (i == entry.sourceIndex) {..._rows[i], col.key: val} else _rows[i]
        ];
      }
    }
    _editCell = null;
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
          next = [...next, _blankRow()];
          r = nRows;
          cc = 0;
        } else {
          r = nRows - 1;
        }
      }
      final t = SuperCell(r.clamp(0, nRows), cc.clamp(0, nCols - 1));
      _sel = t;
      _anchor = t;
      _selRows = {t.r};
      _extraCells.clear();
    }
    if (!identical(next, _rows)) _applyRows(next);
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
    final at = nRows;
    _applyRows([..._rows, _blankRow()]);
    _sel = SuperCell(at, 0);
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
    _sel = SuperCell((viewR + (after ? 1 : 0)).clamp(0, nRows), _sel.c);
    _anchor = _sel;
    notifyListeners();
  }

  void duplicateRow([int? viewR]) {
    final vr = viewR ?? _sel.r;
    final entry = vr < view.length ? view[vr] : null;
    if (entry == null) return;
    final next = [..._rows];
    next.insert(entry.sourceIndex + 1, {...entry.row!});
    _applyRows(next);
    _sel = SuperCell(vr + 1, _sel.c);
    _anchor = _sel;
    notifyListeners();
  }

  void deleteRow([int? viewR]) {
    final vr = viewR ?? _sel.r;
    final entry = vr < view.length ? view[vr] : null;
    if (entry == null) return;
    _applyRows([
      for (var i = 0; i < _rows.length; i++)
        if (i != entry.sourceIndex) _rows[i]
    ]);
    final n = nRows;
    _sel = SuperCell(_sel.r.clamp(0, n == 0 ? 0 : n - 1), _sel.c);
    _anchor = _sel;
    notifyListeners();
  }

  // ── clipboard ──
  String _cellTextFor(int r, int c) {
    final entry = r < view.length ? view[r] : null;
    final col = c < cols.length ? cols[c] : null;
    if (entry == null || col == null) return '';
    return SuperColumnLogic.toText(col, col.rawValue(entry.row!), entry.row!);
  }

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
    if (mode != SuperTableMode.editable || nRows == 0) return;
    copyJson();
    final cells = selectedCells();
    final next = [for (final r in _rows) {...r}];
    var changed = false;
    for (final cell in cells) {
      final entry = cell.r < view.length ? view[cell.r] : null;
      final col = cell.c < cols.length ? cols[cell.c] : null;
      if (entry != null && col != null && canEdit(col)) {
        next[entry.sourceIndex][col.key] = '';
        changed = true;
      }
    }
    if (changed) _applyRows(next);
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
    final next = [for (final r in _rows) {...r}];
    for (var i = 0; i < data.length; i++) {
      final obj = data[i] as Map;
      final vr = _sel.r + i;
      final entry = vr < view.length ? view[vr] : null;
      int idx;
      if (entry != null) {
        idx = entry.sourceIndex;
      } else if (addRowEnabled && !grouped) {
        next.add(_blankRow());
        idx = next.length - 1;
      } else {
        continue;
      }
      for (final field in obj.keys) {
        final col = keyOf[field]!;
        final res = SuperColumnLogic.coercePaste(col, obj[field]);
        if (res.ok) next[idx][col.key] = res.value;
      }
    }
    _applyRows(next);
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
    final next = [for (final r in _rows) {...r}];
    for (var ri = 0; ri < grid.length; ri++) {
      final vr = _sel.r + ri;
      final entry = vr < view.length ? view[vr] : null;
      int idx;
      if (entry != null) {
        idx = entry.sourceIndex;
      } else if (addRowEnabled && !grouped) {
        next.add(_blankRow());
        idx = next.length - 1;
      } else {
        continue;
      }
      for (var ci = 0; ci < grid[ri].length; ci++) {
        final col = cols[startC + ci];
        final res = SuperColumnLogic.coercePaste(col, grid[ri][ci]);
        if (res.ok) next[idx][col.key] = res.value;
      }
    }
    _applyRows(next);
    return null;
  }

  Future<void> paste() async {
    if (mode != SuperTableMode.editable) {
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
    if (cols.isEmpty) return '';
    return _cellTextFor(viewR, 0);
  }

  void selectAll() {
    if (rowMode) {
      _selRows = {for (var i = 0; i < nRows; i++) i};
    } else {
      _anchor = const SuperCell(0, 0);
      _sel = SuperCell(nRows - 1, nCols - 1);
      _extraCells.clear();
    }
    notifyListeners();
  }
}
