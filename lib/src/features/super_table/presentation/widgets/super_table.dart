// ============================================================
// features/super_table/presentation/widgets/super_table.dart
// ------------------------------------------------------------
// The VIEW for the unified SuperTable — a thin, keyboard-first render of the
// SuperTableController. A 1:1 port of the React tool's grid:
//   • an editable-mode FORMULA BAR (Copy JSON · Undo · Redo · Shortcuts),
//   • a GROUPED-BY chips bar when grouping is active,
//   • a sticky header (optional type-tag sub-row, sort caret, resize grip,
//     drag-reorder, click-to-open header menu),
//   • a scrolling body of data rows + multi-level group headers (+ empty state),
//   • an optional totals row,
//   • an actionable trailing column (per-row delete / add-column header),
//   • a footer: load-more button / numbered pager / keyboard status hint.
//
// Every cell display + editor comes from `super_cell.dart`; menus, dialogs and
// the error badge from `super_table_overlays.dart`. All state lives in the
// controller; this widget paints it and forwards pointer + key intents, with
// scroll-on-focus + infinite-scroll wired to the controller.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../domain/entities/super_column.dart';
import '../../domain/entities/super_table_state.dart';
import '../../domain/usecases/super_column_logic.dart';
import '../controllers/super_table_controller.dart';
import 'super_cell.dart';
import 'super_table_overlays.dart';
import 'super_table_skin.dart';

const double _kRowH = 40;
const double _kRowHCompact = 32;
const double _kHeadFull = 46; // with the type-tag sub-row (readable)
const double _kHeadFlat = 38; // label only
const double _kGutter = 40; // row-number / select gutter
const double _kActionW = 46; // trailing action column

class SuperTable extends StatefulWidget {
  final SuperTableController controller;
  final SuperDensity density;

  /// Show the leading row-number gutter.
  final bool numbered;

  /// Show the type-tag header sub-row. Null → on in readable mode (React parity).
  final bool? showTypeTags;

  /// Show the totals row when any column declares an aggregate.
  final bool showTotals;

  /// Show the footer (status hint / pager / load-more).
  final bool showFooter;

  /// Show the editable-mode formula bar (Copy JSON · Undo · Redo · Shortcuts).
  final bool formulaBar;

  /// Optional add-column action in the trailing header cell.
  final VoidCallback? onAddColumn;

  /// Show a per-column filter row directly beneath the header. Combo/enum
  /// columns get a value dropdown, checkbox columns a tri-state, everything
  /// else a contains text field. Filters combine (AND) with each other and the
  /// global search.
  final bool columnFilters;

  /// Loading skeleton (renders shimmer rows instead of the body).
  final bool loading;

  /// Number of skeleton rows while [loading].
  final int skeletonRows;

  /// Outer max-height for the scroll viewport (used by infinite paging).
  final double? maxHeight;

  const SuperTable({
    super.key,
    required this.controller,
    this.density = SuperDensity.comfortable,
    this.numbered = true,
    this.showTypeTags,
    this.showTotals = true,
    this.showFooter = true,
    this.formulaBar = true,
    this.onAddColumn,
    this.columnFilters = true,
    this.loading = false,
    this.skeletonRows = 6,
    this.maxHeight,
  });

  @override
  State<SuperTable> createState() => _SuperTableState();
}

class _SuperTableState extends State<SuperTable> {
  final FocusNode _focus = FocusNode(debugLabel: 'SuperTable');
  final ScrollController _vScroll = ScrollController();
  final ScrollController _hScroll = ScrollController();
  final Map<String, TextEditingController> _filterCtrls = {};
  int? _dragSlot;
  int? _overSlot;
  SuperCell? _lastSel;

