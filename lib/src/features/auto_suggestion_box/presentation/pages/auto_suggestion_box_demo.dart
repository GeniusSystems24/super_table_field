// ============================================================
// features/auto_suggestion_box/presentation/pages/auto_suggestion_box_demo.dart
// ------------------------------------------------------------
// A self-contained gallery page for the AutoSuggestionsBox: a static list
// source with grouped rows + descriptions, a multi-select variant, a fuzzy
// match strategy, progressive remote fallback, and the advanced-search surface.
//
// NEW in the latest commit:
//   • SuggestionSources.remoteFallback — local-first with progressive remote
//     fallback (shows local rows instantly, streams remote rows in behind a
//     "loading more" indicator).
//   • Advanced Search (Ctrl/⌘+F) — opens a larger modal search surface.
//   • restoreOnBlur — reverts unconfirmed typing to the last committed value.
//   • effectiveQuery — search is anchored to the caret position.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/datasources/suggestion_sources.dart';
import '../../domain/entities/auto_suggestion.dart';
import '../../domain/entities/match_strategy.dart';
import '../controllers/auto_suggestions_box_controller.dart';
import '../widgets/auto_suggestions_box.dart';

class AutoSuggestionBoxDemo extends StatefulWidget {
  const AutoSuggestionBoxDemo({super.key});

  @override
  State<AutoSuggestionBoxDemo> createState() => _AutoSuggestionBoxDemoState();
}

class _AutoSuggestionBoxDemoState extends State<AutoSuggestionBoxDemo> {
  static final List<AutoSuggestion<String>> _accounts = [
    const AutoSuggestion(value: '1010', label: 'Cash on Hand', description: '1010 · Current Assets', group: 'Assets', icon: Icons.payments_outlined),
    const AutoSuggestion(value: '1020', label: 'Bank — Operating', description: '1020 · Current Assets', group: 'Assets', icon: Icons.account_balance_outlined),
    const AutoSuggestion(value: '1200', label: 'Accounts Receivable', description: '1200 · Current Assets', group: 'Assets', icon: Icons.receipt_long_outlined),
    const AutoSuggestion(value: '2010', label: 'Accounts Payable', description: '2010 · Current Liabilities', group: 'Liabilities', icon: Icons.request_quote_outlined),
    const AutoSuggestion(value: '2100', label: 'VAT Payable', description: '2100 · Current Liabilities', group: 'Liabilities', icon: Icons.account_balance_wallet_outlined),
    const AutoSuggestion(value: '3000', label: "Owner's Equity", description: '3000 · Equity', group: 'Equity', icon: Icons.savings_outlined),
    const AutoSuggestion(value: '4000', label: 'Sales Revenue', description: '4000 · Income', group: 'Income', icon: Icons.trending_up_outlined),
    const AutoSuggestion(value: '5000', label: 'Cost of Goods Sold', description: '5000 · Expenses', group: 'Expenses', icon: Icons.inventory_2_outlined),
    const AutoSuggestion(value: '5200', label: 'Salaries & Wages', description: '5200 · Expenses', group: 'Expenses', icon: Icons.badge_outlined),
  ];

