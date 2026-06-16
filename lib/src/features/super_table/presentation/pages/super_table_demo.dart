// ============================================================
// features/super_table/presentation/pages/super_table_demo.dart
// ------------------------------------------------------------
// A self-contained gallery page for the unified SuperTable, exercising the full
// feature set with one dataset: readable ↔ editable mode, the four selection
// modes, search, grouping, totals, pagination, and a spread of column types
// (text+bilingual, currency with sign color, enum pills, progress, date, color,
// computed, bool). Used by the example app and as the parity reference.
// ============================================================

import 'package:flutter/material.dart';

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
  SuperTableMode _mode = SuperTableMode.editable;
  SuperSelectionMode _selMode = SuperSelectionMode.singleCell;
  bool _grouped = false;
  String? _toast;

  static final List<SuperColumn> _columns = [
    const SuperColumn(
        key: 'sku',
        label: 'SKU',
        type: SuperColumnType.text,
        width: 130,
        mono: true,
        pin: SuperPin.left),
    const SuperColumn(
        key: 'item',
        label: 'Item',
        type: SuperColumnType.text,
        width: 210,
        arKey: 'item_ar',
        required: true),
    const SuperColumn(
        key: 'cat',
        label: 'Category',
        type: SuperColumnType.enumeration,
        width: 150,
        opts: ['Raw Material', 'Component', 'Finished Good', 'Consumable']),
    const SuperColumn(
        key: 'status',
        label: 'Status',
        type: SuperColumnType.enumeration,
        width: 130,
        opts: ['In Stock', 'Low Stock', 'Out of Stock', 'Discontinued']),
    const SuperColumn(
        key: 'qty',
        label: 'Qty',
        type: SuperColumnType.number,
        width: 90,
        align: SuperAlign.end,
        agg: SuperAgg.sum),
    const SuperColumn(
        key: 'unit',
        label: 'Unit',
        type: SuperColumnType.combo,
        width: 130,
        opts: [
          'each',
          'box',
          'pallet',
          'kg',
          'tonne',
          'litre',
          'metre',
          'roll',
          'sheet'
        ]),
    const SuperColumn(
        key: 'price',
        label: 'Unit Price',
        type: SuperColumnType.currency,
        width: 130,
        align: SuperAlign.end,
        suffix: 'SAR',
        decimals: 2),
    SuperColumn(
      key: 'total',
      label: 'Line Total',
      type: SuperColumnType.computed,
      width: 140,
      align: SuperAlign.end,
      agg: SuperAgg.sum,
      compute: (r) =>
          (r['qty'] is num ? r['qty'] as num : 0) *
          (r['price'] is num ? r['price'] as num : 0),
      format: (v, r) => '${(v as num).toStringAsFixed(2)} SAR',
    ),
    const SuperColumn(
        key: 'fill',
        label: 'Fill',
        type: SuperColumnType.progress,
        width: 130,
        max: 100),
    const SuperColumn(
        key: 'received',
        label: 'Received',
        type: SuperColumnType.date,
        width: 130),
    const SuperColumn(
        key: 'tag', label: 'Tag', type: SuperColumnType.color, width: 110),
    const SuperColumn(
        key: 'active',
        label: 'Active',
        type: SuperColumnType.checkbox,
        width: 80,
        align: SuperAlign.center),
  ];

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
          'tag': '#4A7CFF',
          'active': true
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
          'tag': '#E0A23B',
          'active': true
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
          'tag': '#1DB88A',
          'active': true
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
          'tag': '#EF4444',
          'active': false
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
          'tag': '#8B5CF6',
          'active': true
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
          'tag': '#06B6D4',
          'active': true
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
          'tag': '#EC4899',
          'active': true
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
          'tag': '#8C92A4',
          'active': false
        },
      ];

  @override
  void initState() {
    super.initState();
    _c = _build();
  }

  SuperTableController _build() => SuperTableController(
        columns: _columns,
        rows: _seed(),
        mode: _mode,
        selectionMode: _selMode,
        addRowEnabled: _mode == SuperTableMode.editable,
        pagination: SuperPagination.none,
        onNotify: (kind, msg) {
          setState(() => _toast = msg);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) setState(() => _toast = null);
          });
        },
      );

  void _rebuild() {
    final old = _c;
    _c = _build();
    if (_grouped) _c.toggleGroup('cat');
    old.dispose();
    setState(() {});
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
            constraints: const BoxConstraints(maxWidth: 1080),
            child: Padding(
              padding: const EdgeInsets.all(SuperTokens.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('SUPER TABLE • UNIFIED DATA GRID',
                      style: SuperText.eyebrow
                          .copyWith(color: SuperTokens.accent)),
                  const SizedBox(height: SuperTokens.space2),
                  Text('Issue Inventory',
                      style: SuperText.h1.copyWith(color: t.fg1)),
                  const SizedBox(height: SuperTokens.space6),
                  _toolbar(t),
                  const SizedBox(height: SuperTokens.space4),
                  Flexible(
                    child: SuperTable(controller: _c),
                  ),
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

  Widget _toolbar(SuperThemeData t) {
    return Wrap(
      spacing: SuperTokens.space2,
      runSpacing: SuperTokens.space2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _seg('Mode', [
          (
            'Readable',
            _mode == SuperTableMode.readable,
            () {
              _mode = SuperTableMode.readable;
              _rebuild();
            }
          ),
          (
            'Editable',
            _mode == SuperTableMode.editable,
            () {
              _mode = SuperTableMode.editable;
              _rebuild();
            }
          ),
        ]),
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
        _toggle(t, 'Group by category', _grouped, () {
          setState(() => _grouped = !_grouped);
          _c.clearGroups();
          if (_grouped) _c.toggleGroup('cat');
        }),
        SizedBox(
          width: 200,
          child: _searchField(t),
        ),
      ],
    );
  }

  void _setSel(SuperSelectionMode m) {
    setState(() => _selMode = m);
    _c.setSelectionMode(m);
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
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
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
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: on ? SuperTokens.accent.withOpacity(0.12) : Colors.transparent,
          border: Border.all(color: on ? SuperTokens.accent : t.borderStrong),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
              on
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 15,
              color: on ? SuperTokens.accent : t.fg3),
          const SizedBox(width: 7),
          Text(label,
              style: SuperText.caption.copyWith(
                  color: on ? SuperTokens.accent : t.fg2,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _searchField(SuperThemeData t) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: t.inputBg,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(children: [
        Icon(Icons.search_rounded, size: 15, color: t.fg3),
        const SizedBox(width: 7),
        Expanded(
          child: TextField(
            onChanged: _c.setSearch,
            style: SuperText.caption.copyWith(color: t.fg1, fontSize: 13),
            cursorColor: SuperTokens.accent,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: 'Search rows…',
              hintStyle: SuperText.caption.copyWith(color: t.fg4),
            ),
          ),
        ),
      ]),
    );
  }
}
