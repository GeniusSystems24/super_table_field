// ============================================================
// example/lib/examples/example_23_enumeration_select.dart
// ------------------------------------------------------------
// EXAMPLE 23 — SuperEnumerationColumn + SuperSelectFormField.
//
// Demonstrates three enumeration modes:
//   • local typed values,
//   • explicit SuperSelectSource + optionBuilder metadata,
//   • row-dependent sources rebuilt through row.fingerPrint.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_form_field/super_form_field.dart';
import 'package:super_table_field/super_table_field.dart';
import 'package:super_table_field_example/localizations/generated/l10n.dart';
typedef _Row = Map<String, dynamic>;

class EnumerationSelectExample extends StatefulWidget {
  const EnumerationSelectExample({super.key});

  @override
  State<EnumerationSelectExample> createState() =>
      _EnumerationSelectExampleState();
}

class _EnumerationSelectExampleState extends State<EnumerationSelectExample> {
  static const _bins = <String, List<String>>{
    'Riyadh': ['R-A01', 'R-A02', 'R-B07'],
    'Jeddah': ['J-01', 'J-02', 'J-14'],
    'Dammam': ['D-100', 'D-205', 'D-310'],
  };

  late final SuperTableController<_Row> _controller =
      SuperTableController<_Row>(
        mode: SuperTableMode.editable,
        addRowEnabled: true,
        emptyRowValue: () => <String, dynamic>{
          'sku': '',
          'warehouse': 'Riyadh',
          'bin': 'R-A01',
          'status': 'Draft',
        },
        columns: [
          SuperTextColumn(key: 'sku', label: SuperTableExampleLocalization.of(context).sKU, width: 140, mono: true),
          SuperEnumerationColumn<String>(
            key: 'warehouse',
            label: SuperTableExampleLocalization.of(context).warehouse,
            width: 150,
            values: const ['Riyadh', 'Jeddah', 'Dammam'],
            searchable: true,
            onChange: (context, controller, row, cell, previous, next) {
              if (previous != next) {
                final nextWarehouse = next as String? ?? 'Riyadh';
                row['bin'] = _bins[nextWarehouse]!.first;
                row.randomFingerPrint();
              }
              return true;
            },
          ),
          SuperEnumerationColumn<String>(
            key: 'bin',
            label: SuperTableExampleLocalization.of(context).bin,
            width: 140,
            searchable: false,
            searchHint: 'Search bins…',
            sourcesController: (context, controller, row, cell) {
              final warehouse = row['warehouse'] as String? ?? 'Riyadh';
              return [
                SuperSelectListSource<String>(
                  items: _bins[warehouse] ?? const <String>[],
                ),
              ];
            },
            optionBuilder: (items, index, bin) => SuperOption<String>(
              value: bin,
              label: bin,
              description: SuperTableExampleLocalization.of(context).binOf(index + 1, items.length),
            ),
          ),
          SuperEnumerationColumn<String>(
            key: 'status',
            label: SuperTableExampleLocalization.of(context).status,
            width: 160,
            searchable: false,
            sources: const [
              SuperSelectListSource<String>(
                items: ['Draft', 'Posted', 'Cancelled'],
              ),
            ],
            optionBuilder: (items, index, status) => SuperOption<String>(
              value: status,
              label: status,
              description: switch (status) {
                'Draft' => SuperTableExampleLocalization.of(context).stillEditable,
                'Posted' => SuperTableExampleLocalization.of(context).committedTransaction,
                _ => SuperTableExampleLocalization.of(context).noLongerActive,
              },
            ),
          ),
        ],
        rows: [
          SuperRow.map({
            'sku': 'ITM-001',
            'warehouse': 'Riyadh',
            'bin': 'R-A01',
            'status': 'Draft',
          }),
          SuperRow.map({
            'sku': 'ITM-002',
            'warehouse': 'Jeddah',
            'bin': 'J-14',
            'status': 'Posted',
          }),
          SuperRow.map({
            'sku': 'ITM-003',
            'warehouse': 'Dammam',
            'bin': 'D-205',
            'status': 'Cancelled',
          }),
        ],
      );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SuperTableExampleLocalization.of(context).enumerationSelect)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              SuperTableExampleLocalization.of(context).doubleClickAnEnumerationCellToEditItWithSuperSelectFormField,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              SuperTableExampleLocalization.of(context).changingWarehouseRebuildsTheBinSourcesForThatRow,
            ),
            const SizedBox(height: 16),
            Expanded(child: SuperTable<_Row>(controller: _controller)),
          ],
        ),
      ),
    );
  }
}
