// ============================================================
// example/lib/examples/example_22_big_data_load_more.dart
// ------------------------------------------------------------
// EXAMPLE 22 — Big-data load-more stress test.
//
// Appends a large deterministic batch on every load-more request and exposes
// timings/counters so rendering and controller changes can be profiled with a
// realistic growing dataset. Scroll to the bottom to trigger loading
// automatically, or use the Load button to trigger the same controller path.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

typedef _Row = Map<String, dynamic>;

class BigDataLoadMoreExample extends StatefulWidget {
  const BigDataLoadMoreExample({super.key});

  @override
  State<BigDataLoadMoreExample> createState() => _BigDataLoadMoreExampleState();
}

class _BigDataLoadMoreExampleState extends State<BigDataLoadMoreExample> {
  static const int _maxRows = 1000000;
  static const List<int> _batchSizes = [1000, 5000, 10000, 50000, 100000];

  static const List<String> _categories = [
    'Electronics',
    'Hardware',
    'Grocery',
    'Apparel',
    'Stationery',
    'Industrial',
  ];
  static const List<String> _statuses = [
    'In Stock',
    'Low Stock',
    'Reorder',
    'Out of Stock',
  ];
  static const List<String> _warehouses = [
    'Riyadh',
    'Jeddah',
    'Dammam',
    'Dubai',
  ];
  static const List<String> _units = ['ea', 'box', 'kg', 'm', 'roll', 'pack'];
  static const List<String> _suppliers = [
    'Northwind',
    'Genius Supply',
    'Atlas Trade',
    'Nova Parts',
    'Prime Source',
  ];

  static final List<SuperColumn> _columns = [
    SuperTextColumn(
      key: 'id',
      label: 'ID',
      width: 126,
      mono: true,
      pin: SuperPin.start,
    ),
    SuperTextColumn(key: 'name', label: 'Product', width: 220),
    SuperEnumerationColumn<String>(
      key: 'category',
      label: 'Category',
      width: 136,
      values: _categories,
    ),
    SuperEnumerationColumn<String>(
      key: 'status',
      label: 'Status',
      width: 132,
      values: _statuses,
    ),
    SuperEnumerationColumn<String>(
      key: 'warehouse',
      label: 'Warehouse',
      width: 132,
      values: _warehouses,
    ),
    SuperNumberColumn<int>(key: 'qty', label: 'Qty', width: 92),
    SuperNumberColumn<int>(key: 'reserved', label: 'Reserved', width: 106),
    SuperNumberColumn<int>(key: 'available', label: 'Available', width: 110),
    SuperEnumerationColumn<String>(
      key: 'unit',
      label: 'Unit',
      width: 90,
      values: _units,
    ),
    SuperCurrencyColumn(
      key: 'price',
      label: 'Unit Price',
      width: 122,
      symbol: r'$',
    ),
    SuperCurrencyColumn(
      key: 'value',
      label: 'Stock Value',
      width: 138,
      symbol: r'$',
    ),
    SuperNumberColumn<int>(
      key: 'discount',
      label: 'Disc %',
      width: 94,
      suffix: '%',
    ),
    SuperProgressColumn<num>(
      key: 'level',
      label: 'Stock Level',
      width: 142,
      max: 1,
    ),
    SuperTextColumn(key: 'supplier', label: 'Supplier', width: 150),
    SuperTextColumn(key: 'barcode', label: 'Barcode', width: 154, mono: true),
    SuperDateColumn(key: 'updated', label: 'Updated', width: 124),
    SuperCheckboxColumn(key: 'active', label: 'Active', width: 82),
    SuperTextColumn(key: 'note', label: 'Note', width: 220),
    SuperReadonlyColumn(
      key: 'ref',
      label: 'Ref',
      width: 132,
      mono: true,
      pin: SuperPin.end,
    ),
  ];

  late final SuperTableController<_Row> _c;

  int _batchSize = 5000;
  int _nextId = 0;
  int _lastBatchCount = 0;
  Duration _lastGenerate = Duration.zero;
  Duration _lastAppend = Duration.zero;
  bool _loadingBatch = false;

