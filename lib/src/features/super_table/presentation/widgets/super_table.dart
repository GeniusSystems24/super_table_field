// ============================================================
// features/super_table/presentation/widgets/super_table.dart
// ------------------------------------------------------------
// The VIEW for the unified SuperTable — a thin, keyboard-first render of a
// `SuperTableController<R>`. Generic over the row's backing type `R`.
//
// 0.4.0 highlights:
//   • an ADVANCED-FILTER button in the row-number header (red badge when
//     active; while active the per-column filter fields are cleared, disabled
//     and struck through with a slash),
//   • RIGHT-CLICK (or touch double-tap) opens the column header menu,
//   • conditional ROW styles (via `SuperTable.styles`) and CELL styles (via
//     each column's `styles`) — row styles win,
//   • a host `onKey` hook (on the controller) consulted before defaults,
//   • integrated load-more skeletons at the scroll tail + a shimmer animation.
//
// Cell display + editors come from `super_cell.dart`; menus / dialogs / the
// error badge / the advanced-filter editor from `super_table_overlays.dart`.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import '../../../../../localization/super_table_localizations.dart';
import '../../domain/entities/super_column.dart';
import '../../domain/entities/super_row.dart';
import '../../domain/entities/super_style.dart';
import '../../domain/entities/super_table_state.dart';
import '../../domain/usecases/super_column_logic.dart';
import '../controllers/super_table_controller.dart';
import 'super_cell.dart';
import 'super_table_overlays.dart';
import 'super_table_skin.dart';
import '../../domain/entities/super_row_expansion.dart';
import '../../domain/entities/super_interactions.dart';

const double _kRowH = 40;
const double _kRowHCompact = 32;
const double _kHeadFlat = 38;
const double _kGutter = 40;
const double _kActionW = 46;
const double _kFilterRowH = 38;

/// Context handed to [SuperTable.rowMenuBuilder].
class SuperRowMenuContext<R> {
  final int rowIndex;
  final SuperRow<R> row;
  final SuperTableController<R> controller;
  const SuperRowMenuContext({
    required this.rowIndex,
    required this.row,
    required this.controller,
  });
}

class _ResolvedSuperTableStyle {
  final SuperTableStyleOptions options;
  final SuperTableBorderStyle borderStyle;
  final SuperTableAreaStyle? headerStyle;
  final SuperTableAreaStyle? rowStyle;
  final SuperTableAreaStyle? alternateRowStyle;
  final SuperTableAreaStyle? bandedColumnStyle;
  final SuperTableAreaStyle? groupRowStyle;
  final SuperTableAreaStyle? footerRowStyle;
  final SuperTableAreaStyle? totalRowStyle;
  final SuperTableAreaStyle? firstColumnStyle;
  final SuperTableAreaStyle? lastColumnStyle;
  final SuperTableAreaStyle? selectedRowStyle;
  final SuperTableAreaStyle? selectedCellStyle;
  final SuperTableAreaStyle? hoveredRowStyle;
  final SuperTableAreaStyle? hoveredCellStyle;
  final SuperTableAreaStyle? focusedCellStyle;
  final SuperTableAreaStyle? disabledStyle;

  const _ResolvedSuperTableStyle({
    required this.options,
    required this.borderStyle,
    this.headerStyle,
    this.rowStyle,
    this.alternateRowStyle,
    this.bandedColumnStyle,
    this.groupRowStyle,
    this.footerRowStyle,
    this.totalRowStyle,
    this.firstColumnStyle,
    this.lastColumnStyle,
    this.selectedRowStyle,
    this.selectedCellStyle,
    this.hoveredRowStyle,
    this.hoveredCellStyle,
    this.focusedCellStyle,
    this.disabledStyle,
  });

