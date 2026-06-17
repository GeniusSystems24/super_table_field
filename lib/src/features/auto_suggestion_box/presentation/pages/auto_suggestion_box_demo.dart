// ============================================================
// features/auto_suggestion_box/presentation/pages/auto_suggestion_box_demo.dart
// ------------------------------------------------------------
// A self-contained gallery page for the AutoSuggestionsBox. Demonstrates:
//   1. single-select, grouped, highlighted (static list)
//   2. multi-select
//   3. fuzzy match over plain strings
//   4. progressive REMOTE FALLBACK — local rows show instantly, and when the
//      local match count is small a simulated network call streams more in
//      behind a "loading more" indicator
//   5. ADVANCED SEARCH (Ctrl/⌘+F) — a modal search surface over a large dataset
// Used by the example app and as a visual reference.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/datasources/suggestion_sources.dart';
import '../../domain/entities/auto_suggestion.dart';
import '../../domain/entities/match_strategy.dart';
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

  // A handful of "local" vendors held in memory; the long tail lives "on the
  // server" and is fetched only when the local matches run thin.
  static final List<AutoSuggestion<String>> _localVendors = [
    const AutoSuggestion(value: 'V-001', label: 'Al-Faisal Trading', description: 'Local · Riyadh', icon: Icons.storefront_outlined),
    const AutoSuggestion(value: 'V-002', label: 'Najd Logistics', description: 'Local · Riyadh', icon: Icons.local_shipping_outlined),
    const AutoSuggestion(value: 'V-003', label: 'Gulf Steel Co.', description: 'Local · Dammam', icon: Icons.factory_outlined),
  ];

  static const List<String> _remoteVendors = [
    'Arabian Cement Partners', 'Desert Rose Supplies', 'Eastern Hardware LLC',
    'Falcon Freight Services', 'Granite & Marble Hub', 'Horizon Electricals',
    'Ibn Sina Pharma Dist.', 'Jeddah Port Clearing', 'Kingdom Office Supplies',
    'Levant Timber Imports', 'Madinah Glassworks', 'Northern Pipes & Fittings',
  ];

  // A larger directory for the advanced-search example.
  static final List<AutoSuggestion<String>> _directory = [
    for (var i = 0; i < _remoteVendors.length; i++)
      AutoSuggestion(value: 'D-${i + 1}', label: _remoteVendors[i], description: 'Directory entry', icon: Icons.business_outlined),
    ..._localVendors,
  ];

  Future<List<AutoSuggestion<String>>> _fetchRemote(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 650)); // simulate latency
    final q = query.trim().toLowerCase();
    return [
      for (final name in _remoteVendors)
        if (name.toLowerCase().contains(q))
          AutoSuggestion(value: 'R-$name', label: name, description: 'Server · remote', icon: Icons.cloud_outlined),
    ];
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
                  const SizedBox(height: SuperTokens.space8),

                  // 1 — Single-select, grouped, with highlight.
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

                  // 2 — Multi-select.
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

                  // 3 — Fuzzy strategy over plain strings.
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

                  // 4 — Progressive remote fallback.
                  SectionCard(
                    title: 'Select Vendor',
                    subtitle: 'Local vendors show instantly; the server is queried only when local matches are few',
                    marker: SuperMarker.identity,
                    child: AutoSuggestionsBox<String>(
                      source: SuggestionSources.remoteFallback<String>(
                        initialItems: _localVendors,
                        fetch: _fetchRemote,
                        remoteThreshold: 3, // fetch when ≤ 3 local matches
                        remoteMinChars: 1,
                      ),
                      hintText: 'e.g. cement, freight, glass…',
                      onSelected: (s) {},
                    ),
                  ),
                  const SizedBox(height: SuperTokens.space8),

                  // 5 — Advanced search (Ctrl/⌘+F).
                  SectionCard(
                    title: 'Vendor Directory',
                    subtitle: 'Focus the field and press Ctrl / ⌘ + F to open Advanced Search',
                    marker: SuperMarker.ledger,
                    child: AutoSuggestionsBox<String>(
                      items: _directory,
                      advancedSearch: true,
                      hintText: 'Search the directory…  (⌘F)',
                      onSelected: (s) {},
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
}
