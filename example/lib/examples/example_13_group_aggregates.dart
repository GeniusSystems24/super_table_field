// ============================================================
// example/lib/examples/example_13_group_aggregates.dart
// ------------------------------------------------------------
// EXAMPLE 13 - Programmatic group aggregation + hidden columns.
//
// Demonstrates two 1.1.0 capabilities working together:
//
// 1. Hidden columns: `region` and `supplier` are declared with `hidden: true`.
//    They never render as grid columns, but remain usable for filtering,
//    grouping, and aggregation by key.
//
// 2. Programmatic group aggregation: the rollup panel is built from
//    `controller.groupAggregates(...)`, `aggregateBy(...)`, and
//    `grandTotals(...)`. It is independent of rendered group headers and
//    automatically follows the current grid filter.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

class GroupAggregatesExample extends StatefulWidget {
  const GroupAggregatesExample({super.key});

  @override
  State<GroupAggregatesExample> createState() => _GroupAggregatesExampleState();
}

class _GroupAggregatesExampleState extends State<GroupAggregatesExample> {
  late final SuperTableController<Map<String, dynamic>> _c;
  String? _activeRegion;

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<Map<String, dynamic>>(
      mode: SuperTableMode.readable,
      selectionMode: SuperSelectionMode.singleRow,
      columns: [
        SuperTextColumn(key: 'sku', label: 'SKU', width: 130, mono: true),
        SuperEnumerationColumn<String>(
          key: 'category',
          label: 'Category',
          width: 150,
          values: const ['Raw Material', 'Finished Good', 'Consumable'],
        ),
        SuperNumberColumn<int>(
          key: 'qty',
          label: 'Qty',
          width: 100,
          agg: SuperAgg.sum,
          formatter: (value, row) => '${(value as num?)?.toInt() ?? 0} u',
        ),
        SuperCurrencyColumn(
          key: 'value',
          label: 'Stock Value',
          width: 150,
          agg: SuperAgg.sum,
        ),
        SuperTextColumn(key: 'region', label: 'Region', hidden: true),
        SuperTextColumn(key: 'supplier', label: 'Supplier', hidden: true),
      ],
      rows: [
        SuperRow.map({
          'sku': 'RM-STEEL-01',
          'category': 'Raw Material',
          'qty': 400,
          'value': 1360.0,
          'region': 'North',
          'supplier': 'Atlas',
        }),
        SuperRow.map({
          'sku': 'RM-RESIN-04',
          'category': 'Raw Material',
          'qty': 220,
          'value': 902.0,
          'region': 'North',
          'supplier': 'Polymerix',
        }),
        SuperRow.map({
          'sku': 'FG-BRKT-10',
          'category': 'Finished Good',
          'qty': 60,
          'value': 768.0,
          'region': 'North',
          'supplier': 'Atlas',
        }),
        SuperRow.map({
          'sku': 'FG-BRKT-20',
          'category': 'Finished Good',
          'qty': 35,
          'value': 542.5,
          'region': 'South',
          'supplier': 'Atlas',
        }),
        SuperRow.map({
          'sku': 'CN-GLOVE-09',
          'category': 'Consumable',
          'qty': 800,
          'value': 360.0,
          'region': 'South',
          'supplier': 'SafeCo',
        }),
        SuperRow.map({
          'sku': 'CN-TAPE-04',
          'category': 'Consumable',
          'qty': 220,
          'value': 242.0,
          'region': 'South',
          'supplier': 'SafeCo',
        }),
        SuperRow.map({
          'sku': 'RM-ALU-02',
          'category': 'Raw Material',
          'qty': 150,
          'value': 1125.0,
          'region': 'East',
          'supplier': 'Polymerix',
        }),
        SuperRow.map({
          'sku': 'FG-PANEL-30',
          'category': 'Finished Good',
          'qty': 48,
          'value': 1392.0,
          'region': 'East',
          'supplier': 'Atlas',
        }),
      ],
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _filterRegion(String? region) {
    setState(() => _activeRegion = region);
    _c.setColumnFilter('region', region ?? '');
  }

  String _money(num? value) {
    final amount = (value ?? 0).toDouble();
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts.first;
    final buffer = StringBuffer();

    for (var i = 0; i < whole.length; i++) {
      if (i > 0 && (whole.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(whole[i]);
    }

    return '\$${buffer.toString()}.${parts.last}';
  }

  String _count(num? value) => ((value ?? 0).round()).toString();

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: const Text('Group Aggregates - Hidden Columns'),
        backgroundColor: t.surface,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 920;
          final padding = compact ? 16.0 : 24.0;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _intro(t),
                const SizedBox(height: 14),
                AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) => _stats(t),
                ),
                const SizedBox(height: 14),
                _regionChips(t),
                const SizedBox(height: 16),
                Expanded(child: _workspace(t, compact)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _intro(SuperThemeData t) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.visibility_off_outlined,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Region and Supplier are hidden columns. The grid never renders '
              'them, but the chips filter by Region and the rollup groups by '
              'Region then Category through the controller API.',
              style: TextStyle(color: t.fg3, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stats(SuperThemeData t) {
    final regions = _c.groupAggregates(
      groupBy: const ['region'],
      aggregateColumns: const ['qty', 'value'],
    );
    final totals = _c.grandTotals(columns: const ['qty', 'value']);
    final rowCount = regions.fold<int>(0, (sum, group) => sum + group.count);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _metric(t, 'Visible rows', '$rowCount', Icons.table_rows_outlined),
        _metric(
            t, 'Visible regions', '${regions.length}', Icons.public_outlined),
        _metric(
            t, 'Total qty', _count(totals['qty']), Icons.inventory_2_outlined),
        _metric(t, 'Stock value', _money(totals['value']), Icons.paid_outlined),
      ],
    );
  }

  Widget _metric(SuperThemeData t, String label, String value, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.fg4,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.fg1,
                    fontSize: 15,
                    fontFamily: SuperTokensData.defaultMonoFont,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _regionChips(SuperThemeData t) {
    final regions = _c
        .aggregateBy('region', 'value', filtered: false)
        .keys
        .toList()
      ..sort();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _chip(t, 'All regions', null),
        for (final region in regions) _chip(t, region, region),
      ],
    );
  }

