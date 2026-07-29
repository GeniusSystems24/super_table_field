// ============================================================
// example/lib/examples/example_19_showcase.dart
// ------------------------------------------------------------
// EXAMPLE 19 - Showcase: one end-to-end ERP inventory grid that demonstrates
// every shipped column type and the common host integrations:
//
//   text, custom, enum, number, combo, currency, computed, progress, color,
//   date, time, link, checkbox, readonly, and a hidden grouping field.
//
// Also demonstrates editable/readable mode, column manager, grouping, totals,
// column filters, saved views, validation, change tracking, row actions,
// fill down/right, row activation, selection stats, and sort/cell callbacks.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:super_table_field/super_table_field.dart';

typedef _Row = Map<String, dynamic>;

class ShowcaseExample extends StatefulWidget {
  const ShowcaseExample({super.key});

  @override
  State<ShowcaseExample> createState() => _ShowcaseExampleState();
}

class _ShowcaseExampleState extends State<ShowcaseExample> {
  static const _categories = [
    'Electronics',
    'Apparel',
    'Grocery',
    'Hardware',
    'Stationery',
  ];
  static const _statuses = [
    'In Stock',
    'Low Stock',
    'Out of Stock',
    'Reorder',
    'Discontinued',
  ];
  static const _warehouses = ['WH-Riyadh', 'WH-Jeddah', 'WH-Dammam'];
  static const _recvTimes = ['08:00', '09:30', '11:00', '13:30', '15:00'];
  static const _tagColors = [
    '#4A7CFF',
    '#1DB88A',
    '#E0A23B',
    '#8B5CF6',
    '#EF4444',
    '#06B6D4',
  ];

  late final SuperTableController<_Row> _c;
  bool _grouped = false;
  bool _totals = true;
  bool _filters = true;
  Map<String, dynamic>? _savedView;
  String _status = 'Ready';

