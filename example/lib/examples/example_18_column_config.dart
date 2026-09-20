// ============================================================
// example/lib/examples/example_18_column_config.dart
// ------------------------------------------------------------
// EXAMPLE 18 — Runtime column config (2.2.0).
//
// A wide general-ledger grid the user can reshape at runtime:
//   • The **Columns…** button opens `showSuperColumnManager` — drag to
//     reorder, toggle the eye to show/hide, and pin each column left / right.
//   • Right-click any header for the same via **Pin ▸ / Hide / Manage columns…**
//     (SuperTable(columnManager: true), the default).
//   • Quick buttons drive the controller API directly: `setColumnPin`,
//     `toggleColumnVisible`.
//   • **Save / Restore view** proves pin + visibility + order round-trip
//     through `viewStateJson()` / `applyViewJson()`.
// ============================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';
import 'package:super_core/super_core.dart';
import 'package:super_table_field_example/localizations/generated/l10n.dart';
class ColumnConfigExample extends StatefulWidget {
  const ColumnConfigExample({super.key});
  @override
  State<ColumnConfigExample> createState() => _ColumnConfigExampleState();
}

class _ColumnConfigExampleState extends State<ColumnConfigExample> {
  bool _exampleDependenciesInitialized = false;

  late final SuperTableController<Map<String, dynamic>> _c;
  String? _savedView;
  String _status = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_exampleDependenciesInitialized) return;
    _exampleDependenciesInitialized = true;
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.readable,
      selectionMode: SuperSelectionMode.singleCell,
      columns: [
        SuperTextColumn(
          key: 'code',
          label: SuperTableExampleLocalization.of(context).account,
          width: 120,
          mono: true,
          pin: SuperPin.start,
        ),
        SuperTextColumn(key: 'name', label: SuperTableExampleLocalization.of(context).accountName, width: 230),
        SuperEnumerationColumn<String>(
          key: 'type',
          label: SuperTableExampleLocalization.of(context).type,
          width: 130,
          values: const ['Asset', 'Liability', 'Equity', 'Revenue', 'Expense'],
        ),
        SuperTextColumn(key: 'region', label: SuperTableExampleLocalization.of(context).costCentre, width: 150),
        SuperCurrencyColumn(
          key: 'debit',
          label: SuperTableExampleLocalization.of(context).debit,
          width: 130,
          agg: SuperAgg.sum,
        ),
        SuperCurrencyColumn(
          key: 'credit',
          label: SuperTableExampleLocalization.of(context).credit,
          width: 130,
          agg: SuperAgg.sum,
        ),
        SuperComputedColumn<num>(
          key: 'balance',
          label: SuperTableExampleLocalization.of(context).balance,
          width: 140,
          align: SuperAlign.end,
          agg: SuperAgg.sum,
          compute: (row) =>
              (row.cells['debit']?.value as num? ?? 0) -
              (row.cells['credit']?.value as num? ?? 0),
          format: (v, row) => '\$${(v as num).toStringAsFixed(2)}',
        ),
        SuperEnumerationColumn<String>(
          key: 'status',
          label: SuperTableExampleLocalization.of(context).status,
          width: 120,
          values: const ['Open', 'Locked'],
          tones: {
            'Open': const Color(0xFF1DB88A),
            'Locked': const Color(0xFF8D90A0),
          },
        ),
        SuperDateColumn(key: 'updated', label: SuperTableExampleLocalization.of(context).updated, width: 130),
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

  void _saveView() {
    _savedView = jsonEncode(_c.viewStateJson());
    setState(
      () => _status =
          SuperTableExampleLocalization.of(context).viewSavedOrderWidthsVisibilityANDPinsChars(_savedView!.length),
    );
  }

  void _restoreView() {
    if (_savedView == null) return;
    _c.applyViewJson(jsonDecode(_savedView!) as Map<String, dynamic>);
    setState(
      () => _status = SuperTableExampleLocalization.of(context).viewRestoredColumnsAreBackWhereYouLeftThem,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: Text(SuperTableExampleLocalization.of(context).columnConfig),
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
                SuperTableExampleLocalization.of(context).reshapeTheGridOpenColumnsDragRowsToReorderClickTheEyeToHideAndPi4f6b1e8,
                style: TextStyle(color: t.fg3),
              ),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _btn(
                  t,
                  Icons.view_column_rounded,
                  SuperTableExampleLocalization.of(context).columns,
                  () => showSuperColumnManager(context, _c),
                  filled: true,
                ),
                _btn(
                  t,
                  Icons.push_pin_rounded,
                  SuperTableExampleLocalization.of(context).pinBalanceRight,
                  () => _c.setColumnPin('balance', SuperPin.end),
                ),
                _btn(
                  t,
                  Icons.visibility_off_rounded,
                  SuperTableExampleLocalization.of(context).toggleCostCentre,
                  () => _c.toggleColumnVisible('region'),
                ),
                _btn(t, Icons.bookmark_add_outlined, SuperTableExampleLocalization.of(context).saveView, _saveView),
                _btn(
                  t,
                  Icons.bookmark_outlined,
                  SuperTableExampleLocalization.of(context).restoreView,
                  _savedView == null ? null : _restoreView,
                ),
                _btn(
                  t,
                  Icons.restart_alt_rounded,
                  SuperTableExampleLocalization.of(context).reset,
                  () => _c.resetViewState(clearFilters: false),
                ),
              ],
            ),
            if (_status.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _status,
                  style: TextStyle(color: t.fg2, fontSize: 13),
                ),
              ),
            const SizedBox(height: 14),
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c)),
          ],
        ),
      ),
    );
  }

  Widget _btn(
    SuperThemeData t,
    IconData icon,
    String label,
    VoidCallback? onTap, {
    bool filled = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    if (filled) {
      return FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: t.fg1,
        side: BorderSide(color: t.borderStrong),
      ),
    );
  }

  static const List<Map<String, dynamic>> _seed = [
    {
      'code': '1000',
      'name': 'Cash on hand',
      'type': 'Asset',
      'region': 'HQ',
      'debit': 82400.0,
      'credit': 12100.0,
      'status': 'Open',
      'updated': '2026-07-01',
    },
    {
      'code': '1100',
      'name': 'Accounts receivable',
      'type': 'Asset',
      'region': 'HQ',
      'debit': 45120.0,
      'credit': 8000.0,
      'status': 'Open',
      'updated': '2026-07-03',
    },
    {
      'code': '2000',
      'name': 'Accounts payable',
      'type': 'Liability',
      'region': 'HQ',
      'debit': 6400.0,
      'credit': 39800.0,
      'status': 'Locked',
      'updated': '2026-06-28',
    },
    {
      'code': '3000',
      'name': 'Share capital',
      'type': 'Equity',
      'region': 'HQ',
      'debit': 0.0,
      'credit': 200000.0,
      'status': 'Locked',
      'updated': '2026-01-01',
    },
    {
      'code': '4000',
      'name': 'Product revenue',
      'type': 'Revenue',
      'region': 'West',
      'debit': 1200.0,
      'credit': 118400.0,
      'status': 'Open',
      'updated': '2026-07-04',
    },
    {
      'code': '5000',
      'name': 'Cost of goods sold',
      'type': 'Expense',
      'region': 'West',
      'debit': 64300.0,
      'credit': 900.0,
      'status': 'Open',
      'updated': '2026-07-04',
    },
    {
      'code': '6000',
      'name': 'Salaries & wages',
      'type': 'Expense',
      'region': 'HQ',
      'debit': 51200.0,
      'credit': 0.0,
      'status': 'Open',
      'updated': '2026-07-02',
    },
    {
      'code': '6100',
      'name': 'Office rent',
      'type': 'Expense',
      'region': 'East',
      'debit': 14400.0,
      'credit': 0.0,
      'status': 'Locked',
      'updated': '2026-06-30',
    },
  ];
}
