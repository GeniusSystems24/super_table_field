// ============================================================
// example/lib/examples/example_6_playground.dart
// ------------------------------------------------------------
// EXAMPLE 6 — The full playground.
//
// A Flutter port of the React toolkit's "One grid, two modes" showcase: one
// inventory dataset driven by a toolbar that flips mode (readable ⇄ editable),
// searches, switches the selection model, cycles pagination (off / pages /
// load-more / infinite), and toggles totals + per-column filters — all through
// a single `SuperTableController`. Covers most column types in one grid:
// text+bilingual, enum pills, number, combo, currency, computed, progress,
// color, date, time, checkbox, readonly; with pinned SKU (left) and Ref (right).
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

typedef _Row = Map<String, dynamic>;

class PlaygroundExample extends StatefulWidget {
  const PlaygroundExample({super.key});
  @override
  State<PlaygroundExample> createState() => _PlaygroundExampleState();
}

class _PlaygroundExampleState extends State<PlaygroundExample> {
  static const _categories = ['Electronics', 'Apparel', 'Grocery', 'Hardware', 'Stationery'];
  static const _statuses = ['In Stock', 'Low Stock', 'Out of Stock', 'Reorder', 'Discontinued'];
  static const _units = ['pcs', 'box', 'bag', 'btl', 'pkg', 'kg', 'L', 'set'];
  static const _recvTimes = ['08:00', '09:30', '11:00', '13:30', '15:00', '16:30'];
  static const _tagColors = ['#4A7CFF', '#1DB88A', '#E0A23B', '#8B5CF6', '#EF4444', '#06B6D4'];
  static const int _max = 56;

  late final SuperTableController<_Row> _c;
  bool _totals = true;
  bool _filters = false;
  bool _bounded = false;
  String? _toast;
  Color _toastColor = const Color(0xFF1DB88A);
  int _seed = 0;

  static final List<SuperColumn> _columns = [
    SuperTextColumn(key: 'sku', label: 'SKU', width: 112, mono: true, required: true, pin: SuperPin.left),
    SuperTextColumn(key: 'name', label: 'Product', width: 226, arKey: 'nameAr'),
    SuperEnumerationColumn<String>(key: 'cat', label: 'Category', width: 134, values: _categories),
    SuperNumberColumn<int>(key: 'qty', label: 'Qty', width: 88, agg: SuperAgg.sum, min: 0, max: 99999),
    SuperComboColumn<String>(key: 'uom', label: 'Unit', width: 96, mono: true, values: _units),
    SuperCurrencyColumn(key: 'cost', label: 'Unit Cost', width: 124, agg: SuperAgg.avg),
    SuperComputedColumn<num>(
      key: 'value',
      label: 'Stock Value',
      width: 138,
      align: SuperAlign.end,
      agg: SuperAgg.sum,
      compute: (r) => (r['qty'] is num ? r['qty'] as num : 0) * (r['cost'] is num ? r['cost'] as num : 0),
      format: (v, r) => '\$${(v as num).toStringAsFixed(2)}',
    ),
    SuperProgressColumn<num>(key: 'level', label: 'Stock Level', width: 156, max: 1),
    SuperEnumerationColumn<String>(key: 'status', label: 'Status', width: 138, values: _statuses),
    SuperColorColumn<String>(key: 'tag', label: 'Tag', width: 118),
    SuperDateColumn(key: 'updated', label: 'Updated', width: 130),
    SuperTimeColumn(key: 'recv', label: 'Received', width: 112),
    SuperCheckboxColumn(key: 'active', label: 'Active', width: 74),
    SuperReadonlyColumn(key: 'ref', label: 'Ref', width: 110, mono: true, pin: SuperPin.right),
  ];

