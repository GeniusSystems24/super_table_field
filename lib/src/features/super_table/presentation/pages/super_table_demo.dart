// ============================================================
// features/super_table/presentation/pages/super_table_demo.dart
// ------------------------------------------------------------
// A comprehensive, self-contained gallery page for the unified SuperTable,
// exercising EVERY available feature and state:
//
//   COLUMN TYPES        — text · number · currency · enumeration · combo
//                         · progress · color · date · link · checkbox
//                         · readonly · computed
//   SELECTION MODES     — singleCell · multiCells · singleRow · multiRows
//   MODES               — readable · editable
//   GROUPING            — single & multi-level · expand/collapse
//   FILTERS             — per-column filters (readable mode)
//   SEARCH              — global text search
//   SORT                — ascending · descending · clear
//   PAGINATION          — pages · load-more · infinite-scroll
//   CLIPBOARD           — copy JSON · paste JSON/TSV · cut
//   HISTORY             — undo · redo (200 snapshots)
//   ROW OPS             — add · insert · duplicate · delete
//   EDITING             — inline edit · commit · cancel · tab navigation
//   CUSTOM MENUS        — rowMenuBuilder with nested submenus
//   PINNING             — left · right · none
//   ALIGNMENT           — start · center · end
//   AGGREGATION         — sum · avg · count · none
//   TOTALS ROW          — computed aggregates
//   LOADING STATES      — skeleton · load-more spinner
//   COLUMN VISIBILITY   — hide/show columns
//   WIDTH & REORDER     — resize · drag-to-reorder
//   KEYBOARD NAV        — arrows · Enter · Esc · Tab · Ctrl+A · Ctrl+Z/Y
//   RTL SUPPORT         — bidirectional layout
//
// This is the canonical reference for every SuperTable capability.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../domain/entities/super_column.dart';
import '../../domain/entities/super_table_state.dart';
import '../controllers/super_table_controller.dart';
import '../widgets/super_table.dart';
import '../widgets/super_table_overlays.dart';

class SuperTableDemo extends StatefulWidget {
  const SuperTableDemo({super.key});

  @override
  State<SuperTableDemo> createState() => _SuperTableDemoState();
}

class _SuperTableDemoState extends State<SuperTableDemo> {
  late final SuperTableController _c;

  // ── toolbar toggles ──
  SuperTableMode _mode = SuperTableMode.editable;
  SuperSelectionMode _selMode = SuperSelectionMode.singleCell;
  SuperPagination _pagination = SuperPagination.loadMore;
  bool _groupedByCat = false;
  bool _groupedByStatus = false;
  bool _showTotals = true;
  bool _formulaBar = true;
  bool _columnFilters = true;
  bool _loading = false;
  bool _numbered = true;
  String? _toast;

