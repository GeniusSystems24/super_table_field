import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_table_field/super_table_field.dart';

void main() {
  testWidgets('style null preserves the opt-out API contract', (tester) async {
    final controller = _controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller: controller));

    final table = tester.widget<SuperTable<Map<String, dynamic>>>(
      find.byType(SuperTable<Map<String, dynamic>>),
    );
    expect(table.style, isNull);
  });

  testWidgets('all predefined styles render in light and dark themes', (
    tester,
  ) async {
    for (final style in SuperTableStyle.presets) {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        final controller = _controller(grouped: true);
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _host(controller: controller, style: style, themeMode: mode),
        );
        await tester.pump();

        expect(find.byType(SuperTable<Map<String, dynamic>>), findsOneWidget);
      }
    }
  });

  test(
    'style options expose Office-style switches without structural behavior',
    () {
      expect(SuperTableStyle.bandedRows.options.bandedRows, isTrue);
      expect(SuperTableStyle.bandedColumns.options.bandedColumns, isTrue);
      expect(SuperTableStyle.medium.options.emphasizeFirstColumn, isTrue);
      expect(SuperTableStyle.dark.options.emphasizeLastColumn, isTrue);

      final quiet = SuperTableStyle.accent.copyWith(
        options: const SuperTableStyleOptions(
          bandedRows: false,
          bandedColumns: false,
          emphasizeFirstColumn: false,
          emphasizeLastColumn: false,
        ),
      );

      expect(quiet.options.bandedRows, isFalse);
      expect(quiet.options.bandedColumns, isFalse);
      expect(quiet.options.emphasizeFirstColumn, isFalse);
      expect(quiet.options.emphasizeLastColumn, isFalse);
    },
  );

  testWidgets('conditional row styles still override preset body styling', (
    tester,
  ) async {
    final controller = _controller();
    addTearDown(controller.dispose);

    const override = Color(0xFF123456);
    await tester.pumpWidget(
      _host(
        controller: controller,
        style: SuperTableStyle.light,
        rowStyles: {
          (context, controller, row) =>
              row['account'] == '1100': const SuperRowStyle(
            background: override,
          ),
        },
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget is Container && widget.color == override,
      ),
      findsOneWidget,
    );
  });
}

Widget _host({
  required SuperTableController<Map<String, dynamic>> controller,
  SuperTableStyle? style,
  ThemeMode themeMode = ThemeMode.light,
  Map<SuperRowCondition, SuperRowStyle>? rowStyles,
}) {
  final typography = SuperTextTheme();
  return MaterialApp(
    themeMode: themeMode,
    theme: SuperMaterialThemeData.light(
      textTheme: typography,
      primaryTextTheme: typography,
    ),
    darkTheme: SuperMaterialThemeData.dark(
      textTheme: typography,
      primaryTextTheme: typography,
    ),
    home: Scaffold(
      body: SizedBox(
        height: 360,
        child: SuperTable<Map<String, dynamic>>(
          controller: controller,
          style: style,
          styles: rowStyles,
          groupFooters: true,
          showTotals: true,
          showFooter: false,
          columnFilters: false,
        ),
      ),
    ),
  );
}

SuperTableController<Map<String, dynamic>> _controller({bool grouped = false}) {
  final controller = SuperTableController<Map<String, dynamic>>(
    mode: SuperTableMode.readable,
    selectionMode: SuperSelectionMode.multiCells,
    columns: [
      SuperTextColumn(key: 'account', label: 'Account', width: 110, mono: true),
      SuperTextColumn(key: 'segment', label: 'Segment', width: 130),
      SuperCurrencyColumn(
        key: 'debit',
        label: 'Debit',
        width: 110,
        agg: SuperAgg.sum,
      ),
      SuperCurrencyColumn(
        key: 'credit',
        label: 'Credit',
        width: 110,
        agg: SuperAgg.sum,
      ),
    ],
    rows: [
      SuperRow.map({
        'account': '1100',
        'segment': 'Treasury',
        'debit': 1200.0,
        'credit': 250.0,
      }),
      SuperRow.map({
        'account': '1200',
        'segment': 'Receivables',
        'debit': 780.0,
        'credit': 120.0,
      }),
    ],
  );
  if (grouped) controller.setGroupKeys(['segment']);
  controller.selectCells(const [CellPos(0, 2), CellPos(0, 3)]);
  return controller;
}