  static const List<List<dynamic>> _products = [
    ['SKU-1001', 'Wireless Mouse', 'فأرة لاسلكية', 'Electronics', 320, 'pcs', 18.5, 0.72, 'In Stock', '#4A7CFF', '2024-12-01', true],
    ['SKU-1002', 'USB-C Cable 2m', 'كابل يو إس بي', 'Electronics', 54, 'pcs', 6.25, 0.18, 'Low Stock', '#E0A23B', '2024-12-02', true],
    ['SKU-1003', 'Cotton T-Shirt', 'قميص قطني', 'Apparel', 880, 'pcs', 9.9, 0.91, 'In Stock', '#1DB88A', '2024-11-29', true],
    ['SKU-1004', 'Olive Oil 1L', 'زيت زيتون', 'Grocery', 12, 'btl', 14.0, 0.08, 'Out of Stock', '#EF4444', '2024-12-04', false],
    ['SKU-1005', 'Steel Hex Bolts', 'براغي فولاذية', 'Hardware', 4200, 'box', 0.85, 0.55, 'In Stock', '#8B5CF6', '2024-12-03', true],
    ['SKU-1006', 'A5 Notebook', 'دفتر A5', 'Stationery', 210, 'pcs', 3.2, 0.40, 'Reorder', '#06B6D4', '2024-12-01', true],
    ['SKU-1007', 'Mechanical Keyboard', 'لوحة مفاتيح', 'Electronics', 76, 'pcs', 64.0, 0.31, 'Low Stock', '#4A7CFF', '2024-12-02', true],
    ['SKU-1008', 'Denim Jacket', 'سترة دنيم', 'Apparel', 145, 'pcs', 38.5, 0.62, 'In Stock', '#1DB88A', '2024-11-28', true],
    ['SKU-1009', 'Ground Coffee 500g', 'قهوة مطحونة', 'Grocery', 530, 'bag', 11.75, 0.84, 'In Stock', '#E0A23B', '2024-12-04', true],
    ['SKU-1010', 'Cordless Drill', 'مثقاب لاسلكي', 'Hardware', 33, 'pcs', 89.0, 0.22, 'Low Stock', '#8B5CF6', '2024-12-03', true],
    ['SKU-1011', 'Gel Pens (12)', 'أقلام جل', 'Stationery', 1280, 'box', 4.5, 0.95, 'In Stock', '#06B6D4', '2024-12-01', true],
    ['SKU-1012', 'HDMI Adapter', 'محول HDMI', 'Electronics', 0, 'pcs', 12.0, 0.0, 'Out of Stock', '#EF4444', '2024-12-04', false],
    ['SKU-1013', 'Running Shorts', 'شورت رياضي', 'Apparel', 410, 'pcs', 16.0, 0.58, 'In Stock', '#1DB88A', '2024-11-30', true],
    ['SKU-1014', 'Basmati Rice 5kg', 'أرز بسمتي', 'Grocery', 96, 'bag', 22.0, 0.27, 'Reorder', '#E0A23B', '2024-12-02', true],
  ];

  static const _genNames = ['Bluetooth Speaker', 'Leather Wallet', 'Canned Tomatoes', 'Paint Roller', 'Sticky Notes', 'Webcam HD', 'Wool Scarf', 'Almond Milk', 'Tape Measure', 'Highlighter Set'];
  static const _genNamesAr = ['سماعة بلوتوث', 'محفظة جلد', 'طماطم معلبة', 'أسطوانة دهان', 'ملاحظات لاصقة', 'كاميرا ويب', 'وشاح صوف', 'حليب لوز', 'شريط قياس', 'أقلام تظليل'];

  _Row _seedRow(List<dynamic> a) {
    final num n = int.parse((a[0] as String).substring(4));
    return {
      'sku': a[0], 'name': a[1], 'nameAr': a[2], 'cat': a[3], 'qty': a[4], 'uom': a[5],
      'cost': a[6], 'level': a[7], 'status': a[8], 'tag': a[9], 'updated': a[10], 'active': a[11],
      'recv': _recvTimes[(n % _recvTimes.length).toInt()],
      'ref': 'INV-${(a[0] as String).substring(4)}',
    };
  }

  List<SuperRow<_Row>> _makeRows(int start, int count) {
    final out = <SuperRow<_Row>>[];
    for (var i = 0; i < count; i++) {
      final n = start + i;
      final qty = ((n * 37) % 900) + 10;
      out.add(SuperRow.map({
        'sku': 'SKU-${1100 + n}',
        'name': '${_genNames[n % _genNames.length]} ${(n ~/ _genNames.length) + 1}',
        'nameAr': _genNamesAr[n % _genNamesAr.length],
        'cat': _categories[n % _categories.length],
        'qty': qty,
        'uom': ['pcs', 'box', 'bag', 'btl'][n % 4],
        'cost': (((n * 13) % 90 + 2) * 100).round() / 100,
        'level': ((n * 17) % 100) / 100,
        'status': _statuses[n % _statuses.length],
        'tag': _tagColors[n % _tagColors.length],
        'updated': '2024-${(11 + (n % 2)).toString().padLeft(2, '0')}-${((n % 27) + 1).toString().padLeft(2, '0')}',
        'recv': _recvTimes[n % _recvTimes.length],
        'active': n % 5 != 0,
        'ref': 'INV-${1100 + n}',
      }));
    }
    return out;
  }

  List<SuperRow<_Row>> _initialRows() => [for (final p in _products) SuperRow.map(_seedRow(p))];

  @override
  void initState() {
    super.initState();
    _seed = _products.length;
    _c = SuperTableController<_Row>(
      columns: _columns,
      rows: _initialRows(),
      mode: SuperTableMode.readable,
      selectionMode: SuperSelectionMode.singleCell,
      pageSize: 7,
      emptyRowValue: () => <String, dynamic>{},
      onLoadMore: (filter) {
        if (_c.rows.length >= _max) {
          _c.setLoadMoreState(loadingMore: false, hasMore: false);
          return;
        }
        Future.delayed(const Duration(milliseconds: 950), () {
          if (!mounted) return;
          final add = _makeRows(_seed, 8);
          _seed += 8;
          _c.appendRows(add, hasMore: _c.rows.length + add.length < _max);
        });
      },
      onNotify: (kind, msg) => _notify(kind == SuperNotifyKind.error ? const Color(0xFFEF4444) : const Color(0xFF1DB88A), msg),
    );
  }