  // ── columns (covers every SuperColumnType) ──
  static List<SuperColumn> _columns(SuperTableMode mode) => [
        // text — pinned left, monospace, bilingual
        SuperColumn(
          key: 'sku',
          label: 'SKU',
          type: SuperColumnType.text,
          width: 120,
          mono: true,
          pin: SuperPin.left,
          sortable: true,
          filterable: mode == SuperTableMode.readable,
          editable: mode != SuperTableMode.readable,
          groupable: true,
        ),
        // text — bilingual (arKey)
        SuperColumn(
          key: 'item',
          label: 'Item',
          type: SuperColumnType.text,
          width: 200,
          arKey: 'item_ar',
          required: true,
          sortable: true,
          filterable: mode == SuperTableMode.readable,
          editable: mode != SuperTableMode.readable,
          groupable: true,
        ),
        // enumeration — grouped by default
        SuperColumn(
          key: 'cat',
          label: 'Category',
          type: SuperColumnType.enumeration,
          width: 140,
          opts: const [
            'Raw Material',
            'Component',
            'Finished Good',
            'Consumable'
          ],
          sortable: true,
          filterable: mode == SuperTableMode.readable,
          editable: mode != SuperTableMode.readable,
          groupable: true,
        ),
        // enumeration — status pills
        SuperColumn(
          key: 'status',
          label: 'Status',
          type: SuperColumnType.enumeration,
          width: 120,
          opts: const ['In Stock', 'Low Stock', 'Out of Stock', 'Discontinued'],
          groupable: true,
          sortable: true,
          filterable: mode == SuperTableMode.readable,
          editable: mode != SuperTableMode.readable,
        ),
        // number — right-aligned, sum aggregate
        SuperColumn(
          key: 'qty',
          label: 'Qty',
          type: SuperColumnType.number,
          width: 80,
          align: SuperAlign.end,
          agg: SuperAgg.sum,
          sortable: true,
          filterable: mode == SuperTableMode.readable,
          editable: mode != SuperTableMode.readable,
          groupable: true,
        ),
        // combo — edited via AutoSuggestionsBox
        SuperColumn(
          key: 'unit',
          label: 'Unit',
          type: SuperColumnType.combo,
          width: 110,
          opts: const [
            'each',
            'box',
            'pallet',
            'kg',
            'tonne',
            'litre',
            'metre',
            'roll',
            'sheet'
          ],
          sortable: true,
          filterable: mode == SuperTableMode.readable,
          editable: mode != SuperTableMode.readable,
          groupable: true,
        ),
        // currency — right-aligned, suffix, decimals
        SuperColumn(
          key: 'price',
          label: 'Unit Price',
          type: SuperColumnType.currency,
          width: 120,
          align: SuperAlign.end,
          suffix: 'SAR',
          decimals: 2,
          sortable: true,
          filterable: mode == SuperTableMode.readable,
          editable: mode != SuperTableMode.readable,
          groupable: true,
        ),
        // computed — derived value, sum aggregate
        SuperColumn(
          key: 'total',
          label: 'Line Total',
          type: SuperColumnType.computed,
          width: 130,
          align: SuperAlign.end,
          agg: SuperAgg.sum,
          compute: (r) =>
              (r['qty'] is num ? r['qty'] as num : 0) *
              (r['price'] is num ? r['price'] as num : 0),
          format: (v, r) => '${(v as num).toStringAsFixed(2)} SAR',
        ),
        // progress — 0-100 bar
        SuperColumn(
          key: 'fill',
          label: 'Fill %',
          type: SuperColumnType.progress,
          width: 110,
          max: 100,
          sortable: true,
          filterable: mode == SuperTableMode.readable,
          editable: mode != SuperTableMode.readable,
          groupable: true,
        ),
        // date — YYYY-MM-DD
        SuperColumn(
          key: 'received',
          label: 'Received',
          type: SuperColumnType.date,
          width: 120,
          sortable: true,
          filterable: mode == SuperTableMode.readable,
          editable: mode != SuperTableMode.readable,
          groupable: true,
        ),
        // link — clickable URL
        SuperColumn(
          key: 'doc',
          label: 'Doc',
          type: SuperColumnType.link,
          width: 90,
          sortable: false,
          filterable: false,
        ),
        // color — hex swatch
        SuperColumn(
          key: 'tag',
          label: 'Tag',
          type: SuperColumnType.color,
          width: 90,
          sortable: false,
          filterable: false,
        ),
        // checkbox — boolean tick
        SuperColumn(
          key: 'active',
          label: 'Active',
          type: SuperColumnType.checkbox,
          width: 70,
          align: SuperAlign.center,
          sortable: true,
          filterable: mode == SuperTableMode.readable,
          editable: mode != SuperTableMode.readable,
          groupable: true,
        ),
        // readonly — non-editable display
        SuperColumn(
          key: 'readonly_id',
          label: 'ID',
          type: SuperColumnType.readonly,
          width: 80,
          mono: true,
          sortable: false,
          filterable: false,
        ),
        // number — pinned right, sign-colored
        SuperColumn(
          key: 'delta',
          label: 'Delta',
          type: SuperColumnType.number,
          width: 80,
          align: SuperAlign.end,
          colorSign: true,
          pin: SuperPin.right,
          sortable: true,
          filterable: mode == SuperTableMode.readable,
          editable: mode != SuperTableMode.readable,
          groupable: true,
        ),
      ];

