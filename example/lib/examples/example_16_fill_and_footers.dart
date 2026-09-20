// ============================================================
// example/lib/examples/example_16_fill_and_footers.dart
// ------------------------------------------------------------
// EXAMPLE 16 — Fill down / fill right · group footers · revert.
//
// Demonstrates the remaining 2.1.0 ERP features:
//   • **Fill down / fill right** (editable) — select a range and press ⌘/Ctrl+D
//     to copy the top row downward (Excel semantics), ⌘/Ctrl+R to copy the
//     left column rightward. One undo step.
//   • **Group footers** (readable) — `SuperTable(groupFooters: true)` closes
//     each group with a Σ subtotal row, aggregates aligned under their columns.
//   • **Per-cell / per-row revert** — with trackChanges on, right-click a
//     dirty row → Revert cell / Revert row.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';
import 'package:super_core/super_core.dart';
import 'package:super_table_field_example/localizations/example_l10n.dart';

class FillAndFootersExample extends StatefulWidget {
  const FillAndFootersExample({super.key});
  @override
  State<FillAndFootersExample> createState() => _FillAndFootersExampleState();
}

class _FillAndFootersExampleState extends State<FillAndFootersExample> {
  late final SuperTableController<Map<String, dynamic>> _c;

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.editable,
      selectionMode: SuperSelectionMode.multiCells,
      addRowEnabled: true,
      trackChanges: true,
      emptyRowValue: () => <String, dynamic>{
        'warehouse': 'Main',
        'item': '',
        'bin': '',
        'qty': 0,
        'value': 0.0,
      },
      columns: [
        SuperEnumerationColumn(
          key: 'warehouse',
          label: ExampleL10n.current.warehouse,
          width: 140,
          values: const ['Main', 'North', 'Overflow'],
          groupable: true,
        ),
        SuperTextColumn(key: 'item', label: ExampleL10n.current.item, width: 220),
        SuperTextColumn(key: 'bin', label: ExampleL10n.current.bin, width: 100, mono: true),
        SuperNumberColumn<int>(
          key: 'qty',
          label: ExampleL10n.current.qty,
          width: 100,
          min: 0,
          agg: SuperAgg.sum,
        ),
        SuperCurrencyColumn(
          key: 'value',
          label: ExampleL10n.current.stockValuefdb1ac,
          width: 150,
          agg: SuperAgg.sum,
        ),
      ],
      rows: [
        SuperRow.map({
          'warehouse': 'Main',
          'item': 'Hydraulic filter',
          'bin': 'A-01',
          'qty': 42,
          'value': 777.0,
        }),
        SuperRow.map({
          'warehouse': 'Main',
          'item': 'Air filter element',
          'bin': 'A-02',
          'qty': 17,
          'value': 165.75,
        }),
        SuperRow.map({
          'warehouse': 'North',
          'item': 'Roller bearing 35mm',
          'bin': 'N-11',
          'qty': 8,
          'value': 512.0,
        }),
        SuperRow.map({
          'warehouse': 'North',
          'item': 'Drive belt XL',
          'bin': 'N-12',
          'qty': 25,
          'value': 300.0,
        }),
        SuperRow.map({
          'warehouse': 'Overflow',
          'item': 'Gasket kit',
          'bin': 'O-03',
          'qty': 3,
          'value': 66.3,
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

  bool get _editable => _c.mode == SuperTableMode.editable;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: Text(ExampleL10n.current.fillDownRightGroupFooters),
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
                _editable
                    ? ExampleL10n.current.editableSelectARangeSpanningRowsPressCommandCtrlPlusDToFillDownC05fc021
                    : ExampleL10n.current.readableGroupedByWarehouseWithGroupFootersOnEachGroupClosesWithAb03b87f,
                style: TextStyle(color: t.fg3),
              ),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    if (_editable) {
                      _c.setMode(SuperTableMode.readable);
                      _c.setGroupKeys(['warehouse']);
                    } else {
                      _c.clearGroups();
                      _c.setMode(SuperTableMode.editable);
                    }
                  },
                  icon: Icon(
                    _editable ? Icons.visibility_outlined : Icons.edit_outlined,
                    size: 16,
                  ),
                  label: Text(
                    _editable ? ExampleL10n.current.readablePlusGrouped : ExampleL10n.current.backToEditable,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.fg1,
                    side: BorderSide(color: t.borderStrong),
                  ),
                ),
                if (_editable) ...[
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _c.fillDown,
                    icon: const Icon(Icons.south_rounded, size: 16),
                    label: Text(ExampleL10n.current.fillDown),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.fg1,
                      side: BorderSide(color: t.borderStrong),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _c.fillRight,
                    icon: const Icon(Icons.east_rounded, size: 16),
                    label: Text(ExampleL10n.current.fillRight),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.fg1,
                      side: BorderSide(color: t.borderStrong),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _c.canUndo ? _c.undo : null,
                    icon: const Icon(Icons.undo_rounded, size: 16),
                    label: Text(ExampleL10n.current.undo),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.fg1,
                      side: BorderSide(color: t.borderStrong),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SuperTable<Map<String, dynamic>>(
                controller: _c,
                groupFooters: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
