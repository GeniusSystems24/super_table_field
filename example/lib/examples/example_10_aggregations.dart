// ============================================================
// example/lib/examples/example_10_aggregations.dart
// ------------------------------------------------------------
// EXAMPLE 10 — Extended + custom aggregations.
//
// Demonstrates: the new `SuperAgg.min` / `SuperAgg.max`, and `SuperAgg.custom`
// with a column `aggregator` (here a quantity-weighted average unit cost — a
// classic ERP inventory metric that a plain average can't express). `aggLabel`
// renames the figure shown in group headers.
//
// Group by Category (right-click a row → Group by) to see per-group min, max
// and the weighted average roll up.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';
import 'package:super_core/super_core.dart';
import 'package:super_table_field_example/localizations/example_l10n.dart';

class AggregationsExample extends StatefulWidget {
  const AggregationsExample({super.key});
  @override
  State<AggregationsExample> createState() => _AggregationsExampleState();
}

class _AggregationsExampleState extends State<AggregationsExample> {
  late final SuperTableController<Map<String, dynamic>> _c;

  // Quantity-weighted average unit cost: Σ(qty·cost) / Σ(qty).
  num _weightedAvgCost(List<SuperRow> rows) {
    num totalQty = 0, totalValue = 0;
    for (final r in rows) {
      final q = (r['qty'] as num?) ?? 0;
      final c = (r['cost'] as num?) ?? 0;
      totalQty += q;
      totalValue += q * c;
    }
    return totalQty == 0 ? 0 : totalValue / totalQty;
  }

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.readable,
      columns: [
        SuperTextColumn(key: 'sku', label: ExampleL10n.current.sKU, width: 130, mono: true),
        SuperEnumerationColumn<String>(
          key: 'category',
          label: ExampleL10n.current.category,
          width: 150,
          values: const ['Raw Material', 'Finished Good', 'Consumable'],
        ),
        SuperNumberColumn<int>(
          key: 'qty',
          label: ExampleL10n.current.qty,
          width: 100,
          agg: SuperAgg.sum,
        ),
        // min unit cost across the group / table.
        SuperCurrencyColumn(
          key: 'cost',
          label: ExampleL10n.current.unitCost,
          width: 140,
          agg: SuperAgg.min,
          aggLabel: ExampleL10n.current.mINCOST,
        ),
        // max unit cost — a computed mirror of `cost` so it can carry its own agg.
        SuperComputedColumn<num>(
          key: 'cost_hi',
          label: ExampleL10n.current.costMax,
          width: 140,
          agg: SuperAgg.max,
          aggLabel: ExampleL10n.current.mAXCOST,
          compute: (row) => (row['cost'] as num?) ?? 0,
          format: (v, row) => '\$${(v as num).toStringAsFixed(2)}',
        ),
        // custom: quantity-weighted average unit cost.
        SuperComputedColumn<num>(
          key: 'wac',
          label: ExampleL10n.current.wAC,
          width: 150,
          agg: SuperAgg.custom,
          aggLabel: ExampleL10n.current.wTDAVG,
          aggregator: _weightedAvgCost,
          compute: (row) => (row['cost'] as num?) ?? 0,
          format: (v, row) => '\$${(v as num).toStringAsFixed(2)}',
        ),
      ],
      rows: [
        SuperRow.map({
          'sku': 'RM-STEEL-01',
          'category': 'Raw Material',
          'qty': 400,
          'cost': 3.40,
        }),
        SuperRow.map({
          'sku': 'RM-STEEL-02',
          'category': 'Raw Material',
          'qty': 120,
          'cost': 4.10,
        }),
        SuperRow.map({
          'sku': 'FG-BRKT-10',
          'category': 'Finished Good',
          'qty': 60,
          'cost': 12.80,
        }),
        SuperRow.map({
          'sku': 'FG-BRKT-20',
          'category': 'Finished Good',
          'qty': 35,
          'cost': 15.50,
        }),
        SuperRow.map({
          'sku': 'CN-GLOVE-09',
          'category': 'Consumable',
          'qty': 800,
          'cost': 0.45,
        }),
        SuperRow.map({
          'sku': 'CN-TAPE-04',
          'category': 'Consumable',
          'qty': 220,
          'cost': 1.10,
        }),
      ],
    );
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
        title: Text(ExampleL10n.current.aggregations),
        backgroundColor: t.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                ExampleL10n.current.theTotalsRowShowsQtySumTheCostMinMaxAndAQuantityWeightedAverageC039559c,
                style: TextStyle(color: t.fg3),
              ),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _c.toggleGroup('category'),
                  icon: const Icon(Icons.workspaces_outline, size: 16),
                  label: Text(ExampleL10n.current.toggleGroupByCategory),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.fg1,
                    side: BorderSide(color: t.borderStrong),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c)),
          ],
        ),
      ),
    );
  }
}