  static final List<SuperColumn> _columns = [
    SuperTextColumn(
      key: 'sku',
      label: 'SKU',
      width: 118,
      mono: true,
      required: true,
      unique: true,
      pin: SuperPin.left,
    ),
    SuperTextColumn(
      key: 'name',
      label: 'Product',
      width: 226,
      required: true,
      arKey: 'nameAr',
    ),
    SuperColumn<String>(
      key: 'lot',
      label: 'Lot / Serial',
      width: 132,
      mono: true,
      formatter: (value, row) {
        final text = '$value'.trim();
        return text.isEmpty ? '' : 'Lot $text';
      },
      validator: (context, controller, row, cell, value) =>
          value.trim().isEmpty ? 'Lot is required' : null,
    ),
    SuperTextColumn(
      key: 'warehouse',
      label: 'Warehouse',
      hidden: true,
      groupable: true,
      filterable: true,
    ),
    SuperEnumerationColumn<String>(
      key: 'category',
      label: 'Category',
      width: 136,
      values: _categories,
      onChange: (context, controller, row, cell, previous, next) {
        if (previous == next) return true;
        final units = _unitsFor(next);
        row['uom'] = units.first;
        row['status'] = 'Reorder';
        row.randomFingerPrint();
        return true;
      },
    ),
    SuperEnumerationColumn<String>(
      key: 'status',
      label: 'Status',
      width: 140,
      values: _statuses,
      dot: true,
      tones: const {
        'In Stock': Color(0xFF1DB88A),
        'Low Stock': Color(0xFFE0A23B),
        'Out of Stock': Color(0xFFEF4444),
        'Reorder': Color(0xFF06B6D4),
        'Discontinued': Color(0xFF6B7280),
      },
    ),
    SuperNumberColumn<int>(
      key: 'qty',
      label: 'Qty',
      width: 92,
      min: 0,
      max: 99999,
      agg: SuperAgg.sum,
      validator: (context, controller, row, cell, value) =>
          value < 0 ? 'Qty cannot be negative' : null,
    ),
    SuperNumberColumn<num>(
      key: 'discount',
      label: 'Disc %',
      width: 96,
      min: 0,
      max: 60,
      decimals: 0,
      suffix: '%',
      validator: (context, controller, row, cell, value) =>
          value > 40 ? 'Manager approval required' : null,
    ),
    SuperComboColumn<String>(
      key: 'uom',
      label: 'Unit',
      width: 104,
      mono: true,
      clearButton: true,
      hintText: 'Pick unit',
      sourceController: (context, controller, row, cell) {
        final units = _unitsFor(row['category']);
        return SuggestionSources.list<String>([
          for (final unit in units) AutoSuggestion(value: unit, label: unit),
        ]);
      },
    ),
    SuperCurrencyColumn(
      key: 'cost',
      label: 'Unit Cost',
      width: 126,
      symbol: r'$',
      agg: SuperAgg.avg,
      aggLabel: 'AVG',
      min: 0,
    ),
    SuperComputedColumn<num>(
      key: 'netValue',
      label: 'Net Value',
      width: 138,
      align: SuperAlign.end,
      agg: SuperAgg.sum,
      compute: _netValue,
      format: (value, row) => '\$${(value as num).toStringAsFixed(2)}',
    ),
    SuperProgressColumn<num>(
      key: 'level',
      label: 'Stock Level',
      width: 150,
      max: 1,
      agg: SuperAgg.avg,
    ),
    SuperColorColumn<String>(
      key: 'tag',
      label: 'Tag',
      width: 118,
      filterItems: const [
        FilterItem('Blue', '#4A7CFF'),
        FilterItem('Green', '#1DB88A'),
        FilterItem('Amber', '#E0A23B'),
        FilterItem('Purple', '#8B5CF6'),
        FilterItem('Red', '#EF4444'),
        FilterItem('Cyan', '#06B6D4'),
      ],
    ),
    SuperDateColumn(
      key: 'updated',
      label: 'Updated',
      width: 130,
      required: true,
      validator: (context, controller, row, cell, value) =>
          RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)
          ? null
          : 'Use YYYY-MM-DD',
    ),
    SuperTimeColumn(
      key: 'received',
      label: 'Received',
      width: 116,
      required: true,
    ),
    SuperLinkColumn(
      key: 'vendorUrl',
      label: 'Vendor URL',
      width: 220,
      onOpen: (value, row) {
        debugPrint('Open vendor URL: $value');
      },
    ),
    SuperCheckboxColumn(
      key: 'active',
      label: 'Active',
      width: 82,
      onChange: (context, controller, row, cell, previous, next) {
        if (!next) row['status'] = 'Discontinued';
        return true;
      },
    ),
    SuperReadonlyColumn(
      key: 'ref',
      label: 'Ref',
      width: 118,
      mono: true,
      pin: SuperPin.right,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _c = SuperTableController<_Row>(
      mode: SuperTableMode.readable,
      selectionMode: SuperSelectionMode.multiCells,
      pagination: SuperPagination.pages,
      pageSize: 8,
      addRowEnabled: true,
      trackChanges: true,
      emptyRowValue: _emptyRow,
      cellEditable: (column, row) =>
          row['status'] != 'Discontinued' ||
          column.key == 'status' ||
          column.key == 'active',
      onNotify: (kind, message) => _setStatus(message),
      columns: _columns,
      rows: [
        for (final row in _seedRows)
          SuperRow.map(Map<String, dynamic>.from(row)),
      ],
    );
    _c.addListener(_sync);
  }

  @override
  void dispose() {
    _c.removeListener(_sync);
    _c.dispose();
    super.dispose();
  }

  void _sync() {
    if (mounted) setState(() {});
  }

  void _setStatus(String message) {
    if (!mounted) return;
    setState(() => _status = message);
  }

  void _toggleGroup() {
    _grouped = !_grouped;
    _c.setGroupKeys(_grouped ? ['warehouse', 'category'] : const []);
    _setStatus(
      _grouped ? 'Grouped by warehouse and category.' : 'Grouping cleared.',
    );
  }

  Future<void> _copyCsv() async {
    await Clipboard.setData(ClipboardData(text: _c.toCsv()));
    _setStatus('Copied ${_c.sortedRows.length} rows as CSV.');
  }

  void _validate() {
    showSuperValidationPanel(context, _c);
    _setStatus(
      _c.isValid ? 'All rows valid.' : '${_c.errorCount} validation issue(s).',
    );
  }

  void _saveView() {
    _savedView = _c.viewStateJson();
    _setStatus('View state saved in memory.');
  }

  void _restoreView() {
    final saved = _savedView;
    if (saved == null) {
      _setStatus('No saved view yet.');
      return;
    }
    _c.applyViewJson(saved);
    _grouped = _c.grouped;
    _setStatus('Saved view restored.');
  }

  void _resetView() {
    _c.resetViewState();
    _grouped = false;
    _setStatus('View state reset.');
  }

