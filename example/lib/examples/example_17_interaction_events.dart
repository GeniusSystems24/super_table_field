// ============================================================
// example/lib/examples/example_17_interaction_events.dart
// ------------------------------------------------------------
// EXAMPLE 17 — Interaction events (2.2.0).
//
// Wires `SuperTable(interactions: SuperInteractions(...))` on a readable sales
// grid to drive the surrounding screen WITHOUT changing the grid's own
// behaviour:
//   • onRowActivate  — double-click a row (or select it and press Enter) opens
//                      an order-detail card. The canonical "open record" hook.
//   • onCellTap / onCellSecondaryTap — appended to a live event log.
//   • onSelectionChanged — a status line mirrors the cursor + numeric stats.
//   • onSortChanged  — logged whenever the sort column / direction changes
//                      (works for header clicks AND the programmatic button).
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class InteractionEventsExample extends StatefulWidget {
  const InteractionEventsExample({super.key});
  @override
  State<InteractionEventsExample> createState() =>
      _InteractionEventsExampleState();
}

class _InteractionEventsExampleState extends State<InteractionEventsExample> {
  late final SuperTableController<Map<String, dynamic>> _c;
  final List<String> _log = [];
  Map<String, dynamic>? _openOrder;
  String _selection = 'Nothing selected';

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.readable,
      selectionMode: SuperSelectionMode.multiCells,
      columns: [
        SuperTextColumn(key: 'no', label: 'Order #', width: 120, mono: true),
        SuperTextColumn(key: 'customer', label: 'Customer', width: 210),
        SuperEnumerationColumn<String>(
          key: 'status',
          label: 'Status',
          width: 130,
          values: const ['Paid', 'Pending', 'Overdue'],
          tones: {
            'Paid': const Color(0xFF1DB88A),
            'Pending': const Color(0xFFF97316),
            'Overdue': const Color(0xFFEF4444)
          },
        ),
        SuperTextColumn(key: 'region', label: 'Region', width: 130),
        SuperCurrencyColumn(
            key: 'total', label: 'Total', width: 130, agg: SuperAgg.sum),
        SuperDateColumn(key: 'due', label: 'Due', width: 130),
      ],
      rows: [
        SuperRow.map({
          'no': 'SO-4401',
          'customer': 'Najd Trading Co.',
          'status': 'Paid',
          'region': 'Riyadh',
          'total': 12480.0,
          'due': '2026-07-12'
        }),
        SuperRow.map({
          'no': 'SO-4402',
          'customer': 'Gulf Steel LLC',
          'status': 'Pending',
          'region': 'Dammam',
          'total': 8640.0,
          'due': '2026-07-18'
        }),
        SuperRow.map({
          'no': 'SO-4403',
          'customer': 'Hijaz Foods',
          'status': 'Overdue',
          'region': 'Jeddah',
          'total': 3125.5,
          'due': '2026-06-30'
        }),
        SuperRow.map({
          'no': 'SO-4404',
          'customer': 'Asir Contractors',
          'status': 'Paid',
          'region': 'Abha',
          'total': 21990.0,
          'due': '2026-07-05'
        }),
        SuperRow.map({
          'no': 'SO-4405',
          'customer': 'Tabuk Logistics',
          'status': 'Pending',
          'region': 'Tabuk',
          'total': 5410.0,
          'due': '2026-07-22'
        }),
        SuperRow.map({
          'no': 'SO-4406',
          'customer': 'Qassim Mills',
          'status': 'Paid',
          'region': 'Buraydah',
          'total': 9075.0,
          'due': '2026-07-15'
        }),
      ],
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _push(String s) {
    setState(() {
      _log.insert(0, s);
      if (_log.length > 9) _log.removeLast();
    });
  }

