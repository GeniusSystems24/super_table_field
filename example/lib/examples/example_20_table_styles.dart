import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class TableStylesExample extends StatefulWidget {
  const TableStylesExample({super.key});

  @override
  State<TableStylesExample> createState() => _TableStylesExampleState();
}

class _TableStylesExampleState extends State<TableStylesExample> {
  late final List<_StyleDemo> _demos = [
    _StyleDemo('No SuperTableStyle', null, _controller()),
    for (final style in SuperTableStyle.presets)
      _StyleDemo(style.name, style, _controller()),
  ];

  SuperTableController<Map<String, dynamic>> _controller() {
    final controller = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.readable,
      selectionMode: SuperSelectionMode.multiCells,
      columns: [
        SuperTextColumn(
          key: 'account',
          label: 'Account',
          width: 170,
          mono: true,
        ),
        SuperTextColumn(key: 'name', label: 'Name', width: 220),
        SuperTextColumn(key: 'segment', label: 'Segment', width: 150),
        SuperCurrencyColumn(
          key: 'opening',
          label: 'Opening',
          width: 130,
          agg: SuperAgg.sum,
        ),
        SuperCurrencyColumn(
          key: 'debit',
          label: 'Debit',
          width: 130,
          agg: SuperAgg.sum,
        ),
        SuperCurrencyColumn(
          key: 'credit',
          label: 'Credit',
          width: 130,
          agg: SuperAgg.sum,
        ),
        SuperCurrencyColumn(
          key: 'closing',
          label: 'Closing',
          width: 140,
          agg: SuperAgg.sum,
        ),
        SuperEnumerationColumn<String>(
          key: 'status',
          label: 'Status',
          width: 120,
          values: const ['Open', 'Review', 'Posted'],
        ),
      ],
      rows: [
        SuperRow.map({
          'account': '1100-01',
          'name': 'Cash on Hand',
          'segment': 'Treasury',
          'opening': 18500.00,
          'debit': 4200.00,
          'credit': 2100.00,
          'closing': 20600.00,
          'status': 'Open',
        }),
        SuperRow.map({
          'account': '1110-02',
          'name': 'Operating Bank',
          'segment': 'Treasury',
          'opening': 98500.00,
          'debit': 22640.50,
          'credit': 18720.25,
          'closing': 102420.25,
          'status': 'Posted',
        }),
        SuperRow.map({
          'account': '1200-10',
          'name': 'Trade Receivables',
          'segment': 'Receivables',
          'opening': 44200.00,
          'debit': 12800.00,
          'credit': 9100.00,
          'closing': 47900.00,
          'status': 'Review',
        }),
        SuperRow.map({
          'account': '1210-15',
          'name': 'Retention Receivable',
          'segment': 'Receivables',
          'opening': 7800.00,
          'debit': 1400.00,
          'credit': 600.00,
          'closing': 8600.00,
          'status': 'Open',
        }),
        SuperRow.map({
          'account': '2100-01',
          'name': 'Supplier Payables',
          'segment': 'Payables',
          'opening': 31400.00,
          'debit': 6200.00,
          'credit': 11350.00,
          'closing': 36550.00,
          'status': 'Review',
        }),
        SuperRow.map({
          'account': '2200-05',
          'name': 'Accrued Expenses',
          'segment': 'Payables',
          'opening': 12600.00,
          'debit': 1800.00,
          'credit': 2850.00,
          'closing': 13650.00,
          'status': 'Posted',
        }),
      ],
    );
    controller.setGroupKeys(['segment']);
    controller.selectCells(const [CellPos(1, 3), CellPos(1, 4), CellPos(1, 5)]);
    return controller;
  }

  @override
  void dispose() {
    for (final demo in _demos) {
      demo.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: const Text('Table styles'),
        backgroundColor: t.surface,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: _demos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final demo = _demos[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                demo.title,
                style: context.superTextTheme.heading.copyWith(color: t.fg1),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 390,
                child: SuperTable<Map<String, dynamic>>(
                  controller: demo.controller,
                  style: demo.style,
                  groupFooters: true,
                  showTotals: true,
                  showFooter: false,
                  columnFilters: false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StyleDemo {
  final String title;
  final SuperTableStyle? style;
  final SuperTableController<Map<String, dynamic>> controller;

  const _StyleDemo(this.title, this.style, this.controller);
}
