// ============================================================
// example/lib/examples/example_9_export.dart
// ------------------------------------------------------------
// EXAMPLE 9 — Export (CSV / TSV / JSON).
//
// Demonstrates: `controller.toCsv()`, `toTsv()`, `toJsonRows()`, and
// `copyCsvToClipboard()`. Export honours the **active filter + sort + column
// order**, so type in the search box or sort a column and re-export to see the
// output change.
// ============================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class ExportExample extends StatefulWidget {
  const ExportExample({super.key});
  @override
  State<ExportExample> createState() => _ExportExampleState();
}

class _ExportExampleState extends State<ExportExample> {
  late final SuperTableController<Map<String, dynamic>> _c;
  String _preview = '';
  String _format = 'CSV';

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.readable,
      columns: [
        SuperTextColumn(key: 'ref', label: 'Reference', width: 150, mono: true),
        SuperEnumerationColumn<String>(key: 'type', label: 'Type', width: 120, values: const ['Debit', 'Credit']),
        SuperTextColumn(key: 'memo', label: 'Memo', width: 240),
        SuperCurrencyColumn(key: 'amount', label: 'Amount', width: 140, agg: SuperAgg.sum),
        SuperDateColumn(key: 'date', label: 'Date', width: 140),
      ],
      rows: [
        SuperRow.map({'ref': 'JV-2024-0042', 'type': 'Debit', 'memo': 'Quarterly reconciliation', 'amount': 5240.00, 'date': '2024-09-30'}),
        SuperRow.map({'ref': 'JV-2024-0043', 'type': 'Credit', 'memo': 'Vendor settlement, "Acme"', 'amount': 1820.50, 'date': '2024-10-02'}),
        SuperRow.map({'ref': 'JV-2024-0044', 'type': 'Debit', 'memo': 'Payroll accrual', 'amount': 38000.00, 'date': '2024-10-05'}),
        SuperRow.map({'ref': 'JV-2024-0045', 'type': 'Credit', 'memo': 'Interest income', 'amount': 412.18, 'date': '2024-10-06'}),
      ],
    );
    _c.addListener(() => setState(() {}));
    _rebuild();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _rebuild() {
    setState(() {
      _preview = switch (_format) {
        'TSV' => _c.toTsv(),
        'JSON' => const JsonEncoder.withIndent('  ').convert(_c.toJsonRows()),
        _ => _c.toCsv(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: const Text('Export'), backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                child: TextField(
                  onChanged: (v) {
                    _c.setSearch(v);
                    _rebuild();
                  },
                  style: TextStyle(color: t.fg1),
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    hintText: 'Search (export reflects the filtered view)…',
                    hintStyle: TextStyle(color: t.fg4),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: t.border)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: t.fg2)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'CSV', label: Text('CSV')),
                  ButtonSegment(value: 'TSV', label: Text('TSV')),
                  ButtonSegment(value: 'JSON', label: Text('JSON')),
                ],
                selected: {_format},
                onSelectionChanged: (s) {
                  _format = s.first;
                  _rebuild();
                },
              ),
            ]),
            const SizedBox(height: 16),
            Flexible(flex: 3, child: SuperTable<Map<String, dynamic>>(controller: _c)),
            const SizedBox(height: 16),
            Row(children: [
              Text('$_format output', style: TextStyle(fontWeight: FontWeight.w700, color: t.fg1)),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  _c.copyCsvToClipboard();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV copied to clipboard')));
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy CSV'),
              ),
            ]),
            const SizedBox(height: 8),
            Flexible(
              flex: 2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: t.border),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(_preview, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, height: 1.5, color: t.fg2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
