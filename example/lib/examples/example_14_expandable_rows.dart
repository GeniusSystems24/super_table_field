// ============================================================
// example/lib/examples/example_14_expandable_rows.dart
// ------------------------------------------------------------
// EXAMPLE 14 — Expandable rows (Readable Mode).
//
// Demonstrates:
//   • SuperRowExpansion with a custom panel builder
//   • heightBuilder — per-row panel heights driven by line-item count
//   • mode toggle — multi (any number open) vs single (accordion)
//   • Animated expand/collapse driven by ClipRect + AnimatedAlign
//
// Domain: a journal entry ledger where each row expands to reveal the
// full double-entry breakdown (account · narration · debit · credit).
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

// ── Domain models ─────────────────────────────────────────────────────────

class JournalLine {
  final String account;
  final String narration;
  final num debit;
  final num credit;
  const JournalLine({
    required this.account,
    required this.narration,
    this.debit = 0,
    this.credit = 0,
  });
}

class JournalEntry {
  final String ref;
  final String date;
  final String description;
  final String type;
  final num totalDebit;
  final num totalCredit;
  final String status;
  final List<JournalLine> lines;
  const JournalEntry({
    required this.ref,
    required this.date,
    required this.description,
    required this.type,
    required this.totalDebit,
    required this.totalCredit,
    required this.status,
    required this.lines,
  });
}

// ── Seed data ──────────────────────────────────────────────────────────────

const List<JournalEntry> _seed = [
  JournalEntry(
    ref: 'JV-2024-0001',
    date: '2024-01-15',
    description: 'Opening Balance — Cash & Equity',
    type: 'Opening',
    totalDebit: 50000,
    totalCredit: 50000,
    status: 'Posted',
    lines: [
      JournalLine(account: '1001 · Cash on Hand', narration: 'Opening cash balance', debit: 50000),
      JournalLine(account: '3001 · Retained Earnings', narration: 'Opening equity position', credit: 50000),
    ],
  ),
  JournalEntry(
    ref: 'JV-2024-0002',
    date: '2024-01-18',
    description: 'Purchase — Office Equipment',
    type: 'Purchase',
    totalDebit: 12500,
    totalCredit: 12500,
    status: 'Posted',
    lines: [
      JournalLine(account: '1501 · Office Equipment', narration: 'Laptop × 2, Monitor × 2', debit: 12500),
      JournalLine(account: '2001 · Accounts Payable', narration: 'Vendor: TechSupply Co.', credit: 10000),
      JournalLine(account: '1001 · Cash on Hand', narration: 'Cash down payment', credit: 2500),
    ],
  ),
  JournalEntry(
    ref: 'JV-2024-0003',
    date: '2024-01-22',
    description: 'Sales Revenue — Q1 Invoice Batch',
    type: 'Revenue',
    totalDebit: 34800,
    totalCredit: 34800,
    status: 'Posted',
    lines: [
      JournalLine(account: '1101 · Accounts Receivable', narration: 'INV-2024-0041 through 0044', debit: 34800),
      JournalLine(account: '4001 · Sales Revenue', narration: 'Ledger Pro licences (3)', credit: 18000),
      JournalLine(account: '4002 · Service Revenue', narration: 'Implementation & training', credit: 12000),
      JournalLine(account: '2201 · Tax Payable — VAT', narration: 'VAT 15%', credit: 4800),
    ],
  ),
  JournalEntry(
    ref: 'JV-2024-0004',
    date: '2024-01-28',
    description: 'Payroll — January 2024',
    type: 'Payroll',
    totalDebit: 28400,
    totalCredit: 28400,
    status: 'Posted',
    lines: [
      JournalLine(account: '5001 · Salaries Expense', narration: 'Monthly payroll — 7 staff', debit: 24000),
      JournalLine(account: '5002 · Social Insurance Exp.', narration: 'Employer contribution 18%', debit: 4400),
      JournalLine(account: '1001 · Cash on Hand', narration: 'Net payroll disbursed', credit: 24000),
      JournalLine(account: '2101 · SI Payable', narration: 'Social insurance due date', credit: 4400),
    ],
  ),
  JournalEntry(
    ref: 'JV-2024-0005',
    date: '2024-02-01',
    description: 'Depreciation — Office Equipment',
    type: 'Depreciation',
    totalDebit: 625,
    totalCredit: 625,
    status: 'Draft',
    lines: [
      JournalLine(account: '5101 · Depreciation Expense', narration: 'Office equipment — straight-line', debit: 625),
      JournalLine(account: '1502 · Acc. Depreciation', narration: 'Accumulated depreciation', credit: 625),
    ],
  ),
  JournalEntry(
    ref: 'JV-2024-0006',
    date: '2024-02-05',
    description: 'Cash Receipt — Accounts Receivable',
    type: 'Receipt',
    totalDebit: 18000,
    totalCredit: 18000,
    status: 'Posted',
    lines: [
      JournalLine(account: '1001 · Cash on Hand', narration: 'Payment from client: INV-2024-0041', debit: 18000),
      JournalLine(account: '1101 · Accounts Receivable', narration: 'INV-2024-0041 cleared', credit: 18000),
    ],
  ),
  JournalEntry(
    ref: 'JV-2024-0007',
    date: '2024-02-10',
    description: 'Inventory Purchase — Raw Materials',
    type: 'Purchase',
    totalDebit: 8750,
    totalCredit: 8750,
    status: 'Posted',
    lines: [
      JournalLine(account: '1301 · Raw Materials Inventory', narration: 'Materials batch #INV-2024-0089', debit: 8750),
      JournalLine(account: '2001 · Accounts Payable', narration: 'Supplier: BuildMat LLC', credit: 8750),
    ],
  ),
];

