// ============================================================
// example/lib/main.dart
// ------------------------------------------------------------
// Gallery launcher for super_table_field. Registers the SuperThemeData +
// AutoSuggestionsBoxThemeData extensions (so both components theme light/dark in
// parity), exposes a global Light/Dark + LTR/RTL toggle, and lists the two
// shipped demos:
//   • SuperTable — the unified grid. Switch to Editable and double-click the
//     "Unit" cell: it is a `combo` column edited through the AutoSuggestionsBox.
//   • Auto Suggestion Box — the typeahead on its own.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';

import 'examples/example_1_readonly_report.dart';
import 'examples/example_2_editable_journal.dart';
import 'examples/example_3_async_combo.dart';
import 'examples/example_4_controller_driven.dart';
import 'examples/example_5_styling_and_filters.dart';
import 'examples/example_6_playground.dart';
import 'examples/example_7_change_tracking.dart';
import 'examples/example_8_selection_stats.dart';
import 'examples/example_9_export.dart';
import 'examples/example_10_aggregations.dart';
import 'examples/example_11_cell_locking.dart';
import 'examples/example_12_row_reorder.dart';
import 'examples/example_13_group_aggregates.dart';
import 'examples/example_14_expandable_rows.dart';
import 'examples/example_15_validation_views.dart';
import 'examples/example_16_fill_and_footers.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.dark;
  TextDirection _dir = TextDirection.ltr;

  ThemeData _theme(SuperThemeData s) => ThemeData(
        brightness: s.brightness,
        scaffoldBackgroundColor: s.bg,
        extensions: [
          s,
          s.brightness == Brightness.dark
              ? AutoSuggestionsBoxThemeData.dark
              : AutoSuggestionsBoxThemeData.light,
        ],
      );

  void _toggleTheme() => setState(
      () => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  void _toggleDir() => setState(
      () => _dir = _dir == TextDirection.ltr ? TextDirection.rtl : TextDirection.ltr);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Super Table Field',
      themeMode: _mode,
      theme: _theme(SuperThemeData.light),
      darkTheme: _theme(SuperThemeData.dark),
      builder: (context, child) =>
          Directionality(textDirection: _dir, child: child!),
      home: _Launcher(
        mode: _mode,
        dir: _dir,
        onToggleTheme: _toggleTheme,
        onToggleDir: _toggleDir,
      ),
    );
  }
}

class _Demo {
  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
  const _Demo(this.title, this.subtitle, this.icon, this.builder);
}

class _Launcher extends StatelessWidget {
  const _Launcher({
    required this.mode,
    required this.dir,
    required this.onToggleTheme,
    required this.onToggleDir,
  });

  final ThemeMode mode;
  final TextDirection dir;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleDir;

