// ============================================================
// example/lib/examples/example_21_column_width_fit.dart
// ------------------------------------------------------------
// EXAMPLE 21 — SuperColumnWidthFit (2.8.0).
//
// Demonstrates all four runtime column-width strategies:
//   • none    — fixed declared/default width.
//   • auto    — equal share between auto columns from available viewport width.
//   • maxCell — width of the widest rendered cell content.
//   • fit     — base width + equal share of otherwise-empty viewport space.
//
// Resize the window to make the difference between `auto` and `fit` obvious.
// ============================================================

import 'package:flutter/material.dart';
import 'package:super_table_field/super_table_field.dart';
import 'package:super_core/super_core.dart';
import 'package:super_table_field_example/localizations/example_l10n.dart';

typedef _Row = Map<String, dynamic>;

class ColumnWidthFitExample extends StatefulWidget {
  const ColumnWidthFitExample({super.key});

  @override
  State<ColumnWidthFitExample> createState() => _ColumnWidthFitExampleState();
}

class _ColumnWidthFitExampleState extends State<ColumnWidthFitExample> {
  late final SuperTableController<_Row> _noneController;
  late final SuperTableController<_Row> _autoController;
  late final SuperTableController<_Row> _maxCellController;
  late final SuperTableController<_Row> _fitController;

  @override
  void initState() {
    super.initState();
    _noneController = _buildNoneController();
    _autoController = _buildAutoController();
    _maxCellController = _buildMaxCellController();
    _fitController = _buildFitController();
  }

  @override
  void dispose() {
    _noneController.dispose();
    _autoController.dispose();
    _maxCellController.dispose();
    _fitController.dispose();
    super.dispose();
  }

  SuperTableController<_Row> _buildNoneController() {
    return SuperTableController<_Row>(
      mode: SuperTableMode.readable,
      columns: [
        SuperTextColumn(
          key: 'code',
          label: ExampleL10n.current.code110Px,
          width: 110,
          widthFit: SuperColumnWidthFit.none,
          mono: true,
        ),
        SuperTextColumn(
          key: 'name',
          label: ExampleL10n.current.name220Px,
          width: 220,
          widthFit: SuperColumnWidthFit.none,
        ),
        SuperTextColumn(
          key: 'status',
          label: ExampleL10n.current.status140Px,
          width: 140,
          widthFit: SuperColumnWidthFit.none,
        ),
      ],
      rows: _rows([
        {'code': 'A-100', 'name': 'Cash on hand', 'status': 'Open'},
        {'code': 'A-200', 'name': 'Accounts receivable', 'status': 'Review'},
        {'code': 'A-300', 'name': 'Inventory', 'status': 'Posted'},
      ]),
    );
  }

  SuperTableController<_Row> _buildAutoController() {
    return SuperTableController<_Row>(
      mode: SuperTableMode.readable,
      columns: [
        SuperTextColumn(
          key: 'code',
          label: ExampleL10n.current.fixed120Px,
          width: 120,
          widthFit: SuperColumnWidthFit.none,
          mono: true,
        ),
        SuperTextColumn(
          key: 'region',
          label: ExampleL10n.current.autoADeclared80,
          width: 80,
          widthFit: SuperColumnWidthFit.auto,
        ),
        SuperTextColumn(
          key: 'owner',
          label: ExampleL10n.current.autoBDeclared220,
          width: 220,
          widthFit: SuperColumnWidthFit.auto,
        ),
        SuperTextColumn(
          key: 'status',
          label: ExampleL10n.current.autoCDeclared100,
          width: 100,
          widthFit: SuperColumnWidthFit.auto,
        ),
      ],
      rows: _rows([
        {
          'code': 'INV-01',
          'region': 'North',
          'owner': 'Warehouse Team',
          'status': 'Open',
        },
        {
          'code': 'INV-02',
          'region': 'West',
          'owner': 'Operations',
          'status': 'Review',
        },
        {
          'code': 'INV-03',
          'region': 'East',
          'owner': 'Finance',
          'status': 'Posted',
        },
      ]),
    );
  }