  SuperTableController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_onModel);
    _vScroll.addListener(_onVScroll);
    _lastSel = c.sel;
  }

  @override
  void didUpdateWidget(covariant SuperTable old) {
    super.didUpdateWidget(old);
    if (old.controller != c) {
      old.controller.removeListener(_onModel);
      c.addListener(_onModel);
    }
  }

  void _onModel() {
    if (!mounted) return;
    setState(() {});
    if (_lastSel != c.sel) {
      _lastSel = c.sel;
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisible());
    }
  }

  void _onVScroll() {
    if (c.pagination != SuperPagination.infinite || !_vScroll.hasClients) return;
    final p = _vScroll.position;
    if (p.pixels >= p.maxScrollExtent - 80) c.requestLoadMore();
  }

  @override
  void dispose() {
    c.removeListener(_onModel);
    for (final ctrl in _filterCtrls.values) {
      ctrl.dispose();
    }
    _focus.dispose();
    _vScroll.dispose();
    _hScroll.dispose();
    super.dispose();
  }

  double get _rowH => widget.density == SuperDensity.compact ? _kRowHCompact : _kRowH;
  bool get _showTypeTags => widget.showTypeTags ?? (c.mode == SuperTableMode.readable);
  double get _headH => _showTypeTags ? _kHeadFull : _kHeadFlat;
  bool get _deleteCol => c.mode == SuperTableMode.editable;
  bool get _actionable => _deleteCol || widget.onAddColumn != null;
  double get _gutterW => widget.numbered ? _kGutter : 0;
  double get _actW => _actionable ? _kActionW : 0;
  bool get _editable => c.mode == SuperTableMode.editable;

  // ── scroll the active cell into view (React useLayoutEffect parity) ──
  void _ensureVisible() {
    final sel = c.sel;
    if (_vScroll.hasClients) {
      final flat = c.renderList.indexWhere((it) => !it.isGroup && it.dataIndex == sel.r);
      if (flat >= 0) {
        final top = flat * _rowH, bottom = top + _rowH;
        final vpTop = _vScroll.offset, vpH = _vScroll.position.viewportDimension;
        double? to;
        if (top < vpTop) {
          to = top;
        } else if (bottom > vpTop + vpH) {
          to = bottom - vpH;
        }
        if (to != null) _vScroll.jumpTo(to.clamp(0.0, _vScroll.position.maxScrollExtent));
      }
    }
    if (_hScroll.hasClients && !context.isRtl) {
      final cols = c.cols;
      double x = _gutterW;
      for (var i = 0; i < sel.c && i < cols.length; i++) {
        x += c.widthOf(cols[i]);
      }
      final w = sel.c < cols.length ? c.widthOf(cols[sel.c]) : 0;
      final left = x, right = x + w;
      final vpL = _hScroll.offset, vpW = _hScroll.position.viewportDimension;
      double? to;
      if (left < vpL + _gutterW) {
        to = left - _gutterW;
      } else if (right > vpL + vpW) {
        to = right - vpW;
      }
      if (to != null) _hScroll.jumpTo(to.clamp(0.0, _hScroll.position.maxScrollExtent));
    }
  }

  bool _meta(Set<LogicalKeyboardKey> keys) =>
      keys.contains(LogicalKeyboardKey.metaLeft) ||
      keys.contains(LogicalKeyboardKey.metaRight) ||
      keys.contains(LogicalKeyboardKey.controlLeft) ||
      keys.contains(LogicalKeyboardKey.controlRight);

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    if (c.editCell != null) return KeyEventResult.ignored; // editor owns keys

    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final meta = _meta(keys);
    final k = e.logicalKey;
    final ed = _editable;

    // ── meta combos ──
    if (meta) {
      if (k == LogicalKeyboardKey.keyC) {
        c.copyJson();
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.keyV) {
        c.paste(); // paste() guards readable mode and notifies on its own
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.keyX && ed) {
        c.cutRange();
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.keyA) {
        c.selectAll();
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.keyZ) {
        shift ? c.redo() : c.undo();
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.keyY) {
        c.redo();
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.keyD && ed) {
        c.duplicateRow();
        return KeyEventResult.handled;
      }
      if ((k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) && ed && c.addRowEnabled) {
        c.addRow();
        return KeyEventResult.handled;
      }
      if ((k == LogicalKeyboardKey.backspace || k == LogicalKeyboardKey.delete) && ed) {
        _confirmDeleteRow();
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.home) {
        c.setCursor(const SuperCell(0, 0), extend: shift);
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.end) {
        c.setCursor(SuperCell(c.nRows - 1, c.nCols - 1), extend: shift);
        return KeyEventResult.handled;
      }
    }

    // ── tab (both modes; appends a row only in editable) ──
    if (k == LogicalKeyboardKey.tab) {
      c.tabMove(back: shift);
      return KeyEventResult.handled;
    }

    // ── navigation ──
    switch (k) {
      case LogicalKeyboardKey.arrowRight:
        c.moveSel(0, context.isRtl ? -1 : 1, extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft:
        c.moveSel(0, context.isRtl ? 1 : -1, extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowDown:
        c.moveSel(1, 0, extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        c.moveSel(-1, 0, extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.home:
        c.setCursor(SuperCell(c.sel.r, 0), extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.end:
        c.setCursor(SuperCell(c.sel.r, c.nCols - 1), extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageUp:
        c.setCursor(SuperCell(0, c.sel.c), extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageDown:
        c.setCursor(SuperCell(c.nRows - 1, c.sel.c), extend: shift);
        return KeyEventResult.handled;
    }

    if (!ed) return KeyEventResult.ignored;

    // ── edit triggers ──
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter || k == LogicalKeyboardKey.f2) {
      c.beginEdit();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.backspace || k == LogicalKeyboardKey.delete) {
      // React parity: plain Delete clears ONLY the active cell.
      final col = c.sel.c < c.cols.length ? c.cols[c.sel.c] : null;
      if (col != null && c.canEdit(col)) c.writeCell(c.sel.r, col, '');
      return KeyEventResult.handled;
    }
    final ch = e.character;
    if (ch != null && ch.isNotEmpty && ch.codeUnitAt(0) >= 32 && !meta) {
      c.beginEdit(initial: ch == ' ' ? '' : ch);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _confirmDeleteRow([int? viewR]) async {
    final vr = viewR ?? c.sel.r;
    if (vr >= c.nRows) return;
    final label = c.firstColText(vr);
    final ok = await showSuperConfirm(
      context,
      title: 'Delete row?',
      body: 'Row ${vr + 1} (${label.isEmpty ? '—' : label}) will be permanently removed. This cannot be undone.',
    );
    if (ok) c.deleteRow(vr);
  }

  // ── header menu ──
  void _openHeaderMenu(SuperColumn col, Offset pos) {
    final entries = <SuperMenuEntry>[];
    if (col.sortable) {
      entries.add(SuperMenuEntry(
        icon: Icons.arrow_upward_rounded,
        label: 'Sort ascending',
        checked: c.sort.key == col.key && c.sort.ascending,
        onTap: () => c.sortBy(col, true),
      ));
      entries.add(SuperMenuEntry(
        icon: Icons.arrow_downward_rounded,
        label: 'Sort descending',
        checked: c.sort.key == col.key && !c.sort.ascending,
        onTap: () => c.sortBy(col, false),
      ));
    }
    entries.add(SuperMenuEntry(
      icon: Icons.workspaces_outline,
      label: c.groupKeys.contains(col.key) ? 'Remove from grouping' : 'Group by this column',
      separatorBefore: true,
      checked: c.groupKeys.contains(col.key),
      onTap: () => c.toggleGroup(col.key),
    ));
    if (c.canHideColumns) {
      entries.add(SuperMenuEntry(
        icon: Icons.visibility_off_outlined,
        label: 'Hide column',
        separatorBefore: true,
        disabled: c.visibleColumnCount <= 1,
        onTap: () => c.hideColumn(col.key),
      ));
    }
    showSuperMenu(context, globalPos: pos, entries: entries);
  }

  void _openRowMenu(int viewR, Offset pos) {
    final entries = <SuperMenuEntry>[
      SuperMenuEntry(
        icon: Icons.content_copy_rounded,
        label: 'Copy as JSON',
        hint: '⌘C',
        onTap: () => (c.rowMode && c.selRows.isNotEmpty) ? c.copyRowsJson(c.selRows.toList()) : c.copyRowsJson([viewR]),
      ),
    ];
    if (_editable) {
      entries.addAll([
        SuperMenuEntry(icon: Icons.vertical_align_top_rounded, label: 'Insert row above', separatorBefore: true, onTap: () => c.insertRow(viewR, after: false)),
        SuperMenuEntry(icon: Icons.vertical_align_bottom_rounded, label: 'Insert row below', onTap: () => c.insertRow(viewR, after: true)),
        SuperMenuEntry(icon: Icons.copy_all_rounded, label: 'Duplicate row', hint: '⌘D', onTap: () => c.duplicateRow(viewR)),
        SuperMenuEntry(icon: Icons.delete_outline_rounded, label: 'Delete row', hint: '⌘⌫', danger: true, separatorBefore: true, onTap: () => _confirmDeleteRow(viewR)),
      ]);
    } else {
      final active = c.sel.c < c.cols.length ? c.cols[c.sel.c] : null;
      if (active != null) {
        entries.add(SuperMenuEntry(
          icon: Icons.workspaces_outline,
          label: 'Group by ${active.label}',
          separatorBefore: true,
          onTap: () => c.toggleGroup(active.key),
        ));
      }
    }
    showSuperMenu(context, globalPos: pos, entries: entries);
  }

  @override
  Widget build(BuildContext context) {
    final skin = SuperTableSkin.of(context);
    final cols = c.cols;
    final totalW = _gutterW + cols.fold<double>(0, (a, col) => a + c.widthOf(col)) + _actW;
    final minW = totalW < 320 ? 320.0 : totalW;

    return Focus(
      focusNode: _focus,
      onKeyEvent: _onKey,
      onFocusChange: c.setFocused,
      child: GestureDetector(
        onTap: () => _focus.requestFocus(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.formulaBar && _editable) _buildFormulaBar(skin),
            if (c.grouped) _buildGroupBar(skin),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: skin.surface,
                  border: Border.all(color: skin.borderStrong),
                  borderRadius: BorderRadius.circular(SuperTokens.radiusCard),
                  boxShadow: c.focused
                      ? [BoxShadow(color: skin.accent, blurRadius: 0, spreadRadius: 1)]
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                constraints: widget.maxHeight != null ? BoxConstraints(maxHeight: widget.maxHeight!) : const BoxConstraints(),
                child: Scrollbar(
                  controller: _hScroll,
                  notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _hScroll,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: minW,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(skin, cols),
                          if (widget.columnFilters) _buildFilterRow(skin, cols),
                          Flexible(
                            child: widget.loading
                                ? _buildSkeleton(skin, cols)
                                : (c.nRows == 0 && c.renderList.isEmpty)
                                    ? _buildEmpty(skin)
                                    : Scrollbar(
                                        controller: _vScroll,
                                        child: ListView.builder(
                                          controller: _vScroll,
                                          primary: false,
                                          shrinkWrap: true,
                                          itemCount: c.renderList.length,
                                          itemBuilder: (ctx, i) => _buildRenderItem(skin, cols, c.renderList[i]),
                                        ),
                                      ),
                          ),
                          if (!widget.loading && c.loadingMore)
                            for (var i = 0; i < widget.skeletonRows; i++) _skeletonRow(skin, cols),
                          if (widget.showTotals && _hasTotals(cols) && !widget.loading && c.nRows > 0) _buildTotals(skin, cols),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.showFooter) ..._buildFooterStack(skin),
          ],
        ),
      ),
    );
  }

  bool _hasTotals(List<SuperColumn> cols) => cols.any((c) => c.agg != SuperAgg.none);

  // ── formula bar (editable) ──
  Widget _buildFormulaBar(SuperTableSkin skin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        const Spacer(),
        _BarButton(skin: skin, icon: Icons.content_copy_rounded, label: 'Copy JSON', onTap: () => (c.rowMode && c.selRows.isNotEmpty) ? c.copyRowsJson(c.selRows.toList()) : c.copyJson()),
        const SizedBox(width: 8),
        _BarButton(skin: skin, icon: Icons.undo_rounded, enabled: c.canUndo, onTap: c.undo),
        const SizedBox(width: 8),
        _BarButton(skin: skin, icon: Icons.redo_rounded, enabled: c.canRedo, onTap: c.redo),
        const SizedBox(width: 8),
        _BarButton(skin: skin, icon: Icons.keyboard_rounded, label: 'Shortcuts', onTap: () => showSuperShortcuts(context)),
      ]),
    );
  }

  // ── grouped-by chips bar ──
  Widget _buildGroupBar(SuperTableSkin skin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.workspaces_outline, size: 13, color: skin.accent),
            const SizedBox(width: 6),
            Text('GROUPED BY',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.7, color: skin.fg3)),
          ]),
          for (var i = 0; i < c.groupKeys.length; i++)
            _groupChip(skin, i, c.groupKeys[i]),
          GestureDetector(
            onTap: c.clearGroups,
            child: Text('Clear all',
                style: TextStyle(fontSize: 11.5, color: skin.fg3, decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  Widget _groupChip(SuperTableSkin skin, int i, String key) {
    final col = c.colByKey(key);
    return Container(
      height: 26,
      padding: const EdgeInsetsDirectional.only(start: 11, end: 6),
      decoration: BoxDecoration(
        color: skin.inputBg,
        border: Border.all(color: skin.borderStrong),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('${i + 1}', style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 10, color: skin.fg4)),
        const SizedBox(width: 6),
        Text(col?.label ?? key, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: skin.fg1)),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: () => c.toggleGroup(key),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Icon(Icons.close_rounded, size: 12, color: skin.fg3),
          ),
        ),
      ]),
    );
  }

  // ── header ──
  Widget _buildHeader(SuperTableSkin skin, List<SuperColumn> cols) {
    return Container(
      height: _headH,
      decoration: BoxDecoration(
        color: skin.bg,
        border: Border(bottom: BorderSide(color: skin.borderStrong)),
      ),
      child: Row(children: [
        if (widget.numbered) _gutterHead(skin),
        for (final col in cols) _headerCell(skin, col),
        if (_actionable) _actionHead(skin),
      ]),
    );
  }

  Widget _gutterHead(SuperTableSkin skin) {
    return Container(
      width: _gutterW,
      decoration: BoxDecoration(
        border: BorderDirectional(end: BorderSide(color: skin.border)),
      ),
    );
  }

  Widget _actionHead(SuperTableSkin skin) {
    return Container(
      width: _actW,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: BorderDirectional(start: BorderSide(color: skin.border)),
      ),
      child: widget.onAddColumn != null
          ? _IconHoverButton(
              skin: skin,
              icon: Icons.add_rounded,
              tooltip: 'Add column',
              onTap: widget.onAddColumn!,
            )
          : Icon(Icons.delete_outline_rounded, size: 13, color: skin.fg4),
    );
  }

  // ── per-column filter row (under the header) ──
  static const double _kFilterH = 38;

  TextEditingController _filterCtrl(String key) {
    final existing = _filterCtrls[key];
    final current = c.columnFilter(key);
    if (existing != null) {
      if (existing.text != current) {
        existing.value = TextEditingValue(
          text: current,
          selection: TextSelection.collapsed(offset: current.length),
        );
      }
      return existing;
    }
    final ctrl = TextEditingController(text: current);
    _filterCtrls[key] = ctrl;
    return ctrl;
  }

  Widget _buildFilterRow(SuperTableSkin skin, List<SuperColumn> cols) {
    return Container(
      height: _kFilterH,
      decoration: BoxDecoration(
        color: skin.surface2,
        border: Border(bottom: BorderSide(color: skin.border)),
      ),
      child: Row(children: [
        if (widget.numbered) _filterGutter(skin),
        for (final col in cols) _filterCell(skin, col),
        if (_actionable) _filterAction(skin),
      ]),
    );
  }

  Widget _filterGutter(SuperTableSkin skin) {
    final active = c.hasColumnFilters;
    return Container(
      width: _gutterW,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: BorderDirectional(end: BorderSide(color: skin.border)),
      ),
      child: _IconHoverButton(
        skin: skin,
        icon: active ? Icons.filter_alt_off_rounded : Icons.filter_alt_outlined,
        tooltip: active ? 'Clear all filters' : 'Filter rows',
        onTap: active ? c.clearColumnFilters : () {},
      ),
    );
  }

  Widget _filterAction(SuperTableSkin skin) {
    return Container(
      width: _actW,
      decoration: BoxDecoration(
        border: BorderDirectional(start: BorderSide(color: skin.border)),
      ),
    );
  }

  Widget _filterCell(SuperTableSkin skin, SuperColumn col) {
    final w = c.widthOf(col);
    final current = c.columnFilter(col.key);
    final filterable = col.type != SuperColumnType.color;

    Widget field;
    if (!filterable) {
      field = const SizedBox.shrink();
    } else if (col.type == SuperColumnType.enumeration ||
        col.type == SuperColumnType.combo) {
      field = _filterDropdown(skin, col, current, options: col.opts ?? const []);
    } else if (col.type == SuperColumnType.checkbox) {
      field = _filterDropdown(skin, col, current,
          options: const ['Yes', 'No'],
          labelFor: (v) => v == 'Yes' ? 'Checked' : 'Unchecked');
    } else {
      field = _filterText(skin, col, current);
    }

    return Container(
      width: w,
      height: _kFilterH,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        border: BorderDirectional(end: BorderSide(color: skin.border)),
      ),
      alignment: Alignment.center,
      child: field,
    );
  }

  Widget _filterText(SuperTableSkin skin, SuperColumn col, String current) {
    final isEnd = col.align == SuperAlign.end;
    final active = current.trim().isNotEmpty;
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: skin.inputBg,
        borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
        border: Border.all(color: active ? skin.accent : skin.border),
      ),
      padding: const EdgeInsetsDirectional.only(start: 8, end: 4),
      child: Row(children: [
        Icon(Icons.search_rounded, size: 13, color: active ? skin.accent : skin.fg4),
        const SizedBox(width: 5),
        Expanded(
          child: TextField(
            controller: _filterCtrl(col.key),
            onChanged: (v) => c.setColumnFilter(col.key, v),
            textAlign: isEnd ? TextAlign.right : TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(
              fontFamily: col.mono ? SuperTokensFonts.mono : SuperTokensFonts.body,
              fontSize: 12,
              color: skin.fg1,
            ),
            cursorColor: skin.accent,
            cursorHeight: 14,
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              hintText: 'Filter…',
              hintStyle: TextStyle(fontSize: 12, color: skin.fg4),
            ),
          ),
        ),
        if (active)
          GestureDetector(
            onTap: () {
              c.setColumnFilter(col.key, '');
              _filterCtrls[col.key]?.clear();
            },
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Icon(Icons.close_rounded, size: 13, color: skin.fg3),
            ),
          ),
      ]),
    );
  }

  Widget _filterDropdown(
    SuperTableSkin skin,
    SuperColumn col,
    String current, {
    required List<String> options,
    String Function(String)? labelFor,
  }) {
    final active = current.trim().isNotEmpty;
    final label = active ? (labelFor?.call(current) ?? current) : 'All';
    return _DropdownTap(
      onOpen: (pos) {
        final entries = <SuperMenuEntry>[
          SuperMenuEntry(
            label: 'All',
            checked: !active,
            onTap: () => c.setColumnFilter(col.key, ''),
          ),
          for (final o in options)
            SuperMenuEntry(
              label: labelFor?.call(o) ?? o,
              checked: current == o,
              onTap: () => c.setColumnFilter(col.key, o),
            ),
        ];
        showSuperMenu(context, globalPos: pos, entries: entries);
      },
      child: Container(
        height: 28,
        padding: const EdgeInsetsDirectional.only(start: 8, end: 5),
        decoration: BoxDecoration(
          color: skin.inputBg,
          borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
          border: Border.all(color: active ? skin.accent : skin.border),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? skin.fg1 : skin.fg4,
              ),
            ),
          ),
          const SizedBox(width: 2),
          Icon(Icons.expand_more_rounded, size: 14, color: active ? skin.accent : skin.fg4),
        ]),
      ),
    );
  }

  Widget _headerCell(SuperTableSkin skin, SuperColumn col) {
    final w = c.widthOf(col);
    final active = c.sort.key == col.key;
    final slot = c.slotOfKey(col.key);
    final isPinned = col.pin != SuperPin.none;
    final draggable = slot >= 0; // mid columns only
    final inGroup = c.groupKeys.contains(col.key);
    final isDropTarget = _overSlot == slot && _dragSlot != null && _dragSlot != slot;

    final tagRow = _showTypeTags
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            if (draggable) ...[Icon(Icons.drag_indicator_rounded, size: 10, color: skin.fg4), const SizedBox(width: 4)],
            if (isPinned) ...[Icon(Icons.push_pin_outlined, size: 9, color: skin.accent), const SizedBox(width: 4)],
            if (inGroup) ...[Icon(Icons.layers_rounded, size: 9, color: skin.accent), const SizedBox(width: 4)],
            Text(col.type.wire.toUpperCase(),
                style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 8.5, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: skin.accent)),
          ])
        : null;

    final isEnd = col.align == SuperAlign.end;
    final labelRow = Row(
      mainAxisAlignment: isEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!_showTypeTags && draggable) ...[Icon(Icons.drag_indicator_rounded, size: 11, color: skin.fg4), const SizedBox(width: 4)],
        Flexible(
          child: Text(
            col.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: SuperTokensFonts.body,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: active || inGroup ? skin.fg1 : skin.fg3,
            ),
          ),
        ),
        if (col.required) Text(' *', style: TextStyle(fontSize: 11, color: skin.danger)),
        if (active) ...[
          const SizedBox(width: 3),
          Icon(c.sort.ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 11, color: skin.accent),
        ],
        if (!isEnd) const Spacer(),
        const SizedBox(width: 5),
        Icon(Icons.expand_more_rounded, size: 12, color: skin.fg4),
      ],
    );

    Widget inner = Container(
      width: w,
      height: _headH,
      padding: EdgeInsets.symmetric(horizontal: 11, vertical: _showTypeTags ? 6 : 0),
      decoration: BoxDecoration(
        color: isDropTarget ? skin.accentWash(0.12) : skin.bg,
        border: BorderDirectional(
          start: isDropTarget ? BorderSide(color: skin.accent, width: 2) : BorderSide.none,
          end: BorderSide(color: skin.border),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tagRow != null) ...[tagRow, const SizedBox(height: 2)],
          labelRow,
        ],
      ),
    );

    Widget cell = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) => _openHeaderMenu(col, d.globalPosition),
      onSecondaryTapDown: (d) => _openHeaderMenu(col, d.globalPosition),
      child: MouseRegion(cursor: SystemMouseCursors.click, child: inner),
    );

    // resize grip
    cell = Stack(children: [
      cell,
      PositionedDirectional(
        end: -3,
        top: 0,
        bottom: 0,
        width: 8,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeColumn,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (d) {
              final dir = context.isRtl ? -1 : 1;
              c.setWidth(col.key, c.widthOf(col) + d.delta.dx * dir);
            },
            onDoubleTap: () => c.resetWidth(col.key),
          ),
        ),
      ),
    ]);

    if (draggable) {
      return DragTarget<int>(
        onWillAcceptWithDetails: (d) {
          setState(() => _overSlot = slot);
          return true;
        },
        onLeave: (_) => setState(() => _overSlot = null),
        onAcceptWithDetails: (d) {
          c.reorder(d.data, slot);
          setState(() {
            _overSlot = null;
            _dragSlot = null;
          });
        },
        builder: (ctx, cand, rej) => Draggable<int>(
          data: slot,
          axis: Axis.horizontal,
          onDragStarted: () => setState(() => _dragSlot = slot),
          onDragEnd: (_) => setState(() {
            _dragSlot = null;
            _overSlot = null;
          }),
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.9,
              child: Container(
                width: w,
                height: _headH,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: skin.accent, borderRadius: BorderRadius.circular(5)),
                child: Text(col.label.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: cell),
          child: cell,
        ),
      );
    }
    return cell;
  }

  // ── render item (group header OR data row) ──
  Widget _buildRenderItem(SuperTableSkin skin, List<SuperColumn> cols, RenderItem item) {
    if (item.isGroup) return _buildGroupHeader(skin, cols, item);
    return _buildRow(skin, cols, item);
  }

  Widget _buildGroupHeader(SuperTableSkin skin, List<SuperColumn> cols, RenderItem g) {
    final collapsed = c.isCollapsed(g.path);
    return GestureDetector(
      onTap: () => c.toggleCollapse(g.path),
      child: Container(
        height: _rowH,
        padding: EdgeInsetsDirectional.only(start: 12.0 + g.depth * 20, end: 16),
        decoration: BoxDecoration(
          color: skin.surface2,
          border: Border(bottom: BorderSide(color: skin.borderStrong)),
        ),
        child: Row(children: [
          AnimatedRotation(
            turns: collapsed ? (context.isRtl ? 0.25 : -0.25) : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Icon(Icons.expand_more_rounded, size: 14, color: skin.fg3),
          ),
          const SizedBox(width: 9),
          Text(g.groupCol!.label.toUpperCase(),
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.7, color: skin.fg4)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(g.groupValue == null || g.groupValue!.isEmpty ? '—' : g.groupValue!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: skin.fg1)),
          ),
          const SizedBox(width: 8),
          SuperPill(text: '${g.groupCount}', color: skin.accent, dot: false),
          const SizedBox(width: 4),
          ..._groupAggregates(skin, cols, g.groupRows),
        ]),
      ),
    );
  }

  List<Widget> _groupAggregates(SuperTableSkin skin, List<SuperColumn> cols, List<SuperRow> rows) {
    final out = <Widget>[];
    for (final col in cols) {
      if (col.agg == SuperAgg.none || col.agg == SuperAgg.count) continue;
      final v = SuperColumnLogic.aggregate(col, rows);
      if (v == null) continue;
      final isCur = col.type == SuperColumnType.currency;
      final prefix = isCur ? r'$' : '';
      final isProgAvg = col.type == SuperColumnType.progress && col.agg == SuperAgg.avg;
      final body = col.agg == SuperAgg.avg
          ? (v * 100).round() / 100
          : v.round();
      final txt = '$prefix${SuperColumnLogic.fmtNum(body, col.copyWith(decimals: col.agg == SuperAgg.avg ? 2 : 0))}${isProgAvg ? '%' : ''}';
      out.add(Padding(
        padding: const EdgeInsetsDirectional.only(start: 14),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text('${col.label.toUpperCase()} ',
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: skin.fg4)),
          Text(txt, style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 11, fontWeight: FontWeight.w600, color: skin.fg2)),
        ]),
      ));
    }
    return out;
  }

  Widget _buildRow(SuperTableSkin skin, List<SuperColumn> cols, RenderItem item) {
    final r = item.dataIndex;
    final rowActive = (c.rowMode ? c.selRows.contains(r) : c.sel.r == r) && c.focused;
    return GestureDetector(
      onSecondaryTapDown: (d) => _openRowMenu(r, d.globalPosition),
      child: SizedBox(
        height: _rowH,
        child: Row(children: [
          if (widget.numbered) _rowGutter(skin, r, rowActive),
          for (var ci = 0; ci < cols.length; ci++) _bodyCell(skin, cols[ci], item, r, ci),
          if (_actionable) _actionCell(skin, r, rowActive),
        ]),
      ),
    );
  }

  Widget _rowGutter(SuperTableSkin skin, int r, bool rowActive) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _focus.requestFocus(),
      onTap: () {
        if (c.editCell != null) c.commit();
        if (c.rowMode) {
          c.pick(r, 0, shift: HardwareKeyboard.instance.isShiftPressed);
        } else {
          c.pick(r, c.nCols - 1, shift: HardwareKeyboard.instance.isShiftPressed);
        }
      },
      child: Container(
        width: _gutterW,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: rowActive ? skin.accentWashOnBg(0.12) : skin.bg,
          border: BorderDirectional(
            end: BorderSide(color: skin.borderStrong),
            bottom: BorderSide(color: skin.border),
          ),
        ),
        child: Text('${(r + 1).toString().padLeft(2, '0')}',
            style: TextStyle(
                fontFamily: SuperTokensFonts.mono,
                fontSize: 11,
                fontWeight: rowActive ? FontWeight.w700 : FontWeight.w400,
                color: rowActive ? skin.accent : skin.fg3)),
      ),
    );
  }

  Widget _actionCell(SuperTableSkin skin, int r, bool rowActive) {
    return Container(
      width: _actW,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rowActive ? skin.accentWash(0.05) : skin.surface,
        border: BorderDirectional(
          start: BorderSide(color: skin.border),
          bottom: BorderSide(color: skin.border),
        ),
      ),
      child: _deleteCol
          ? _IconHoverButton(
              skin: skin,
              icon: Icons.delete_outline_rounded,
              tooltip: 'Delete row',
              danger: true,
              onTap: () => _confirmDeleteRow(r),
            )
          : _IconHoverButton(
              skin: skin,
              icon: Icons.drag_indicator_rounded,
              tooltip: 'Row options',
              onTap: () {},
            ),
    );
  }

  Widget _bodyCell(SuperTableSkin skin, SuperColumn col, RenderItem item, int r, int ci) {
    final w = c.widthOf(col);
    final isCursor = c.sel.r == r && c.sel.c == ci;
    final active = isCursor && c.focused;
    final selDim = isCursor && !c.focused;
    final isEditing = c.editCell == SuperCell(r, ci);
    final selected = c.isCellSelected(r, ci) && c.focused;
    final editableCell = c.canEdit(col);
    final dim = col.type == SuperColumnType.computed || col.type == SuperColumnType.readonly;
    final error = _editable ? SuperColumnLogic.validateCell(col, col.rawValue(item.row!)) : null;
    final rowActive = (c.rowMode ? c.selRows.contains(r) : c.sel.r == r) && c.focused;

    final align = switch (col.align) {
      SuperAlign.end => AlignmentDirectional.centerEnd,
      SuperAlign.center => Alignment.center,
      SuperAlign.start => AlignmentDirectional.centerStart,
    };

    Color bg;
    if (isEditing) {
      bg = skin.surface;
    } else if (active) {
      bg = skin.accentWash(0.14);
    } else if (selected) {
      bg = skin.accentWash(0.09);
    } else if (rowActive) {
      bg = skin.accentWash(0.05);
    } else if (dim) {
      bg = skin.dimFill;
    } else {
      bg = Colors.transparent;
    }

    Widget content = isEditing
        ? SuperCellEditor(
            col: col,
            row: item.row!,
            value: c.draft,
            height: _rowH,
            rtl: context.isRtl,
            onChanged: c.setDraft,
            onCancel: c.cancelEdit,
            onCommit: ({Object? override, int dr = 0, int dc = 0}) =>
                c.commit(move: (dr == 0 && dc == 0) ? null : SuperCell(dr, dc), override: override),
          )
        : Align(
            alignment: align,
            child: SuperCellDisplay(col: col, row: item.row!),
          );

    Widget cell = Container(
      width: w,
      height: _rowH,
      padding: isEditing ? EdgeInsets.zero : EdgeInsetsDirectional.only(start: 11, end: (error != null) ? 26 : 11),
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          right: BorderSide(color: skin.border),
          bottom: BorderSide(color: skin.border),
        ),
      ),
      child: content,
    );

    // selection / cursor / invalid outline overlay
    Border? outline;
    if (active) {
      outline = Border.all(color: skin.accent, width: 2);
    } else if (selected) {
      outline = Border.all(color: skin.accent.withOpacity(0.45), width: 1);
    } else if (selDim) {
      outline = Border.all(color: skin.borderStrong, width: 1);
    } else if (error != null && !isEditing) {
      outline = Border.all(color: skin.danger.withOpacity(0.55), width: 1);
    }
    if (outline != null) {
      cell = Stack(children: [
        cell,
        Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(border: outline)))),
      ]);
    }

    if (error != null && !isEditing) {
      cell = Stack(children: [
        cell,
        PositionedDirectional(end: 4, top: 0, bottom: 0, child: Center(child: SuperCellErrorBadge(error: error))),
      ]);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _focus.requestFocus(),
      onTap: () {
        if (isEditing) return;
        if (c.editCell != null) c.commit();
        final keys = HardwareKeyboard.instance.logicalKeysPressed;
        c.pick(r, ci, shift: HardwareKeyboard.instance.isShiftPressed, meta: _meta(keys));
      },
      onDoubleTap: editableCell ? () => c.beginEdit(r: r, c: ci) : null,
      onSecondaryTapDown: (d) => _openRowMenu(r, d.globalPosition),
      child: MouseRegion(
        cursor: editableCell ? SystemMouseCursors.cell : SystemMouseCursors.basic,
        child: cell,
      ),
    );
  }

  // ── empty state ──
  Widget _buildEmpty(SuperTableSkin skin) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox_rounded, size: 26, color: skin.fg3),
        const SizedBox(height: 10),
        Text('No rows', style: TextStyle(fontSize: 13, color: skin.fg3)),
      ]),
    );
  }

  // ── totals ──
  Widget _buildTotals(SuperTableSkin skin, List<SuperColumn> cols) {
    return Container(
      height: _rowH,
      decoration: BoxDecoration(
        color: skin.surface2,
        border: Border(top: BorderSide(color: skin.borderStrong, width: 2)),
      ),
      child: Row(children: [
        if (widget.numbered)
          Container(
            width: _gutterW,
            alignment: Alignment.center,
            decoration: BoxDecoration(border: BorderDirectional(end: BorderSide(color: skin.border))),
            child: Icon(Icons.grid_on_rounded, size: 13, color: skin.fg4),
          ),
        for (var i = 0; i < cols.length; i++) _totalCell(skin, cols[i], i),
        if (_actionable) SizedBox(width: _actW),
      ]),
    );
  }

  Widget _totalCell(SuperTableSkin skin, SuperColumn col, int i) {
    final w = c.widthOf(col);
    final v = col.agg == SuperAgg.none ? null : SuperColumnLogic.aggregate(col, c.sortedRows);
    Widget child;
    if (v != null) {
      final isCur = col.type == SuperColumnType.currency;
      final prefix = col.prefix ?? (isCur ? r'$' : '');
      final suffix = col.suffix != null ? (isCur ? ' ${col.suffix}' : col.suffix) : '';
      final txt = col.agg == SuperAgg.count
          ? '${v.toInt()}'
          : '$prefix${SuperColumnLogic.fmtNum(col.agg == SuperAgg.avg ? (v * 100).round() / 100 : v, col.copyWith(decimals: col.type == SuperColumnType.progress ? 0 : col.decimals))}$suffix';
      child = Text(txt,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 12.5, fontWeight: FontWeight.w700, color: skin.fg1));
    } else if (i == 0) {
      child = Text('TOTALS',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: skin.fg3));
    } else {
      child = const SizedBox.shrink();
    }
    return Container(
      width: w,
      height: _rowH,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      alignment: col.align == SuperAlign.end ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      decoration: BoxDecoration(border: Border(right: BorderSide(color: skin.border))),
      child: child,
    );
  }

  // ── footer stack: load-more · pager · status hint ──
  List<Widget> _buildFooterStack(SuperTableSkin skin) {
    final out = <Widget>[];
    if (c.pagination == SuperPagination.loadMore && c.hasMore && !widget.loading) {
      out.add(Padding(
        padding: const EdgeInsets.only(top: 14),
        child: Center(
          child: _BarButton(
            skin: skin,
            icon: c.loadingMore ? null : Icons.arrow_downward_rounded,
            label: c.loadingMore ? 'Loading…' : 'Load more',
            enabled: !c.loadingMore,
            onTap: c.requestLoadMore,
          ),
        ),
      ));
    }
    if (c.pagination == SuperPagination.pages && !c.grouped && c.pageCount > 1) {
      out.add(_buildPager(skin));
    }
    out.add(_buildStatusHint(skin));
    return out;
  }

  Widget _buildPager(SuperTableSkin skin) {
    final total = c.sortedRows.length;
    final from = total == 0 ? 0 : c.page * c.pageSize + 1;
    final to = (c.page * c.pageSize + c.pageSize).clamp(0, total);
    final pages = <int>[
      for (var i = 0; i < c.pageCount; i++)
        if ((i - c.page).abs() <= 2 || i == 0 || i == c.pageCount - 1) i
    ];
    final widgets = <Widget>[];
    int? prev;
    for (final i in pages) {
      if (prev != null && i - prev > 1) {
        widgets.add(SizedBox(width: 20, child: Center(child: Text('…', style: TextStyle(color: skin.fg4)))));
      }
      widgets.add(_PageNumBtn(skin: skin, n: i, active: i == c.page, onTap: () => c.setPage(i)));
      prev = i;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(children: [
        Text(total == 0 ? '0 of 0' : '$from–$to of $total',
            style: TextStyle(fontSize: 12, color: skin.fg3)),
        const Spacer(),
        _PagerBtn(skin: skin, icon: context.isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, enabled: c.page > 0, onTap: () => c.setPage(c.page - 1)),
        const SizedBox(width: 6),
        ...widgets.expand((w) => [w, const SizedBox(width: 3)]),
        const SizedBox(width: 3),
        _PagerBtn(skin: skin, icon: context.isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, enabled: c.page < c.pageCount - 1, onTap: () => c.setPage(c.page + 1)),
      ]),
    );
  }

  Widget _buildStatusHint(SuperTableSkin skin) {
    final n = _editable ? c.rows.length : c.sortedRows.length;
    final hint = _editable
        ? '$n row${n == 1 ? '' : 's'} · ↵ edit · Tab next (new row at end) · ⌘C/V JSON copy·paste · ⌘Z undo'
        : '$n row${n == 1 ? '' : 's'} · ⇧+arrows to range-select · right-click to copy as JSON · ⌘C copy';
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(children: [
        Expanded(
          child: Text(hint, style: TextStyle(fontSize: 12, color: skin.fg3)),
        ),
        if (c.rowMode && c.selRows.isNotEmpty)
          Text('${c.selRows.length} selected', style: TextStyle(fontSize: 12, color: skin.accent)),
      ]),
    );
  }

  // ── skeleton ──
  Widget _buildSkeleton(SuperTableSkin skin, List<SuperColumn> cols) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [for (var i = 0; i < widget.skeletonRows; i++) _skeletonRow(skin, cols)],
    );
  }

  Widget _skeletonRow(SuperTableSkin skin, List<SuperColumn> cols) {
    return Container(
      height: _rowH,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: skin.border))),
      child: Row(children: [
        if (widget.numbered)
          Container(
            width: _gutterW,
            decoration: BoxDecoration(color: skin.bg, border: BorderDirectional(end: BorderSide(color: skin.border))),
          ),
        for (final col in cols)
          Container(
            width: c.widthOf(col),
            padding: const EdgeInsets.symmetric(horizontal: 11),
            decoration: BoxDecoration(border: Border(right: BorderSide(color: skin.border))),
            child: _shimmerBar(skin, c.widthOf(col) * 0.55),
          ),
        if (_actionable) SizedBox(width: _actW),
      ]),
    );
  }

  Widget _shimmerBar(SuperTableSkin skin, double w) => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          width: w,
          height: 10,
          decoration: BoxDecoration(color: skin.inputBg, borderRadius: BorderRadius.circular(4)),
        ),
      );
}