  void _notify(Color color, String msg) {
    setState(() {
      _toast = msg;
      _toastColor = color;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  void _setPaging(SuperPagination p) {
    setState(() => _bounded = p == SuperPagination.infinite);
    final resetToBase = p == SuperPagination.none || p == SuperPagination.pages;
    if (resetToBase) {
      _seed = _products.length;
      _c.updateRows(_initialRows());
      _c.setLoadMoreState(hasMore: false, loadingMore: false);
    } else {
      _c.setLoadMoreState(hasMore: _c.rows.length < _max, loadingMore: false);
    }
    _c.setPagination(p);
  }

  void _addColumn() {
    final key = 'f${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
    _c.updateColumns([
      ..._columns.where((col) => col.pin != SuperPin.right),
      SuperTextColumn(key: key, label: 'Field', width: 130),
      ..._columns.where((col) => col.pin == SuperPin.right),
    ]);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: const Text('Playground — one grid, two modes'), backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _toolbar(t),
                const SizedBox(height: 16),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _c,
                    builder: (ctx, _) => SuperTable<_Row>(
                      controller: _c,
                      showTotals: _totals,
                      columnFilters: _filters,
                      onAddColumn: _c.mode == SuperTableMode.editable ? _addColumn : null,
                      maxHeight: _bounded ? 420 : null,
                      skeletonRows: 5,
                    ),
                  ),
                ),
              ],
            ),
            if (_toast != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                    decoration: BoxDecoration(
                      color: t.surface,
                      border: Border.all(color: _toastColor),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: t.cardShadow,
                    ),
                    child: Text(_toast!, style: TextStyle(fontSize: 13, color: t.fg1)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar(SuperThemeData t) {
    return ListenableBuilder(
      listenable: _c,
      builder: (ctx, _) => Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _seg('Mode', [
            ('Readable', _c.mode == SuperTableMode.readable, () => _c.setMode(SuperTableMode.readable)),
            ('Editable', _c.mode == SuperTableMode.editable, () => _c.setMode(SuperTableMode.editable)),
          ]),
          SizedBox(width: 180, child: _search(t)),
          _seg('Select', [
            ('Cell', _c.selectionMode == SuperSelectionMode.singleCell, () => _c.setSelectionMode(SuperSelectionMode.singleCell)),
            ('Cells', _c.selectionMode == SuperSelectionMode.multiCells, () => _c.setSelectionMode(SuperSelectionMode.multiCells)),
            ('Row', _c.selectionMode == SuperSelectionMode.singleRow, () => _c.setSelectionMode(SuperSelectionMode.singleRow)),
            ('Rows', _c.selectionMode == SuperSelectionMode.multiRows, () => _c.setSelectionMode(SuperSelectionMode.multiRows)),
          ]),
          _seg('Paging', [
            ('Off', _c.pagination == SuperPagination.none, () => _setPaging(SuperPagination.none)),
            ('Pages', _c.pagination == SuperPagination.pages, () => _setPaging(SuperPagination.pages)),
            ('Load+', _c.pagination == SuperPagination.loadMore, () => _setPaging(SuperPagination.loadMore)),
            ('Infinite', _c.pagination == SuperPagination.infinite, () => _setPaging(SuperPagination.infinite)),
          ]),
          _chip(t, 'Totals', Icons.functions_rounded, _totals, () => setState(() => _totals = !_totals)),
          _chip(t, 'Filters', Icons.filter_alt_outlined, _filters, () => setState(() => _filters = !_filters)),
        ],
      ),
    );
  }

  Widget _seg(String label, List<(String, bool, VoidCallback)> opts) {
    final t = context.superTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Text('${label.toUpperCase()}  ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: t.fg4)),
      Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: t.inputBg, border: Border.all(color: t.border), borderRadius: BorderRadius.circular(7)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          for (final o in opts)
            GestureDetector(
              onTap: o.$3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: o.$2 ? cs.primary : Colors.transparent, borderRadius: BorderRadius.circular(5)),
                child: Text(o.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: o.$2 ? Colors.white : t.fg2)),
              ),
            ),
        ]),
      ),
    ]);
  }

  Widget _chip(SuperThemeData t, String label, IconData icon, bool on, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: on ? cs.primary.withOpacity(0.12) : Colors.transparent,
          border: Border.all(color: on ? cs.primary : t.borderStrong),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: on ? cs.primary : t.fg3),
          const SizedBox(width: 7),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: on ? cs.primary : t.fg2)),
        ]),
      ),
    );
  }

  Widget _search(SuperThemeData t) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: t.inputBg, border: Border.all(color: t.border), borderRadius: BorderRadius.circular(6)),
      child: Row(children: [
        Icon(Icons.search_rounded, size: 15, color: t.fg3),
        const SizedBox(width: 7),
        Expanded(
          child: TextField(
            onChanged: _c.setSearch,
            style: TextStyle(fontSize: 13, color: t.fg1),
            cursorColor: cs.primary,
            decoration: InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero, hintText: 'Search…', hintStyle: TextStyle(fontSize: 13, color: t.fg4)),
          ),
        ),
      ]),
    );
  }
}
