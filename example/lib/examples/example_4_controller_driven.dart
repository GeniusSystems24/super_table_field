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
import 'package:super_form_field/super_form_field.dart';
import 'package:super_core/super_core.dart';
import 'package:super_table_field_example/localizations/example_l10n.dart';

class ControllerDrivenExample extends StatefulWidget {
  const ControllerDrivenExample({super.key});
  @override
  State<ControllerDrivenExample> createState() =>
      _ControllerDrivenExampleState();
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
        SuperTextColumn(key: 'id', label: ExampleL10n.current.reference, width: 150, mono: true),
        SuperEnumerationColumn<String>(
          key: 'type',
          label: ExampleL10n.current.type,
          width: 120,
          values: const ['Debit', 'Credit'],
        ),
        SuperCurrencyColumn(key: 'amount', label: ExampleL10n.current.amount, width: 140),
        SuperEnumerationColumn<String>(
          key: 'status',
          label: ExampleL10n.current.status,
          width: 130,
          sources: const [
            SuperSelectListSource<String>(items: ['Posted', 'Pending', 'Void']),
          ],
          searchable: true,
          optionBuilder: (items, index, status) => SuperOption<String>(
            value: status,
            label: status,
            description: index == 0 ? ExampleL10n.current.finalizedTransaction : null,
          ),
        ),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(ExampleL10n.current.filterState(json))));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: Text(ExampleL10n.current.controllerDriven),
        backgroundColor: t.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _btn(ExampleL10n.current.toggleMode, Icons.swap_horiz_rounded, _c.toggleMode),
                _btn(
                  ExampleL10n.current.filterPosted,
                  Icons.filter_alt_outlined,
                  () => _c.setColumnFilter('status', 'Posted'),
                ),
                _btn(
                  ExampleL10n.current.advancedAmountGreaterEqual500,
                  Icons.tune_rounded,
                  () => _c.setAdvancedFilter([
                    const AdvancedFilterClause(
                      columnKey: 'amount',
                      op: FilterOp.greaterOrEqual,
                      value: 500,
                    ),
                  ]),
                ),
                _btn(ExampleL10n.current.clearFilters, Icons.filter_alt_off_outlined, () {
                  _c.clearColumnFilters();
                  _c.clearAdvancedFilter();
                }),
                _btn(
                  ExampleL10n.current.selectRowsZeroTwo,
                  Icons.checklist_rounded,
                  () => _c.selectRowsAt([0, 1, 2]),
                ),
                _btn(
                  ExampleL10n.current.clearSelection,
                  Icons.deselect_rounded,
                  _c.clearSelection,
                ),
                _btn(ExampleL10n.current.loadMore, Icons.arrow_downward_rounded, _c.loadMore),
                _btn(ExampleL10n.current.filterJSON, Icons.data_object_rounded, _showFilterJson),
                _btn(ExampleL10n.current.clearTable, Icons.delete_sweep_outlined, _c.clearTable),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SuperTable<Map<String, dynamic>>(
                controller: _c,
                maxHeight: 460,
              ),
            ),
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
      style: OutlinedButton.styleFrom(
        foregroundColor: t.fg1,
        side: BorderSide(color: t.borderStrong),
      ),
    );
  }
}
