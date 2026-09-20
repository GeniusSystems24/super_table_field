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
import 'package:super_core/super_core.dart';
import 'package:super_table_field_example/localizations/generated/l10n.dart';
class ValidationViewsExample extends StatefulWidget {
  const ValidationViewsExample({super.key});
  @override
  State<ValidationViewsExample> createState() => _ValidationViewsExampleState();
}

class _ValidationViewsExampleState extends State<ValidationViewsExample> {
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
      mode: SuperTableMode.editable,
      selectionMode: SuperSelectionMode.multiCells,
      addRowEnabled: true,
      trackChanges: true,
      emptyRowValue: () => <String, dynamic>{
        'sku': '',
        'name': '',
        'qty': 0,
        'cost': 0.0,
      },
      columns: [
        SuperTextColumn(
          key: 'sku',
          label: SuperTableExampleLocalization.of(context).sKU,
          width: 130,
          required: true,
          unique: true,
          mono: true,
        ),
        SuperTextColumn(
          key: 'name',
          label: SuperTableExampleLocalization.of(context).itemName,
          width: 240,
          required: true,
        ),
        SuperNumberColumn<int>(
          key: 'qty',
          label: SuperTableExampleLocalization.of(context).onHand,
          width: 110,
          min: 0,
        ),
        SuperCurrencyColumn(
          key: 'cost',
          label: SuperTableExampleLocalization.of(context).unitCostb16e07,
          width: 130,
          agg: SuperAgg.sum,
        ),
      ],
      rows: [
        SuperRow.map({
          'sku': 'FLT-0001',
          'name': 'Hydraulic filter',
          'qty': 42,
          'cost': 18.50,
        }),
        SuperRow.map({
          'sku': 'FLT-0002',
          'name': 'Air filter element',
          'qty': 17,
          'cost': 9.75,
        }),
        SuperRow.map({
          'sku': 'BRG-0114',
          'name': 'Roller bearing 35mm',
          'qty': 8,
          'cost': 64.00,
        }),
        SuperRow.map({
          'sku': '',
          'name': 'Gasket kit — unlabelled',
          'qty': 3,
          'cost': 22.10,
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

  void _validate() => showSuperValidationPanel(context, _c);

  void _post() {
    if (!_c.isValid) {
      _c.validateAll(); // light the badges
      setState(
        () => _status = SuperTableExampleLocalization.of(context).cannotPostFixTheValidationIssuesFirst,
      );
      showSuperValidationPanel(context, _c);
      return;
    }
    _c.acceptChanges();
    setState(
      () => _status = SuperTableExampleLocalization.of(context).postedBaselineCapturedCellsAreCleanAgain,
    );
  }

  void _saveView() {
    _savedView = jsonEncode(_c.viewStateJson());
    setState(
      () => _status = SuperTableExampleLocalization.of(context).viewSavedCharsOfJSON(_savedView!.length),
    );
  }

  void _restoreView() {
    if (_savedView == null) return;
    _c.applyViewJson(jsonDecode(_savedView!) as Map<String, dynamic>);
    setState(
      () =>
          _status = SuperTableExampleLocalization.of(context).viewRestoredOrderWidthsSortAndFiltersAreBack,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: Text(SuperTableExampleLocalization.of(context).validationSummarySavedViews),
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
                SuperTableExampleLocalization.of(context).sKUIsRequiredANDUniqueTryDuplicatingOneOrLeaveItBlankThenHitVali3f35562,
                style: TextStyle(color: t.fg3),
              ),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _validate,
                  icon: const Icon(Icons.rule_rounded, size: 16),
                  label: Text(SuperTableExampleLocalization.of(context).validate),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.fg1,
                    side: BorderSide(color: t.borderStrong),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _post,
                  icon: const Icon(Icons.task_alt_rounded, size: 16),
                  label: Text(SuperTableExampleLocalization.of(context).post),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.fg1,
                    side: BorderSide(color: t.borderStrong),
                  ),
                ),
                const SizedBox(width: 24),
                OutlinedButton.icon(
                  onPressed: _saveView,
                  icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                  label: Text(SuperTableExampleLocalization.of(context).saveView),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.fg1,
                    side: BorderSide(color: t.borderStrong),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _savedView == null ? null : _restoreView,
                  icon: const Icon(Icons.bookmark_outlined, size: 16),
                  label: Text(SuperTableExampleLocalization.of(context).restoreView),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.fg1,
                    side: BorderSide(color: t.borderStrong),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _c.resetViewState(),
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: Text(SuperTableExampleLocalization.of(context).resetView),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.fg1,
                    side: BorderSide(color: t.borderStrong),
                  ),
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
            const SizedBox(height: 12),
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c)),
          ],
        ),
      ),
    );
  }
}