// ── small shared widgets ──

/// Secondary toolbar/formula-bar button (icon + optional label).
class _BarButton extends StatefulWidget {
  final SuperTableSkin skin;
  final IconData? icon;
  final String? label;
  final bool enabled;
  final VoidCallback onTap;
  const _BarButton({required this.skin, this.icon, this.label, this.enabled = true, required this.onTap});
  @override
  State<_BarButton> createState() => _BarButtonState();
}

class _BarButtonState extends State<_BarButton> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.skin;
    final on = widget.enabled;
    return Opacity(
      opacity: on ? 1 : 0.4,
      child: MouseRegion(
        cursor: on ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: on ? widget.onTap : null,
          child: Container(
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: widget.label != null ? 11 : 8),
            decoration: BoxDecoration(
              color: on && _h ? s.hover : Colors.transparent,
              border: Border.all(color: s.borderStrong),
              borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (widget.icon != null) Icon(widget.icon, size: 14, color: s.fg2),
              if (widget.icon != null && widget.label != null) const SizedBox(width: 7),
              if (widget.label != null)
                Text(widget.label!,
                    style: TextStyle(fontFamily: SuperTokensFonts.body, fontSize: 13, fontWeight: FontWeight.w600, color: s.fg2)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// A tap surface that reports the global position of the tap so a floating
/// menu can be anchored to it. Used by the per-column filter dropdowns.
class _DropdownTap extends StatefulWidget {
  final Widget child;
  final void Function(Offset globalPos) onOpen;
  const _DropdownTap({required this.child, required this.onOpen});
  @override
  State<_DropdownTap> createState() => _DropdownTapState();
}

class _DropdownTapState extends State<_DropdownTap> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => widget.onOpen(d.globalPosition),
        child: widget.child,
      ),
    );
  }
}

