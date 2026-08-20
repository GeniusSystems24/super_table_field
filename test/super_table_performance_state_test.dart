import 'package:flutter_test/flutter_test.dart';
import 'package:super_table_field/super_table_field.dart';

void main() {
  group('SuperTableController v3 materialized state', () {
    test('derived getters rebuild the pipeline once, then stay O(1)', () {
      final controller = _controller(rowCount: 100);
      addTearDown(controller.dispose);
      controller.resetDebugPerformanceCounters();

      final render = controller.renderList;
      expect(render, hasLength(100));
      expect(controller.debugPipelineRebuildCount, 1);
      expect(controller.debugRowIndexRebuildCount, 1);

      // Repeated frame-style reads must not run filtering/sorting/grouping again.
      expect(identical(render, controller.renderList), isTrue);
      expect(controller.view, hasLength(100));
      expect(controller.filteredRows, hasLength(100));
      expect(controller.sortedRows, hasLength(100));
      expect(controller.nRows, 100);
      expect(controller.pageCount, 1);
      expect(controller.debugPipelineRebuildCount, 1);
      expect(controller.debugRowIndexRebuildCount, 1);
    });

    test('selection-only mutations do not invalidate the data pipeline', () {
      final controller = _controller(rowCount: 20);
      addTearDown(controller.dispose);
      controller.renderList;
      controller.resetDebugPerformanceCounters();

      controller.pick(5, 1);
      controller.setFocused(true);
      controller.selectGutterRow(7);

      controller.renderList;
      controller.view;
      expect(controller.debugPipelineRebuildCount, 0);
      expect(controller.debugRowIndexRebuildCount, 0);
    });

    test('filter mutation rebuilds once and subsequent reads reuse snapshot', () {
      final controller = _controller(rowCount: 100);
      addTearDown(controller.dispose);
      controller.renderList;
      controller.resetDebugPerformanceCounters();

      controller.setSearch('row 9');
      final buildsAfterMutation = controller.debugPipelineRebuildCount;
      expect(buildsAfterMutation, 1);
      expect(controller.nRows, 11); // row 9 + row 90...row 99

      controller.renderList;
      controller.view;
      controller.sortedRows;
      expect(controller.debugPipelineRebuildCount, buildsAfterMutation);
    });

    test('column lookup and resolved columns are materialized', () {
      final controller = _controller(rowCount: 2);
      addTearDown(controller.dispose);
      controller.resetDebugPerformanceCounters();

      final firstCols = controller.cols;
      expect(controller.colByKey('name')?.label, 'Name');
      expect(controller.colByKey('amount')?.label, 'Amount');
      expect(identical(firstCols, controller.cols), isTrue);
      expect(controller.debugColumnCacheRebuildCount, 1);

      controller.reorder(0, 1);
      final secondCols = controller.cols;
      expect(controller.debugColumnCacheRebuildCount, 2);
      expect(secondCols.map((c) => c.key), ['amount', 'name']);
    });

    test('row source indexes are O(1) and remain correct after sorting', () {
      final controller = _controller(rowCount: 8);
      addTearDown(controller.dispose);
      final amount = controller.colByKey('amount')!;

      controller.sortBy(amount, false);
      final view = controller.view;

      expect(view.first.row?['amount'], 7);
      expect(view.first.sourceIndex, 7);
      expect(view.last.row?['amount'], 0);
      expect(view.last.sourceIndex, 0);
    });

    test('batch coalesces listener notifications', () {
      final controller = _controller(rowCount: 10);
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.batch(() {
        controller.setFocused(true);
        controller.setSelectionMode(SuperSelectionMode.multiCells);
        controller.setPage(0);
      });

      expect(notifications, 1);
    });
  });
}

SuperTableController<Map<String, dynamic>> _controller({required int rowCount}) {
  return SuperTableController<Map<String, dynamic>>(
    columns: [
      SuperTextColumn(key: 'name', label: 'Name', width: 140),
      SuperNumberColumn<num>(key: 'amount', label: 'Amount', width: 100),
    ],
    rows: [
      for (var i = 0; i < rowCount; i++)
        SuperRow.map({'name': 'row $i', 'amount': i}),
    ],
  );
}
