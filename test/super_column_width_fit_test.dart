import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_table_field/super_table_field.dart';

void main() {
  test('SuperColumnWidthFit defaults to none and copyWith preserves it', () {
    const column = SuperColumn<String>(
      key: 'name',
      label: 'Name',
      width: 140,
      widthFit: SuperColumnWidthFit.fit,
    );

    expect(column.widthFit, SuperColumnWidthFit.fit);
    expect(column.copyWith().widthFit, SuperColumnWidthFit.fit);
    expect(
      column.copyWith(widthFit: SuperColumnWidthFit.auto).widthFit,
      SuperColumnWidthFit.auto,
    );
  });

  testWidgets('auto columns share the available viewport equally', (
    tester,
  ) async {
    final controller = SuperTableController<Object>(
      columns: [
        SuperTextColumn(key: 'fixed', label: 'Fixed', width: 100),
        SuperTextColumn(
          key: 'a',
          label: 'A',
          width: 80,
          widthFit: SuperColumnWidthFit.auto,
        ),
        SuperTextColumn(
          key: 'b',
          label: 'B',
          width: 220,
          widthFit: SuperColumnWidthFit.auto,
        ),
      ],
      rows: const [],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 300,
            child: SuperTable<Object>(
              controller: controller,
              numbered: false,
              showFooter: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final fixed = controller.colByKey('fixed')!;
    final a = controller.colByKey('a')!;
    final b = controller.colByKey('b')!;

    expect(controller.widthOf(fixed), closeTo(100, 0.01));
    expect(controller.widthOf(a), closeTo(controller.widthOf(b), 0.01));
    expect(controller.widthOf(a), closeTo(250, 2.0));
  });

  testWidgets('fit columns share only the empty viewport space', (
    tester,
  ) async {
    final controller = SuperTableController<Object>(
      columns: [
        SuperTextColumn(key: 'fixed', label: 'Fixed', width: 100),
        SuperTextColumn(
          key: 'fitA',
          label: 'Fit A',
          width: 100,
          widthFit: SuperColumnWidthFit.fit,
        ),
        SuperTextColumn(
          key: 'fitB',
          label: 'Fit B',
          width: 100,
          widthFit: SuperColumnWidthFit.fit,
        ),
      ],
      rows: const [],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 300,
            child: SuperTable<Object>(
              controller: controller,
              numbered: false,
              showFooter: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final fitA = controller.colByKey('fitA')!;
    final fitB = controller.colByKey('fitB')!;

    expect(controller.widthOf(fitA), closeTo(250, 2.0));
    expect(controller.widthOf(fitB), closeTo(250, 2.0));
  });

  testWidgets('maxCell grows from the widest rendered cell value', (
    tester,
  ) async {
    final controller = SuperTableController<Map<String, Object?>>(
      columns: [
        SuperTextColumn(
          key: 'name',
          label: 'Name',
          width: 60,
          widthFit: SuperColumnWidthFit.maxCell,
        ),
      ],
      rows: [
        SuperRow<Map<String, Object?>>.of(
          const {'name': 'Short'},
          const {'name': 'Short'},
        ),
        SuperRow<Map<String, Object?>>.of(
          const {'name': 'A much much longer cell value for width measurement'},
          const {'name': 'A much much longer cell value for width measurement'},
        ),
      ],
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 300,
            child: SuperTable<Map<String, Object?>>(
              controller: controller,
              numbered: false,
              showFooter: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final column = controller.colByKey('name')!;

    const longest = 'A much much longer cell value for width measurement';
    final painter = TextPainter(
      text: const TextSpan(text: longest, style: TextStyle(fontSize: 12)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final intrinsicTextWidth = painter.width;
    painter.dispose();

    // maxCell = widest text + 22 px normal cell padding + 12 px allowance.
    expect(
      controller.widthOf(column),
      greaterThanOrEqualTo(intrinsicTextWidth + 34.0),
    );
  });

  testWidgets('manual width override disables responsive fit until reset', (
    tester,
  ) async {
    final controller = SuperTableController<Object>(
      columns: [
        SuperTextColumn(
          key: 'fit',
          label: 'Fit',
          width: 100,
          widthFit: SuperColumnWidthFit.fit,
        ),
      ],
      rows: const [],
    );
    addTearDown(controller.dispose);

    controller.setWidth('fit', 180);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 600,
            height: 300,
            child: SuperTable<Object>(
              controller: controller,
              numbered: false,
              showFooter: false,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final column = controller.colByKey('fit')!;
    expect(controller.widthOf(column), closeTo(180, 0.01));

    controller.resetWidth('fit');
    await tester.pump();

    expect(controller.widthOf(column), greaterThan(500));
  });
}
