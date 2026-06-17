// ============================================================
// example/lib/examples/example_2_editable_journal.dart
// ------------------------------------------------------------
// EXAMPLE 2 — An editable journal entry.
//
// Demonstrates: editable mode, per-column `validator` (required account, debit
// XOR credit), per-column `onChange` (typing a debit zeroes the credit and
// vice-versa), Tab-at-end to append a row, Ctrl+Enter / Ctrl+Shift+Enter to
// insert rows, and a live balance computed from the rows.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class EditableJournalExample extends StatefulWidget {
  const EditableJournalExample({super.key});
  @override
  State<EditableJournalExample> createState() => _EditableJournalExampleState();
}

class _EditableJournalExampleState extends State<EditableJournalExample> {
  late final SuperTableController<Map<String, dynamic>> _c;

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.editable,
      addRowEnabled: true,
      emptyRowValue: () => <String, dynamic>{'account': '', 'memo': '', 'debit': 0, 'credit': 0},
      columns: [
        SuperEnumerationColumn<String>(
          key: 'account',
          label: 'Account',
          width: 200,
          required: true,
          values: const ['1010 · Cash', '1200 · Receivable', '2000 · Payable', '4000 · Revenue', '5000 · Expense'],
          validator: (ctx, c, row, cell, v) => (v.isEmpty) ? 'Pick an account' : null,
        ),
        SuperTextColumn(key: 'memo', label: 'Memo', width: 220),
        SuperNumberColumn<num>(
          key: 'debit',
          label: 'Debit',
          width: 130,
          min: 0,
          // Entering a debit clears the credit on the same row.
          onChange: (ctx, c, row, cell, prev, next) {
            if (next > 0) row['credit'] = 0;
            return next >= 0;
          },
        ),
        SuperNumberColumn<num>(
          key: 'credit',
          label: 'Credit',
          width: 130,
          min: 0,
          onChange: (ctx, c, row, cell, prev, next) {
            if (next > 0) row['debit'] = 0;
            return next >= 0;
          },
        ),
      ],
      rows: [
        SuperRow.map({'account': '1010 · Cash', 'memo': 'Opening balance', 'debit': 5000, 'credit': 0}),
        SuperRow.map({'account': '4000 · Revenue', 'memo': 'Opening balance', 'debit': 0, 'credit': 5000}),
      ],
      onChange: (_) => setState(() {}),
    );
  }

  ({num debit, num credit}) get _totals {
    num d = 0, cr = 0;
    for (final r in _c.rows) {
      d += (r['debit'] is num ? r['debit'] as num : 0);
      cr += (r['credit'] is num ? r['credit'] as num : 0);
    }
    return (debit: d, credit: cr);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final tot = _totals;
    final balanced = tot.debit == tot.credit;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: const Text('Editable journal entry'), backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: balanced ? const Color(0x141DB88A) : const Color(0x14EF4444),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: balanced ? const Color(0xFF1DB88A) : const Color(0xFFEF4444)),
              ),
              child: Row(children: [
                Icon(balanced ? Icons.check_circle_outline : Icons.error_outline, size: 18, color: balanced ? const Color(0xFF1DB88A) : const Color(0xFFEF4444)),
                const SizedBox(width: 10),
                Text(balanced ? 'Balanced' : 'Out of balance', style: TextStyle(fontWeight: FontWeight.w700, color: t.fg1)),
                const Spacer(),
                Text('Debit \$${tot.debit}   ·   Credit \$${tot.credit}', style: TextStyle(fontFamily: 'JetBrainsMono', color: t.fg2)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
