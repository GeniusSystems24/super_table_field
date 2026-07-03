// ============================================================
// example/lib/examples/example_15_validation_views.dart
// ------------------------------------------------------------
// EXAMPLE 15 — Validation summary · unique columns · saved views.
//
// Demonstrates three 2.1.0 ERP features:
//   • `unique: true` on the SKU column — duplicates are rejected at commit
//     time and reported by `validateAll()`.
//   • `controller.validateAll()` / `isValid` — the **Validate** button opens
//     the built-in summary panel (jump-to-cell); *Post* is gated on isValid.
//   • `controller.viewStateJson()` / `applyViewJson()` — save the grid layout
//     (order, widths, sort, filters) and restore it later, as a user
//     preference would be.
// ============================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class ValidationViewsExample extends StatefulWidget {
  const ValidationViewsExample({super.key});
  @override
  State<ValidationViewsExample> createState() => _ValidationViewsExampleState();
}

class _ValidationViewsExampleState extends State<ValidationViewsExample> {
  late final SuperTableController<Map<String, dynamic>> _c;
  String? _savedView;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.editable,
      selectionMode: SuperSelectionMode.multiCells,
      addRowEnabled: true,
      trackChanges: true,
      emptyRowValue: () => <String, dynamic>{'sku': '', 'name': '', 'qty': 0, 'cost': 0.0},
      columns: [
        SuperTextColumn(key: 'sku', label: 'SKU', width: 130, required: true, unique: true, mono: true),
        SuperTextColumn(key: 'name', label: 'Item name', width: 240, required: true),
        SuperNumberColumn<int>(key: 'qty', label: 'On hand', width: 110, min: 0),
        SuperCurrencyColumn(key: 'cost', label: 'Unit cost', width: 130, agg: SuperAgg.sum),
      ],
      rows: [
        SuperRow.map({'sku': 'FLT-0001', 'name': 'Hydraulic filter', 'qty': 42, 'cost': 18.50}),
        SuperRow.map({'sku': 'FLT-0002', 'name': 'Air filter element', 'qty': 17, 'cost': 9.75}),
        SuperRow.map({'sku': 'BRG-0114', 'name': 'Roller bearing 35mm', 'qty': 8, 'cost': 64.00}),
        SuperRow.map({'sku': '', 'name': 'Gasket kit — unlabelled', 'qty': 3, 'cost': 22.10}),
      ],
    );
    _c.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _validate() => showSuperValidationPanel(context, _c);

  void _post() {
    if (!_c.isValid) {
      _c.validateAll(); // light the badges
      setState(() => _status = 'Cannot post — fix the validation issues first.');
      showSuperValidationPanel(context, _c);
      return;
    }
    _c.acceptChanges();
    setState(() => _status = 'Posted ✓  (baseline captured — cells are clean again)');
  }

  void _saveView() {
    _savedView = jsonEncode(_c.viewStateJson());
    setState(() => _status = 'View saved (${_savedView!.length} chars of JSON).');
  }

  void _restoreView() {
    if (_savedView == null) return;
    _c.applyViewJson(jsonDecode(_savedView!) as Map<String, dynamic>);
    setState(() => _status = 'View restored — order, widths, sort and filters are back.');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(title: const Text('Validation summary · saved views'), backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'SKU is required AND unique — try duplicating one, or leave it blank, then hit '
                'Validate. Post is gated on controller.isValid. Save view snapshots the grid '
                'layout (drag a column, resize, sort, filter…) and Restore brings it back.',
                style: TextStyle(color: t.fg3),
              ),
            ),
            Row(children: [
              OutlinedButton.icon(
                onPressed: _validate,
                icon: const Icon(Icons.rule_rounded, size: 16),
                label: const Text('Validate'),
                style: OutlinedButton.styleFrom(foregroundColor: t.fg1, side: BorderSide(color: t.borderStrong)),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _post,
                icon: const Icon(Icons.task_alt_rounded, size: 16),
                label: const Text('Post'),
                style: OutlinedButton.styleFrom(foregroundColor: t.fg1, side: BorderSide(color: t.borderStrong)),
              ),
              const SizedBox(width: 24),
              OutlinedButton.icon(
                onPressed: _saveView,
                icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                label: const Text('Save view'),
                style: OutlinedButton.styleFrom(foregroundColor: t.fg1, side: BorderSide(color: t.borderStrong)),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _savedView == null ? null : _restoreView,
                icon: const Icon(Icons.bookmark_outlined, size: 16),
                label: const Text('Restore view'),
                style: OutlinedButton.styleFrom(foregroundColor: t.fg1, side: BorderSide(color: t.borderStrong)),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _c.resetViewState(),
                icon: const Icon(Icons.restart_alt_rounded, size: 16),
                label: const Text('Reset view'),
                style: OutlinedButton.styleFrom(foregroundColor: t.fg1, side: BorderSide(color: t.borderStrong)),
              ),
            ]),
            if (_status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_status, style: TextStyle(color: t.fg2, fontSize: 13)),
              ),
            const SizedBox(height: 12),
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c)),
          ],
        ),
      ),
    );
  }
}