  factory _ResolvedSuperTableStyle.resolve(
    BuildContext context,
    SuperTableSkin skin,
    SuperTableStyle source,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    Color mix(Color color, Color surface, double alpha) =>
        Color.alphaBlend(color.withValues(alpha: alpha), surface);
    Color neutral(double alpha) => Color.alphaBlend(
      (skin.isDark ? Colors.white : Colors.black).withValues(alpha: alpha),
      skin.surface,
    );
    Color primaryFill(double alpha) => mix(primary, skin.surface, alpha);
    Color primaryBg(double alpha) => mix(primary, skin.bg, alpha);

    late final SuperTableBorderStyle borders;
    late final SuperTableAreaStyle header;
    late final SuperTableAreaStyle row;
    late final SuperTableAreaStyle alternateRow;
    late final SuperTableAreaStyle bandedColumn;
    late final SuperTableAreaStyle group;
    late final SuperTableAreaStyle footer;
    late final SuperTableAreaStyle total;
    late final SuperTableAreaStyle firstColumn;
    late final SuperTableAreaStyle lastColumn;

    switch (source.preset) {
      case SuperTableStylePreset.plainMinimal:
        borders = SuperTableBorderStyle(
          outerColor: skin.border,
          dividerColor: skin.border,
          strongDividerColor: skin.borderStrong,
        );
        header = SuperTableAreaStyle(
          background: skin.bg,
          foreground: skin.fg3,
          fontWeight: FontWeight.w700,
        );
        row = const SuperTableAreaStyle();
        alternateRow = SuperTableAreaStyle(background: neutral(0.025));
        bandedColumn = SuperTableAreaStyle(background: neutral(0.018));
        group = SuperTableAreaStyle(
          background: neutral(0.055),
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
        footer = SuperTableAreaStyle(
          background: neutral(0.045),
          foreground: skin.fg2,
          fontWeight: FontWeight.w700,
        );
        total = SuperTableAreaStyle(
          background: neutral(0.06),
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
        firstColumn = const SuperTableAreaStyle(fontWeight: FontWeight.w600);
        lastColumn = const SuperTableAreaStyle(fontWeight: FontWeight.w600);
      case SuperTableStylePreset.light:
      case SuperTableStylePreset.bandedRows:
        borders = SuperTableBorderStyle(
          outerColor: skin.borderStrong,
          dividerColor: skin.border,
          strongDividerColor: skin.borderStrong,
        );
        header = SuperTableAreaStyle(
          background: neutral(0.055),
          foreground: skin.fg2,
          fontWeight: FontWeight.w700,
        );
        row = SuperTableAreaStyle(background: skin.surface);
        alternateRow = SuperTableAreaStyle(background: neutral(0.035));
        bandedColumn = SuperTableAreaStyle(background: neutral(0.026));
        group = SuperTableAreaStyle(
          background: neutral(0.075),
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
        footer = SuperTableAreaStyle(
          background: neutral(0.06),
          foreground: skin.fg2,
          fontWeight: FontWeight.w700,
        );
        total = SuperTableAreaStyle(
          background: neutral(0.09),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        firstColumn = SuperTableAreaStyle(
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
        lastColumn = const SuperTableAreaStyle(fontWeight: FontWeight.w700);
      case SuperTableStylePreset.medium:
      case SuperTableStylePreset.gridBordered:
        final strong = source.preset == SuperTableStylePreset.gridBordered;
        borders = SuperTableBorderStyle(
          outerColor: strong ? skin.borderStrong : skin.border,
          dividerColor: strong ? skin.borderStrong : skin.border,
          strongDividerColor: skin.borderStrong,
          width: strong ? 1.0 : null,
          strongWidth: strong ? 1.4 : null,
        );
        header = SuperTableAreaStyle(
          background: primaryFill(0.105),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        row = SuperTableAreaStyle(background: skin.surface);
        alternateRow = SuperTableAreaStyle(background: primaryFill(0.035));
        bandedColumn = SuperTableAreaStyle(background: primaryFill(0.028));
        group = SuperTableAreaStyle(
          background: primaryFill(0.115),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        footer = SuperTableAreaStyle(
          background: primaryFill(0.075),
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
        total = SuperTableAreaStyle(
          background: primaryFill(0.13),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        firstColumn = SuperTableAreaStyle(
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        lastColumn = SuperTableAreaStyle(
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
      case SuperTableStylePreset.dark:
        borders = SuperTableBorderStyle(
          outerColor: skin.borderStrong,
          dividerColor: skin.borderStrong,
          strongDividerColor: skin.borderStrong,
        );
        header = SuperTableAreaStyle(
          background: neutral(skin.isDark ? 0.18 : 0.12),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        row = SuperTableAreaStyle(background: skin.surface);
        alternateRow = SuperTableAreaStyle(background: neutral(0.05));
        bandedColumn = SuperTableAreaStyle(background: neutral(0.04));
        group = SuperTableAreaStyle(
          background: neutral(skin.isDark ? 0.16 : 0.105),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        footer = SuperTableAreaStyle(
          background: neutral(skin.isDark ? 0.13 : 0.085),
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
        total = SuperTableAreaStyle(
          background: neutral(skin.isDark ? 0.19 : 0.13),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        firstColumn = SuperTableAreaStyle(
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        lastColumn = SuperTableAreaStyle(
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
      case SuperTableStylePreset.accent:
        borders = SuperTableBorderStyle(
          outerColor: primary.withValues(alpha: 0.42),
          dividerColor: skin.border,
          strongDividerColor: primary.withValues(alpha: 0.48),
        );
        header = SuperTableAreaStyle(
          background: primaryFill(0.13),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        row = SuperTableAreaStyle(background: skin.surface);
        alternateRow = SuperTableAreaStyle(background: primaryFill(0.038));
        bandedColumn = SuperTableAreaStyle(background: primaryFill(0.03));
        group = SuperTableAreaStyle(
          background: primaryFill(0.15),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
          accentBar: primary,
        );
        footer = SuperTableAreaStyle(
          background: primaryFill(0.085),
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
        total = SuperTableAreaStyle(
          background: primaryFill(0.16),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        firstColumn = SuperTableAreaStyle(
          foreground: primary,
          fontWeight: FontWeight.w800,
        );
        lastColumn = const SuperTableAreaStyle(fontWeight: FontWeight.w700);
      case SuperTableStylePreset.bandedColumns:
        borders = SuperTableBorderStyle(
          outerColor: skin.borderStrong,
          dividerColor: skin.border,
          strongDividerColor: skin.borderStrong,
        );
        header = SuperTableAreaStyle(
          background: neutral(0.06),
          foreground: skin.fg2,
          fontWeight: FontWeight.w700,
        );
        row = SuperTableAreaStyle(background: skin.surface);
        alternateRow = SuperTableAreaStyle(background: neutral(0.025));
        bandedColumn = SuperTableAreaStyle(background: primaryFill(0.04));
        group = SuperTableAreaStyle(
          background: neutral(0.075),
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
        footer = SuperTableAreaStyle(
          background: neutral(0.06),
          foreground: skin.fg2,
          fontWeight: FontWeight.w700,
        );
        total = SuperTableAreaStyle(
          background: neutral(0.09),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        firstColumn = const SuperTableAreaStyle(fontWeight: FontWeight.w700);
        lastColumn = const SuperTableAreaStyle(fontWeight: FontWeight.w700);
      case SuperTableStylePreset.headerEmphasis:
        borders = SuperTableBorderStyle(
          outerColor: skin.borderStrong,
          dividerColor: skin.border,
          strongDividerColor: primary.withValues(alpha: 0.55),
          strongWidth: 1.6,
        );
        header = SuperTableAreaStyle(
          background: primaryBg(0.15),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        row = SuperTableAreaStyle(background: skin.surface);
        alternateRow = SuperTableAreaStyle(background: neutral(0.025));
        bandedColumn = SuperTableAreaStyle(background: neutral(0.02));
        group = SuperTableAreaStyle(
          background: primaryFill(0.08),
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
        footer = SuperTableAreaStyle(
          background: neutral(0.055),
          foreground: skin.fg2,
          fontWeight: FontWeight.w700,
        );
        total = SuperTableAreaStyle(
          background: primaryFill(0.09),
          foreground: skin.fg1,
          fontWeight: FontWeight.w800,
        );
        firstColumn = const SuperTableAreaStyle(fontWeight: FontWeight.w700);
        lastColumn = const SuperTableAreaStyle(fontWeight: FontWeight.w700);
      case SuperTableStylePreset.subtleBorders:
        borders = SuperTableBorderStyle(
          outerColor: skin.border,
          dividerColor: skin.border.withValues(alpha: 0.72),
          strongDividerColor: skin.borderStrong.withValues(alpha: 0.76),
          width: 0.7,
          strongWidth: 1.0,
        );
        header = SuperTableAreaStyle(
          background: skin.bg,
          foreground: skin.fg3,
          fontWeight: FontWeight.w700,
        );
        row = SuperTableAreaStyle(background: skin.surface);
        alternateRow = SuperTableAreaStyle(background: neutral(0.02));
        bandedColumn = SuperTableAreaStyle(background: neutral(0.016));
        group = SuperTableAreaStyle(
          background: neutral(0.045),
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
        footer = SuperTableAreaStyle(
          background: neutral(0.035),
          foreground: skin.fg2,
          fontWeight: FontWeight.w700,
        );
        total = SuperTableAreaStyle(
          background: neutral(0.05),
          foreground: skin.fg1,
          fontWeight: FontWeight.w700,
        );
        firstColumn = const SuperTableAreaStyle(fontWeight: FontWeight.w600);
        lastColumn = const SuperTableAreaStyle(fontWeight: FontWeight.w600);
    }

    final hoverRow = SuperTableAreaStyle(background: primaryFill(0.045));
    final hoverCell = SuperTableAreaStyle(background: primaryFill(0.065));
    final selectedRow = SuperTableAreaStyle(background: primaryBg(0.08));
    final selectedCell = SuperTableAreaStyle(background: primaryFill(0.095));
    final focusedCell = SuperTableAreaStyle(background: primaryFill(0.15));
    final disabled = SuperTableAreaStyle(
      background: neutral(0.04),
      foreground: skin.fg3,
    );

    return _ResolvedSuperTableStyle(
      options: source.options,
      borderStyle: borders.merge(source.borderStyle),
      headerStyle: header.merge(source.headerStyle),
      rowStyle: row.merge(source.rowStyle),
      alternateRowStyle: alternateRow.merge(source.alternateRowStyle),
      bandedColumnStyle: bandedColumn.merge(source.bandedColumnStyle),
      groupRowStyle: group.merge(source.groupRowStyle),
      footerRowStyle: footer.merge(source.footerRowStyle),
      totalRowStyle: total.merge(source.totalRowStyle),
      firstColumnStyle: firstColumn.merge(source.firstColumnStyle),
      lastColumnStyle: lastColumn.merge(source.lastColumnStyle),
      selectedRowStyle: selectedRow.merge(source.selectedRowStyle),
      selectedCellStyle: selectedCell.merge(source.selectedCellStyle),
      hoveredRowStyle: hoverRow.merge(source.hoveredRowStyle),
      hoveredCellStyle: hoverCell.merge(source.hoveredCellStyle),
      focusedCellStyle: focusedCell.merge(source.focusedCellStyle),
      disabledStyle: disabled.merge(source.disabledStyle),
    );
  }
}

class SuperTable<R> extends StatefulWidget {
  final SuperTableController<R> controller;
  final SuperDensity density;
  final bool numbered;

  /// Deprecated and ignored — a column's data type is never displayed in the
  /// header. Kept for source compatibility; setting it has no effect.
  final bool? showTypeTags;
  final bool showTotals;
  final bool showFooter;
  final bool formulaBar;

  /// Show the editable-mode "Copy JSON" action in the table action bar.
  final bool showCopyJsonButton;

  /// Show the editable-mode redo/undo action in the table action bar.
  final bool showRedoUndoButtons;

  /// Show the editable-mode redo action in the table action bar.
  bool get showRedoButton => showRedoUndoButtons;

  final VoidCallback? onAddColumn;
  final bool columnFilters;

  /// Optional table-wide visual style. Null preserves the current/default table
  /// appearance without applying any predefined [SuperTableStyle].
  final SuperTableStyle? style;

  /// Enable the advanced (cross-column) filter button in the row-number header.
  /// Readable mode only.
  final bool advancedFilter;

  /// Conditional ROW styles (readable mode). The FIRST entry whose condition
  /// returns true wins. Row styles take priority over column [CellStyle]s.
  final Map<SuperRowCondition, SuperRowStyle>? styles;

  final List<SuperMenuEntry> Function(
    SuperRowMenuContext<R> ctx,
    List<SuperMenuEntry> defaults,
  )?
  rowMenuBuilder;
  final bool loading;
  final int skeletonRows;
  final double? maxHeight;

  /// Expandable-row configuration (Readable mode only).
  ///
  /// When set, each data row gains a rotate-chevron in the gutter that toggles
  /// a smoothly-animated panel below the row. Editable mode is unaffected —
  /// the grid's editing behaviour is completely unchanged.
  ///
  /// See [SuperRowExpansion] and [SuperRowExpansionMode] for full docs.
  final SuperRowExpansion<R>? expansion;

  /// Render a subtotal row after each expanded group (2.1.0, readable mode).
  /// The footer repeats the group's aggregates — [SuperColumn.agg] /
  /// [SuperColumn.aggregator] — in the aggregate columns, aligned under them,
  /// closing the group visually like a ledger subtotal line.
  final bool groupFooters;

  /// Host interaction callbacks (2.2.0) — cell/row taps, activation, and
  /// selection / sort snapshots. Pure observers: they never change how the grid
  /// itself responds to a gesture. Null (default) = no interaction work is done.
  final SuperInteractions<R>? interactions;

  /// Add a **Manage columns…** entry (and *Pin* / *Hide column* entries) to
  /// every header menu (2.2.0); the entry opens [showSuperColumnManager]
  /// (drag-reorder · show/hide · pin). Default true — set false to hide the
  /// entries (the programmatic column-config API still works).
  final bool columnManager;

  const SuperTable({
    super.key,
    required this.controller,
    this.density = SuperDensity.comfortable,
    this.numbered = true,
    this.showTypeTags,
    this.showTotals = true,
    this.showFooter = true,
    this.formulaBar = true,
    this.showCopyJsonButton = true,
    this.showRedoUndoButtons = true,
    this.onAddColumn,
    this.columnFilters = true,
    this.style,
    this.advancedFilter = true,
    this.styles,
    this.rowMenuBuilder,
    this.loading = false,
    this.skeletonRows = 6,
    this.maxHeight,
    this.expansion,
    this.groupFooters = false,
    this.interactions,
    this.columnManager = true,
  });

  @override
  State<SuperTable<R>> createState() => _SuperTableState<R>();
}

class _SuperTableState<R> extends State<SuperTable<R>> {
  final FocusNode _focus = FocusNode(debugLabel: 'SuperTable');
  final ScrollController _vScroll = ScrollController();
  final ScrollController _vScrollG = ScrollController();
  final ScrollController _hScroll = ScrollController();
  final Map<String, TextEditingController> _filterCtrls = {};
  CellPos? _lastSel;
  bool _wasEditing = false;
  _ResolvedSuperTableStyle? _tableStyle;
  int? _hoveredRow;
  CellPos? _hoveredCell;

  // ── interaction-event diffing (2.2.0) ──
  Offset _lastPointer = Offset.zero;
  String? _lastSelSig;
  String? _lastSortKey;
  bool _lastSortAsc = true;

  /// IDs ([SuperRow.id]) of rows currently in the expanded state.
  /// Lives in the View — expansion is a pure presentation concern.
  final Set<int> _expandedRowIds = {};

  SuperTableController<R> get c => widget.controller;

  BorderSide _dividerSide(SuperTableSkin skin) => BorderSide(
    color: _tableStyle?.borderStyle.dividerColor ?? skin.border,
    width: _tableStyle?.borderStyle.width ?? 1,
  );

  BorderSide _strongDividerSide(SuperTableSkin skin, {double? width}) =>
      BorderSide(
        color: _tableStyle?.borderStyle.strongDividerColor ?? skin.borderStrong,
        width: width ?? _tableStyle?.borderStyle.strongWidth ?? 1,
      );

  BorderSide _outerSide(SuperTableSkin skin) => BorderSide(
    color: _tableStyle?.borderStyle.outerColor ?? skin.borderStrong,
    width: _tableStyle?.borderStyle.strongWidth ?? 1,
  );

  SuperTableAreaStyle? get _headerArea {
    final s = _tableStyle;
    if (s == null || !s.options.showHeaderRow) return null;
    return s.headerStyle;
  }

  SuperTableAreaStyle? get _groupArea {
    final s = _tableStyle;
    if (s == null || !s.options.showGroupRows) return null;
    return s.groupRowStyle;
  }

  SuperTableAreaStyle? get _footerArea {
    final s = _tableStyle;
    if (s == null || !s.options.showFooterRow) return null;
    return s.footerRowStyle;
  }

  SuperTableAreaStyle? get _totalArea {
    final s = _tableStyle;
    if (s == null || !s.options.showTotalRow) return null;
    return s.totalRowStyle;
  }

  SuperTableAreaStyle? _bodyArea(
    int rowIndex,
    int columnIndex,
    int columnCount,
  ) {
    final s = _tableStyle;
    if (s == null) return null;
    var area = s.rowStyle;
    if (s.options.bandedRows && rowIndex.isOdd) {
      area = (area ?? const SuperTableAreaStyle()).merge(s.alternateRowStyle);
    }
    if (s.options.bandedColumns && columnIndex.isOdd) {
      area = (area ?? const SuperTableAreaStyle()).merge(s.bandedColumnStyle);
    }
    if (s.options.emphasizeFirstColumn && columnIndex == 0) {
      area = (area ?? const SuperTableAreaStyle()).merge(s.firstColumnStyle);
    }
    if (s.options.emphasizeLastColumn && columnIndex == columnCount - 1) {
      area = (area ?? const SuperTableAreaStyle()).merge(s.lastColumnStyle);
    }
    final pos = CellPos(rowIndex, columnIndex);
    if (_hoveredCell == pos) {
      area = (area ?? const SuperTableAreaStyle()).merge(s.hoveredCellStyle);
    } else if (_hoveredRow == rowIndex) {
      area = (area ?? const SuperTableAreaStyle()).merge(s.hoveredRowStyle);
    }
    return area;
  }

  void _setHoveredRow(int? rowIndex) {
    if (_hoveredRow == rowIndex) return;
    setState(() => _hoveredRow = rowIndex);
  }

  void _setHoveredCell(CellPos? pos) {
    if (_hoveredCell == pos) return;
    setState(() => _hoveredCell = pos);
  }

  @override
  void initState() {
    super.initState();
    c.addListener(_onModel);
    _vScroll.addListener(_onVScroll);
    _vScroll.addListener(_syncGutter);
    _lastSel = c.sel;
    _wasEditing = c.editCell != null;
    _lastSelSig = _selSig();
    _lastSortKey = c.sort.key;
    _lastSortAsc = c.sort.ascending;
  }

  void _syncGutter() {
    if (!_vScrollG.hasClients || !_vScroll.hasClients) return;
    final target = _vScroll.offset.clamp(
      0.0,
      _vScrollG.position.maxScrollExtent,
    );
    if ((_vScrollG.offset - target).abs() > 0.5) _vScrollG.jumpTo(target);
  }

  @override
  void didUpdateWidget(covariant SuperTable<R> old) {
    super.didUpdateWidget(old);
    if (old.controller != c) {
      old.controller.removeListener(_onModel);
      c.addListener(_onModel);
    }
    if (widget.style == null && old.style != null) {
      _hoveredRow = null;
      _hoveredCell = null;
    }
  }

  void _onModel() {
    if (!mounted) return;
    setState(() {});
    _fireInteractionDiffs();
    if (_lastSel != c.sel) {
      _lastSel = c.sel;
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisible());
    }
    final editing = c.editCell != null;
    if (_wasEditing && !editing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focus.hasFocus) _focus.requestFocus();
      });
    }
    _wasEditing = editing;
  }

  // ── interaction events (2.2.0) ─────────────────────────────────────────
  String _selSig() =>
      '${c.sel.token}|${c.anchor.token}|${(c.selRows.toList()..sort()).join(',')}|${(c.rowBand.toList()..sort()).join(',')}';

  /// Fire onSelectionChanged / onSortChanged when the controller settles into a
  /// new state. Diffing here (rather than at each call-site) means programmatic
  /// selection / sort changes are reported too.
  void _fireInteractionDiffs() {
    final it = widget.interactions;
    if (it == null) return;
    if (it.onSelectionChanged != null) {
      final sig = _selSig();
      if (sig != _lastSelSig) {
        _lastSelSig = sig;
        it.onSelectionChanged!(
          SuperSelectionSnapshot<R>(
            cursor: c.sel,
            anchor: c.anchor,
            selectedRows: Set.of(c.selRows),
            cells: c.selectedCells(),
            stats: c.selectionStats,
          ),
        );
      }
    }
    if (it.onSortChanged != null) {
      final sk = c.sort.key;
      final sa = c.sort.ascending;
      if (sk != _lastSortKey || sa != _lastSortAsc) {
        _lastSortKey = sk;
        _lastSortAsc = sa;
        it.onSortChanged!(
          SuperSortSnapshot(
            columnKey: sk,
            columnLabel: sk == null ? null : c.colByKey(sk)?.label,
            ascending: sa,
          ),
        );
      }
    }
  }

  SuperCellInteraction<R> _cellInteraction(
    SuperColumn col,
    SuperRow<R> row,
    int r,
    int ci,
    int sourceIndex,
    Offset pos,
  ) => SuperCellInteraction<R>(
    rowIndex: r,
    columnIndex: ci,
    sourceIndex: sourceIndex,
    column: col,
    row: row,
    cell: row.cells[col.key],
    value: col.rawValue(row),
    controller: c,
    globalPosition: pos,
  );

  SuperRowInteraction<R> _rowInteraction(
    SuperRow<R> row,
    int r,
    int sourceIndex, [
    Offset? pos,
  ]) => SuperRowInteraction<R>(
    rowIndex: r,
    sourceIndex: sourceIndex,
    row: row,
    controller: c,
    globalPosition: pos,
  );

  /// Fire onRowTap for a gutter row-number tap.
  void _fireRowTap(int r) {
    final it = widget.interactions;
    if (it?.onRowTap == null || r >= c.view.length) return;
    final entry = c.view[r];
    final row = entry.row;
    if (row != null) {
      it!.onRowTap!(_rowInteraction(row, r, entry.sourceIndex, _lastPointer));
    }
  }

  void _onVScroll() {
    if (c.pagination != SuperPagination.infinite || !_vScroll.hasClients) {
      return;
    }
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
    _vScrollG.dispose();
    _hScroll.dispose();
    super.dispose();
  }

  double get _rowH =>
      widget.density == SuperDensity.compact ? _kRowHCompact : _kRowH;
  // Column data types are never displayed; the header is always the flat height.
  double get _headH => _kHeadFlat;
  bool get _deleteCol => c.mode == SuperTableMode.editable;
  bool get _actionable => _deleteCol || widget.onAddColumn != null;
  double get _gutterW => widget.numbered ? _kGutter : 0;
  double get _actW => _actionable ? _kActionW : 0;
  bool get _editable => c.mode == SuperTableMode.editable;
  bool get _showAdvanced =>
      widget.advancedFilter && c.mode == SuperTableMode.readable;
  bool get _hasFormulaBarActions =>
      widget.showCopyJsonButton ||
      widget.showRedoUndoButtons ||
      widget.showRedoButton;

  // ── conditional style resolution ──
  SuperRowStyle? _rowStyle(SuperRow<R> row) {
    final styles = widget.styles;
    if (styles == null || c.mode != SuperTableMode.readable) return null;
    for (final e in styles.entries) {
      if (e.key(context, c, row)) return e.value;
    }
    return null;
  }

  CellStyle? _cellStyle(SuperColumn col, SuperRow<R> row) {
    final styles = col.styles;
    if (styles == null || c.mode != SuperTableMode.readable) return null;
    final cell = row.cells[col.key];
    if (cell == null) return null;
    for (final e in styles.entries) {
      if (e.key(context, c, row, cell)) return e.value;
    }
    return null;
  }

  void _ensureVisible() {
    final sel = c.sel;
    // Skip vertical auto-scroll when expansion is active: item heights are
    // variable and a flat-index × rowH calculation would be wrong.
    if (_vScroll.hasClients && widget.expansion == null) {
      final flat = c.renderList.indexWhere(
        (it) => !it.isGroup && it.dataIndex == sel.r,
      );
      if (flat >= 0) {
        final top = flat * _rowH, bottom = top + _rowH;
        final vpTop = _vScroll.offset,
            vpH = _vScroll.position.viewportDimension;
        double? to;
        if (top < vpTop) {
          to = top;
        } else if (bottom > vpTop + vpH) {
          to = bottom - vpH;
        }
        if (to != null) {
          _vScroll.jumpTo(to.clamp(0.0, _vScroll.position.maxScrollExtent));
        }
      }
    }
    if (_hScroll.hasClients && !context.isRtl) {
      final cols = c.cols;
      double x = 0;
      for (var i = 0; i < sel.c && i < cols.length; i++) {
        x += c.widthOf(cols[i]);
      }
      final w = sel.c < cols.length ? c.widthOf(cols[sel.c]) : 0;
      final left = x, right = x + w;
      final vpL = _hScroll.offset, vpW = _hScroll.position.viewportDimension;
      double? to;
      if (left < vpL) {
        to = left;
      } else if (right > vpL + vpW) {
        to = right - vpW;
      }
      if (to != null) {
        _hScroll.jumpTo(to.clamp(0.0, _hScroll.position.maxScrollExtent));
      }
    }
  }

  bool _meta(Set<LogicalKeyboardKey> keys) =>
      keys.contains(LogicalKeyboardKey.metaLeft) ||
      keys.contains(LogicalKeyboardKey.metaRight) ||
      keys.contains(LogicalKeyboardKey.controlLeft) ||
      keys.contains(LogicalKeyboardKey.controlRight);

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    // Host hook first — return true to mark handled and skip defaults.
    if (c.onKey != null && c.onKey!(context, c, node, e)) {
      return KeyEventResult.handled;
    }

    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final keys = HardwareKeyboard.instance.logicalKeysPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final meta = _meta(keys);
    final k = e.logicalKey;
    final ed = _editable;

    if (e is KeyDownEvent && k == LogicalKeyboardKey.f1) {
      showSuperShortcuts(context);
      return KeyEventResult.handled;
    }

    if (c.editCell != null) return KeyEventResult.ignored;

    // ── Expansion keyboard shortcuts ───────────────────────────────────────
    // Checked here — before the meta/arrow blocks — so Ctrl+Shift+↓/↑ does
    // not fall through to moveSel. Only fires when a keymap is configured and
    // the table is in Readable mode.
    {
      final expConfig = widget.expansion;
      final km = expConfig?.keymap;
      if (km != null && c.mode == SuperTableMode.readable) {
        if (km.expand.matches(e, keys)) {
          _expandFocusedRow(expConfig!);
          return KeyEventResult.handled;
        }
        if (km.collapse.matches(e, keys)) {
          _collapseFocusedRow();
          return KeyEventResult.handled;
        }
      }
    }

    if (meta) {
      if (k == LogicalKeyboardKey.keyC) {
        c.copyJson();
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.keyV) {
        c.paste();
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
        // Excel semantics when a multi-row range is selected: fill down.
        // Single row/cell keeps the long-standing duplicate-row behaviour.
        if (c.cellMode && c.anchor.r != c.sel.r) {
          c.fillDown();
        } else {
          c.duplicateRow();
        }
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.keyR && ed && c.cellMode) {
        c.fillRight();
        return KeyEventResult.handled;
      }
      // Ctrl/⌘ + Enter → insert AFTER focus; + Shift → insert BEFORE focus.
      if ((k == LogicalKeyboardKey.enter ||
              k == LogicalKeyboardKey.numpadEnter) &&
          ed) {
        shift ? c.insertRowBeforeFocus() : c.insertRowAfterFocus();
        return KeyEventResult.handled;
      }
      if ((k == LogicalKeyboardKey.backspace ||
              k == LogicalKeyboardKey.delete) &&
          ed) {
        _confirmDeleteRow();
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.home) {
        c.setCursor(const CellPos(0, 0), extend: shift);
        return KeyEventResult.handled;
      }
      if (k == LogicalKeyboardKey.end) {
        c.setCursor(CellPos(c.nRows - 1, c.nCols - 1), extend: shift);
        return KeyEventResult.handled;
      }
    }

    if (k == LogicalKeyboardKey.tab) {
      c.tabMove(back: shift);
      return KeyEventResult.handled;
    }

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
        c.setCursor(CellPos(c.sel.r, 0), extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.end:
        c.setCursor(CellPos(c.sel.r, c.nCols - 1), extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageUp:
        c.setCursor(CellPos(0, c.sel.c), extend: shift);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.pageDown:
        c.setCursor(CellPos(c.nRows - 1, c.sel.c), extend: shift);
        return KeyEventResult.handled;
    }

    if (!ed) {
      final it = widget.interactions;
      if (it?.onRowActivate != null &&
          (k == LogicalKeyboardKey.enter ||
              k == LogicalKeyboardKey.numpadEnter) &&
          c.sel.r < c.view.length) {
        final entry = c.view[c.sel.r];
        final row = entry.row;
        if (row != null) {
          it!.onRowActivate!(_rowInteraction(row, c.sel.r, entry.sourceIndex));
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    }

    if (k == LogicalKeyboardKey.enter ||
        k == LogicalKeyboardKey.numpadEnter ||
        k == LogicalKeyboardKey.f2) {
      if ((k != LogicalKeyboardKey.f2) && c.advanceOnEnter) {
        c.clearAdvanceOnEnter();
        c.moveSel(1, 0);
        return KeyEventResult.handled;
      }
      c.beginEdit();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.backspace || k == LogicalKeyboardKey.delete) {
      final col = c.sel.c < c.cols.length ? c.cols[c.sel.c] : null;
      if (col != null && c.canEdit(col)) c.writeCell(c.sel.r, col, '');
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.space) {
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
    final l10n = context.superTableTranslations;
    final label = c.firstColText(vr);
    final ok = await showSuperConfirm(
      context,
      title: l10n.deleteRowTitle,
      body: l10n.deleteRowBody(vr + 1, label.isEmpty ? '-' : label),
    );
    if (ok) c.deleteRow(vr);
  }

  // ── header sort cycling (left-click) ──
  /// Cycles sort for [col]: no-sort → ascending → descending → no-sort.
  void _cycleSortForColumn(SuperColumn col) {
    if (!col.sortable) return;
    if (c.sort.key != col.key) {
      c.sortBy(col, true); // 1st click: ascending
    } else if (c.sort.ascending) {
      c.sortBy(col, false); // 2nd click: descending
    } else {
      c.clearSort(); // 3rd click: clear
    }
  }

  // ── header menu (opens on RIGHT-click / touch double-tap) ──
  void _openHeaderMenu(SuperColumn col, Offset pos) {
    final l10n = context.superTableTranslations;
    final entries = <SuperMenuEntry>[];
    if (col.sortable) {
      entries.add(
        SuperMenuEntry(
          icon: Icons.arrow_upward_rounded,
          label: l10n.sortAscending,
          checked: c.sort.key == col.key && c.sort.ascending,
          onTap: () => c.sortBy(col, true),
        ),
      );
      entries.add(
        SuperMenuEntry(
          icon: Icons.arrow_downward_rounded,
          label: l10n.sortDescending,
          checked: c.sort.key == col.key && !c.sort.ascending,
          onTap: () => c.sortBy(col, false),
        ),
      );
      if (c.sort.key == col.key) {
        entries.add(
          SuperMenuEntry(
            icon: Icons.sort_rounded,
            label: l10n.clearSort,
            onTap: c.clearSort,
          ),
        );
      }
    }
    if (c.mode == SuperTableMode.readable && col.groupable) {
      entries.add(
        SuperMenuEntry(
          icon: Icons.workspaces_outline,
          label: c.groupKeys.contains(col.key)
              ? l10n.removeFromGrouping
              : l10n.groupByThisColumn,
          separatorBefore: true,
          checked: c.groupKeys.contains(col.key),
          onTap: () => c.toggleGroup(col.key),
        ),
      );
    }
    if (c.canHideColumns) {
      entries.add(
        SuperMenuEntry(
          icon: Icons.visibility_off_outlined,
          label: l10n.hideColumn,
          separatorBefore: !widget.columnManager,
          disabled: c.visibleColumnCount <= 1,
          onTap: () => c.hideColumn(col.key),
        ),
      );
    }
    if (widget.columnManager) {
      entries.add(
        SuperMenuEntry(
          icon: c.pinOf(col) == SuperPin.none
              ? Icons.push_pin_outlined
              : Icons.push_pin_rounded,
          label: l10n.pin,
          separatorBefore: true,
          children: [
            SuperMenuEntry(
              icon: Icons.first_page_rounded,
              label: l10n.pinLeft,
              checked: c.pinOf(col) == SuperPin.left,
              onTap: () => c.setColumnPin(col.key, SuperPin.left),
            ),
            SuperMenuEntry(
              icon: Icons.last_page_rounded,
              label: l10n.pinRight,
              checked: c.pinOf(col) == SuperPin.right,
              onTap: () => c.setColumnPin(col.key, SuperPin.right),
            ),
            SuperMenuEntry(
              icon: Icons.remove_rounded,
              label: l10n.unpinned,
              checked: c.pinOf(col) == SuperPin.none,
              onTap: () => c.setColumnPin(col.key, SuperPin.none),
            ),
          ],
        ),
      );
      if (!c.canHideColumns) {
        entries.add(
          SuperMenuEntry(
            icon: Icons.visibility_off_outlined,
            label: l10n.hideColumn,
            disabled: c.visibleColumnCount <= 1,
            onTap: () => c.hideColumn(col.key),
          ),
        );
      }
      entries.add(
        SuperMenuEntry(
          icon: Icons.view_column_rounded,
          label: l10n.manageColumns,
          onTap: () => showSuperColumnManager<R>(context, c),
        ),
      );
    }
    showSuperMenu(context, globalPos: pos, entries: entries);
  }

  void _openRowMenu(int viewR, Offset pos) {
    if (viewR >= c.view.length) return;
    final l10n = context.superTableTranslations;
    final row = c.view[viewR].row!;
    final entries = <SuperMenuEntry>[
      SuperMenuEntry(
        icon: Icons.content_copy_rounded,
        label: l10n.copyAsJson,
        hint: '⌘C',
        onTap: () => (c.rowMode && c.selRows.isNotEmpty)
            ? c.copyRowsJson(c.selRows.toList())
            : c.copyRowsJson([viewR]),
      ),
    ];
    if (_editable) {
      entries.addAll([
        SuperMenuEntry(
          icon: Icons.vertical_align_top_rounded,
          label: l10n.insertRowAbove,
          hint: '⌘⇧↵',
          separatorBefore: true,
          onTap: () => c.insertRow(viewR, after: false),
        ),
        SuperMenuEntry(
          icon: Icons.vertical_align_bottom_rounded,
          label: l10n.insertRowBelow,
          hint: '⌘↵',
          onTap: () => c.insertRow(viewR, after: true),
        ),
        SuperMenuEntry(
          icon: Icons.copy_all_rounded,
          label: l10n.duplicateRow,
          hint: '⌘D',
          onTap: () => c.duplicateRow(viewR),
        ),
        if (c.trackChanges) ...[
          SuperMenuEntry(
            icon: Icons.restore_rounded,
            label: l10n.revertCell,
            separatorBefore: true,
            disabled:
                !(c.sel.r == viewR &&
                    c.sel.c < c.cols.length &&
                    (row.cells[c.cols[c.sel.c].key]?.isDirty ?? false)),
            onTap: () => c.revertCell(row, c.cols[c.sel.c].key),
          ),
          SuperMenuEntry(
            icon: Icons.settings_backup_restore_rounded,
            label: row.isNew ? l10n.revertRowRemoveAdded : l10n.revertRow,
            disabled: !c.isRowDirty(row),
            onTap: () => c.revertRow(row),
          ),
        ],
        SuperMenuEntry(
          icon: Icons.arrow_upward_rounded,
          label: l10n.moveRowUp,
          separatorBefore: true,
          disabled: viewR == 0,
          onTap: () => c.moveRowUp(viewR),
        ),
        SuperMenuEntry(
          icon: Icons.arrow_downward_rounded,
          label: l10n.moveRowDown,
          disabled: viewR >= c.view.length - 1,
          onTap: () => c.moveRowDown(viewR),
        ),
        SuperMenuEntry(
          icon: Icons.delete_outline_rounded,
          label: l10n.deleteRow,
          hint: '⌘⌫',
          danger: true,
          separatorBefore: true,
          onTap: () => _confirmDeleteRow(viewR),
        ),
      ]);
    } else {
      final groupables = c.cols.where((col) => col.groupable).toList();
      if (groupables.isNotEmpty) {
        entries.add(
          SuperMenuEntry(
            icon: Icons.workspaces_outline,
            label: l10n.groupBy,
            separatorBefore: true,
            children: [
              for (final col in groupables)
                SuperMenuEntry(
                  label: col.label,
                  checked: c.groupKeys.contains(col.key),
                  onTap: () => c.toggleGroup(col.key),
                ),
            ],
          ),
        );
      }
    }
    final builder = widget.rowMenuBuilder;
    final finalEntries = builder == null
        ? entries
        : builder(
            SuperRowMenuContext<R>(rowIndex: viewR, row: row, controller: c),
            entries,
          );
    if (finalEntries.isEmpty) return;
    showSuperMenu(context, globalPos: pos, entries: finalEntries);
  }

  void _openAdvancedFilter() {
    showSuperAdvancedFilter(
      context,
      columns: [
        for (final col in c.cols.where((col) => col.filterable))
          AdvFilterColumn(col.key, col.label, numeric: col.type.isNumeric),
      ],
      initial: c.advancedFilter,
      onApply: (clauses) => c.setAdvancedFilter(clauses, active: true),
      onClear: c.clearAdvancedFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Expose the live context so the controller can invoke onChange/validator.
    c.viewContext = context;
    c.groupFootersEnabled =
        widget.groupFooters && c.mode == SuperTableMode.readable;
    final skin = SuperTableSkin.of(context);
    final cols = c.cols;
    final colsW = cols.fold<double>(0, (a, col) => a + c.widthOf(col));
    final bodyW = (colsW + _actW) < 280 ? 280.0 : (colsW + _actW);

    final showFilter =
        widget.columnFilters && c.mode == SuperTableMode.readable;
    final showTotalsRow =
        widget.showTotals && _hasTotals(cols) && !widget.loading && c.nRows > 0;
    final extraSkeleton = c.loadingMore && !widget.loading
        ? widget.skeletonRows
        : 0;
    _tableStyle = widget.style == null
        ? null
        : _ResolvedSuperTableStyle.resolve(context, skin, widget.style!);

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
            if (widget.formulaBar && _editable && _hasFormulaBarActions)
              _buildFormulaBar(skin),
            if (c.grouped) _buildGroupBar(skin),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                  color: skin.surface,
                  border: Border.fromBorderSide(_outerSide(skin)),
                  borderRadius: BorderRadius.circular(
                    context.superTheme.spacing.radiusCard,
                  ),
                  boxShadow: c.focused
                      ? [
                          BoxShadow(
                            color: skin.accent(context),
                            blurRadius: 0,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                constraints: widget.maxHeight != null
                    ? BoxConstraints(maxHeight: widget.maxHeight!)
                    : const BoxConstraints(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.numbered)
                      _buildGutterPane(
                        skin,
                        cols,
                        showFilter: showFilter,
                        extraSkeleton: extraSkeleton,
                        showTotals: showTotalsRow,
                      ),
                    Expanded(
                      child: Scrollbar(
                        controller: _hScroll,
                        notificationPredicate: (n) =>
                            n.metrics.axis == Axis.horizontal,
                        child: SingleChildScrollView(
                          controller: _hScroll,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: bodyW,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildHeader(skin, cols),
                                if (showFilter) _buildFilterRow(skin, cols),
                                Flexible(
                                  child: widget.loading
                                      ? _buildSkeleton(skin, cols)
                                      : (c.nRows == 0 &&
                                            c.renderList.isEmpty &&
                                            extraSkeleton == 0)
                                      ? _buildEmpty(skin)
                                      : Scrollbar(
                                          controller: _vScroll,
                                          child: ListView.builder(
                                            controller: _vScroll,
                                            primary: false,
                                            // itemExtent must be null when expansion is active.
                                            itemExtent: widget.expansion == null
                                                ? _rowH
                                                : null,
                                            itemCount:
                                                c.renderList.length +
                                                extraSkeleton,
                                            itemBuilder: (ctx, i) =>
                                                i < c.renderList.length
                                                ? _buildRenderItem(
                                                    skin,
                                                    cols,
                                                    c.renderList[i],
                                                  )
                                                : _skeletonRow(skin, cols),
                                          ),
                                        ),
                                ),
                                if (showTotalsRow) _buildTotals(skin, cols),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.showFooter) ..._buildFooterStack(skin),
          ],
        ),
      ),
    );
  }

  // ── pinned row-number gutter pane ──
  Widget _buildGutterPane(
    SuperTableSkin skin,
    List<SuperColumn> cols, {
    required bool showFilter,
    required int extraSkeleton,
    required bool showTotals,
  }) {
    Widget middle;
    if (widget.loading) {
      middle = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.skeletonRows; i++)
            _gutterSkeletonCell(skin),
        ],
      );
    } else if (c.nRows == 0 && c.renderList.isEmpty && extraSkeleton == 0) {
      middle = const SizedBox.shrink();
    } else {
      middle = ListView.builder(
        controller: _vScrollG,
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        // itemExtent must be null when expansion is active: rows are variable
        // height (base rowH + animated panel height).
        itemExtent: widget.expansion == null ? _rowH : null,
        itemCount: c.renderList.length + extraSkeleton,
        itemBuilder: (ctx, i) => i < c.renderList.length
            ? _gutterItem(skin, c.renderList[i])
            : _gutterSkeletonCell(skin),
      );
    }
    return SizedBox(
      width: _gutterW,
      child: Column(
        children: [
          _gutterHead(skin),
          if (showFilter) _filterGutter(skin),
          Expanded(child: middle),
          if (showTotals) _gutterTotalsCell(skin),
        ],
      ),
    );
  }

  Widget _gutterItem(SuperTableSkin skin, RenderItem<R> item) {
    if (item.isGroup || item.isGroupFooter) {
      final area = item.isGroup ? _groupArea : _footerArea;
      return Container(
        height: _rowH,
        decoration: BoxDecoration(
          color: area?.background ?? skin.surface2,
          border: BorderDirectional(
            end: _strongDividerSide(skin),
            bottom: _strongDividerSide(skin),
          ),
        ),
      );
    }
    final r = item.dataIndex;
    final rowActive =
        (c.rowMode ? c.selRows.contains(r) : c.sel.r == r) && c.focused;
    final exp = widget.expansion;
    // Return the simple gutter cell when expansion is off or in editable mode.
    if (exp == null || c.mode != SuperTableMode.readable) {
      return _rowGutter(skin, r, rowActive);
    }
    // Expansion active: row-number gutter + animated spacer that matches the
    // body's expansion panel height so the two lists stay in perfect sync.
    final row = item.row!;
    final expanded = _isExpanded(row);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _rowGutterWithExpand(skin, r, row, rowActive, expanded, exp),
        AnimatedContainer(
          duration: exp.animationDuration,
          curve: exp.animationCurve,
          height: expanded ? exp.heightFor(row) : 0.0,
          decoration: BoxDecoration(
            color: skin.surface2,
            border: BorderDirectional(end: _strongDividerSide(skin)),
          ),
        ),
      ],
    );
  }

  Widget _gutterSkeletonCell(SuperTableSkin skin) => Container(
    height: _rowH,
    decoration: BoxDecoration(
      color: skin.bg,
      border: BorderDirectional(
        end: _dividerSide(skin),
        bottom: _dividerSide(skin),
      ),
    ),
    child: const Center(child: _Shimmer(width: 14, height: 9)),
  );

  Widget _gutterTotalsCell(SuperTableSkin skin) => Container(
    height: _rowH,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: _totalArea?.background ?? skin.surface2,
      border: BorderDirectional(
        end: _dividerSide(skin),
        top: _strongDividerSide(skin, width: 2),
      ),
    ),
    child: Icon(Icons.grid_on_rounded, size: 13, color: skin.fg4),
  );

  bool _hasTotals(List<SuperColumn> cols) =>
      cols.any((c) => c.agg != SuperAgg.none);

  // ── formula bar (editable) ──
  Widget _buildFormulaBar(SuperTableSkin skin) {
    final l10n = context.superTableTranslations;
    final actions = <Widget>[];

    void addAction(Widget action) {
      if (actions.isNotEmpty) actions.add(const SizedBox(width: 8));
      actions.add(action);
    }

    if (widget.showCopyJsonButton) {
      addAction(
        _BarButton(
          skin: skin,
          icon: Icons.content_copy_rounded,
          label: l10n.copyJson,
          onTap: () => (c.rowMode && c.selRows.isNotEmpty)
              ? c.copyRowsJson(c.selRows.toList())
              : c.copyJson(),
        ),
      );
    }
    if (widget.showRedoUndoButtons) {
      addAction(
        _BarButton(
          skin: skin,
          icon: Icons.undo_rounded,
          enabled: c.canUndo,
          onTap: c.undo,
        ),
      );
    }
    if (widget.showRedoButton) {
      addAction(
        _BarButton(
          skin: skin,
          icon: Icons.redo_rounded,
          enabled: c.canRedo,
          onTap: c.redo,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [const Spacer(), ...actions]),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspaces_outline,
                size: 13,
                color: skin.accent(context),
              ),
              const SizedBox(width: 6),
              Text(
                context.superTableTranslations.groupedBy,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                  color: skin.fg3,
                ),
              ),
            ],
          ),
          for (var i = 0; i < c.groupKeys.length; i++)
            _groupChip(skin, i, c.groupKeys[i]),
          GestureDetector(
            onTap: c.clearGroups,
            child: Text(
              context.superTableTranslations.clearAll,
              style: TextStyle(
                fontSize: 11.5,
                color: skin.fg3,
                decoration: TextDecoration.underline,
              ),
            ),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${i + 1}',
            style: TextStyle(
              fontFamily: context.superTextTheme.mono.fontFamily,
              fontSize: 10,
              color: skin.fg4,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            col?.label ?? key,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: skin.fg1,
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () => c.toggleGroup(key),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close_rounded, size: 12, color: skin.fg3),
            ),
          ),
        ],
      ),
    );
  }

  // ── header ──
  Widget _buildHeader(SuperTableSkin skin, List<SuperColumn> cols) {
    final area = _headerArea;
    return Container(
      height: _headH,
      decoration: BoxDecoration(
        color: area?.background ?? skin.bg,
        border: Border(bottom: _strongDividerSide(skin)),
      ),
      child: Row(
        children: [
          for (final col in cols) _headerCell(skin, col),
          if (_actionable) _actionHead(skin),
        ],
      ),
    );
  }

  Widget _gutterHead(SuperTableSkin skin) {
    final active = c.advancedActive;
    final area = _headerArea;
    return Container(
      width: _gutterW,
      height: _headH,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: area?.background ?? skin.bg,
        border: BorderDirectional(
          end: _dividerSide(skin),
          bottom: _strongDividerSide(skin),
        ),
      ),
      child: _showAdvanced
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                _IconHoverButton(
                  skin: skin,
                  icon: Icons.tune_rounded,
                  tooltip: active
                      ? context.superTableTranslations.advancedFilterActiveEdit
                      : context.superTableTranslations.advancedFilter,
                  accent: active,
                  onTap: _openAdvancedFilter,
                ),
                if (active)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: skin.danger(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: area?.background ?? skin.bg,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : null,
    );
  }

  Widget _actionHead(SuperTableSkin skin) {
    return Container(
      width: _actW,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: BorderDirectional(start: _dividerSide(skin)),
      ),
      child: widget.onAddColumn != null
          ? _IconHoverButton(
              skin: skin,
              icon: Icons.add_rounded,
              tooltip: context.superTableTranslations.addColumn,
              onTap: widget.onAddColumn!,
            )
          : Icon(Icons.delete_outline_rounded, size: 13, color: skin.fg4),
    );
  }

  // ── per-column filter row ──
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
      height: _kFilterRowH,
      decoration: BoxDecoration(
        color: skin.surface2,
        border: Border(bottom: _dividerSide(skin)),
      ),
      child: Row(
        children: [
          for (final col in cols) _filterCell(skin, col),
          if (_actionable) _filterAction(skin),
        ],
      ),
    );
  }

  Widget _filterGutter(SuperTableSkin skin) {
    final active = c.hasColumnFilters;
    final l10n = context.superTableTranslations;
    return Container(
      width: _gutterW,
      height: _kFilterRowH,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: skin.surface2,
        border: BorderDirectional(
          end: _dividerSide(skin),
          bottom: _dividerSide(skin),
        ),
      ),
      child: c.advancedActive
          ? Icon(Icons.block_rounded, size: 13, color: skin.fg4)
          : _IconHoverButton(
              skin: skin,
              icon: active
                  ? Icons.filter_alt_off_rounded
                  : Icons.filter_alt_outlined,
              tooltip: active ? l10n.clearAllFilters : l10n.filterRows,
              onTap: active ? c.clearColumnFilters : () {},
            ),
    );
  }

  Widget _filterAction(SuperTableSkin skin) => Container(
    width: _actW,
    decoration: BoxDecoration(
      border: BorderDirectional(start: _dividerSide(skin)),
    ),
  );

  Widget _filterCell(SuperTableSkin skin, SuperColumn col) {
    final w = c.widthOf(col);
    final current = c.columnFilter(col.key);
    final filterable = col.filterable && col.type != SuperColumnType.color;
    final disabled = c.advancedActive;

    Widget field;
    if (disabled) {
      // Advanced filter active: clear, disable, and slash the column field.
      field = _DisabledFilter(skin: skin);
    } else if (!filterable) {
      field = const SizedBox.shrink();
    } else if (col.type == SuperColumnType.enumeration ||
        col.type == SuperColumnType.combo) {
      field = _filterDropdown(
        skin,
        col,
        current,
        options: col.opts ?? const [],
      );
    } else if (col.type == SuperColumnType.checkbox) {
      field = _filterDropdown(
        skin,
        col,
        current,
        options: const ['Yes', 'No'],
        labelFor: (v) => v == 'Yes'
            ? context.superTableTranslations.checked
            : context.superTableTranslations.unchecked,
      );
    } else {
      field = _filterText(skin, col, current);
    }

    return Container(
      width: w,
      height: _kFilterRowH,
      decoration: BoxDecoration(
        border: BorderDirectional(end: _dividerSide(skin)),
      ),
      child: field,
    );
  }

  Widget _filterText(SuperTableSkin skin, SuperColumn col, String current) {
    final isEnd = col.align == SuperAlign.end;
    final active = current.trim().isNotEmpty;
    return Container(
      height: _kFilterRowH,
      color: active ? skin.accentWash(context, 0.07) : Colors.transparent,
      // padding: const EdgeInsetsDirectional.only(start: 4, end: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _filterCtrl(col.key),
              onChanged: (v) => c.setColumnFilter(col.key, v),
              textAlign: isEnd ? TextAlign.right : TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontFamily: col.mono
                    ? context.superTextTheme.mono.fontFamily
                    : context.superTextTheme.body.fontFamily,
                fontSize: 12,
                color: skin.fg1,
              ),
              cursorColor: skin.accent(context),
              cursorHeight: 14,
              decoration: InputDecoration(
                isDense: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 13,
                  color: active ? skin.accent(context) : skin.fg4,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 25,
                  minHeight: 24,
                ),
                hintText: context.superTableTranslations.filterHint,
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
        ],
      ),
    );
  }

  Widget _filterDropdown(
    SuperTableSkin skin,
    SuperColumn col,
    String current, {
    required List<String> options,
    String Function(String)? labelFor,
  }) {
    final l10n = context.superTableTranslations;
    final active = current.trim().isNotEmpty;
    final label = active ? (labelFor?.call(current) ?? current) : l10n.all;
    return _DropdownTap(
      onOpen: (pos) {
        final entries = <SuperMenuEntry>[
          SuperMenuEntry(
            label: l10n.all,
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
        height: _kFilterRowH,
        color: active ? skin.accentWash(context, 0.07) : Colors.transparent,
        padding: const EdgeInsetsDirectional.only(start: 9, end: 6),
        child: Row(
          children: [
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
            Icon(
              Icons.expand_more_rounded,
              size: 14,
              color: active ? skin.accent(context) : skin.fg4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(SuperTableSkin skin, SuperColumn col) {
    final w = c.widthOf(col);
    final active = c.sort.key == col.key;
    final isPinned = c.pinOf(col) != SuperPin.none;
    final inGroup = c.groupKeys.contains(col.key);
    final area = _headerArea;

    final isEnd = col.align == SuperAlign.end;
    // Column data types are never surfaced: the header shows only the label and
    // its pin / group / sort affordances.
    final labelRow = Row(
      mainAxisAlignment: isEnd
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (isPinned) ...[
          Icon(Icons.push_pin_outlined, size: 10, color: skin.accent(context)),
          const SizedBox(width: 4),
        ],
        if (inGroup) ...[
          Icon(Icons.layers_rounded, size: 10, color: skin.accent(context)),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            col.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: context.superTextTheme.body.fontFamily,
              fontSize: 10,
              fontWeight: area?.fontWeight ?? FontWeight.w700,
              letterSpacing: 0.5,
              color: active || inGroup
                  ? skin.fg1
                  : area?.foreground ?? skin.fg3,
            ),
          ),
        ),
        if (col.required)
          Text(
            ' *',
            style: TextStyle(fontSize: 11, color: skin.danger(context)),
          ),
        if (active) ...[
          const SizedBox(width: 3),
          Icon(
            c.sort.ascending
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 11,
            color: skin.accent(context),
          ),
        ],
        if (!isEnd) const Spacer(),
        const SizedBox(width: 5),
        Icon(Icons.more_vert_rounded, size: 12, color: skin.fg4),
      ],
    );

    final Widget inner = Container(
      width: w,
      height: _headH,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: area?.background ?? skin.bg,
        border: BorderDirectional(
          start: BorderSide.none,
          end: _dividerSide(skin),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [labelRow],
      ),
    );

    // Right-click (mouse) or double-tap (touch) opens the menu.
    Widget cell = GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Left-click cycles sort: ascending → descending → clear (no-op for unsortable)
      onTap: col.sortable ? () => _cycleSortForColumn(col) : null,
      onSecondaryTapDown: (d) => _openHeaderMenu(col, d.globalPosition),
      onDoubleTap: () {
        final box = context.findRenderObject() as RenderBox?;
        final pos = box != null
            ? box.localToGlobal(Offset(box.size.width / 2, _headH))
            : Offset.zero;
        _openHeaderMenu(col, pos);
      },
      child: MouseRegion(cursor: SystemMouseCursors.click, child: inner),
    );

    cell = Stack(
      children: [
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
      ],
    );

    return cell;
  }

  // ── render item ──
  Widget _buildRenderItem(
    SuperTableSkin skin,
    List<SuperColumn> cols,
    RenderItem<R> item,
  ) {
    if (item.isGroup) return _buildGroupHeader(skin, cols, item);
    if (item.isGroupFooter) return _buildGroupFooter(skin, cols, item);
    return _buildRow(skin, cols, item);
  }

  Widget _buildGroupHeader(
    SuperTableSkin skin,
    List<SuperColumn> cols,
    RenderItem<R> g,
  ) {
    final collapsed = c.isCollapsed(g.path);
    final area = _groupArea;
    return GestureDetector(
      onTap: () => c.toggleCollapse(g.path),
      child: Container(
        height: _rowH,
        padding: EdgeInsetsDirectional.only(
          start: 12.0 + g.depth * 20,
          end: 16,
        ),
        decoration: BoxDecoration(
          color: area?.background ?? skin.surface2,
          border: Border(bottom: _strongDividerSide(skin)),
        ),
        child: Row(
          children: [
            AnimatedRotation(
              turns: collapsed ? (context.isRtl ? 0.25 : -0.25) : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(Icons.expand_more_rounded, size: 14, color: skin.fg3),
            ),
            const SizedBox(width: 9),
            Text(
              g.groupCol!.label.toUpperCase(),
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: area?.fontWeight ?? FontWeight.w700,
                letterSpacing: 0.7,
                color: area?.foreground ?? skin.fg4,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                g.groupValue == null || g.groupValue!.isEmpty
                    ? '—'
                    : g.groupValue!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: area?.fontWeight ?? FontWeight.w700,
                  color: area?.foreground ?? skin.fg1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SuperPill(
              text: '${g.groupCount}',
              color: skin.accent(context),
              dot: false,
            ),
            const SizedBox(width: 4),
            ..._groupAggregates(skin, cols, g.groupRows),
          ],
        ),
      ),
    );
  }

  List<Widget> _groupAggregates(
    SuperTableSkin skin,
    List<SuperColumn> cols,
    List<SuperRow<R>> rows,
  ) {
    final out = <Widget>[];
    final area = _groupArea;
    for (final col in cols) {
      if (col.agg == SuperAgg.none || col.agg == SuperAgg.count) continue;
      final v = SuperColumnLogic.aggregate(col, rows);
      if (v == null) continue;
      final isCur = col.type == SuperColumnType.currency;
      final prefix = isCur ? r'$' : '';
      final isProgAvg =
          col.type == SuperColumnType.progress && col.agg == SuperAgg.avg;
      final body = col.agg == SuperAgg.avg
          ? (v * 100).round() / 100
          : v.round();
      final txt =
          '$prefix${SuperColumnLogic.fmtNum(body, col.copyWith(decimals: col.agg == SuperAgg.avg ? 2 : 0))}${isProgAvg ? '%' : ''}';
      out.add(
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(col.aggLabel ?? col.label).toUpperCase()} ',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: area?.foreground ?? skin.fg4,
                ),
              ),
              Text(
                txt,
                style: TextStyle(
                  fontFamily: context.superTextTheme.mono.fontFamily,
                  fontSize: 11,
                  fontWeight: area?.fontWeight ?? FontWeight.w600,
                  color: area?.foreground ?? skin.fg2,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return out;
  }

  /// A subtotal row closing a group (2.1.0, `groupFooters:`). Unlike the
  /// header's inline chips, the footer aligns each aggregate UNDER its own
  /// column — a ledger subtotal line.
  Widget _buildGroupFooter(
    SuperTableSkin skin,
    List<SuperColumn> cols,
    RenderItem<R> g,
  ) {
    final area = _footerArea;
    return Container(
      height: _rowH,
      decoration: BoxDecoration(
        color: area?.background ?? skin.surface2,
        border: Border(bottom: _strongDividerSide(skin)),
      ),
      child: Row(
        children: [
          for (var ci = 0; ci < cols.length; ci++)
            _groupFooterCell(skin, cols[ci], g, ci),
          if (_actionable) SizedBox(width: _actW),
        ],
      ),
    );
  }

  Widget _groupFooterCell(
    SuperTableSkin skin,
    SuperColumn col,
    RenderItem<R> g,
    int ci,
  ) {
    final area = _footerArea;
    Widget? child;
    if (ci == 0) {
      final label = g.groupValue == null || g.groupValue!.isEmpty
          ? '—'
          : g.groupValue!;
      child = Text(
        'Σ $label',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: area?.fontWeight ?? FontWeight.w700,
          letterSpacing: 0.2,
          color: area?.foreground ?? skin.fg3,
        ),
      );
    }
    if (col.agg != SuperAgg.none) {
      final v = SuperColumnLogic.aggregate(col, g.groupRows);
      String? txt;
      if (col.agg == SuperAgg.count) {
        txt = '${g.groupCount}';
      } else if (v != null) {
        final isCur = col.type == SuperColumnType.currency;
        final isProgAvg =
            col.type == SuperColumnType.progress && col.agg == SuperAgg.avg;
        final body = col.agg == SuperAgg.avg ? (v * 100).round() / 100 : v;
        txt =
            '${isCur ? r'$' : ''}${SuperColumnLogic.fmtNum(body, col.copyWith(decimals: col.agg == SuperAgg.avg ? 2 : col.decimals))}${isProgAvg ? '%' : ''}';
      }
      if (txt != null) {
        child = Text(
          txt,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: context.superTextTheme.mono.fontFamily,
            fontSize: 11.5,
            fontWeight: area?.fontWeight ?? FontWeight.w700,
            color: area?.foreground ?? skin.fg1,
          ),
        );
      }
    }
    return Container(
      width: c.widthOf(col),
      height: _rowH,
      alignment: col.align == SuperAlign.end && ci != 0
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        border: BorderDirectional(end: _dividerSide(skin)),
      ),
      child: child,
    );
  }

  Widget _buildRow(
    SuperTableSkin skin,
    List<SuperColumn> cols,
    RenderItem<R> item,
  ) {
    final r = item.dataIndex;
    final rowActive =
        (c.rowMode ? c.selRows.contains(r) : c.sel.r == r) && c.focused;
    final rowStyle = _rowStyle(item.row!);
    final exp = widget.expansion;

    Widget rowWidget = GestureDetector(
      onSecondaryTapDown: (d) => _openRowMenu(r, d.globalPosition),
      child: Container(
        height: _rowH,
        color: rowStyle?.background,
        child: Row(
          children: [
            if (rowStyle?.accentBar != null)
              Container(width: 3, color: rowStyle!.accentBar),
            for (var ci = 0; ci < cols.length; ci++)
              _bodyCell(skin, cols[ci], item, r, ci, cols.length, rowStyle),
            if (_actionable) _actionCell(skin, r, rowActive),
          ],
        ),
      ),
    );

    if (_tableStyle != null) {
      rowWidget = MouseRegion(
        onEnter: (_) => _setHoveredRow(r),
        onExit: (_) {
          if (_hoveredRow == r) _setHoveredRow(null);
          if (_hoveredCell?.r == r) _setHoveredCell(null);
        },
        child: rowWidget,
      );
    }

    // No expansion feature, or currently in editable mode — return the bare row.
    if (exp == null || c.mode != SuperTableMode.readable) return rowWidget;

    final expanded = _isExpanded(item.row!);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        rowWidget,
        _buildExpansionPanel(skin, item.row!, exp, expanded),
      ],
    );
  }

  Widget _rowGutter(SuperTableSkin skin, int r, bool rowActive) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) {
        _focus.requestFocus();
        _lastPointer = d.globalPosition;
      },
      // Clicking the row number selects the WHOLE row WITHOUT moving the edit
      // cursor (0.4.0). Shift/⌘ extend or toggle.
      onTap: () {
        c.selectGutterRow(
          r,
          shift: HardwareKeyboard.instance.isShiftPressed,
          meta: _meta(HardwareKeyboard.instance.logicalKeysPressed),
        );
        _fireRowTap(r);
      },
      child: Container(
        width: _gutterW,
        height: _rowH,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: rowActive
              ? _tableStyle?.selectedRowStyle?.background ??
                    skin.accentWashOnBg(context, 0.12)
              : skin.bg,
          border: BorderDirectional(
            end: _strongDividerSide(skin),
            bottom: _dividerSide(skin),
          ),
        ),
        child: Text(
          (r + 1).toString().padLeft(2, '0'),
          style: TextStyle(
            fontFamily: context.superTextTheme.mono.fontFamily,
            fontSize: 11,
            fontWeight: rowActive ? FontWeight.w700 : FontWeight.w400,
            color: rowActive ? skin.accent(context) : skin.fg3,
          ),
        ),
      ),
    );
  }

  Widget _actionCell(SuperTableSkin skin, int r, bool rowActive) {
    return Container(
      width: _actW,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: rowActive
            ? _tableStyle?.selectedRowStyle?.background ??
                  skin.accentWash(context, 0.05)
            : skin.surface,
        border: BorderDirectional(
          start: _dividerSide(skin),
          bottom: _dividerSide(skin),
        ),
      ),
      child: _deleteCol
          ? _IconHoverButton(
              skin: skin,
              icon: Icons.delete_outline_rounded,
              tooltip: context.superTableTranslations.deleteRow,
              danger: true,
              onTap: () => _confirmDeleteRow(r),
            )
          : _IconHoverButton(
              skin: skin,
              icon: Icons.drag_indicator_rounded,
              tooltip: context.superTableTranslations.rowOptions,
              onTap: () {},
            ),
    );
  }

  Widget _bodyCell(
    SuperTableSkin skin,
    SuperColumn col,
    RenderItem<R> item,
    int r,
    int ci,
    int columnCount,
    SuperRowStyle? rowStyle,
  ) {
    final w = c.widthOf(col);
    final isCursor = c.sel.r == r && c.sel.c == ci;
    final active = isCursor && c.focused;
    final selDim = isCursor && !c.focused;
    final isEditing = c.editCell == CellPos(r, ci);
    final selected = c.isCellSelected(r, ci) && c.focused;
    final editableCell = c.canEditRow(col, item.row!);
    final dim =
        col.type == SuperColumnType.computed ||
        col.type == SuperColumnType.readonly;
    final storedError = item.row!.cells[col.key]?.error;
    final error = _editable
        ? (storedError ??
              SuperColumnLogic.validateCell(col, col.rawValue(item.row!)))
        : null;
    final rowActive =
        (c.rowMode ? c.selRows.contains(r) : c.sel.r == r) && c.focused;
    final cellStyle = _cellStyle(col, item.row!);
    final tableArea = _bodyArea(r, ci, columnCount);
    final disabledArea = dim ? _tableStyle?.disabledStyle : null;

    // Row styles take priority over cell styles for fg/weight.
    final fg =
        rowStyle?.foreground ??
        cellStyle?.foreground ??
        disabledArea?.foreground ??
        tableArea?.foreground;
    final weight =
        rowStyle?.fontWeight ??
        cellStyle?.fontWeight ??
        disabledArea?.fontWeight ??
        tableArea?.fontWeight;

    final alignV = cellStyle?.align;
    final align = switch (alignV ?? _colAlign(col)) {
      TextAlign.right => AlignmentDirectional.centerEnd,
      TextAlign.center => Alignment.center,
      _ => AlignmentDirectional.centerStart,
    };

    Color bg;
    if (isEditing) {
      bg = skin.surface;
    } else if (active) {
      bg =
          _tableStyle?.focusedCellStyle?.background ??
          skin.accentWash(context, 0.14);
    } else if (selected) {
      bg =
          _tableStyle?.selectedCellStyle?.background ??
          skin.accentWash(context, 0.09);
    } else if (cellStyle?.background != null && rowStyle?.background == null) {
      bg = cellStyle!.background!;
    } else if (rowActive) {
      bg =
          _tableStyle?.selectedRowStyle?.background ??
          skin.accentWash(context, 0.05);
    } else if (rowStyle?.background != null) {
      bg = Colors.transparent; // row paints its own background
    } else if (dim) {
      bg = disabledArea?.background ?? skin.dimFill;
    } else if (tableArea?.background != null) {
      bg = tableArea!.background!;
    } else {
      bg = Colors.transparent;
    }

    final Widget content = isEditing
        ? SuperCellEditor(
            controller: c,
            col: col,
            row: item.row!,
            value: c.draft,
            height: _rowH,
            rtl: context.isRtl,
            onChanged: c.setDraft,
            onCancel: c.cancelEdit,
            onCommit: ({Object? override, int dr = 0, int dc = 0}) => c.commit(
              move: (dr == 0 && dc == 0) ? null : CellPos(dr, dc),
              override: override,
            ),
          )
        : Align(
            alignment: align,
            child: SuperCellDisplay(
              col: col,
              row: item.row!,
              fg: fg,
              weight: weight,
            ),
          );

    Widget cell = Container(
      width: w,
      height: _rowH,
      padding: isEditing
          ? EdgeInsets.zero
          : EdgeInsetsDirectional.only(
              start: 11,
              end: (error != null) ? 26 : 11,
            ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(right: _dividerSide(skin), bottom: _dividerSide(skin)),
      ),
      child: content,
    );

    Border? outline;
    if (active) {
      outline = Border.all(color: skin.accent(context), width: 2);
    } else if (selected) {
      outline = Border.all(
        color: skin.accent(context).withValues(alpha: 0.45),
        width: 1,
      );
    } else if (selDim) {
      outline = Border.all(color: skin.borderStrong, width: 1);
    } else if (error != null && !isEditing) {
      outline = Border.all(
        color: skin.danger(context).withValues(alpha: 0.55),
        width: 1,
      );
    }
    if (outline != null) {
      cell = Stack(
        children: [
          cell,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(decoration: BoxDecoration(border: outline)),
            ),
          ),
        ],
      );
    }

    if (error != null && !isEditing) {
      cell = Stack(
        children: [
          cell,
          PositionedDirectional(
            end: 4,
            top: 0,
            bottom: 0,
            child: Center(child: SuperCellErrorBadge(error: error)),
          ),
        ],
      );
    }

    // Change-tracking: mark dirty cells with a small accent corner (1.0.0).
    if (c.trackChanges && !isEditing && c.isCellDirty(item.row!, col.key)) {
      cell = Stack(
        children: [
          cell,
          PositionedDirectional(
            top: 0,
            start: 0,
            child: IgnorePointer(
              child: CustomPaint(
                size: const Size(8, 8),
                painter: _DirtyCornerPainter(skin.accent(context)),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) {
        _focus.requestFocus();
        _lastPointer = d.globalPosition;
      },
      onTap: () {
        if (isEditing) return;
        if (c.editCell != null) c.commit();
        final keys = HardwareKeyboard.instance.logicalKeysPressed;
        c.pick(
          r,
          ci,
          shift: HardwareKeyboard.instance.isShiftPressed,
          meta: _meta(keys),
        );
        widget.interactions?.onCellTap?.call(
          _cellInteraction(
            col,
            item.row!,
            r,
            ci,
            item.sourceIndex,
            _lastPointer,
          ),
        );
      },
      onDoubleTap:
          (editableCell ||
              widget.interactions?.onCellDoubleTap != null ||
              (widget.interactions?.onRowActivate != null &&
                  c.mode == SuperTableMode.readable))
          ? () {
              widget.interactions?.onCellDoubleTap?.call(
                _cellInteraction(
                  col,
                  item.row!,
                  r,
                  ci,
                  item.sourceIndex,
                  _lastPointer,
                ),
              );
              if (editableCell) {
                c.beginEdit(r: r, c: ci);
              } else if (c.mode == SuperTableMode.readable) {
                widget.interactions?.onRowActivate?.call(
                  _rowInteraction(item.row!, r, item.sourceIndex, _lastPointer),
                );
              }
            }
          : null,
      onSecondaryTapDown: (d) {
        _lastPointer = d.globalPosition;
        widget.interactions?.onCellSecondaryTap?.call(
          _cellInteraction(
            col,
            item.row!,
            r,
            ci,
            item.sourceIndex,
            d.globalPosition,
          ),
        );
        _openRowMenu(r, d.globalPosition);
      },
      child: MouseRegion(
        onEnter: _tableStyle == null
            ? null
            : (_) => _setHoveredCell(CellPos(r, ci)),
        onExit: _tableStyle == null
            ? null
            : (_) {
                if (_hoveredCell == CellPos(r, ci)) _setHoveredCell(null);
              },
        cursor: editableCell
            ? SystemMouseCursors.cell
            : SystemMouseCursors.basic,
        child: cell,
      ),
    );
  }

  TextAlign _colAlign(SuperColumn col) => switch (col.align) {
    SuperAlign.end => TextAlign.right,
    SuperAlign.center => TextAlign.center,
    SuperAlign.start => TextAlign.left,
  };

  // ── row expansion helpers (readable mode) ──────────────────────────────

  /// Whether [row] is currently expanded.
  bool _isExpanded(SuperRow<R> row) => _expandedRowIds.contains(row.id);

  /// Toggle the expansion state of [row], honouring the [SuperRowExpansionMode]
  /// policy set on [exp].
  ///
  /// [single] mode: clears all other expanded rows before opening the new one.
  /// [multi]  mode: any number of rows may be open simultaneously.
  void _toggleExpansion(SuperRow<R> row, SuperRowExpansion<R> exp) {
    setState(() {
      final id = row.id;
      if (_expandedRowIds.contains(id)) {
        _expandedRowIds.remove(id);
      } else {
        if (exp.mode == SuperRowExpansionMode.single) _expandedRowIds.clear();
        _expandedRowIds.add(id);
      }
    });
  }

  /// Expand the currently focused row (keyboard shortcut handler).
  /// No-op when the row is already expanded or the cursor is on a group header.
  /// Respects [SuperRowExpansionMode]: in [single] mode any other open row is
  /// collapsed first.
  void _expandFocusedRow(SuperRowExpansion<R> exp) {
    final viewR = c.sel.r;
    if (viewR >= c.view.length) return;
    final row = c.view[viewR].row;
    if (row == null) return; // group-header row — not expandable
    final id = row.id;
    if (!_expandedRowIds.contains(id)) {
      setState(() {
        if (exp.mode == SuperRowExpansionMode.single) _expandedRowIds.clear();
        _expandedRowIds.add(id);
      });
    }
  }

  /// Collapse the currently focused row (keyboard shortcut handler).
  /// No-op when the row is already collapsed or the cursor is on a group header.
  void _collapseFocusedRow() {
    final viewR = c.sel.r;
    if (viewR >= c.view.length) return;
    final row = c.view[viewR].row;
    if (row == null) return;
    final id = row.id;
    if (_expandedRowIds.contains(id)) {
      setState(() => _expandedRowIds.remove(id));
    }
  }

  /// Builds the animated expansion panel for [row].
  ///
  /// Uses [ClipRect] + [AnimatedAlign] with a `heightFactor` tween so the
  /// child is always laid out at the full panel height and smoothly
  /// revealed/hidden — the same technique Flutter's own [ExpansionTile] uses.
  /// The gutter's [AnimatedContainer] uses an identical height tween so both
  /// animate in perfect lock-step regardless of curve or duration.
  Widget _buildExpansionPanel(
    SuperTableSkin skin,
    SuperRow<R> row,
    SuperRowExpansion<R> exp,
    bool expanded,
  ) {
    final panelH = exp.heightFor(row);
    return ClipRect(
      child: AnimatedAlign(
        alignment: Alignment.topCenter,
        heightFactor: expanded ? 1.0 : 0.0,
        duration: exp.animationDuration,
        curve: exp.animationCurve,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: skin.surface2,
            border: Border(bottom: _dividerSide(skin)),
          ),
          child: SizedBox(
            width: double.infinity,
            height: panelH,
            child: exp.builder(context, c, row),
          ),
        ),
      ),
    );
  }

  /// Gutter cell variant used when expansion is enabled. Tapping anywhere in
  /// the row-number cell selects the row and toggles its expansion state.
  Widget _rowGutterWithExpand(
    SuperTableSkin skin,
    int r,
    SuperRow<R> row,
    bool rowActive,
    bool expanded,
    SuperRowExpansion<R> exp,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) {
        _focus.requestFocus();
        _lastPointer = d.globalPosition;
      },
      onTap: () {
        c.selectGutterRow(
          r,
          shift: HardwareKeyboard.instance.isShiftPressed,
          meta: _meta(HardwareKeyboard.instance.logicalKeysPressed),
        );
        _fireRowTap(r);
        _toggleExpansion(row, exp);
      },
      child: Container(
        width: _gutterW,
        height: _rowH,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: rowActive
              ? _tableStyle?.selectedRowStyle?.background ??
                    skin.accentWashOnBg(context, 0.12)
              : skin.bg,
          border: BorderDirectional(
            end: _strongDividerSide(skin),
            bottom: _dividerSide(skin),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 1),
              child: AnimatedRotation(
                turns: expanded ? 0.5 : 0.0,
                duration: exp.animationDuration,
                curve: exp.animationCurve,
                child: Icon(
                  Icons.expand_more_rounded,
                  size: 13,
                  color: expanded ? skin.accent(context) : skin.fg4,
                ),
              ),
            ),
            Text(
              (r + 1).toString().padLeft(2, '0'),
              style: TextStyle(
                fontFamily: context.superTextTheme.mono.fontFamily,
                fontSize: 10,
                fontWeight: rowActive ? FontWeight.w700 : FontWeight.w400,
                color: rowActive ? skin.accent(context) : skin.fg3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(SuperTableSkin skin) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 26, color: skin.fg3),
          const SizedBox(height: 10),
          Text(
            context.superTableTranslations.noRows,
            style: TextStyle(fontSize: 13, color: skin.fg3),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals(SuperTableSkin skin, List<SuperColumn> cols) {
    final area = _totalArea;
    return Container(
      height: _rowH,
      decoration: BoxDecoration(
        color: area?.background ?? skin.surface2,
        border: Border(top: _strongDividerSide(skin, width: 2)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < cols.length; i++) _totalCell(skin, cols[i], i),
          if (_actionable) SizedBox(width: _actW),
        ],
      ),
    );
  }

  Widget _totalCell(SuperTableSkin skin, SuperColumn col, int i) {
    final area = _totalArea;
    final w = c.widthOf(col);
    final v = col.agg == SuperAgg.none
        ? null
        : SuperColumnLogic.aggregate(col, c.sortedRows);
    Widget child;
    if (v != null) {
      final isCur = col.type == SuperColumnType.currency;
      final prefix = col.prefix ?? (isCur ? r'$' : '');
      final suffix = col.suffix != null
          ? (isCur ? ' ${col.suffix}' : col.suffix)
          : '';
      final txt = col.agg == SuperAgg.count
          ? '${v.toInt()}'
          : '$prefix${SuperColumnLogic.fmtNum(col.agg == SuperAgg.avg ? (v * 100).round() / 100 : v, col.copyWith(decimals: col.type == SuperColumnType.progress ? 0 : col.decimals))}$suffix';
      child = Text(
        txt,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: context.superTextTheme.mono.fontFamily,
          fontSize: 12.5,
          fontWeight: area?.fontWeight ?? FontWeight.w700,
          color: area?.foreground ?? skin.fg1,
        ),
      );
    } else if (i == 0) {
      child = Text(
        context.superTableTranslations.totals,
        style: TextStyle(
          fontSize: 10,
          fontWeight: area?.fontWeight ?? FontWeight.w700,
          letterSpacing: 0.6,
          color: area?.foreground ?? skin.fg3,
        ),
      );
    } else {
      child = const SizedBox.shrink();
    }
    return Container(
      width: w,
      height: _rowH,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      alignment: col.align == SuperAlign.end
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      decoration: BoxDecoration(border: Border(right: _dividerSide(skin))),
      child: child,
    );
  }

  List<Widget> _buildFooterStack(SuperTableSkin skin) {
    final l10n = context.superTableTranslations;
    final out = <Widget>[];
    if (c.pagination == SuperPagination.loadMore &&
        c.hasMore &&
        !widget.loading) {
      out.add(
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Center(
            child: _BarButton(
              skin: skin,
              icon: c.loadingMore ? null : Icons.arrow_downward_rounded,
              label: c.loadingMore ? l10n.loading : l10n.loadMore,
              enabled: !c.loadingMore,
              onTap: c.requestLoadMore,
            ),
          ),
        ),
      );
    }
    if (c.pagination == SuperPagination.pages &&
        !c.grouped &&
        c.pageCount > 1) {
      out.add(_buildPager(skin));
    }
    out.add(_buildStatusHint(skin));
    return out;
  }

  Widget _buildPager(SuperTableSkin skin) {
    final l10n = context.superTableTranslations;
    final total = c.sortedRows.length;
    final from = total == 0 ? 0 : c.page * c.pageSize + 1;
    final to = (c.page * c.pageSize + c.pageSize).clamp(0, total);
    final pages = <int>[
      for (var i = 0; i < c.pageCount; i++)
        if ((i - c.page).abs() <= 2 || i == 0 || i == c.pageCount - 1) i,
    ];
    final widgets = <Widget>[];
    int? prev;
    for (final i in pages) {
      if (prev != null && i - prev > 1) {
        widgets.add(
          SizedBox(
            width: 20,
            child: Center(
              child: Text('…', style: TextStyle(color: skin.fg4)),
            ),
          ),
        );
      }
      widgets.add(
        _PageNumBtn(
          skin: skin,
          n: i,
          active: i == c.page,
          onTap: () => c.setPage(i),
        ),
      );
      prev = i;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Text(
            total == 0 ? l10n.pageRangeEmpty : l10n.pageRange(from, to, total),
            style: TextStyle(fontSize: 12, color: skin.fg3),
          ),
          const Spacer(),
          _PagerBtn(
            skin: skin,
            icon: context.isRtl
                ? Icons.chevron_right_rounded
                : Icons.chevron_left_rounded,
            enabled: c.page > 0,
            onTap: () => c.setPage(c.page - 1),
          ),
          const SizedBox(width: 6),
          ...widgets.expand((w) => [w, const SizedBox(width: 3)]),
          const SizedBox(width: 3),
          _PagerBtn(
            skin: skin,
            icon: context.isRtl
                ? Icons.chevron_left_rounded
                : Icons.chevron_right_rounded,
            enabled: c.page < c.pageCount - 1,
            onTap: () => c.setPage(c.page + 1),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHint(SuperTableSkin skin) {
    final l10n = context.superTableTranslations;
    final n = _editable ? c.rows.length : c.sortedRows.length;
    final expKeys = !_editable && widget.expansion?.keymap != null
        ? l10n.expandCollapseHint
        : '';
    final rowCount = l10n.rowCount(n, n == 1 ? '' : 's');
    final hint = _editable
        ? l10n.editableStatusHint(rowCount)
        : l10n.readableStatusHint(rowCount, expKeys);
    final stats = c.selectionStats;
    final issues = _editable ? c.errorCount : 0;
    String fmt(num v) =>
        v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        runSpacing: 12,
        spacing: 12,
        children: [
          Text(hint, style: TextStyle(fontSize: 12, color: skin.fg3)),
          if (issues > 0) ...[
            _ValidationChip(
              skin: skin,
              count: issues,
              onTap: () => showSuperValidationPanel<R>(context, c),
            ),
            const SizedBox(width: 14),
          ],
          if (stats != null && stats.hasAggregate) ...[
            Text(
              l10n.selectionStats(
                fmt(stats.sum),
                fmt(stats.average),
                fmt(stats.min!),
                fmt(stats.max!),
                stats.numericCount,
              ),
              style: TextStyle(
                fontFamily: context.superTextTheme.mono.fontFamily,
                fontSize: 11.5,
                color: skin.accent(context),
              ),
            ),
            const SizedBox(width: 14),
          ],
          if (c.rowMode && c.selRows.isNotEmpty)
            Text(
              l10n.selectedCount(c.selRows.length),
              style: TextStyle(fontSize: 12, color: skin.accent(context)),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(SuperTableSkin skin, List<SuperColumn> cols) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.skeletonRows; i++) _skeletonRow(skin, cols),
      ],
    );
  }

  Widget _skeletonRow(SuperTableSkin skin, List<SuperColumn> cols) {
    return Container(
      height: _rowH,
      decoration: BoxDecoration(border: Border(bottom: _dividerSide(skin))),
      child: Row(
        children: [
          for (final col in cols)
            Container(
              width: c.widthOf(col),
              alignment: col.align == SuperAlign.end
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                border: Border(right: _dividerSide(skin)),
              ),
              child: _Shimmer(
                width: (c.widthOf(col) * 0.5).clamp(24.0, 160.0),
                height: 10,
              ),
            ),
          if (_actionable) SizedBox(width: _actW),
        ],
      ),
    );
  }
}

// ── footer validation chip (2.1.0) ──
class _ValidationChip extends StatelessWidget {
  final SuperTableSkin skin;
  final int count;
  final VoidCallback onTap;
  const _ValidationChip({
    required this.skin,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: skin.tint(skin.danger(context), 0.07),
            border: Border.all(
              color: skin.danger(context).withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 13,
                color: skin.danger(context),
              ),
              const SizedBox(width: 5),
              Text(
                context.superTableTranslations.issueCount(
                  count,
                  count == 1 ? '' : 's',
                ),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: skin.danger(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── animated shimmer bar for skeleton rows ──
class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  const _Shimmer({required this.width, required this.height});
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = SuperTableSkin.of(context);
    return AnimatedBuilder(
      animation: _ac,
      builder: (ctx, _) {
        final t = 0.45 + 0.55 * _ac.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: skin.inputBg.withValues(alpha: t),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      },
    );
  }
}

/// Disabled per-column filter field shown with a slash while the advanced
/// filter is active.
class _DisabledFilter extends StatelessWidget {
  final SuperTableSkin skin;
  const _DisabledFilter({required this.skin});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kFilterRowH,
      color: skin.dimFill,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _SlashPainter(skin.fg4.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlashPainter extends CustomPainter {
  final Color color;
  _SlashPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.32, size.height * 0.72),
      Offset(size.width * 0.68, size.height * 0.28),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _SlashPainter old) => old.color != color;
}

/// A small filled triangle painted in a cell's top-leading corner to mark a
/// dirty (changed) cell when change-tracking is on.
class _DirtyCornerPainter extends CustomPainter {
  final Color color;
  _DirtyCornerPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(covariant _DirtyCornerPainter old) => old.color != color;
}

// ── small shared widgets ──
class _BarButton extends StatefulWidget {
  final SuperTableSkin skin;
  final IconData? icon;
  final String? label;
  final bool enabled;
  final VoidCallback onTap;
  const _BarButton({
    required this.skin,
    this.icon,
    this.label,
    this.enabled = true,
    required this.onTap,
  });
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
            padding: EdgeInsets.symmetric(
              horizontal: widget.label != null ? 11 : 8,
            ),
            decoration: BoxDecoration(
              color: on && _h ? s.hover : Colors.transparent,
              border: Border.all(color: s.borderStrong),
              borderRadius: BorderRadius.circular(
                context.superTheme.spacing.radiusControl,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null)
                  Icon(widget.icon, size: 14, color: s.fg2),
                if (widget.icon != null && widget.label != null)
                  const SizedBox(width: 7),
                if (widget.label != null)
                  Text(
                    widget.label!,
                    style: TextStyle(
                      fontFamily: context.superTextTheme.body.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: s.fg2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

class _IconHoverButton extends StatefulWidget {
  final SuperTableSkin skin;
  final IconData icon;
  final String tooltip;
  final bool danger;
  final bool accent;
  final VoidCallback onTap;
  const _IconHoverButton({
    required this.skin,
    required this.icon,
    required this.tooltip,
    this.danger = false,
    this.accent = false,
    required this.onTap,
  });
  @override
  State<_IconHoverButton> createState() => _IconHoverButtonState();
}

class _IconHoverButtonState extends State<_IconHoverButton> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.skin;
    final color = widget.accent
        ? s.accent(context)
        : (_h
              ? (widget.danger ? s.danger(context) : s.accent(context))
              : (widget.danger ? s.fg3 : s.fg4));
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
              color: (_h || widget.accent)
                  ? (widget.danger
                        ? s.tint(s.danger(context), 0.12)
                        : s.accentWash(context, 0.14))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                context.superTheme.spacing.radiusControl,
              ),
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
  const _PageNumBtn({
    required this.skin,
    required this.n,
    required this.active,
    required this.onTap,
  });
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
          color: active ? skin.accent(context) : Colors.transparent,
          border: Border.all(
            color: active ? Colors.transparent : skin.borderStrong,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          '${n + 1}',
          style: TextStyle(
            fontFamily: context.superTextTheme.mono.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : skin.fg2,
          ),
        ),
      ),
    );
  }
}

class _PagerBtn extends StatelessWidget {
  final SuperTableSkin skin;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PagerBtn({
    required this.skin,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });
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
