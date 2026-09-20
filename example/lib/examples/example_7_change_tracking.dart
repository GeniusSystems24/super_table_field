// ============================================================
// example/lib/examples/example_7_change_tracking.dart
// ------------------------------------------------------------
// EXAMPLE 7 — Change tracking (the ERP save-delta surface).
//
// Demonstrates: `SuperTableController(trackChanges: true)`, the per-cell dirty
// marker (accent corner), `controller.changes` (added / modified / deleted),
// and the Save / Revert pair (`acceptChanges` / `rejectChanges`).
//
// Edit a price, add a row (Tab past the last cell), delete a row — then watch
// the changeset panel update and post only the delta on Save.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';
import 'package:super_core/super_core.dart';
import 'package:super_table_field_example/localizations/example_l10n.dart';

class ChangeTrackingExample extends StatefulWidget {
  const ChangeTrackingExample({super.key});
  @override
  State<ChangeTrackingExample> createState() => _ChangeTrackingExampleState();
}

class _ChangeTrackingExampleState extends State<ChangeTrackingExample> {
  late final SuperTableController<Map<String, dynamic>> _c;

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.editable,
      addRowEnabled: true,
      trackChanges: true, // ← capture a per-cell baseline
      emptyRowValue: () => <String, dynamic>{
        'sku': '',
        'name': '',
        'qty': 0,
        'price': 0.0,
      },
      columns: [
        SuperTextColumn(
          key: 'sku',
          label: ExampleL10n.current.sKU,
          width: 140,
          mono: true,
          required: true,
        ),
        SuperTextColumn(key: 'name', label: ExampleL10n.current.product, width: 220),
        SuperNumberColumn<int>(
          key: 'qty',
          label: ExampleL10n.current.onHand41733d,
          width: 110,
          min: 0,
          agg: SuperAgg.sum,
        ),
        SuperCurrencyColumn(
          key: 'price',
          label: ExampleL10n.current.unitPrice,
          width: 140,
          agg: SuperAgg.sum,
        ),
      ],
      rows: [
        SuperRow.map({
          'sku': 'INV-SB-200',
          'name': 'Steel bracket',
          'qty': 120,
          'price': 3.40,
        }),
        SuperRow.map({
          'sku': 'INV-CM-050',
          'name': 'Cement bag 50kg',
          'qty': 38,
          'price': 18.50,
        }),
        SuperRow.map({
          'sku': 'INV-PV-110',
          'name': 'PVC pipe 110mm',
          'qty': 64,
          'price': 9.20,
        }),
      ],
      onChange: (_) => setState(() {}),
    );
    _c.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _save() {
    final delta = _c.changes;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(ExampleL10n.current.pOSTDeltaTo(delta.toString()))));
    _c.acceptChanges(); // re-baseline: the grid is now clean
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final delta = _c.changes;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: Text(ExampleL10n.current.changeTracking),
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
                ExampleL10n.current.editACellTabPastTheLastCellToAddARowOrRightClickToDeleteDirtyCel9f2a32d,
                style: TextStyle(color: t.fg3),
              ),
            ),
            Flexible(child: SuperTable<Map<String, dynamic>>(controller: _c)),
            const SizedBox(height: 16),
            _ChangePanel(delta: delta),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _c.hasChanges
                      ? ExampleL10n.current.unsavedChanges(delta.count)
                      : ExampleL10n.current.noChanges,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _c.hasChanges ? const Color(0xFFE0A23B) : t.fg3,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _c.hasChanges ? _c.rejectChanges : null,
                  icon: const Icon(Icons.undo_rounded, size: 16),
                  label: Text(ExampleL10n.current.revert),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: t.fg1,
                    side: BorderSide(color: t.borderStrong),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _c.hasChanges ? _save : null,
                  icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                  label: Text(ExampleL10n.current.saveChanges),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePanel extends StatelessWidget {
  const _ChangePanel({required this.delta});
  final SuperChangeSet<Map<String, dynamic>> delta;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    Widget chip(String label, int n, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withValues(alpha: 0.14), t.surface),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$n',
            style: TextStyle(
              fontFamily: context.superTextTheme.mono.fontFamily,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: t.fg2)),
        ],
      ),
    );
    return Row(
      children: [
        chip(ExampleL10n.current.added, delta.added.length, const Color(0xFF1DB88A)),
        const SizedBox(width: 10),
        chip(ExampleL10n.current.modified, delta.modified.length, const Color(0xFFE0A23B)),
        const SizedBox(width: 10),
        chip(ExampleL10n.current.deleted, delta.deleted.length, const Color(0xFFEF4444)),
      ],
    );
  }
}