  static final List<_Demo> _demos = [
    _Demo('Super Table', 'Editable/readable grid · typed columns · combo ⇒ AutoSuggestionsBox',
        Icons.grid_on_outlined, (_) => const SuperTableDemo()),
    _Demo('1 · Read-only report', 'Readable mode · typed model · conditional row styling',
        Icons.assessment_outlined, (_) => const ReadonlyReportExample()),
    _Demo('2 · Editable journal', 'validator + onChange · Ctrl+Enter insert · live balance',
        Icons.edit_note_outlined, (_) => const EditableJournalExample()),
    _Demo('3 · Async combo', 'SuperComboColumn sourceController · fingerPrint rebuild',
        Icons.cloud_sync_outlined, (_) => const AsyncComboExample()),
    _Demo('4 · Controller-driven', 'setMode · onLoadMore · programmatic filters + selection',
        Icons.tune_outlined, (_) => const ControllerDrivenExample()),
    _Demo('5 · Styling & filters', 'Cell/row styles · FilterItem dropdowns · onKey',
        Icons.palette_outlined, (_) => const StylingAndFiltersExample()),
    _Demo('6 · Playground', 'Full toolbar · mode/search/select/paging/totals/filters',
        Icons.dashboard_customize_outlined, (_) => const PlaygroundExample()),
    _Demo('7 · Change tracking', 'trackChanges · dirty cells · changes delta · save/revert',
        Icons.fact_check_outlined, (_) => const ChangeTrackingExample()),
    _Demo('8 · Selection statistics', 'multiCells · selectionStats · Sum/Avg/Min/Max status bar',
        Icons.functions_outlined, (_) => const SelectionStatsExample()),
    _Demo('9 · Export', 'toCsv / toTsv / toJsonRows · respects filter + sort',
        Icons.file_download_outlined, (_) => const ExportExample()),
    _Demo('10 · Aggregations', 'min / max / custom aggregator · weighted average · aggLabel',
        Icons.summarize_outlined, (_) => const AggregationsExample()),
    _Demo('11 · Cell locking', 'cellEditable · lock posted rows · read-only cells',
        Icons.lock_outline, (_) => const CellLockingExample()),
    _Demo('12 · Row reordering', 'moveRowUp / moveRowDown / moveRow · undo',
        Icons.swap_vert_outlined, (_) => const RowReorderExample()),
    _Demo('13 · Group aggregates · Hidden columns', 'groupAggregates / aggregateBy / grandTotals · filter+group-only columns',
        Icons.account_tree_outlined, (_) => const GroupAggregatesExample()),
    _Demo('14 · Expandable rows', 'SuperRowExpansion · multi & single mode · per-row heights · animated panels',
        Icons.unfold_more_outlined, (_) => const ExpandableRowsExample()),
    _Demo('15 · Validation · saved views', 'validateAll + unique · isValid gate · viewStateJson / applyViewJson',
        Icons.rule_outlined, (_) => const ValidationViewsExample()),
    _Demo('16 · Fill · group footers · revert', '⌘D/⌘R fill · Σ subtotal rows · revert cell/row',
        Icons.south_outlined, (_) => const FillAndFootersExample()),
    _Demo('Auto Suggestion Box', 'Typeahead · groups · multi-select · fuzzy',
        Icons.manage_search_outlined, (_) => const AutoSuggestionBoxDemo()),
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
                  Text('SUPER TABLE FIELD \u2022 GALLERY',
                      style: SuperText.eyebrow.copyWith(color: SuperTokens.accent)),
                  const SizedBox(height: SuperTokens.space2),
                  Text('Component Demos مكتبة المكونات',
                      style: SuperText.h1.copyWith(color: t.fg1)),
                  const SizedBox(height: SuperTokens.space8),
                  for (final d in _demos) ...[
                    _DemoCard(demo: d),
                    const SizedBox(height: SuperTokens.space3),
                  ],
                  const SizedBox(height: SuperTokens.space6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SuperButton(
                        label: mode == ThemeMode.dark ? 'Light Theme' : 'Dark Theme',
                        variant: SuperButtonVariant.secondary,
                        onPressed: onToggleTheme,
                      ),
                      const SizedBox(width: SuperTokens.space3),
                      SuperButton(
                        label: dir == TextDirection.ltr ? 'العربية (RTL)' : 'English (LTR)',
                        variant: SuperButtonVariant.secondary,
                        onPressed: onToggleDir,
                      ),
                    ],
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

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.demo});
  final _Demo demo;

  @override
  Widget build(BuildContext context) {
    final t = context.superTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(SuperTokens.radiusCard),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: demo.builder)),
        child: Container(
          padding: const EdgeInsets.all(SuperTokens.space4),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(SuperTokens.radiusCard),
            border: Border.all(color: t.border),
            boxShadow: t.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                      SuperTokens.accent.withOpacity(0.14), t.surface),
                  borderRadius: BorderRadius.circular(SuperTokens.radiusControl),
                ),
                child: Icon(demo.icon, size: 22, color: SuperTokens.accent),
              ),
              const SizedBox(width: SuperTokens.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(demo.title, style: SuperText.heading.copyWith(color: t.fg1)),
                    const SizedBox(height: 2),
                    Text(demo.subtitle, style: SuperText.caption.copyWith(color: t.fg3)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: t.fg4),
            ],
          ),
        ),
      ),
    );
  }
}
