// ============================================================
// example/lib/examples/example_8_selection_stats.dart
// ------------------------------------------------------------
// EXAMPLE 8 — Programmatic selection statistics.
//
// Demonstrates: `multiCells` selection + `controller.selectionStats`. Drag (or
// Shift+arrow) across a block of numbers; this screen renders the returned
// Sum / Avg / Min / Max / Count in an application-owned summary card.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';
import 'package:super_core/super_core.dart';
import 'package:super_table_field_example/localizations/example_l10n.dart';

class SelectionStatsExample extends StatefulWidget {
  const SelectionStatsExample({super.key});
  @override
  State<SelectionStatsExample> createState() => _SelectionStatsExampleState();
}

class _SelectionStatsExampleState extends State<SelectionStatsExample> {
  late final SuperTableController<Map<String, dynamic>> _c;

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.readable,
      selectionMode: SuperSelectionMode.multiCells, // ← rubber-band cells
      columns: [
        SuperTextColumn(
          key: 'account',
          label: ExampleL10n.current.account,
          width: 200,
          mono: true,
        ),
        SuperCurrencyColumn(key: 'q1', label: ExampleL10n.current.q1, width: 130),
        SuperCurrencyColumn(key: 'q2', label: ExampleL10n.current.q2, width: 130),
        SuperCurrencyColumn(key: 'q3', label: ExampleL10n.current.q3, width: 130),
        SuperCurrencyColumn(key: 'q4', label: ExampleL10n.current.q4, width: 130),
      ],
      rows: [
        SuperRow.map({
          'account': '4000 · Revenue',
          'q1': 124000.0,
          'q2': 138500.0,
          'q3': 142250.0,
          'q4': 159900.0,
        }),
        SuperRow.map({
          'account': '5000 · COGS',
          'q1': 61200.0,
          'q2': 66800.0,
          'q3': 70100.0,
          'q4': 78400.0,
        }),
        SuperRow.map({
          'account': '6000 · Payroll',
          'q1': 38000.0,
          'q2': 38000.0,
          'q3': 41000.0,
          'q4': 41000.0,
        }),
        SuperRow.map({
          'account': '6100 · Rent',
          'q1': 12000.0,
          'q2': 12000.0,
          'q3': 12000.0,
          'q4': 12000.0,
        }),
        SuperRow.map({
          'account': '6200 · Utilities',
          'q1': 3400.0,
          'q2': 2900.0,
          'q3': 3100.0,
          'q4': 4200.0,
        }),
      ],
    );
    _c.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final stats = _c.selectionStats;
    String money(num v) =>
        '\$${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: Text(ExampleL10n.current.selectionStatistics),
        backgroundColor: t.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                ExampleL10n.current.shiftDragABlockOfTheQuarterlyNumbersTheLiveSumAvgMinMaxAppearsIn8285e43,
                style: TextStyle(color: t.fg3),
              ),
            ),
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: t.border),
              ),
              child: (stats == null || !stats.hasAggregate)
                  ? Text(
                      ExampleL10n.current.selectTwoOrMoreNumericCellsToSeeStatistics,
                      style: TextStyle(color: t.fg3),
                    )
                  : Wrap(
                      spacing: 28,
                      runSpacing: 10,
                      children: [
                        _stat(ExampleL10n.current.sUM, money(stats.sum), t),
                        _stat(ExampleL10n.current.aVERAGE, money(stats.average), t),
                        _stat(ExampleL10n.current.mIN, money(stats.min!), t),
                        _stat(ExampleL10n.current.mAX, money(stats.max!), t),
                        _stat(ExampleL10n.current.cOUNT, '${stats.numericCount}', t),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, dynamic t) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.7,
          color: t.fg4,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: TextStyle(
          fontFamily: context.superTextTheme.mono.fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: t.fg1,
        ),
      ),
    ],
  );
}
