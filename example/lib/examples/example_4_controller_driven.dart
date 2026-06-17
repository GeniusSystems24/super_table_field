// ============================================================
// example/lib/examples/example_4_controller_driven.dart
// ------------------------------------------------------------
// EXAMPLE 4 — Driving everything through the controller.
//
// Demonstrates: switching mode at runtime (setMode), load-more paging with the
// `onLoadMore` hook (which receives the current filter state), programmatic
// column + advanced filters, programmatic selection, clearing the table, and
// extracting the filter state as JSON.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class ControllerDrivenExample extends StatefulWidget {
  const ControllerDrivenExample({super.key});
  @override
  State<ControllerDrivenExample> createState() => _ControllerDrivenExampleState();
}

class _ControllerDrivenExampleState extends State<ControllerDrivenExample> {
  int _nextId = 1;
  late final SuperTableController<Map<String, dynamic>> _c;

  List<SuperRow<Map<String, dynamic>>> _page(int n) => [
        for (var i = 0; i < n; i++)
          SuperRow.map({
            'id': 'TXN-${(_nextId++).toString().padLeft(4, '0')}',
            'type': ['Debit', 'Credit'][_nextId % 2],
            'amount': (50 + (_nextId * 37) % 950).toDouble(),
            'status': ['Posted', 'Pending', 'Void'][_nextId % 3],
          }),
      ];

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.readable,
      selectionMode: SuperSelectionMode.multiRows,
      pagination: SuperPagination.loadMore,
      hasMore: true,
      columns: [
        SuperTextColumn(key: 'id', label: 'Reference', width: 150, mono: true),
        SuperEnumerationColumn<String>(key: 'type', label: 'Type', width: 120, values: const ['Debit', 'Credit']),
        SuperCurrencyColumn(key: 'amount', label: 'Amount', width: 140),
        SuperEnumerationColumn<String>(key: 'status', label: 'Status', width: 130, values: const ['Posted', 'Pending', 'Void']),
      ],
      rows: _page(8),
      // Called when the user (or code) asks for more — receives the live filter
      // state so a real backend could honor it.
      onLoadMore: (filter) async {
        debugPrint('onLoadMore with filter: ${filter.toJson()}');
        await Future<void>.delayed(const Duration(milliseconds: 600));
        _c.appendRows(_page(8), hasMore: _nextId < 40);
      },
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _showFilterJson() {
    final json = _c.filterStateJson();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('filterState: $json')));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: const Text('Controller-driven'), backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(spacing: 8, runSpacing: 8, children: [
              _btn('Toggle mode', Icons.swap_horiz_rounded, _c.toggleMode),
              _btn('Filter: Posted', Icons.filter_alt_outlined, () => _c.setColumnFilter('status', 'Posted')),
              _btn('Advanced: amount ≥ 500', Icons.tune_rounded, () => _c.setAdvancedFilter([
                    const AdvancedFilterClause(columnKey: 'amount', op: FilterOp.greaterOrEqual, value: 500),
                  ])),
              _btn('Clear filters', Icons.filter_alt_off_outlined, () {
                _c.clearColumnFilters();
                _c.clearAdvancedFilter();
              }),
              _btn('Select rows 0–2', Icons.checklist_rounded, () => _c.selectRowsAt([0, 1, 2])),
              _btn('Clear selection', Icons.deselect_rounded, _c.clearSelection),
              _btn('Load more', Icons.arrow_downward_rounded, _c.loadMore),
              _btn('Filter JSON', Icons.data_object_rounded, _showFilterJson),
              _btn('Clear table', Icons.delete_sweep_outlined, _c.clearTable),
            ]),
            const SizedBox(height: 16),
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c, maxHeight: 460)),
          ],
        ),
      ),
    );
  }

  Widget _btn(String label, IconData icon, VoidCallback onTap) {
    final t = context.superTheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(foregroundColor: t.fg1, side: BorderSide(color: t.borderStrong)),
    );
  }
}
