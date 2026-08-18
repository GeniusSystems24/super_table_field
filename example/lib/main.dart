// ============================================================
// example/lib/main.dart
// ------------------------------------------------------------
// Gallery launcher for super_table_field. Uses the super_core 3.3.0 Material
// theme with explicit SuperTextTheme typography, exposes Light/Dark + LTR/RTL
// toggle, and lists the shipped demos:
//   • SuperTable — the unified grid. Switch to Editable and double-click the
//     "Unit" cell: it is a `combo` column edited through the SuperAutoSuggestionsBox.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:super_form_field/super_form_field.dart';
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
import 'examples/example_17_interaction_events.dart';
import 'examples/example_18_column_config.dart';
import 'examples/example_19_showcase.dart';
import 'examples/example_20_table_styles.dart';
import 'super_table_demo.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  ThemeMode _mode = ThemeMode.dark;
  TextDirection _dir = TextDirection.ltr;

  void _toggleTheme() => setState(
    () => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
  );
  void _toggleDir() => setState(
    () => _dir = _dir == TextDirection.ltr
        ? TextDirection.rtl
        : TextDirection.ltr,
  );

  @override
  Widget build(BuildContext context) {
    final typography = SuperTextTheme(isArabic: _dir == TextDirection.rtl);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Super Table Field',
      themeMode: _mode,
      theme: SuperMaterialThemeData.light(
        textTheme: typography,
        primaryTextTheme: typography,
      ),
      darkTheme: SuperMaterialThemeData.dark(
        textTheme: typography,
        primaryTextTheme: typography,
      ),
      locale: _dir == TextDirection.rtl
          ? const Locale('ar')
          : const Locale('en'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        SuperTableTranslation.delegate,
        SuperFormTranslation.delegate,
      ],
      supportedLocales: SuperTableTranslation.delegate.supportedLocales,

      // builder: (context, child) =>
      //     Directionality(textDirection: _dir, child: child!),
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
    _Demo(
      'Super Table',
      'Editable/readable grid · typed columns · combo ⇒ SuperAutoSuggestionsBox',
      Icons.grid_on_outlined,
      (_) => const SuperTableDemo(),
    ),
    _Demo(
      '1 · Read-only report',
      'Readable mode · typed model · conditional row styling',
      Icons.assessment_outlined,
      (_) => const ReadonlyReportExample(),
    ),
    _Demo(
      '2 · Editable journal',
      'validator + onChange · Ctrl+Enter insert · live balance',
      Icons.edit_note_outlined,
      (_) => const EditableJournalExample(),
    ),
    _Demo(
      '3 · Async combo',
      'SuperComboColumn sourceController · fingerPrint rebuild',
      Icons.cloud_sync_outlined,
      (_) => const AsyncComboExample(),
    ),
    _Demo(
      '4 · Controller-driven',
      'setMode · onLoadMore · programmatic filters + selection',
      Icons.tune_outlined,
      (_) => const ControllerDrivenExample(),
    ),
    _Demo(
      '5 · Styling & filters',
      'Cell/row styles · FilterItem dropdowns · onKey',
      Icons.palette_outlined,
      (_) => const StylingAndFiltersExample(),
    ),
    _Demo(
      '6 · Playground',
      'Full toolbar · mode/search/select/paging/totals/filters',
      Icons.dashboard_customize_outlined,
      (_) => const PlaygroundExample(),
    ),
    _Demo(
      '7 · Change tracking',
      'trackChanges · dirty cells · changes delta · save/revert',
      Icons.fact_check_outlined,
      (_) => const ChangeTrackingExample(),
    ),
    _Demo(
      '8 · Selection statistics',
      'multiCells · selectionStats · Sum/Avg/Min/Max status bar',
      Icons.functions_outlined,
      (_) => const SelectionStatsExample(),
    ),
    _Demo(
      '9 · Export',
      'toCsv / toTsv / toJsonRows · respects filter + sort',
      Icons.file_download_outlined,
      (_) => const ExportExample(),
    ),
    _Demo(
      '10 · Aggregations',
      'min / max / custom aggregator · weighted average · aggLabel',
      Icons.summarize_outlined,
      (_) => const AggregationsExample(),
    ),
    _Demo(
      '11 · Cell locking',
      'cellEditable · lock posted rows · read-only cells',
      Icons.lock_outline,
      (_) => const CellLockingExample(),
    ),
    _Demo(
      '12 · Row reordering',
      'moveRowUp / moveRowDown / moveRow · undo',
      Icons.swap_vert_outlined,
      (_) => const RowReorderExample(),
    ),
    _Demo(
      '13 · Group aggregates · Hidden columns',
      'groupAggregates / aggregateBy / grandTotals · filter+group-only columns',
      Icons.account_tree_outlined,
      (_) => const GroupAggregatesExample(),
    ),
    _Demo(
      '14 · Expandable rows',
      'SuperRowExpansion · multi & single mode · per-row heights · animated panels',
      Icons.unfold_more_outlined,
      (_) => const ExpandableRowsExample(),
    ),
    _Demo(
      '15 · Validation · saved views',
      'validateAll + unique · isValid gate · viewStateJson / applyViewJson',
      Icons.rule_outlined,
      (_) => const ValidationViewsExample(),
    ),
    _Demo(
      '16 · Fill · group footers · revert',
      '⌘D/⌘R fill · Σ subtotal rows · revert cell/row',
      Icons.south_outlined,
      (_) => const FillAndFootersExample(),
    ),
    _Demo(
      '17 · Interaction events',
      'SuperInteractions · onRowActivate · cell/row taps · selection + sort',
      Icons.ads_click_outlined,
      (_) => const InteractionEventsExample(),
    ),
    _Demo(
      '18 · Column config',
      'showSuperColumnManager · reorder / pin / show-hide · pins persist in views',
      Icons.view_column_outlined,
      (_) => const ColumnConfigExample(),
    ),
    _Demo(
      '19 · Showcase',
      'Interactions + column manager + grouping + totals + tracking + export',
      Icons.dashboard_outlined,
      (_) => const ShowcaseExample(),
    ),
    _Demo(
      '20 - Table styles',
      'Optional SuperTableStyle presets - banding - group footers - totals',
      Icons.table_chart_outlined,
      (_) => const TableStylesExample(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SuperScaffold(
            maxWidth: 1120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'SUPER TABLE FIELD • GALLERY',
                  style: context.superTextTheme.eyebrow.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: spacing.space2),
                Text(
                  'Component Demos مكتبة المكونات',
                  style: context.superTextTheme.h1.copyWith(color: theme.fg1),
                ),
                SizedBox(height: spacing.space8),
                for (final demo in _demos) ...[
                  _DemoCard(demo: demo),
                  SizedBox(height: spacing.section),
                ],
                SizedBox(height: spacing.space6),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: spacing.space3,
                  runSpacing: spacing.space3,
                  children: [
                    SuperButton(
                      label: mode == ThemeMode.dark
                          ? 'Light Theme'
                          : 'Dark Theme',
                      variant: SuperButtonVariant.secondary,
                      onPressed: onToggleTheme,
                    ),
                    SuperButton(
                      label: dir == TextDirection.ltr
                          ? 'العربية (RTL)'
                          : 'English (LTR)',
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
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.demo});

  final _Demo demo;

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return SuperSectionCard(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: demo.builder)),
      padding: spacing.cardPadding,
      child: Row(
        children: [
          Container(
            width: spacing.controlHeight,
            height: spacing.controlHeight,
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                colorScheme.primary.withValues(alpha: 0.14),
                theme.surface,
              ),
              borderRadius: spacing.borderRadiusControl,
            ),
            child: Icon(demo.icon, size: 22, color: colorScheme.primary),
          ),
          SizedBox(width: spacing.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  demo.title,
                  style: context.superTextTheme.heading.copyWith(
                    color: theme.fg1,
                  ),
                ),
                SizedBox(height: spacing.space1),
                Text(
                  demo.subtitle,
                  style: context.superTextTheme.caption.copyWith(
                    color: theme.fg3,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: theme.fg4),
        ],
      ),
    );
  }
}
