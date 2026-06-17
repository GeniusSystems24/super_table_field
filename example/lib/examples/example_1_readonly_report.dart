// ============================================================
// example/lib/examples/example_1_readonly_report.dart
// ------------------------------------------------------------
// EXAMPLE 1 — A read-only report.
//
// Demonstrates: readable mode, typed columns, conditional ROW styling, the
// advanced (cross-column) filter button, per-column filters, grouping, totals.
// Nothing is editable — the grid is a presentation surface over a typed model.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

/// The host's typed domain model (the row's backing `value`).
class Sale {
  final String region;
  final String rep;
  final String product;
  final int units;
  final num revenue;
  final String status;
  const Sale(this.region, this.rep, this.product, this.units, this.revenue, this.status);
}

class ReadonlyReportExample extends StatefulWidget {
  const ReadonlyReportExample({super.key});
  @override
  State<ReadonlyReportExample> createState() => _ReadonlyReportExampleState();
}

class _ReadonlyReportExampleState extends State<ReadonlyReportExample> {
  late final SuperTableController<Sale> _c = SuperTableController<Sale>(
    mode: SuperTableMode.readable,
    selectionMode: SuperSelectionMode.singleRow,
    columns: [
      SuperEnumerationColumn<String>(key: 'region', label: 'Region', width: 130, values: const ['North', 'South', 'East', 'West']),
      SuperTextColumn(key: 'rep', label: 'Sales Rep', width: 160),
      SuperTextColumn(key: 'product', label: 'Product', width: 170),
      SuperNumberColumn<int>(key: 'units', label: 'Units', width: 90, agg: SuperAgg.sum),
      SuperCurrencyColumn(key: 'revenue', label: 'Revenue', width: 140, agg: SuperAgg.sum),
      SuperEnumerationColumn<String>(key: 'status', label: 'Status', width: 130, values: const ['Won', 'Open', 'Lost']),
    ],
    rows: [
      for (final s in _seed)
        SuperRow<Sale>.of(s, {
          'region': s.region, 'rep': s.rep, 'product': s.product,
          'units': s.units, 'revenue': s.revenue, 'status': s.status,
        }),
    ],
  );

  static const List<Sale> _seed = [
    Sale('North', 'A. Haddad', 'Ledger Pro', 12, 14400, 'Won'),
    Sale('South', 'M. Saleh', 'Inventory Suite', 4, 5200, 'Open'),
    Sale('East', 'R. Nasser', 'Audit Trail', 9, 10800, 'Won'),
    Sale('West', 'L. Faris', 'Ledger Pro', 2, 2400, 'Lost'),
    Sale('North', 'A. Haddad', 'Settlement', 7, 9100, 'Open'),
    Sale('South', 'M. Saleh', 'Audit Trail', 15, 18000, 'Won'),
    Sale('East', 'R. Nasser', 'Inventory Suite', 1, 1300, 'Lost'),
  ];

  // Row styles win over column styles. First matching condition applies.
  Map<SuperRowCondition, SuperRowStyle> get _styles => {
        (ctx, c, row) => row['status'] == 'Lost': const SuperRowStyle(foreground: Color(0xFF94A0B4)),
        (ctx, c, row) => (row['revenue'] as num) >= 15000: const SuperRowStyle(background: Color(0x141DB88A), accentBar: Color(0xFF1DB88A)),
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
      appBar: AppBar(title: const Text('Read-only report'), backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SuperTable<Sale>(controller: _c, styles: _styles),
      ),
    );
  }
}