/// A small hover icon-button used in header/row action cells.
class _IconHoverButton extends StatefulWidget {
  final SuperTableSkin skin;
  final IconData icon;
  final String tooltip;
  final bool danger;
  final VoidCallback onTap;
  const _IconHoverButton({required this.skin, required this.icon, required this.tooltip, this.danger = false, required this.onTap});
  @override
  State<_IconHoverButton> createState() => _IconHoverButtonState();
}

class _IconHoverButtonState extends State<_IconHoverButton> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.skin;
    final color = _h ? (widget.danger ? s.danger : s.accent) : (widget.danger ? s.fg3 : s.fg4);
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _h ? (widget.danger ? s.tint(s.danger, 0.12) : s.hover) : Colors.transparent,
              borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
            ),
            child: Icon(widget.icon, size: 14, color: color),
          ),
        ),
      ),
    );
  }
}

class _PageNumBtn extends StatelessWidget {
  final SuperTableSkin skin;
  final int n;
  final bool active;
  final VoidCallback onTap;
  const _PageNumBtn({required this.skin, required this.n, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 30),
        height: 30,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: active ? skin.accent : Colors.transparent,
          border: Border.all(color: active ? Colors.transparent : skin.borderStrong),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text('${n + 1}',
            style: TextStyle(
                fontFamily: SuperTokensFonts.mono,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : skin.fg2)),
      ),
    );
  }
}

class _PagerBtn extends StatelessWidget {
  final SuperTableSkin skin;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PagerBtn({required this.skin, required this.icon, required this.enabled, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: skin.inputBg,
            border: Border.all(color: skin.borderStrong),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(icon, size: 16, color: skin.fg2),
        ),
      ),
    );
  }
}
