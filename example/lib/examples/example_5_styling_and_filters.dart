// ============================================================
// example/lib/examples/example_5_styling_and_filters.dart
// ------------------------------------------------------------
// EXAMPLE 5 — Conditional styling + rich filtering.
//
// Demonstrates: conditional CELL styles (per column), conditional ROW styles
// (whole row), enumeration/currency filters built from `FilterItem`s, and a
// custom `onKey` shortcut handler on the controller.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_table_field/super_table_field.dart';

class StylingAndFiltersExample extends StatefulWidget {
  const StylingAndFiltersExample({super.key});
  @override
  State<StylingAndFiltersExample> createState() => _StylingAndFiltersExampleState();
}

class _StylingAndFiltersExampleState extends State<StylingAndFiltersExample> {
  late final SuperTableController<Map<String, dynamic>> _c = SuperTableController<Map<String, dynamic>>(
    mode: SuperTableMode.readable,
    columns: [
      SuperTextColumn(key: 'task', label: 'Task', width: 220),
      SuperEnumerationColumn<String>(
        key: 'priority',
        label: 'Priority',
        width: 130,
        values: const ['Low', 'Medium', 'High', 'Critical'],
        // FilterItem lets the dropdown label differ from the matched value.
        filterItems: const [
          FilterItem('🟢 Low', 'Low'),
          FilterItem('🟡 Medium', 'Medium'),
          FilterItem('🟠 High', 'High'),
          FilterItem('🔴 Critical', 'Critical'),
        ],
      ),
      SuperNumberColumn<int>(
        key: 'progress',
        label: 'Progress',
        width: 120,
        // Conditional CELL styles: red text when stalled, green when done.
        styles: {
          (ctx, c, row, cell) => (cell.value as num) >= 100: const CellStyle(foreground: Color(0xFF1DB88A), fontWeight: FontWeight.w700),
          (ctx, c, row, cell) => (cell.value as num) == 0: const CellStyle(foreground: Color(0xFFEF4444)),
        },
      ),
      SuperCurrencyColumn(
        key: 'budget',
        label: 'Budget',
        width: 140,
        filterItems: const [
          FilterItem('Under \$5k', 5000),
          FilterItem('\$5k–\$20k', 20000),
          FilterItem('Over \$20k', 100000),
        ],
      ),
    ],
    rows: [
      SuperRow.map({'task': 'Migrate ledger schema', 'priority': 'Critical', 'progress': 40, 'budget': 24000}),
      SuperRow.map({'task': 'Reconcile Q3 accounts', 'priority': 'High', 'progress': 100, 'budget': 8000}),
      SuperRow.map({'task': 'Draft audit memo', 'priority': 'Low', 'progress': 0, 'budget': 1500}),
      SuperRow.map({'task': 'Vendor onboarding', 'priority': 'Medium', 'progress': 70, 'budget': 12000}),
    ],
    // Custom shortcut: press "R" to reset all filters.
    onKey: (ctx, c, node, e) {
      if (e is KeyDownEvent && e.logicalKey.keyLabel == 'R') {
        c.clearColumnFilters();
        c.clearAdvancedFilter();
        return true;
      }
      return false;
    },
  );

  // Conditional ROW styles take priority over the cell styles above.
  Map<SuperRowCondition, SuperRowStyle> get _rowStyles => {
        (ctx, c, row) => row['priority'] == 'Critical': const SuperRowStyle(background: Color(0x14EF4444), accentBar: Color(0xFFEF4444)),
      };

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
      appBar: AppBar(title: const Text('Styling & filters'), backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('Use the column filter row, the advanced-filter button (gutter header), or press "R" to reset.', style: TextStyle(color: t.fg3)),
            ),
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c, styles: _rowStyles)),
          ],
        ),
      ),
    );
  }
}
