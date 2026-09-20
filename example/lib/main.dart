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
import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart'
    show SuperAutoSuggestionLocalization;
import 'package:super_form_field/super_form_field.dart';
import 'package:super_table_field/super_table_field.dart';
import 'package:super_core/super_core.dart';
import 'package:super_table_field_example/localizations/generated/l10n.dart';

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
import 'examples/example_21_column_width_fit.dart';
import 'examples/example_22_big_data_load_more.dart';
import 'examples/example_23_enumeration_select.dart';
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
      onGenerateTitle: (context) =>
          SuperTableExampleLocalization.of(context).appTitle,
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
        SuperTableLocalization.delegate,
        SuperFormTranslation.delegate,
        SuperAutoSuggestionLocalization.delegate,
        SuperTableExampleLocalization.delegate,
      ],
      supportedLocales: SuperTableExampleLocalization.supportedLocales,
      builder: (context, child) {
// return Directionality(textDirection: _dir, child: child!);
        return child!;
      },
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

  List<_Demo> _demos(BuildContext context) => [
    _Demo(
      SuperTableExampleLocalization.of(context).superTable,
      SuperTableExampleLocalization.of(context).superTableDescription,
      Icons.grid_on_outlined,
      (_) => const SuperTableDemo(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).oneReadOnlyReport,
      SuperTableExampleLocalization.of(context).readOnlyReportDescription,
      Icons.assessment_outlined,
      (_) => const ReadonlyReportExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).twoEditableJournal,
      SuperTableExampleLocalization.of(context).validatorPlusOnChangeCtrlPlusEnterInsertLiveBalance,
      Icons.edit_note_outlined,
      (_) => const EditableJournalExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).threeAsyncCombo,
      SuperTableExampleLocalization.of(context).asyncComboDescription,
      Icons.cloud_sync_outlined,
      (_) => const AsyncComboExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).fourControllerDriven,
      SuperTableExampleLocalization.of(context).controllerDrivenDescription,
      Icons.tune_outlined,
      (_) => const ControllerDrivenExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).fiveStylingAndFilters,
      SuperTableExampleLocalization.of(context).stylingAndFiltersDescription,
      Icons.palette_outlined,
      (_) => const StylingAndFiltersExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).sixPlayground,
      SuperTableExampleLocalization.of(context).playgroundDescription,
      Icons.dashboard_customize_outlined,
      (_) => const PlaygroundExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).sevenChangeTracking,
      SuperTableExampleLocalization.of(context).changeTrackingDescription,
      Icons.fact_check_outlined,
      (_) => const ChangeTrackingExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).eightSelectionStatistics,
      SuperTableExampleLocalization.of(context).selectionStatisticsDescription,
      Icons.functions_outlined,
      (_) => const SelectionStatsExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).nineExport,
      SuperTableExampleLocalization.of(context).exportDescription,
      Icons.file_download_outlined,
      (_) => const ExportExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).tenAggregations,
      SuperTableExampleLocalization.of(context).aggregationsDescription,
      Icons.summarize_outlined,
      (_) => const AggregationsExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).elevenCellLocking,
      SuperTableExampleLocalization.of(context).cellLockingDescription,
      Icons.lock_outline,
      (_) => const CellLockingExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).twelveRowReordering,
      SuperTableExampleLocalization.of(context).rowReorderingDescription,
      Icons.swap_vert_outlined,
      (_) => const RowReorderExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).thirteenGroupAggregatesHiddenColumns,
      SuperTableExampleLocalization.of(context).groupAggregatesDescription,
      Icons.account_tree_outlined,
      (_) => const GroupAggregatesExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).fourteenExpandableRows,
      SuperTableExampleLocalization.of(context).expandableRowsDescription,
      Icons.unfold_more_outlined,
      (_) => const ExpandableRowsExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).fifteenValidationSavedViews,
      SuperTableExampleLocalization.of(context).validationAndSavedViewsDescription,
      Icons.rule_outlined,
      (_) => const ValidationViewsExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).sixteenFillGroupFootersRevert,
      SuperTableExampleLocalization.of(context).fillAndGroupFootersDescription,
      Icons.south_outlined,
      (_) => const FillAndFootersExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).seventeenInteractionEvents,
      SuperTableExampleLocalization.of(context).interactionEventsDescription,
      Icons.ads_click_outlined,
      (_) => const InteractionEventsExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).eighteenColumnConfig,
      SuperTableExampleLocalization.of(context).columnConfigDescription,
      Icons.view_column_outlined,
      (_) => const ColumnConfigExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).nineteenShowcase,
      SuperTableExampleLocalization.of(context)
          .interactionsPlusColumnManagerPlusGroupingPlusTotalsPlusTrackingPc4d7ca8,
      Icons.dashboard_outlined,
      (_) => const ShowcaseExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).twentyTableStyles,
      SuperTableExampleLocalization.of(context)
          .optionalSuperTableStylePresetsBandingGroupFootersTotals,
      Icons.table_chart_outlined,
      (_) => const TableStylesExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).twentyOneColumnWidthFit,
      SuperTableExampleLocalization.of(context).noneAutoMaxCellFitResponsiveViewportSizing,
      Icons.width_normal_outlined,
      (_) => const ColumnWidthFitExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).twentyTwoBigDataLoadMore,
      SuperTableExampleLocalization.of(context).message1k5k10kRowsPerLoad100kMaxPerformanceCounters,
      Icons.speed_rounded,
      (_) => const BigDataLoadMoreExample(),
    ),
    _Demo(
      SuperTableExampleLocalization.of(context).twentyThreeEnumerationSelect,
      SuperTableExampleLocalization.of(context)
          .superEnumerationColumnSuperSelectFormFieldRowAwareSources,
      Icons.list_alt_outlined,
      (_) => const EnumerationSelectExample(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.bg,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: mode == ThemeMode.dark
                ? SuperTableExampleLocalization.of(context).lightTheme
                : SuperTableExampleLocalization.of(context).darkTheme,
            onPressed: onToggleTheme,
            icon: Icon(
              mode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
          ),
          IconButton(
            tooltip: dir == TextDirection.ltr
                ? SuperTableExampleLocalization.of(context).switchToArabic
                : SuperTableExampleLocalization.of(context).switchToEnglish,
            onPressed: onToggleDir,
            icon: const Icon(Icons.language_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SuperScaffold(
            maxWidth: 1120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  SuperTableExampleLocalization.of(context).galleryEyebrow,
                  style: context.superTextTheme.eyebrow.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
                SizedBox(height: spacing.space2),
                Text(
                  SuperTableExampleLocalization.of(context).componentDemoseb5e41,
                  style: context.superTextTheme.h1.copyWith(color: theme.fg1),
                ),
                SizedBox(height: spacing.space8),
                for (final demo in _demos(context)) ...[
                  _DemoCard(demo: demo),
                  SizedBox(height: spacing.section),
                ],
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

    return SuperSectionCard1(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: spacing.borderRadiusCard,
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: demo.builder)),
          child: Padding(
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
          ),
        ),
      ),
    );
  }
}
