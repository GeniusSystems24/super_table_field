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
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import 'package:super_table_field_example/localizations/generated/l10n.dart';
class EditableJournalExample extends StatefulWidget {
  const EditableJournalExample({super.key});
  @override
  State<EditableJournalExample> createState() => _EditableJournalExampleState();
}

class _EditableJournalExampleState extends State<EditableJournalExample> {
  bool _exampleDependenciesInitialized = false;

  late final SuperTableController<Map<String, dynamic>> _c;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_exampleDependenciesInitialized) return;
    _exampleDependenciesInitialized = true;
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.editable,
      addRowEnabled: true,
      emptyRowValue: () => <String, dynamic>{
        'account': '',
        'memo': '',
        'debit': 0,
        'credit': 0,
      },
      columns: [
        SuperComboColumn<String>(
          key: 'account',
          label: SuperTableExampleLocalization.of(context).account,
          width: 200,
          required: true,
          allowFreeText: false,
          clearButton: true,
          hintText: SuperTableExampleLocalization.of(context).searchAccount,
          values: const [
            '1010 · Cash',
            '1200 · Receivable',
            '2000 · Payable',
            '4000 · Revenue',
            '5000 · Expense',
          ],
          suggestionBuilder: (context, items, index, account) {
            final parts = account.split(' · ');
            final code = parts.first;
            final name = parts.length > 1 ? parts.last : account;
            return SuperAutoSuggestionsItem<String>(
              value: account,
              titleText: name,
              descriptionText: code,
              keywords: [account, code, name],
            );
          },
          validator: (ctx, c, row, cell, v) =>
              (v.isEmpty) ? SuperTableExampleLocalization.of(context).pickAnAccount : null,
        ),
        SuperTextColumn(key: 'memo', label: SuperTableExampleLocalization.of(context).memo, width: 220),
        SuperNumberColumn<num>(
          key: 'debit',
          label: SuperTableExampleLocalization.of(context).debit,
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
          label: SuperTableExampleLocalization.of(context).credit,
          width: 130,
          min: 0,
          onChange: (ctx, c, row, cell, prev, next) {
            if (next > 0) row['debit'] = 0;
            return next >= 0;
          },
        ),
      ],
      rows: [
        SuperRow.map({
          'account': '1010 · Cash',
          'memo': 'Opening balance',
          'debit': 5000,
          'credit': 0,
        }),
        SuperRow.map({
          'account': '4000 · Revenue',
          'memo': 'Opening balance',
          'debit': 0,
          'credit': 5000,
        }),
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
      appBar: AppBar(
        title: Text(SuperTableExampleLocalization.of(context).editableJournalEntry),
        backgroundColor: t.surface,
      ),
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
                color: balanced
                    ? const Color(0x141DB88A)
                    : const Color(0x14EF4444),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: balanced
                      ? const Color(0xFF1DB88A)
                      : const Color(0xFFEF4444),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    balanced ? Icons.check_circle_outline : Icons.error_outline,
                    size: 18,
                    color: balanced
                        ? const Color(0xFF1DB88A)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    balanced ? SuperTableExampleLocalization.of(context).balanced : SuperTableExampleLocalization.of(context).outOfBalance,
                    style: TextStyle(fontWeight: FontWeight.w700, color: t.fg1),
                  ),
                  const Spacer(),
                  Text(
                    SuperTableExampleLocalization.of(context).debitCredit(tot.debit, tot.credit),
                    style: TextStyle(
                      fontFamily: context.superTextTheme.mono.fontFamily,
                      color: t.fg2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