  String _money(num v) => '\$${v.toStringAsFixed(2)}';
  String _fmt(Object? v) => v == null ? '—' : (v is num ? _money(v) : '$v');

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
          title: const Text('Interaction events'), backgroundColor: t.surface),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Double-click a row (or select + Enter) to open it. Click cells, right-click, drag a '
                'range, or sort a column — every gesture flows through SuperInteractions into the '
                'panel on the right. The grid still behaves exactly as normal.',
                style: TextStyle(color: t.fg3),
              ),
            ),
            Row(children: [
              OutlinedButton.icon(
                onPressed: () => _c.sortBy(_c.colByKey('total')!, false),
                icon: const Icon(Icons.sort_rounded, size: 16),
                label: const Text('Sort by total ↓ (programmatic)'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: t.fg1,
                    side: BorderSide(color: t.borderStrong)),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () => _c.clearSort(),
                icon: const Icon(Icons.clear_rounded, size: 16),
                label: const Text('Clear sort'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: t.fg1,
                    side: BorderSide(color: t.borderStrong)),
              ),
              const Spacer(),
              Text(_selection,
                  style: TextStyle(
                      fontFamily: 'JetBrainsMono', fontSize: 12, color: t.fg1)),
            ]),
            const SizedBox(height: 14),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      flex: 3,
                      child: SuperTable<Map<String, dynamic>>(
                        controller: _c,
                        interactions: SuperInteractions<Map<String, dynamic>>(
                          onRowActivate: (d) => setState(() {
                            _openOrder = d.row.value;
                            _push('▸ activated ${d.row.value['no']} (double-click / Enter)');
                          }),
                          onCellTap: (d) => _push('tap · ${d.column.label} · ${_fmt(d.value)}'),
                          onCellSecondaryTap: (d) => _push('right-click · ${d.column.label}'),
                          onSortChanged: (s) => _push(s.isSorted ? 'sort · ${s.columnLabel} ${s.ascending ? '↑' : '↓'}' : 'sort · cleared'),
                          onSelectionChanged: (sel) => setState(() {
                            final stats = sel.stats;
                            _selection = stats != null && stats.hasAggregate
                                ? '${sel.cells.length} cells · Σ ${_money(stats.sum)} · avg ${_money(stats.average)}'
                                : 'Cursor ${sel.cursor.r + 1}×${sel.cursor.c + 1} · ${sel.cells.length} cell${sel.cells.length == 1 ? '' : 's'}';
                          }),
                        ),
                      )),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _sidePanel(t)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidePanel(SuperThemeData t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_openOrder != null) ...[
          _DetailCard(
              order: _openOrder!,
              onClose: () => setState(() => _openOrder = null)),
          const SizedBox(height: 14),
        ],
        Text('EVENT LOG',
            style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                color: t.fg4)),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: t.surface,
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _log.isEmpty
                ? Center(
                    child: Text('Interact with the grid…',
                        style: TextStyle(color: t.fg4, fontSize: 12.5)))
                : ListView(
                    children: [
                      for (final e in _log)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(e,
                              style: TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  fontSize: 12,
                                  color: t.fg2)),
                        ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onClose;
  const _DetailCard({required this.order, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    Widget row(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            SizedBox(
                width: 84,
                child: Text(k, style: TextStyle(fontSize: 11.5, color: t.fg4))),
            Expanded(
                child: Text(v,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: t.fg1))),
          ]),
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(t.fg1.withOpacity(0.06), t.surface),
        border: Border.all(color: t.fg1.withOpacity(0.35)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.receipt_long_rounded, size: 16, color: t.fg1),
            const SizedBox(width: 8),
            Expanded(
                child: Text('Order ${order['no']}',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: t.fg1))),
            GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close_rounded, size: 16, color: t.fg3)),
          ]),
          const SizedBox(height: 10),
          row('Customer', '${order['customer']}'),
          row('Status', '${order['status']}'),
          row('Region', '${order['region']}'),
          row('Total', '\$${(order['total'] as num).toStringAsFixed(2)}'),
          row('Due', '${order['due']}'),
        ],
      ),
    );
  }
}
