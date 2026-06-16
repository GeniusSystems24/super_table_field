// ============================================================
// features/auto_suggestion_box/presentation/pages/auto_suggestion_box_demo.dart
// ------------------------------------------------------------
// A self-contained gallery page for the AutoSuggestionsBox: a static list
// source with grouped rows + descriptions, a multi-select variant, and a fuzzy
// match strategy. Used by the example app and as a visual reference.
// ============================================================

import 'package:flutter/material.dart';

import '../../../../core/core.dart';
import '../../data/datasources/suggestion_sources.dart';
import '../../domain/entities/auto_suggestion.dart';
import '../../domain/entities/match_strategy.dart';
import '../widgets/auto_suggestions_box.dart';

class AutoSuggestionBoxDemo extends StatelessWidget {
  const AutoSuggestionBoxDemo({super.key});

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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