  Widget _chip(SuperThemeData t, String label, String? region) {
    final active = _activeRegion == region;
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => _filterRegion(region),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? cs.primary : t.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? cs.primary : t.borderStrong,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : t.fg2,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _workspace(SuperThemeData t, bool compact) {
    if (compact) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 420,
              child: SuperTable<Map<String, dynamic>>(controller: _c),
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _c,
              builder: (context, _) => _rollupPanel(t),
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 5,
          child: SuperTable<Map<String, dynamic>>(controller: _c),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 390,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => _rollupPanel(t),
          ),
        ),
      ],
    );
  }

  Widget _rollupPanel(SuperThemeData t) {
    final tree = _c.groupAggregates(
      groupBy: const ['region', 'category'],
      aggregateColumns: const ['qty', 'value'],
    );
    final totals = _c.grandTotals(columns: const ['qty', 'value']);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border),
        boxShadow: t.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 30,
                decoration: BoxDecoration(
                  color: SuperTokensData.defaultSuccess,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROGRAMMATIC ROLLUP',
                      style: TextStyle(
                        color: t.fg2,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'groupAggregates(region / category)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: t.fg4, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (tree.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No rows match the current filter.',
                  style: TextStyle(color: t.fg4)),
            )
          else
            for (final region in tree) ...[
              _rollupRow(
                t,
                label: region.value,
                count: region.count,
                qty: region.aggregate('qty'),
                value: region.aggregate('value'),
                bold: true,
              ),
              for (final category in region.children)
                _rollupRow(
                  t,
                  label: category.value,
                  count: category.count,
                  qty: category.aggregate('qty'),
                  value: category.aggregate('value'),
                  indent: true,
                ),
            ],
          Divider(color: t.borderStrong, height: 28),
          _rollupRow(
            t,
            label: 'Grand total',
            count: null,
            qty: totals['qty'],
            value: totals['value'],
            bold: true,
            accent: true,
          ),
        ],
      ),
    );
  }

  Widget _rollupRow(
    SuperThemeData t, {
    required String label,
    required int? count,
    required num? qty,
    required num? value,
    bool bold = false,
    bool indent = false,
    bool accent = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final color = accent ? cs.primary : (bold ? t.fg1 : t.fg2);
    final weight = bold ? FontWeight.w700 : FontWeight.w400;

    return Padding(
      padding:
          EdgeInsetsDirectional.only(start: indent ? 18 : 0, top: 5, bottom: 5),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                if (indent)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: Icon(
                      Icons.subdirectory_arrow_right_rounded,
                      size: 14,
                      color: t.fg4,
                    ),
                  ),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontWeight: weight,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: t.fg4,
                      fontSize: 11,
                      fontFamily: SuperTokensData.defaultMonoFont,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _count(qty),
              textAlign: TextAlign.end,
              style: TextStyle(
                color: color,
                fontWeight: weight,
                fontSize: 13,
                fontFamily: SuperTokensData.defaultMonoFont,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money(value),
              textAlign: TextAlign.end,
              style: TextStyle(
                color: color,
                fontWeight: weight,
                fontSize: 13,
                fontFamily: SuperTokensData.defaultMonoFont,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