  /// Simulated remote fetch for the progressive fallback demo.
  Future<List<AutoSuggestion<String>>> _fetchRemote(String query) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final q = query.toLowerCase();
    return [
      AutoSuggestion(value: 'REM-001', label: 'Remote: $query Result A', description: 'Fetched from server', group: 'Remote'),
      AutoSuggestion(value: 'REM-002', label: 'Remote: $query Result B', description: 'Fetched from server', group: 'Remote'),
    ].where((s) => s.label.toLowerCase().contains(q) || q.isEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SuperTokens.space10),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: SuperTokens.contentColumn),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('AUTO SUGGESTION BOX',
                      style: SuperText.eyebrow.copyWith(color: SuperTokens.accent)),
                  const SizedBox(height: SuperTokens.space2),
                  Text('Account Lookup', style: SuperText.h1.copyWith(color: t.fg1)),
                  const SizedBox(height: SuperTokens.space2),
                  _hints(t),
                  const SizedBox(height: SuperTokens.space8),

                  // Single-select, grouped, with highlight.
                  SectionCard(
                    title: 'Post To Account',
                    subtitle: 'Search the chart of accounts by name or code',
                    marker: SuperMarker.identity,
                    child: AutoSuggestionsBox<String>(
                      items: _accounts,
                      hintText: 'e.g. Accounts Receivable',
                      onSelected: (s) {},
                    ),
                  ),
                  const SizedBox(height: SuperTokens.space8),

                  // Multi-select.
                  SectionCard(
                    title: 'Tag Cost Centers',
                    subtitle: 'Assign one or more cost centers to this entry',
                    marker: SuperMarker.ledger,
                    child: AutoSuggestionsBox<String>(
                      items: _accounts,
                      multiSelect: true,
                      hintText: 'Select cost centers…',
                    ),
                  ),
                  const SizedBox(height: SuperTokens.space8),

                  // Fuzzy strategy over plain strings.
                  SectionCard(
                    title: 'Quick Filter',
                    subtitle: 'Fuzzy match — type loosely',
                    marker: SuperMarker.notes,
                    child: AutoSuggestionsBox<String>(
                      source: SuggestionSources.strings(
                        const ['Riyadh', 'Jeddah', 'Dammam', 'Mecca', 'Medina', 'Khobar', 'Tabuk', 'Abha'],
                        match: AutoSuggestionMatch.fuzzy,
                      ),
                      highlightMatch: AutoSuggestionMatch.fuzzy,
                      hintText: 'e.g. rdh',
                    ),
                  ),
                  const SizedBox(height: SuperTokens.space8),

                  // Progressive remote fallback — shows local rows instantly,
                  // then streams remote rows in with a "loading more" indicator.
                  SectionCard(
                    title: 'Progressive Remote Fallback',
                    subtitle: 'Local-first; remote results merge in when local ≤ 5 matches',
                    marker: SuperMarker.notes,
                    child: AutoSuggestionsBox<String>(
                      source: SuggestionSources.remoteFallback(
                        initialItems: _accounts,
                        fetch: _fetchRemote,
                        remoteThreshold: 5,
                      ),
                      
                      hintText: 'Type to trigger remote fallback…',
                    ),
                  ),
                  const SizedBox(height: SuperTokens.space8),

                  // Advanced search surface (Ctrl/⌘+F).
                  SectionCard(
                    title: 'Advanced Search',
                    subtitle: 'Press Ctrl/⌘+F while focused to open the advanced surface',
                    marker: SuperMarker.identity,
                    child: AutoSuggestionsBox<String>(
                      items: _accounts,
                      advancedSearch: true,
                      advancedSearchBuilder: _buildAdvancedSearch,
                      hintText: 'Focus here, then press Ctrl/⌘+F',
                    ),
                  ),
                  const SizedBox(height: SuperTokens.space8),

                  // restoreOnBlur demo — type without picking, then tab/blur away.
                  SectionCard(
                    title: 'Restore on Blur',
                    subtitle: 'Type freely; blur reverts to the last committed value',
                    marker: SuperMarker.ledger,
                    child: AutoSuggestionsBox<String>(
                      items: _accounts,
                      restoreOnBlur: true,
                      hintText: 'Pick an account, then type and blur…',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hints(SuperThemeData t) {
    return Wrap(
      spacing: SuperTokens.space3,
      runSpacing: SuperTokens.space2,
      children: [
        _hintChip(t, Icons.cloud_sync_outlined, 'Remote fallback with progressive loading'),
        _hintChip(t, Icons.keyboard_command_key, 'Ctrl/⌘+F → Advanced Search'),
        _hintChip(t, Icons.restore, 'restoreOnBlur reverts unconfirmed typing'),
        _hintChip(t, Icons.format_list_bulleted, 'Grouped suggestions with icons & descriptions'),
      ],
    );
  }

  Widget _hintChip(SuperThemeData t, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: t.fg3),
        const SizedBox(width: 6),
        Text(text, style: SuperText.caption.copyWith(color: t.fg2)),
      ]),
    );
  }

  /// A simple advanced-search dialog. Reuses the live controller so any pick
  /// made here commits straight back into the inline field.
  Widget _buildAdvancedSearch(BuildContext context, AutoSuggestionsBoxController<String> controller) {
    final t = Theme.of(context).extension<SuperThemeData>()!;
    return AlertDialog(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      title: Text('Advanced Search', style: SuperText.heading.copyWith(color: t.fg1)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'The same controller is wired here — pick an item and it commits back to the field.',
              style: SuperText.caption.copyWith(color: t.fg3),
            ),
            const SizedBox(height: SuperTokens.space4),
            // Re-use the same controller in a bare inline box.
            AutoSuggestionsBox<String>(
              controller: controller,
              bare: true,
              hintText: 'Search accounts…',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close', style: TextStyle(color: t.fg2)),
        ),
      ],
    );
  }
}