  @override
  void initState() {
    super.initState();

    final initial = _makeBatch(_batchSize);
    _lastBatchCount = initial.length;

    _c = SuperTableController<_Row>(
      mode: SuperTableMode.readable,
      selectionMode: SuperSelectionMode.multiRows,
      pagination: SuperPagination.loadMore,
      hasMore: _nextId < _maxRows,
      columns: _columns,
      rows: initial,
      onLoadMore: (_) async {
        if (_loadingBatch || _nextId >= _maxRows) return;
        _loadingBatch = true;
        if (mounted) setState(() {});

        // Yield one frame so the loading state can paint before intentionally
        // doing the synchronous stress work below.
        await Future<void>.delayed(const Duration(milliseconds: 16));

        final generateWatch = Stopwatch()..start();
        final rows = _makeBatch(_batchSize);
        generateWatch.stop();

        final appendWatch = Stopwatch()..start();
        _c.appendRows(rows, hasMore: _nextId < _maxRows);
        appendWatch.stop();

        _lastBatchCount = rows.length;
        _lastGenerate = generateWatch.elapsed;
        _lastAppend = appendWatch.elapsed;
        _loadingBatch = false;
        if (mounted) setState(() {});
      },
    );
  }

  List<SuperRow<_Row>> _makeBatch(int requested) {
    final remaining = _maxRows - _nextId;
    if (requested <= 0 || remaining <= 0) return const <SuperRow<_Row>>[];
    final count = requested < remaining ? requested : remaining;

    final rows = List<SuperRow<_Row>>.generate(count, (index) {
      final id = _nextId + index + 1;
      final qty = 25 + (id * 17) % 975;
      final reserved = (id * 7) % 80;
      final available = qty - reserved;
      final price = 4.5 + ((id * 31) % 25000) / 100;
      final category = _categories[id % _categories.length];
      final status = _statuses[id % _statuses.length];
      final month = 1 + id % 12;
      final day = 1 + id % 28;

      return SuperRow.map(<String, dynamic>{
        'id': 'ROW-${id.toString().padLeft(7, '0')}',
        'name': 'Generated Product $id',
        'category': category,
        'status': status,
        'warehouse': _warehouses[id % _warehouses.length],
        'qty': qty,
        'reserved': reserved,
        'available': available,
        'unit': _units[id % _units.length],
        'price': price,
        'value': available * price,
        'discount': id % 35,
        'level': ((id * 13) % 101) / 100,
        'supplier': _suppliers[id % _suppliers.length],
        'barcode': '629${(1000000000 + id).toString()}',
        'updated':
            '2026-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}',
        'active': id % 11 != 0,
        'note': 'Synthetic load-more row for performance profiling #$id',
        'ref': 'PERF-${(id * 97).toString().padLeft(8, '0')}',
      });
    }, growable: false);

    _nextId += count;
    return rows;
  }

  void _reset() {
    _nextId = 0;
    final watch = Stopwatch()..start();
    final rows = _makeBatch(_batchSize);
    watch.stop();

    final appendWatch = Stopwatch()..start();
    _c.updateRows(rows);
    _c.setLoadMoreState(hasMore: _nextId < _maxRows, loadingMore: false);
    appendWatch.stop();

    setState(() {
      _lastBatchCount = rows.length;
      _lastGenerate = watch.elapsed;
      _lastAppend = appendWatch.elapsed;
      _loadingBatch = false;
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
      appBar: AppBar(
        title: const Text('Big-data load-more stress test'),
        backgroundColor: t.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Each load appends a large batch. Scroll to the bottom for automatic load-more, or trigger it manually.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Rows per load:'),
                for (final size in _batchSizes)
                  ChoiceChip(
                    label: Text(_compact(size)),
                    selected: _batchSize == size,
                    onSelected: _loadingBatch
                        ? null
                        : (selected) {
                            if (selected) setState(() => _batchSize = size);
                          },
                  ),
                FilledButton.icon(
                  onPressed: _loadingBatch || !_c.hasMore ? null : _c.loadMore,
                  icon: _loadingBatch
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_rounded),
                  label: Text(
                    _loadingBatch ? 'Loading…' : 'Load ${_compact(_batchSize)}',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _loadingBatch ? null : _reset,
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Metric('Rows', '${_compact(_nextId)} / ${_compact(_maxRows)}'),
                _Metric('Last batch', _compact(_lastBatchCount)),
                _Metric('Generate', '${_lastGenerate.inMilliseconds} ms'),
                _Metric('appendRows', '${_lastAppend.inMilliseconds} ms'),
                _Metric('Pipeline rebuilds', '${_c.debugPipelineRebuildCount}'),
                _Metric(
                  'Column-cache rebuilds',
                  '${_c.debugColumnCacheRebuildCount}',
                ),
                _Metric(
                  'Row-index rebuilds',
                  '${_c.debugRowIndexRebuildCount}',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SuperTable<_Row>(
                controller: _c,
                maxHeight: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _compact(int value) {
    if (value >= 1000 && value % 1000 == 0) return '${value ~/ 1000}k';
    return '$value';
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$label: $value'),
    );
  }
}
