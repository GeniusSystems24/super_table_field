// ============================================================
// example/lib/examples/example_11_cell_locking.dart
// ------------------------------------------------------------
// EXAMPLE 11 — Per-cell edit locking.
//
// Demonstrates: `SuperTableController(cellEditable: ...)`. ERP rows often become
// read-only once posted/approved. Here, any row whose `status` is "Posted" is
// locked — its cells won't enter edit mode, won't accept Delete-to-clear, and
// won't take a paste. Flip a row to "Draft" to unlock it.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class CellLockingExample extends StatefulWidget {
  const CellLockingExample({super.key});
  @override
  State<CellLockingExample> createState() => _CellLockingExampleState();
}

class _CellLockingExampleState extends State<CellLockingExample> {
  late final SuperTableController<Map<String, dynamic>> _c;

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.editable,
      addRowEnabled: true,
      emptyRowValue: () => <String, dynamic>{'ref': '', 'memo': '', 'amount': 0.0, 'status': 'Draft'},
      // The status column stays editable so you can unlock a row; every other
      // column is locked while the row is Posted.
      cellEditable: (col, row) => row['status'] == 'Draft' || col.key == 'status',
      columns: [
        SuperTextColumn(key: 'ref', label: 'Reference', width: 150, mono: true),
        SuperTextColumn(key: 'memo', label: 'Memo', width: 240),
        SuperCurrencyColumn(key: 'amount', label: 'Amount', width: 140, agg: SuperAgg.sum),
        SuperEnumerationColumn<String>(
          key: 'status',
          label: 'Status',
          width: 130,
          values: const ['Draft', 'Posted'],
        ),
      ],
      rows: [
        SuperRow.map({'ref': 'JV-0101', 'memo': 'Opening balance', 'amount': 5000.0, 'status': 'Posted'}),
        SuperRow.map({'ref': 'JV-0102', 'memo': 'Office supplies', 'amount': 240.0, 'status': 'Draft'}),
        SuperRow.map({'ref': 'JV-0103', 'memo': 'Client retainer', 'amount': 12000.0, 'status': 'Posted'}),
        SuperRow.map({'ref': 'JV-0104', 'memo': 'Bank fees', 'amount': 35.0, 'status': 'Draft'}),
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

  // Tint locked (Posted) rows so the lock is legible at a glance.
  // NOTE: row `styles` only render in READABLE mode; this example is editable,
  // so the Status pill (enum colors) is the at-a-glance lock cue instead.

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: const Text('Cell locking'), backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Posted rows are locked. Double-click their cells — nothing happens. '
                'Change a row’s Status to Draft to unlock its other cells.',
                style: TextStyle(color: t.fg3),
              ),
            ),
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c)),
          ],
        ),
      ),
    );
  }
}