  SuperTableController<_Row> _buildMaxCellController() {
    return SuperTableController<_Row>(
      mode: SuperTableMode.readable,
      columns: [
        SuperTextColumn(
          key: 'code',
          label: ExampleL10n.current.codeMaxCell,
          width: 90,
          widthFit: SuperColumnWidthFit.maxCell,
          mono: true,
        ),
        SuperTextColumn(
          key: 'description',
          label: ExampleL10n.current.descriptionMaxCell,
          width: 120,
          widthFit: SuperColumnWidthFit.maxCell,
        ),
        SuperTextColumn(
          key: 'note',
          label: ExampleL10n.current.noteMaxCell,
          width: 100,
          widthFit: SuperColumnWidthFit.maxCell,
        ),
      ],
      rows: _rows([
        {'code': 'P-1', 'description': 'Bolt', 'note': 'Short'},
        {
          'code': 'PRODUCT-2026-VERY-LONG-CODE',
          'description': 'Industrial stainless steel mounting bracket',
          'note': 'This row intentionally contains the widest visible cell.',
        },
        {'code': 'P-3', 'description': 'Washer', 'note': 'Medium note'},
      ]),
    );
  }

  SuperTableController<_Row> _buildFitController() {
    return SuperTableController<_Row>(
      mode: SuperTableMode.readable,
      columns: [
        SuperTextColumn(
          key: 'code',
          label: ExampleL10n.current.fixed120Px,
          width: 120,
          widthFit: SuperColumnWidthFit.none,
          mono: true,
        ),
        SuperTextColumn(
          key: 'name',
          label: ExampleL10n.current.fitABase150,
          width: 150,
          widthFit: SuperColumnWidthFit.fit,
        ),
        SuperTextColumn(
          key: 'notes',
          label: ExampleL10n.current.fitBBase150,
          width: 150,
          widthFit: SuperColumnWidthFit.fit,
        ),
      ],
      rows: _rows([
        {
          'code': '1000',
          'name': 'Cash',
          'notes': 'Both fit columns share unused width equally.',
        },
        {
          'code': '2000',
          'name': 'Accounts payable',
          'notes': 'When no empty width remains, base widths are retained.',
        },
        {
          'code': '3000',
          'name': 'Revenue',
          'notes': 'Resize the window to watch both fit columns grow together.',
        },
      ]),
    );
  }

