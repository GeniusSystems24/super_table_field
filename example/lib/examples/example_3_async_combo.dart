// ============================================================
// example/lib/examples/example_3_async_combo.dart
// ------------------------------------------------------------
// EXAMPLE 3 — An async combo backed by a "remote" source.
//
// Demonstrates: SuperComboColumn with a per-cell `sourceController` that returns
// an ASYNC AutoSuggestionsSource (here, a fake network call), and a `fingerPrint`
// rebuild: changing the "Warehouse" cell bumps the row's fingerPrint so the
// "Bin" combo rebuilds its source scoped to the chosen warehouse.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class AsyncComboExample extends StatefulWidget {
  const AsyncComboExample({super.key});
  @override
  State<AsyncComboExample> createState() => _AsyncComboExampleState();
}

class _AsyncComboExampleState extends State<AsyncComboExample> {
  // Pretend these come from a backend, keyed by warehouse.
  static const Map<String, List<String>> _bins = {
    'WH-Riyadh': ['R-A01', 'R-A02', 'R-B07', 'R-C15'],
    'WH-Jeddah': ['J-01', 'J-02', 'J-14', 'J-22'],
    'WH-Dammam': ['D-100', 'D-101', 'D-205'],
  };

  Future<List<AutoSuggestion<String>>> _fetchBins(String warehouse, String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 500)); // simulate latency
    final all = _bins[warehouse] ?? const [];
    final q = query.trim().toLowerCase();
    return [
      for (final b in all)
        if (q.isEmpty || b.toLowerCase().contains(q)) AutoSuggestion<String>(value: b, label: b),
    ];
  }

  late final SuperTableController<Map<String, dynamic>> _c = SuperTableController<Map<String, dynamic>>(
    mode: SuperTableMode.editable,
    addRowEnabled: true,
    emptyRowValue: () => <String, dynamic>{'sku': '', 'warehouse': 'WH-Riyadh', 'bin': ''},
    columns: [
      SuperTextColumn(key: 'sku', label: 'SKU', width: 130, mono: true),
      SuperComboColumn<String>(
        key: 'warehouse',
        label: 'Warehouse',
        width: 160,
        values: const ['WH-Riyadh', 'WH-Jeddah', 'WH-Dammam'],
        // Changing the warehouse invalidates the bin + forces the bin combo to
        // rebuild its source (via a fresh fingerPrint).
        onChange: (ctx, c, row, cell, prev, next) {
          if (prev != next) {
            row['bin'] = '';
            row.randomFingerPrint();
          }
          return true;
        },
      ),
      SuperComboColumn<String>(
        key: 'bin',
        label: 'Bin',
        width: 160,
        hintText: 'Search bins…',
        // Rebuilt whenever the row's fingerPrint changes (i.e. after a warehouse
        // change) — scoped to the row's current warehouse.
        sourceController: (ctx, c, row, cell) {
          final wh = '${row['warehouse']}';
          return SuggestionSources.async<String>((q) => _fetchBins(wh, q));
        },
      ),
    ],
    rows: [
      SuperRow.map({'sku': 'ITM-001', 'warehouse': 'WH-Riyadh', 'bin': 'R-A01'}),
      SuperRow.map({'sku': 'ITM-002', 'warehouse': 'WH-Jeddah', 'bin': 'J-14'}),
    ],
  );

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
      appBar: AppBar(title: const Text('Async combo (fingerPrint rebuild)'), backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('Double-click a Bin cell to search "remotely". Change the Warehouse and the Bin list rescopes.', style: TextStyle(color: t.fg3)),
            ),
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c)),
          ],
        ),
      ),
    );
  }
}