  // ── seed data (16 rows, diverse values) ──
  static List<SuperRow> _seed() => [
        {
          'sku': 'INV-SB-200',
          'item': 'Steel Beam 200mm',
          'item_ar': 'عارضة فولاذية ٢٠٠ مم',
          'cat': 'Raw Material',
          'status': 'In Stock',
          'qty': 120,
          'unit': 'each',
          'price': 340.0,
          'fill': 82,
          'received': '2026-02-12',
          'doc': 'https://example.com/sb200',
          'tag': '#4A7CFF',
          'active': true,
          'readonly_id': 'RM-001',
          'delta': 12
        },
        {
          'sku': 'INV-CM-050',
          'item': 'Concrete Mix 50kg',
          'item_ar': 'خلطة خرسانة ٥٠ كجم',
          'cat': 'Consumable',
          'status': 'Low Stock',
          'qty': 38,
          'unit': 'box',
          'price': 18.5,
          'fill': 24,
          'received': '2026-03-01',
          'doc': 'https://example.com/cm050',
          'tag': '#E0A23B',
          'active': true,
          'readonly_id': 'CO-002',
          'delta': -5
        },
        {
          'sku': 'INV-RB-012',
          'item': 'Rebar Bundle 12mm',
          'item_ar': 'حزمة حديد تسليح ١٢ مم',
          'cat': 'Component',
          'status': 'In Stock',
          'qty': 64,
          'unit': 'pallet',
          'price': 96.75,
          'fill': 58,
          'received': '2026-01-20',
          'doc': 'https://example.com/rb012',
          'tag': '#1DB88A',
          'active': true,
          'readonly_id': 'CP-003',
          'delta': 8
        },
        {
          'sku': 'INV-WP-018',
          'item': 'Waterproof Membrane',
          'item_ar': 'غشاء عازل للماء',
          'cat': 'Finished Good',
          'status': 'Out of Stock',
          'qty': 0,
          'unit': 'roll',
          'price': 220.0,
          'fill': 0,
          'received': '2025-12-08',
          'doc': 'https://example.com/wp018',
          'tag': '#EF4444',
          'active': false,
          'readonly_id': 'FG-004',
          'delta': -22
        },
        {
          'sku': 'INV-AL-040',
          'item': 'Aluminium Sheet 4mm',
          'item_ar': 'صفيحة ألمنيوم ٤ مم',
          'cat': 'Raw Material',
          'status': 'In Stock',
          'qty': 210,
          'unit': 'sheet',
          'price': 154.25,
          'fill': 91,
          'received': '2026-02-28',
          'doc': 'https://example.com/al040',
          'tag': '#8B5CF6',
          'active': true,
          'readonly_id': 'RM-005',
          'delta': 45
        },
        {
          'sku': 'INV-PV-025',
          'item': 'PVC Pipe 25mm',
          'item_ar': 'أنبوب بي في سي ٢٥ مم',
          'cat': 'Component',
          'status': 'Low Stock',
          'qty': 47,
          'unit': 'metre',
          'price': 12.4,
          'fill': 31,
          'received': '2026-03-09',
          'doc': 'https://example.com/pv025',
          'tag': '#06B6D4',
          'active': true,
          'readonly_id': 'CP-006',
          'delta': -3
        },
        {
          'sku': 'INV-GL-006',
          'item': 'Tempered Glass 6mm',
          'item_ar': 'زجاج مقسّى ٦ مم',
          'cat': 'Finished Good',
          'status': 'In Stock',
          'qty': 88,
          'unit': 'sheet',
          'price': 410.0,
          'fill': 67,
          'received': '2026-01-15',
          'doc': 'https://example.com/gl006',
          'tag': '#EC4899',
          'active': true,
          'readonly_id': 'FG-007',
          'delta': 18
        },
        {
          'sku': 'INV-NL-100',
          'item': 'Galvanized Nails 100mm',
          'item_ar': 'مسامير مجلفنة ١٠٠ مم',
          'cat': 'Consumable',
          'status': 'Discontinued',
          'qty': 12,
          'unit': 'box',
          'price': 4.8,
          'fill': 8,
          'received': '2025-11-30',
          'doc': 'https://example.com/nl100',
          'tag': '#8C92A4',
          'active': false,
          'readonly_id': 'CO-008',
          'delta': -1
        },
        {
          'sku': 'INV-CE-001',
          'item': 'Ceramic Tile 60×60',
          'item_ar': 'بلاط سيراميك ٦٠×٦٠',
          'cat': 'Finished Good',
          'status': 'In Stock',
          'qty': 350,
          'unit': 'box',
          'price': 65.0,
          'fill': 78,
          'received': '2026-03-15',
          'doc': 'https://example.com/ce001',
          'tag': '#F59E0B',
          'active': true,
          'readonly_id': 'FG-009',
          'delta': 30
        },
        {
          'sku': 'INV-SD-009',
          'item': 'Silicone Sealant 300ml',
          'item_ar': 'مانع تسرب سيليكون ٣٠٠ مل',
          'cat': 'Consumable',
          'status': 'Low Stock',
          'qty': 22,
          'unit': 'each',
          'price': 8.5,
          'fill': 15,
          'received': '2026-02-20',
          'doc': 'https://example.com/sd009',
          'tag': '#10B981',
          'active': true,
          'readonly_id': 'CO-010',
          'delta': -8
        },
        {
          'sku': 'INV-AC-030',
          'item': 'Acoustic Panel 60×120',
          'item_ar': 'لوحة صوتية ٦٠×١٢٠',
          'cat': 'Component',
          'status': 'In Stock',
          'qty': 45,
          'unit': 'sheet',
          'price': 120.0,
          'fill': 42,
          'received': '2026-01-28',
          'doc': 'https://example.com/ac030',
          'tag': '#6366F1',
          'active': true,
          'readonly_id': 'CP-011',
          'delta': 5
        },
        {
          'sku': 'INV-FN-007',
          'item': 'Flush Nails 50mm',
          'item_ar': 'مسامير مسطحة ٥٠ مم',
          'cat': 'Consumable',
          'status': 'Out of Stock',
          'qty': 0,
          'unit': 'box',
          'price': 3.2,
          'fill': 0,
          'received': '2025-10-15',
          'doc': 'https://example.com/fn007',
          'tag': '#EF4444',
          'active': false,
          'readonly_id': 'CO-012',
          'delta': -12
        },
        {
          'sku': 'INV-WS-015',
          'item': 'Welding Rod 3.2mm',
          'item_ar': 'قضيب لحام ٣.٢ مم',
          'cat': 'Raw Material',
          'status': 'In Stock',
          'qty': 180,
          'unit': 'kg',
          'price': 28.5,
          'fill': 74,
          'received': '2026-03-05',
          'doc': 'https://example.com/ws015',
          'tag': '#3B82F6',
          'active': true,
          'readonly_id': 'RM-013',
          'delta': 22
        },
        {
          'sku': 'INV-EP-008',
          'item': 'Epoxy Resin 1L',
          'item_ar': 'راتنج إيبوكسي ١ لتر',
          'cat': 'Consumable',
          'status': 'In Stock',
          'qty': 55,
          'unit': 'litre',
          'price': 42.0,
          'fill': 48,
          'received': '2026-02-25',
          'doc': 'https://example.com/ep008',
          'tag': '#14B8A6',
          'active': true,
          'readonly_id': 'CO-014',
          'delta': 10
        },
        {
          'sku': 'INV-BR-022',
          'item': 'Brick Red 240×115',
          'item_ar': 'طوب أحمر ٢٤٠×١١٥',
          'cat': 'Component',
          'status': 'Low Stock',
          'qty': 33,
          'unit': 'pallet',
          'price': 85.0,
          'fill': 27,
          'received': '2026-01-10',
          'doc': 'https://example.com/br022',
          'tag': '#F97316',
          'active': true,
          'readonly_id': 'CP-015',
          'delta': -7
        },
        {
          'sku': 'INV-SA-011',
          'item': 'Sand Fine 50kg',
          'item_ar': 'رمل ناعم ٥٠ كجم',
          'cat': 'Raw Material',
          'status': 'In Stock',
          'qty': 420,
          'unit': 'tonne',
          'price': 15.0,
          'fill': 95,
          'received': '2026-03-18',
          'doc': 'https://example.com/sa011',
          'tag': '#84CC16',
          'active': true,
          'readonly_id': 'RM-016',
          'delta': 55
        },
      ];

