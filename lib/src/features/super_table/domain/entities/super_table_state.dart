// ============================================================
// features/super_table/domain/entities/super_table_state.dart
// ------------------------------------------------------------
// Small value types describing the unified SuperTable's mode + view state:
// the grid mode, selection model, pagination strategy, density, a sort spec,
// a cell coordinate, and the interleaved render-list item (group header vs
// data row). All immutable; the controller owns the live instances.
// ============================================================

import 'package:flutter/foundation.dart';

import 'super_column.dart';

/// readable = sortable/selectable/copyable display grid;
/// editable = spreadsheet cell editing + row ops.
enum SuperTableMode { readable, editable }

/// How selection behaves: a single cursor cell, a rectangular + discrete cell
/// range, a single whole row, or many whole rows.
enum SuperSelectionMode { singleCell, multiCells, singleRow, multiRows }

/// How overflow rows are paged.
enum SuperPagination { none, pages, infinite, loadMore }

/// Row height preset.
enum SuperDensity { comfortable, compact }

/// A sort specification: which [key] (null = unsorted) and direction.
@immutable
class SortSpec {
  final String? key;
  final bool ascending;
  const SortSpec({this.key, this.ascending = true});

  SortSpec copyWith({String? key, bool? ascending}) =>
      SortSpec(key: key ?? this.key, ascending: ascending ?? this.ascending);
}

/// A cell coordinate in the *view* (post-filter/sort/paginate) space.
@immutable
class SuperCell {
  final int r;
  final int c;
  const SuperCell(this.r, this.c);

  String get token => '$r:$c';

  @override
  bool operator ==(Object other) => other is SuperCell && other.r == r && other.c == c;
  @override
  int get hashCode => Object.hash(r, c);
}

/// One entry of the flat render list: either a [group] header or a [data] row.
@immutable
class RenderItem {
  final bool isGroup;

  // data-row fields
  final SuperRow? row;
  final int dataIndex; // index within the visible data view
  final int sourceIndex; // index within the original rows list

  // group-header fields
  final SuperColumn? groupCol;
  final String? groupValue;
  final int groupCount;
  final int depth;
  final String path;
  final List<SuperRow> groupRows;

  const RenderItem.data({
    required this.row,
    required this.dataIndex,
    required this.sourceIndex,
  })  : isGroup = false,
        groupCol = null,
        groupValue = null,
        groupCount = 0,
        depth = 0,
        path = '',
        groupRows = const [];

  const RenderItem.group({
    required this.groupCol,
    required this.groupValue,
    required this.groupCount,
    required this.depth,
    required this.path,
    required this.groupRows,
  })  : isGroup = true,
        row = null,
        dataIndex = -1,
        sourceIndex = -1;
}

/// A toast-style notification kind raised by the controller (copy/paste, etc.).
enum SuperNotifyKind { ok, error }
