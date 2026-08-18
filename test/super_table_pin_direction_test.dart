import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_table_field/super_table_field.dart';

void main() {
  testWidgets('SuperPin.start/end follow TextDirection', (tester) async {
    final controller = SuperTableController<Object>(
      columns: [
        SuperTextColumn(key: 'start', label: 'Start', pin: SuperPin.start),
        SuperTextColumn(key: 'middle', label: 'Middle'),
        SuperTextColumn(key: 'end', label: 'End', pin: SuperPin.end),
      ],
      rows: const [],
    );
    addTearDown(controller.dispose);

    Future<Map<String, double>> positions(TextDirection direction) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: direction,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 300,
                child: Row(
                  children: [
                    for (final column in controller.cols)
                      SizedBox(
                        key: ValueKey(column.key),
                        width: 100,
                        height: 40,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      return {
        for (final key in const ['start', 'middle', 'end'])
          key: tester.getTopLeft(find.byKey(ValueKey(key))).dx,
      };
    }

    // Controller order is logical and must not be manually mirrored.
    expect(controller.cols.map((column) => column.key).toList(), const [
      'start',
      'middle',
      'end',
    ]);

    final ltr = await positions(TextDirection.ltr);
    expect(ltr['start']!, lessThan(ltr['middle']!));
    expect(ltr['middle']!, lessThan(ltr['end']!));

    final rtl = await positions(TextDirection.rtl);
    expect(rtl['start']!, greaterThan(rtl['middle']!));
    expect(rtl['middle']!, greaterThan(rtl['end']!));
  });

  test(
    'persisted legacy left/right pin names migrate to logical start/end',
    () {
      final controller = SuperTableController<Object>(
        columns: [
          SuperTextColumn(key: 'a', label: 'A'),
          SuperTextColumn(key: 'b', label: 'B'),
        ],
        rows: const [],
      );
      addTearDown(controller.dispose);

      controller.applyViewState(
        SuperViewState(pins: const {'a': 'left', 'b': 'right'}),
      );

      expect(controller.pinOf(controller.colByKey('a')!), SuperPin.start);
      expect(controller.pinOf(controller.colByKey('b')!), SuperPin.end);

      final saved = controller.viewState();
      expect(saved.pins['a'], 'start');
      expect(saved.pins['b'], 'end');
    },
  );
}