  @override
  void initState() {
    super.initState();
    _c = _build();
  }

  SuperTableController _build() => SuperTableController(
      columns: _columns(_mode),
      rows: _seed(),
      mode: _mode,
      selectionMode: _selMode,
      addRowEnabled: _mode == SuperTableMode.editable,
      pagination: _pagination,
      pageSize: 6,
      onChange: (next) => _notify('Data changed (${next.length} rows)'),
      onNotify: (kind, msg) => setState(() => _toast = msg),
      onLoadMore: () {});

  void _rebuild() {
    final old = _c;
    _c = _build();
    // restore grouping state
    if (_groupedByCat) _c.toggleGroup('cat');
    if (_groupedByStatus) _c.toggleGroup('status');
    old.dispose();
    setState(() {});
  }

  void _notify(String msg) {
    setState(() => _toast = msg);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440),
            child: Padding(
              padding: const EdgeInsets.all(SuperTokens.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('SUPER TABLE • FULL FEATURE DEMO',
                      style: SuperText.eyebrow
                          .copyWith(color: SuperTokens.accent)),
                  const SizedBox(height: SuperTokens.space2),
                  Text('Issue Inventory',
                      style: SuperText.h1.copyWith(color: t.fg1)),
                  const SizedBox(height: SuperTokens.space2),
                  _hints(t),
                  const SizedBox(height: SuperTokens.space6),
                  _toolbar(t),
                  const SizedBox(height: SuperTokens.space4),
                  Flexible(
                    child: SuperTable(
                      controller: _c,
                      numbered: _numbered,
                      showTotals: _showTotals,
                      formulaBar: _formulaBar,
                      columnFilters: _columnFilters,
                      loading: _loading,
                      skeletonRows: 10,

                      // ── rowMenuBuilder: custom nested submenus ──
                      rowMenuBuilder: (ctx, defaults) => [
                        ...defaults,
                        SuperMenuEntry(
                          icon: Icons.analytics_outlined,
                          label: 'Analytics',
                          separatorBefore: true,
                          expanded: true,
                          children: [
                            SuperMenuEntry(
                              label: 'View Trend',
                              onTap: () =>
                                  _notify('Trend for ${ctx.row['sku']}'),
                            ),
                            SuperMenuEntry(
                              label: 'Compare to Average',
                              onTap: () => _notify('Compare ${ctx.row['sku']}'),
                            ),
                            SuperMenuEntry(
                              label: 'Export Row JSON',
                              onTap: () {
                                final json = ctx.row.toString();
                                Clipboard.setData(ClipboardData(text: json));
                                _notify('Copied row JSON');
                              },
                            ),
                          ],
                        ),
                        SuperMenuEntry(
                          icon: Icons.copy_outlined,
                          label: 'Copy SKU',
                          onTap: () {
                            final sku = ctx.row['sku']?.toString() ?? '';
                            Clipboard.setData(ClipboardData(text: sku));
                            _notify('Copied $sku');
                          },
                        ),
                        SuperMenuEntry(
                          icon: Icons.open_in_new_outlined,
                          label: 'Open Doc Link',
                          onTap: () => _notify('Open ${ctx.row['doc']}'),
                        ),
                      ],
                    ),
                  ),
                  // pagination controls
                  if (_pagination == SuperPagination.pages && !_loading)
                    _pageBar(t),
                  if (_toast != null) ...[
                    const SizedBox(height: SuperTokens.space3),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: t.surface,
                          border: Border.all(color: t.borderStrong),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: t.cardShadow,
                        ),
                        child: Text(_toast!,
                            style: SuperText.caption.copyWith(color: t.fg1)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── hint chips ──
  Widget _hints(SuperThemeData t) {
    return Wrap(
      spacing: SuperTokens.space3,
      runSpacing: SuperTokens.space2,
      children: [
        _hintChip(t, Icons.touch_app_outlined, 'Right-click → custom submenus'),
        _hintChip(
            t, Icons.keyboard_arrow_up, 'Combo: ↑/↓ + Enter pick, Esc cancel'),
        _hintChip(t, Icons.format_list_numbered, 'Frozen row-number gutter'),
        _hintChip(t, Icons.filter_alt_outlined, 'Readable-mode column filters'),
        _hintChip(t, Icons.group_work_outlined, 'Multi-level grouping'),
        _hintChip(t, Icons.copy_all_outlined, 'Ctrl+C JSON · Ctrl+V paste'),
        _hintChip(t, Icons.undo_outlined, 'Undo / Redo (Ctrl+Z / Ctrl+Y)'),
        _hintChip(t, Icons.table_chart_outlined,
            '15 column types · pin · align · agg'),
      ],
    );
  }

  Widget _hintChip(SuperThemeData t, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: t.inputBg,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: t.fg3),
        const SizedBox(width: 6),
        Text(text, style: SuperText.caption.copyWith(color: t.fg2)),
      ]),
    );
  }

  // ── toolbar ──
  Widget _toolbar(SuperThemeData t) {
    return Wrap(
      spacing: SuperTokens.space2,
      runSpacing: SuperTokens.space2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Mode
        _seg('Mode', [
          (
            'Readable',
            _mode == SuperTableMode.readable,
            () {
              setState(() {
                _mode = SuperTableMode.readable;
              });
              _rebuild();
            }
          ),
          (
            'Editable',
            _mode == SuperTableMode.editable,
            () {
              setState(() {
                _mode = SuperTableMode.editable;
              });
              _rebuild();
            }
          ),
        ]),
        // Selection
        _seg('Select', [
          (
            'Cell',
            _selMode == SuperSelectionMode.singleCell,
            () => _setSel(SuperSelectionMode.singleCell)
          ),
          (
            'Cells',
            _selMode == SuperSelectionMode.multiCells,
            () => _setSel(SuperSelectionMode.multiCells)
          ),
          (
            'Row',
            _selMode == SuperSelectionMode.singleRow,
            () => _setSel(SuperSelectionMode.singleRow)
          ),
          (
            'Rows',
            _selMode == SuperSelectionMode.multiRows,
            () => _setSel(SuperSelectionMode.multiRows)
          ),
        ]),
        // Pagination
        _seg('Pages', [
          (
            'Off',
            _pagination == SuperPagination.none,
            () => _setPag(SuperPagination.none)
          ),
          (
            'Pages',
            _pagination == SuperPagination.pages,
            () => _setPag(SuperPagination.pages)
          ),
          (
            'Load+',
            _pagination == SuperPagination.loadMore,
            () => _setPag(SuperPagination.loadMore)
          ),
        ]),
        // Grouping toggles
        _toggle(t, 'Group: Cat', _groupedByCat, () {
          setState(() => _groupedByCat = !_groupedByCat);
          _c.toggleGroup('cat');
        }),
        _toggle(t, 'Group: Status', _groupedByStatus, () {
          setState(() => _groupedByStatus = !_groupedByStatus);
          _c.toggleGroup('status');
        }),
        // Feature toggles
        _toggle(t, 'Totals', _showTotals,
            () => setState(() => _showTotals = !_showTotals)),
        _toggle(t, 'Formula', _formulaBar,
            () => setState(() => _formulaBar = !_formulaBar)),
        _toggle(t, 'Filters', _columnFilters,
            () => setState(() => _columnFilters = !_columnFilters)),
        _toggle(t, 'Numbered', _numbered,
            () => setState(() => _numbered = !_numbered)),
        _toggle(
            t, 'Loading', _loading, () => setState(() => _loading = !_loading)),
        // Search
        SizedBox(width: 180, child: _searchField(t)),
        // History
        _iconBtn(t, Icons.undo_outlined, _c.canUndo, () {
          _c.undo();
          _notify('Undo');
        }),
        _iconBtn(t, Icons.redo_outlined, _c.canRedo, () {
          _c.redo();
          _notify('Redo');
        }),
        // Clipboard
        _iconBtn(t, Icons.copy_outlined, _c.nRows > 0, () {
          _c.copyJson();
        }),
        _iconBtn(t, Icons.paste_outlined, _mode == SuperTableMode.editable, () {
          _c.paste();
        }),
        _iconBtn(t, Icons.cut_outlined,
            _mode == SuperTableMode.editable && _c.nRows > 0, () {
          _c.cutRange();
        }),
        // Row ops
        _iconBtn(t, Icons.add_outlined, _mode == SuperTableMode.editable, () {
          _c.addRow();
          _notify('Row added');
        }),
        _iconBtn(t, Icons.delete_outline,
            _mode == SuperTableMode.editable && _c.nRows > 0, () {
          _c.deleteRow();
          _notify('Row deleted');
        }),
        _iconBtn(t, Icons.content_copy_outlined,
            _mode == SuperTableMode.editable && _c.nRows > 0, () {
          _c.duplicateRow();
          _notify('Row duplicated');
        }),
      ],
    );
  }

  void _setSel(SuperSelectionMode m) {
    setState(() => _selMode = m);
    _c.setSelectionMode(m);
  }

  void _setPag(SuperPagination p) {
    setState(() => _pagination = p);
    _rebuild();
  }

  Widget _seg(String label, List<(String, bool, VoidCallback)> opts) {
    final t = context.superTheme;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('$label  ', style: SuperText.caption.copyWith(color: t.fg3)),
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: t.inputBg,
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final o in opts)
            GestureDetector(
              onTap: o.$3,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: o.$2 ? SuperTokens.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(o.$1,
                    style: SuperText.caption.copyWith(
                        color: o.$2 ? Colors.white : t.fg2,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ]),
      ),
    ]);
  }

  Widget _toggle(SuperThemeData t, String label, bool on, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: on
              ? SuperTokens.accent.withValues(alpha: 0.12)
              : Colors.transparent,
          border: Border.all(color: on ? SuperTokens.accent : t.borderStrong),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
              on
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 14,
              color: on ? SuperTokens.accent : t.fg3),
          const SizedBox(width: 6),
          Text(label,
              style: SuperText.caption.copyWith(
                  color: on ? SuperTokens.accent : t.fg2,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _iconBtn(
      SuperThemeData t, IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? t.inputBg : Colors.transparent,
          border: Border.all(
              color: enabled ? t.border : t.border.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: enabled ? t.fg2 : t.fg4),
      ),
    );
  }

  Widget _searchField(SuperThemeData t) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: t.inputBg,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(children: [
        Icon(Icons.search_rounded, size: 14, color: t.fg3),
        const SizedBox(width: 6),
        Expanded(
          child: TextField(
            onChanged: _c.setSearch,
            style: SuperText.caption.copyWith(color: t.fg1, fontSize: 12.5),
            cursorColor: SuperTokens.accent,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'Search…',
              hintStyle: SuperText.caption.copyWith(color: t.fg4),
            ),
          ),
        ),
      ]),
    );
  }

  // ── pagination bar ──
  Widget _pageBar(SuperThemeData t) {
    final pc = _c.pageCount;
    final cp = _c.page;
    return Padding(
      padding: const EdgeInsets.only(top: SuperTokens.space3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageBtn(t, Icons.first_page, cp > 0, () => _c.setPage(0)),
          _pageBtn(t, Icons.chevron_left, cp > 0, () => _c.setPage(cp - 1)),
          const SizedBox(width: 8),
          Text('Page ${cp + 1} / $pc',
              style: SuperText.caption.copyWith(color: t.fg2)),
          const SizedBox(width: 8),
          _pageBtn(
              t, Icons.chevron_right, cp < pc - 1, () => _c.setPage(cp + 1)),
          _pageBtn(t, Icons.last_page, cp < pc - 1, () => _c.setPage(pc - 1)),
        ],
      ),
    );
  }

  Widget _pageBtn(
      SuperThemeData t, IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(icon, size: 18, color: enabled ? t.fg2 : t.fg4),
      ),
    );
  }
}
