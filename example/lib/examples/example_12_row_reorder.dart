// ============================================================
// example/lib/examples/example_12_row_reorder.dart
// ------------------------------------------------------------
// EXAMPLE 12 — Manual row reordering.
//
// Demonstrates: `controller.moveRowUp` / `moveRowDown` / `moveRow`. ERP
// documents (a quotation, a delivery note, a BOM) care about line order. Right-
// click a row → Move row up / down in editable mode, or drive it from the
// toolbar here. Reordering records undo (⌘Z).
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class RowReorderExample extends StatefulWidget {
  const RowReorderExample({super.key});
  @override
  State<RowReorderExample> createState() => _RowReorderExampleState();
}

class _RowReorderExampleState extends State<RowReorderExample> {
  late final SuperTableController<Map<String, dynamic>> _c;

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.editable,
      selectionMode: SuperSelectionMode.singleRow,
      addRowEnabled: true,
      emptyRowValue: () => <String, dynamic>{'line': '', 'desc': '', 'qty': 1, 'price': 0.0},
      columns: [
        SuperTextColumn(key: 'desc', label: 'Description', width: 280),
        SuperNumberColumn<int>(key: 'qty', label: 'Qty', width: 90, min: 1),
        SuperCurrencyColumn(key: 'price', label: 'Unit Price', width: 140),
        SuperComputedColumn<num>(
          key: 'total',
          label: 'Line Total',
          width: 150,
          agg: SuperAgg.sum,
          compute: (row) => ((row['qty'] as num?) ?? 0) * ((row['price'] as num?) ?? 0),
          format: (v, row) => '\$${(v as num).toStringAsFixed(2)}',
        ),
      ],
      rows: [
        SuperRow.map({'desc': 'Site survey & setup', 'qty': 1, 'price': 1200.0}),
        SuperRow.map({'desc': 'Steel frame fabrication', 'qty': 4, 'price': 860.0}),
        SuperRow.map({'desc': 'Concrete pour (m³)', 'qty': 12, 'price': 145.0}),
        SuperRow.map({'desc': 'Finishing & inspection', 'qty': 1, 'price': 2400.0}),
      ],
      onChange: (_) => setState(() {}),
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
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: const Text('Row reordering'), backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Click a row number to select it, then use the buttons below — or right-click → '
                'Move row up / down. ⌘Z undoes a move.',
                style: TextStyle(color: t.fg3),
              ),
            ),
            Row(children: [
              OutlinedButton.icon(
                onPressed: () => _c.moveRowUp(),
                icon: const Icon(Icons.arrow_upward_rounded, size: 16),
                label: const Text('Move up'),
                style: OutlinedButton.styleFrom(foregroundColor: t.fg1, side: BorderSide(color: t.borderStrong)),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _c.moveRowDown(),
                icon: const Icon(Icons.arrow_downward_rounded, size: 16),
                label: const Text('Move down'),
                style: OutlinedButton.styleFrom(foregroundColor: t.fg1, side: BorderSide(color: t.borderStrong)),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _c.canUndo ? _c.undo : null,
                icon: const Icon(Icons.undo_rounded, size: 16),
                label: const Text('Undo'),
                style: OutlinedButton.styleFrom(foregroundColor: t.fg1, side: BorderSide(color: t.borderStrong)),
              ),
            ]),
            const SizedBox(height: 12),
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c)),
          ],
        ),
      ),
    );
  }
}