// ── Example widget ────────────────────────────────────────────────────────

class ExpandableRowsExample extends StatefulWidget {
  const ExpandableRowsExample({super.key});
  @override
  State<ExpandableRowsExample> createState() => _ExpandableRowsExampleState();
}

class _ExpandableRowsExampleState extends State<ExpandableRowsExample> {
  SuperRowExpansionMode _expansionMode = SuperRowExpansionMode.multi;

  late final SuperTableController<JournalEntry> _c =
      SuperTableController<JournalEntry>(
    mode: SuperTableMode.readable,
    selectionMode: SuperSelectionMode.singleRow,
    columns: [
      SuperTextColumn(key: 'ref', label: 'Reference', width: 148, mono: true),
      SuperTextColumn(key: 'date', label: 'Date', width: 114, mono: true),
      SuperTextColumn(key: 'description', label: 'Description', width: 280),
      SuperEnumerationColumn<String>(
        key: 'type',
        label: 'Type',
        width: 126,
        values: const [
          'Opening',
          'Purchase',
          'Revenue',
          'Payroll',
          'Depreciation',
          'Receipt',
        ],
      ),
      SuperCurrencyColumn(
          key: 'totalDebit', label: 'Total Debit', width: 136, agg: SuperAgg.sum),
      SuperCurrencyColumn(
          key: 'totalCredit', label: 'Total Credit', width: 136, agg: SuperAgg.sum),
      SuperEnumerationColumn<String>(
        key: 'status',
        label: 'Status',
        width: 108,
        values: const ['Posted', 'Draft'],
      ),
    ],
    rows: [
      for (final e in _seed)
        SuperRow<JournalEntry>.of(e, {
          'ref': e.ref,
          'date': e.date,
          'description': e.description,
          'type': e.type,
          'totalDebit': e.totalDebit,
          'totalCredit': e.totalCredit,
          'status': e.status,
        }),
    ],
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  // Build the expansion config; recreated whenever _expansionMode changes.
  SuperRowExpansion<JournalEntry> get _expansion =>
      SuperRowExpansion<JournalEntry>(
        mode: _expansionMode,
        // Give rows with more lines a proportionally taller panel.
        heightBuilder: (row) {
          final n = row.value.lines.length;
          if (n >= 4) return 28.0 + n * 32.0 + 4.0; // header + lines + padding
          if (n == 3) return 28.0 + 3 * 32.0 + 4.0;
          return 28.0 + 2 * 32.0 + 4.0; // minimum: 2 lines
        },
        // Enable keyboard control:
        //   Ctrl/⌘ + Shift + ↓  →  expand the focused row
        //   Ctrl/⌘ + Shift + ↑  →  collapse the focused row
        // Pass a custom SuperRowExpansionKeymap(...) to override the defaults.
        keymap: const SuperRowExpansionKeymap(),
        builder: (ctx, ctrl, row) => _LineItemsPanel(entry: row.value),
      );

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final cs = Theme.of(context).colorScheme;
    final isSingle = _expansionMode == SuperRowExpansionMode.single;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: const Text('Expandable Rows'),
        backgroundColor: t.surface,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EXPANSION MODE',
                  style: TextStyle(
                    fontFamily: SuperTokensFonts.body,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: t.fg3,
                  ),
                ),
                const SizedBox(width: 10),
                _ModeChip(
                  label: 'Multi',
                  active: !isSingle,
                  onTap: () => setState(
                      () => _expansionMode = SuperRowExpansionMode.multi),
                ),
                const SizedBox(width: 6),
                _ModeChip(
                  label: 'Single',
                  active: isSingle,
                  onTap: () => setState(
                      () => _expansionMode = SuperRowExpansionMode.single),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instruction hint
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 13, color: t.fg3),
                  const SizedBox(width: 7),
                  Text(
                    isSingle
                        ? 'Single mode — only one row can be open at a time (accordion).'
                        : 'Multi mode — multiple rows can be expanded simultaneously.',
                    style: TextStyle(
                      fontFamily: SuperTokensFonts.body,
                      fontSize: 12.5,
                      color: t.fg3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap the chevron (▾) in the row number column to expand.',
                    style: TextStyle(
                      fontFamily: SuperTokensFonts.body,
                      fontSize: 12.5,
                      color: t.fg4,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SuperTable<JournalEntry>(
                controller: _c,
                // Dim draft rows
                styles: {
                  (ctx, c, row) => row['status'] == 'Draft':
                      const SuperRowStyle(foreground: Color(0xFF94A0B4)),
                },
                // ── Expandable rows ───────────────────────────────────────
                expansion: _expansion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expansion panel — line items breakdown ────────────────────────────────

class _LineItemsPanel extends StatelessWidget {
  const _LineItemsPanel({required this.entry});
  final JournalEntry entry;

  String _fmt(num v) =>
      v == 0 ? '—' : '\$${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final cs = Theme.of(context).colorScheme;
    final isDark = t.brightness == Brightness.dark;
    final headerBg = isDark
        ? Color.alphaBlend(const Color(0x0DFFFFFF), t.surface)
        : Color.alphaBlend(const Color(0x09000000), t.surface);

    return Container(
      // Left-indent to visually nest under the row content (gutter is 40 px).
      padding: const EdgeInsetsDirectional.only(start: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Column header ──
          Container(
            height: 28,
            color: headerBg,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _colHead(t, 'ACCOUNT', flex: 4),
                _colHead(t, 'NARRATION', flex: 3),
                _colHeadFixed(t, 'DEBIT', width: 120, end: true),
                _colHeadFixed(t, 'CREDIT', width: 120, end: true),
                const SizedBox(width: 8),
              ],
            ),
          ),
          // ── Line items ──
          for (final line in entry.lines)
            Container(
              height: 32,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: t.border)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      line.account,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: SuperTokensFonts.mono,
                        fontSize: 11.5,
                        color: t.fg2,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      line.narration,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: SuperTokensFonts.body,
                        fontSize: 12,
                        color: t.fg3,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      _fmt(line.debit),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: SuperTokensFonts.mono,
                        fontSize: 12,
                        fontWeight: line.debit > 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: line.debit > 0 ? t.fg1 : t.fg4,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text(
                      _fmt(line.credit),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: SuperTokensFonts.mono,
                        fontSize: 12,
                        fontWeight: line.credit > 0
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: line.credit > 0 ? t.fg1 : t.fg4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _colHead(dynamic t, String label, {required int flex}) => Expanded(
        flex: flex,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: SuperTokensFonts.body,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.55,
            color: t.fg4,
          ),
        ),
      );

  Widget _colHeadFixed(dynamic t, String label,
          {required double width, bool end = false}) =>
      SizedBox(
        width: width,
        child: Text(
          label,
          textAlign: end ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            fontFamily: SuperTokensFonts.body,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.55,
            color: t.fg4,
          ),
        ),
      );
}

// ── Mode toggle chip ──────────────────────────────────────────────────────

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: active
                ? Color.alphaBlend(
                    cs.primary.withOpacity(0.16), t.surface)
                : t.inputBg,
            border: Border.all(
              color: active ? cs.primary : t.borderStrong,
            ),
            borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: SuperTokensFonts.body,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? cs.primary : t.fg2,
            ),
          ),
        ),
      ),
    );
  }
}
