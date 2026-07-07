// ============================================================
// example/lib/examples/example_19_showcase.dart
// ------------------------------------------------------------
// EXAMPLE 19 — Showcase: an end-to-end ERP inventory screen that combines the
// two 2.2.0 features with the wider toolkit.
//
//   • Interaction events  — onRowActivate pops a snackbar ("open item"),
//     onSelectionChanged drives the status line.
//   • Column config       — the Columns… button + header menus (manage /
//     pin / hide); the SKU stays pinned left.
//   • Plus: readable⇄editable toggle, group-by, Σ totals + group footers,
//     change tracking (dirty markers), CSV export, and validate.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_table_field/super_table_field.dart';

class ShowcaseExample extends StatefulWidget {
  const ShowcaseExample({super.key});
  @override
  State<ShowcaseExample> createState() => _ShowcaseExampleState();
}

class _ShowcaseExampleState extends State<ShowcaseExample> {
  late final SuperTableController<Map<String, dynamic>> _c;
  bool _grouped = false;
  String _status = 'Ready';

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.readable,
      selectionMode: SuperSelectionMode.multiCells,
      addRowEnabled: true,
      trackChanges: true,
      emptyRowValue: () => <String, dynamic>{
        'sku': '',
        'name': '',
        'category': 'Filters',
        'qty': 0,
        'price': 0.0,
        'active': true,
        'updated': '2026-07-06'
      },
      onNotify: (kind, msg) => setState(() => _status = msg),
      columns: [
        SuperTextColumn(
            key: 'sku',
            label: 'SKU',
            width: 128,
            mono: true,
            required: true,
            unique: true,
            pin: SuperPin.left),
        SuperTextColumn(key: 'name', label: 'Item', width: 230, required: true),
        SuperEnumerationColumn<String>(
          key: 'category',
          label: 'Category',
          width: 150,
          values: const ['Filters', 'Bearings', 'Seals', 'Fasteners'],
        ),
        SuperNumberColumn<int>(
            key: 'qty',
            label: 'On hand',
            width: 110,
            min: 0,
            agg: SuperAgg.sum),
        SuperCurrencyColumn(
            key: 'price',
            label: 'Unit price',
            width: 130,
            agg: SuperAgg.avg,
            aggLabel: 'AVG'),
        SuperComputedColumn<num>(
          key: 'value',
          label: 'Stock value',
          width: 150,
          align: SuperAlign.end,
          agg: SuperAgg.sum,
          compute: (row) =>
              (row.cells['qty']?.value as num? ?? 0) *
              (row.cells['price']?.value as num? ?? 0),
          format: (v, row) => '\$${(v as num).toStringAsFixed(2)}',
        ),
        SuperCheckboxColumn(key: 'active', label: 'Active', width: 90),
        SuperDateColumn(key: 'updated', label: 'Updated', width: 130),
      ],
      rows: [for (final r in _seed) SuperRow.map(r)],
    );
    _c.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggleGroup() {
    setState(() => _grouped = !_grouped);
    _c.setGroupKeys(_grouped ? ['category'] : const []);
  }

  Future<void> _copyCsv() async {
    await Clipboard.setData(ClipboardData(text: _c.toCsv()));
    setState(() => _status =
        'Copied ${_c.sortedRows.length} rows as CSV to the clipboard.');
  }

  void _validate() {
    showSuperValidationPanel(context, _c);
    setState(() => _status = _c.isValid
        ? 'All rows valid ✓'
        : '${_c.errorCount} validation issue(s).');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final editable = _c.mode == SuperTableMode.editable;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
          title: const Text('Showcase · inventory'),
          backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _btn(
                      t,
                      editable ? Icons.visibility_rounded : Icons.edit_rounded,
                      editable ? 'Readable' : 'Editable',
                      _c.toggleMode,
                      filled: true),
                  _btn(t, Icons.view_column_rounded, 'Columns…',
                      () => showSuperColumnManager(context, _c)),
                  _btn(
                      t,
                      _grouped
                          ? Icons.layers_clear_rounded
                          : Icons.layers_rounded,
                      _grouped ? 'Ungroup' : 'Group by category',
                      _toggleGroup),
                  _btn(t, Icons.file_download_outlined, 'Copy CSV', _copyCsv),
                  _btn(t, Icons.rule_rounded, 'Validate', _validate),
                  if (_c.hasChanges)
                    _btn(t, Icons.save_rounded, 'Accept changes',
                        _c.acceptChanges),
                ]),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Icon(editable ? Icons.edit_rounded : Icons.visibility_rounded,
                    size: 14, color: t.fg3),
                const SizedBox(width: 6),
                Text(
                    editable
                        ? 'Editable — double-click a cell to edit; dirty cells show a corner mark.'
                        : 'Readable — double-click a row (or Enter) to open it.',
                    style: TextStyle(color: t.fg3, fontSize: 12.5)),
                const Spacer(),
                Text(_status,
                    style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                        color: t.fg1)),
              ]),
            ),
            Flexible(
              child: SuperTable<Map<String, dynamic>>(
                controller: _c,
                groupFooters: true,
                interactions: SuperInteractions<Map<String, dynamic>>(
                  onRowActivate: (d) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text('Open item ${d.row.value['sku']} — ${d.row.value['name']}'), duration: const Duration(seconds: 2)));
                  },
                  onSelectionChanged: (sel) => setState(() {
                    final s = sel.stats;
                    _status = s != null && s.hasAggregate
                        ? '${sel.cells.length} cells · Σ ${s.sum.toStringAsFixed(2)} · avg ${s.average.toStringAsFixed(2)}'
                        : 'Cursor at row ${sel.cursor.r + 1}, col ${sel.cursor.c + 1}';
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(
      SuperThemeData t, IconData icon, String label, VoidCallback? onTap,
      {bool filled = false}) {
    if (filled) {
      return FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: FilledButton.styleFrom(
            backgroundColor: t.fg1, foregroundColor: Colors.white),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
          foregroundColor: t.fg1, side: BorderSide(color: t.borderStrong)),
    );
  }

  static const List<Map<String, dynamic>> _seed = [
    {
      'sku': 'FLT-0001',
      'name': 'Hydraulic filter',
      'category': 'Filters',
      'qty': 42,
      'price': 18.50,
      'active': true,
      'updated': '2026-07-01'
    },
    {
      'sku': 'FLT-0002',
      'name': 'Air filter element',
      'category': 'Filters',
      'qty': 17,
      'price': 9.75,
      'active': true,
      'updated': '2026-07-02'
    },
    {
      'sku': 'BRG-0114',
      'name': 'Roller bearing 35mm',
      'category': 'Bearings',
      'qty': 8,
      'price': 64.00,
      'active': true,
      'updated': '2026-06-29'
    },
    {
      'sku': 'BRG-0120',
      'name': 'Ball bearing 20mm',
      'category': 'Bearings',
      'qty': 55,
      'price': 12.30,
      'active': true,
      'updated': '2026-07-03'
    },
    {
      'sku': 'SEL-0301',
      'name': 'O-ring seal kit',
      'category': 'Seals',
      'qty': 120,
      'price': 3.20,
      'active': true,
      'updated': '2026-07-04'
    },
    {
      'sku': 'SEL-0302',
      'name': 'Shaft seal 40mm',
      'category': 'Seals',
      'qty': 6,
      'price': 22.10,
      'active': false,
      'updated': '2026-06-25'
    },
    {
      'sku': 'FST-0500',
      'name': 'Hex bolt M10 (100pk)',
      'category': 'Fasteners',
      'qty': 34,
      'price': 8.90,
      'active': true,
      'updated': '2026-07-05'
    },
    {
      'sku': 'FST-0501',
      'name': 'Lock washer M10 (200pk)',
      'category': 'Fasteners',
      'qty': 61,
      'price': 4.15,
      'active': true,
      'updated': '2026-07-05'
    },
  ];
}