  void _addRow() {
    _c.addRow();
    _c.setMode(SuperTableMode.editable);
    _setStatus('New editable row added.');
  }

  void _moveUp() {
    _c.moveRowUp();
    _setStatus('Focused row moved up.');
  }

  void _moveDown() {
    _c.moveRowDown();
    _setStatus('Focused row moved down.');
  }

  void _fillDown() {
    _c.fillDown();
    _setStatus('Fill down applied to the current selection.');
  }

  void _fillRight() {
    _c.fillRight();
    _setStatus('Fill right applied to the current selection.');
  }

  void _rejectChanges() {
    _c.rejectChanges();
    _setStatus('Changes rejected.');
  }

  void _acceptChanges() {
    _c.acceptChanges();
    _setStatus('Changes accepted.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = SuperMaterialThemeData.of(context);
    final t = theme.superTheme;
    final editable = _c.mode == SuperTableMode.editable;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: const Text('Showcase - all column types'),
        backgroundColor: t.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _toolbar(theme, editable),
            const SizedBox(height: 8),
            _statusLine(theme, editable),
            const SizedBox(height: 12),
            Expanded(
              child: SuperTable<_Row>(
                controller: _c,
                showTotals: _totals,
                columnFilters: _filters,
                groupFooters: true,
                skeletonRows: 5,
                interactions: SuperInteractions<_Row>(
                  onRowActivate: (details) {
                    final row = details.row.value;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('Open ${row['sku']} - ${row['name']}'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  },
                  onCellDoubleTap: (details) => _setStatus(
                    'Double tap ${details.column.label}: ${details.value ?? ''}',
                  ),
                  onCellSecondaryTap: (details) =>
                      _setStatus('Context menu on ${details.column.label}.'),
                  onSelectionChanged: (selection) {
                    final stats = selection.stats;
                    if (stats != null && stats.hasAggregate) {
                      _setStatus(
                        '${selection.cells.length} cells selected - sum ${stats.sum.toStringAsFixed(2)} - avg ${stats.average.toStringAsFixed(2)}',
                      );
                    } else {
                      _setStatus(
                        'Cursor row ${selection.cursor.r + 1}, column ${selection.cursor.c + 1}.',
                      );
                    }
                  },
                  onSortChanged: (sort) => _setStatus(
                    sort.isSorted
                        ? 'Sorted ${sort.columnLabel} ${sort.ascending ? 'asc' : 'desc'}.'
                        : 'Sort cleared.',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar(SuperMaterialThemeData theme, bool editable) {
    final t = theme.superTheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _btn(
          theme,
          editable ? Icons.visibility_rounded : Icons.edit_rounded,
          editable ? 'Readable' : 'Editable',
          _c.toggleMode,
          filled: true,
        ),
        _btn(
          theme,
          Icons.view_column_rounded,
          'Columns',
          () => showSuperColumnManager(context, _c),
        ),
        _btn(
          theme,
          _grouped ? Icons.layers_clear_rounded : Icons.layers_rounded,
          _grouped ? 'Ungroup' : 'Group',
          _toggleGroup,
        ),
        _chip(theme, 'Totals', Icons.functions_rounded, _totals, () {
          setState(() => _totals = !_totals);
        }),
        _chip(theme, 'Filters', Icons.filter_alt_outlined, _filters, () {
          setState(() => _filters = !_filters);
        }),
        _btn(theme, Icons.add_rounded, 'Add row', _addRow),
        _btn(theme, Icons.keyboard_arrow_up_rounded, 'Move up', _moveUp),
        _btn(theme, Icons.keyboard_arrow_down_rounded, 'Move down', _moveDown),
        _btn(
          theme,
          Icons.south_rounded,
          'Fill down',
          editable ? _fillDown : null,
        ),
        _btn(
          theme,
          Icons.east_rounded,
          'Fill right',
          editable ? _fillRight : null,
        ),
        _btn(theme, Icons.file_download_outlined, 'Copy CSV', _copyCsv),
        _btn(theme, Icons.rule_rounded, 'Validate', _validate),
        _btn(theme, Icons.bookmark_add_outlined, 'Save view', _saveView),
        _btn(theme, Icons.restore_rounded, 'Restore view', _restoreView),
        _btn(theme, Icons.restart_alt_rounded, 'Reset view', _resetView),
        if (_c.hasChanges) ...[
          _btn(theme, Icons.save_rounded, 'Accept', _acceptChanges),
          _btn(theme, Icons.undo_rounded, 'Reject', _rejectChanges),
        ],
      ],
    );
  }

  Widget _statusLine(SuperMaterialThemeData theme, bool editable) {
    final t = theme.superTheme;
    final modeText = editable
        ? 'Editable: Enter opens/closes the editor; boolean cells toggle with Space while editing.'
        : 'Readable: Enter activates the row; Space does not edit display cells.';

    return Row(
      children: [
        Icon(
          editable ? Icons.edit_rounded : Icons.visibility_rounded,
          size: 15,
          color: t.fg3,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            modeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: t.fg3, fontSize: 12.5),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _status,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: t.tokens.monoFont,
            fontSize: 12,
            color: t.fg1,
          ),
        ),
      ],
    );
  }

  Widget _btn(
    SuperMaterialThemeData theme,
    IconData icon,
    String label,
    VoidCallback? onTap, {
    bool filled = false,
  }) {
    final t = theme.superTheme;
    if (filled) {
      return FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
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

  Widget _chip(
    SuperMaterialThemeData theme,
    String label,
    IconData icon,
    bool selected,
    VoidCallback onTap,
  ) {
    final t = theme.superTheme;
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? cs.primary.withValues(alpha: 0.10) : null,
        foregroundColor: selected ? cs.primary : t.fg1,
        side: BorderSide(color: selected ? cs.primary : t.borderStrong),
      ),
    );
  }

  static List<String> _unitsFor(Object? category) {
    return switch ('$category') {
      'Grocery' => const ['bag', 'btl', 'kg', 'box'],
      'Hardware' => const ['pcs', 'box', 'set'],
      'Stationery' => const ['pcs', 'box', 'pkg'],
      'Apparel' => const ['pcs', 'set'],
      _ => const ['pcs', 'box', 'set'],
    };
  }

  static num _netValue(SuperRow row) {
    final qty = row['qty'] is num ? row['qty'] as num : 0;
    final cost = row['cost'] is num ? row['cost'] as num : 0;
    final discount = row['discount'] is num ? row['discount'] as num : 0;
    return qty * cost * (1 - (discount / 100));
  }

  static _Row _emptyRow() => {
    'sku': '',
    'name': '',
    'nameAr': '',
    'lot': '',
    'warehouse': _warehouses.first,
    'category': _categories.first,
    'status': 'Reorder',
    'qty': 0,
    'discount': 0,
    'uom': _unitsFor(_categories.first).first,
    'cost': 0.0,
    'level': 0.0,
    'tag': _tagColors.first,
    'updated': '2026-07-29',
    'received': _recvTimes.first,
    'vendorUrl': 'https://example.com/vendors/new',
    'active': true,
    'ref': 'NEW-${DateTime.now().millisecondsSinceEpoch}',
  };

  static final List<_Row> _seedRows = [
    _row(
      sku: 'SKU-1001',
      name: 'Wireless Mouse',
      nameAr: 'Wireless mouse',
      lot: 'A01',
      warehouse: 'WH-Riyadh',
      category: 'Electronics',
      status: 'In Stock',
      qty: 320,
      discount: 5,
      uom: 'pcs',
      cost: 18.50,
      level: 0.72,
      tag: '#4A7CFF',
      updated: '2026-07-01',
      received: '08:00',
      active: true,
      ref: 'INV-1001',
    ),
    _row(
      sku: 'SKU-1002',
      name: 'USB-C Cable 2m',
      nameAr: 'USB-C cable',
      lot: 'A02',
      warehouse: 'WH-Riyadh',
      category: 'Electronics',
      status: 'Low Stock',
      qty: 54,
      discount: 0,
      uom: 'pcs',
      cost: 6.25,
      level: 0.18,
      tag: '#E0A23B',
      updated: '2026-07-02',
      received: '09:30',
      active: true,
      ref: 'INV-1002',
    ),
    _row(
      sku: 'SKU-1003',
      name: 'Cotton T-Shirt',
      nameAr: 'Cotton T-Shirt',
      lot: 'B11',
      warehouse: 'WH-Jeddah',
      category: 'Apparel',
      status: 'In Stock',
      qty: 880,
      discount: 12,
      uom: 'pcs',
      cost: 9.90,
      level: 0.91,
      tag: '#1DB88A',
      updated: '2026-07-03',
      received: '11:00',
      active: true,
      ref: 'INV-1003',
    ),
    _row(
      sku: 'SKU-1004',
      name: 'Olive Oil 1L',
      nameAr: 'Olive oil',
      lot: 'G20',
      warehouse: 'WH-Jeddah',
      category: 'Grocery',
      status: 'Out of Stock',
      qty: 0,
      discount: 0,
      uom: 'btl',
      cost: 14.00,
      level: 0.00,
      tag: '#EF4444',
      updated: '2026-07-04',
      received: '13:30',
      active: false,
      ref: 'INV-1004',
    ),
    _row(
      sku: 'SKU-1005',
      name: 'Steel Hex Bolts',
      nameAr: 'Steel bolts',
      lot: 'H08',
      warehouse: 'WH-Dammam',
      category: 'Hardware',
      status: 'In Stock',
      qty: 4200,
      discount: 18,
      uom: 'box',
      cost: 0.85,
      level: 0.55,
      tag: '#8B5CF6',
      updated: '2026-07-05',
      received: '15:00',
      active: true,
      ref: 'INV-1005',
    ),
    _row(
      sku: 'SKU-1006',
      name: 'A5 Notebook',
      nameAr: 'A5 notebook',
      lot: 'S03',
      warehouse: 'WH-Dammam',
      category: 'Stationery',
      status: 'Reorder',
      qty: 210,
      discount: 7,
      uom: 'pcs',
      cost: 3.20,
      level: 0.40,
      tag: '#06B6D4',
      updated: '2026-07-06',
      received: '08:00',
      active: true,
      ref: 'INV-1006',
    ),
    _row(
      sku: 'SKU-1007',
      name: 'Cordless Drill',
      nameAr: 'Cordless drill',
      lot: 'H10',
      warehouse: 'WH-Riyadh',
      category: 'Hardware',
      status: 'Low Stock',
      qty: 33,
      discount: 3,
      uom: 'pcs',
      cost: 89.00,
      level: 0.22,
      tag: '#8B5CF6',
      updated: '2026-07-07',
      received: '09:30',
      active: true,
      ref: 'INV-1007',
    ),
    _row(
      sku: 'SKU-1008',
      name: 'HDMI Adapter',
      nameAr: 'HDMI adapter',
      lot: 'A09',
      warehouse: 'WH-Jeddah',
      category: 'Electronics',
      status: 'Discontinued',
      qty: 12,
      discount: 45,
      uom: 'pcs',
      cost: 12.00,
      level: 0.08,
      tag: '#EF4444',
      updated: '2026-07-08',
      received: '11:00',
      active: false,
      ref: 'INV-1008',
    ),
    _row(
      sku: 'SKU-1009',
      name: 'Ground Coffee 500g',
      nameAr: 'Ground coffee',
      lot: 'G22',
      warehouse: 'WH-Dammam',
      category: 'Grocery',
      status: 'In Stock',
      qty: 530,
      discount: 8,
      uom: 'bag',
      cost: 11.75,
      level: 0.84,
      tag: '#E0A23B',
      updated: '2026-07-09',
      received: '13:30',
      active: true,
      ref: 'INV-1009',
    ),
    _row(
      sku: 'SKU-1010',
      name: 'Gel Pens (12)',
      nameAr: 'Gel pens',
      lot: 'S14',
      warehouse: 'WH-Riyadh',
      category: 'Stationery',
      status: 'In Stock',
      qty: 1280,
      discount: 10,
      uom: 'box',
      cost: 4.50,
      level: 0.95,
      tag: '#06B6D4',
      updated: '2026-07-10',
      received: '15:00',
      active: true,
      ref: 'INV-1010',
    ),
  ];

  static _Row _row({
    required String sku,
    required String name,
    required String nameAr,
    required String lot,
    required String warehouse,
    required String category,
    required String status,
    required int qty,
    required num discount,
    required String uom,
    required num cost,
    required num level,
    required String tag,
    required String updated,
    required String received,
    required bool active,
    required String ref,
  }) {
    return {
      'sku': sku,
      'name': name,
      'nameAr': nameAr,
      'lot': lot,
      'warehouse': warehouse,
      'category': category,
      'status': status,
      'qty': qty,
      'discount': discount,
      'uom': uom,
      'cost': cost,
      'level': level,
      'tag': tag,
      'updated': updated,
      'received': received,
      'vendorUrl': 'https://example.com/vendors/${sku.toLowerCase()}',
      'active': active,
      'ref': ref,
    };
  }
}