  static List<SuperRow<_Row>> _rows(List<_Row> rows) => [
    for (final row in rows) SuperRow.map(row),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.superTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.surface,
        foregroundColor: theme.fg1,
        title: Text(ExampleL10n.current.columnWidthFit),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(spacing.space6),
          children: [
            Text(
              ExampleL10n.current.sUPERCOLUMNWIDTHFITTwoEightZero,
              style: context.superTextTheme.eyebrow.copyWith(
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: spacing.space2),
            Text(
              ExampleL10n.current.fourWaysToSizeTableColumns,
              style: context.superTextTheme.h1.copyWith(color: theme.fg1),
            ),
            SizedBox(height: spacing.space2),
            Text(
              ExampleL10n.current.resizeThisWindowWhileViewingTheAutoAndFitSectionsTheTablesResolvf66f1f9,
              style: context.superTextTheme.body.copyWith(color: theme.fg3),
            ),
            SizedBox(height: spacing.space6),
            _modeCard(
              context,
              mode: ExampleL10n.current.superColumnWidthFitNone,
              title: ExampleL10n.current.oneNoneFixedWidth,
              description:
                  ExampleL10n.current.usesTheColumnWidthExactlyAsDeclaredIfWidthIsNotSpecifiedTheTyped1d19a8c,
              rules: const [
                'Declared width is authoritative.',
                'Does not consume or share spare viewport width.',
                'Horizontal scrolling is preserved when fixed columns are wider than the viewport.',
              ],
              controller: _noneController,
            ),
            SizedBox(height: spacing.space6),
            _modeCard(
              context,
              mode: ExampleL10n.current.superColumnWidthFitAuto,
              title: ExampleL10n.current.twoAutoEqualResponsiveWidth,
              description:
                  ExampleL10n.current.allAutoColumnsReceiveTheSameWidthFromTheHorizontalSpaceLeftAfterc1a55d1,
              rules: const [
                'Every auto column receives the same resolved width.',
                'Declared widths do not control the final auto share.',
                'Resize the window: Auto A, B and C remain equal.',
              ],
              controller: _autoController,
            ),
            SizedBox(height: spacing.space6),
            _modeCard(
              context,
              mode: ExampleL10n.current.superColumnWidthFitMaxCell,
              title: ExampleL10n.current.threeMaxCellIntrinsicContentWidth,
              description:
                  ExampleL10n.current.measuresRenderedRowTextAndUsesTheWidestVisibleCellContentPlusNor8947460,
              rules: const [
                'A longer cell makes that column wider.',
                'Each maxCell column is measured independently.',
                'With no rows, the declared width is used as the fallback.',
              ],
              controller: _maxCellController,
            ),
            SizedBox(height: spacing.space6),
            _modeCard(
              context,
              mode: ExampleL10n.current.superColumnWidthFitFit,
              title: ExampleL10n.current.fourFitFillOtherwiseEmptySpace,
              description:
                  ExampleL10n.current.startsFromTheDeclaredBaseWidthAnyViewportWidthStillUnusedAfterAl2e61e70,
              rules: const [
                'The declared width is the minimum/base width.',
                'Multiple fit columns share only the remaining empty space.',
                'If there is no spare space, fit columns keep their base widths.',
              ],
              controller: _fitController,
            ),
            SizedBox(height: spacing.space6),
            _manualResizeNote(context),
            SizedBox(height: spacing.space8),
          ],
        ),
      ),
    );
  }

  Widget _modeCard(
    BuildContext context, {
    required String mode,
    required String title,
    required String description,
    required List<String> rules,
    required SuperTableController<_Row> controller,
  }) {
    final theme = context.superTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return SuperSectionCard1(
      padding: spacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: spacing.space2,
            runSpacing: spacing.space2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                title,
                style: context.superTextTheme.heading.copyWith(
                  color: theme.fg1,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.space2,
                  vertical: spacing.space1,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: spacing.borderRadiusControl,
                ),
                child: Text(
                  mode,
                  style: context.superTextTheme.mono.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.space2),
          Text(
            description,
            style: context.superTextTheme.body.copyWith(color: theme.fg2),
          ),
          SizedBox(height: spacing.space3),
          for (final rule in rules)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.space1),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: context.superTextTheme.body.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: spacing.space2),
                  Expanded(
                    child: Text(
                      rule,
                      style: context.superTextTheme.caption.copyWith(
                        color: theme.fg3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: spacing.space3),
          Container(
            height: 255,
            decoration: BoxDecoration(
              border: Border.all(color: theme.border),
              borderRadius: spacing.borderRadiusCard,
            ),
            clipBehavior: Clip.antiAlias,
            child: SuperTable<_Row>(
              controller: controller,
              showFooter: false,
              columnFilters: false,
              numbered: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _manualResizeNote(BuildContext context) {
    final theme = context.superTheme;
    final spacing = theme.spacing;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: spacing.cardPadding,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          colorScheme.primary.withValues(alpha: 0.08),
          theme.surface,
        ),
        border: Border.all(color: theme.borderStrong),
        borderRadius: spacing.borderRadiusCard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.drag_indicator_rounded, color: colorScheme.primary),
          SizedBox(width: spacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ExampleL10n.current.manualWidthOverride,
                  style: context.superTextTheme.heading.copyWith(
                    color: theme.fg1,
                  ),
                ),
                SizedBox(height: spacing.space1),
                Text(
                  ExampleL10n.current.controllerSetWidthKeyPxAlwaysWinsOverWidthFitCallControllerReset0192e51,
                  style: context.superTextTheme.body.copyWith(color: theme.fg2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
