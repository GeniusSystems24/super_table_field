// ============================================================
// features/super_table/domain/entities/super_group.dart
// ------------------------------------------------------------
// The value type returned by the SuperTable's **programmatic** grouping +
// aggregation API (1.1.0): `SuperTableController.groupAggregates(...)`.
//
// A [SuperGroupAggregate] is one node of a (possibly nested) group tree. It
// names the grouping column + value, carries the rows that fell into the group,
// the per-column [aggregates] computed over them, and — for multi-level
// grouping — its [children] subgroups. It is a pure read-model: building it
// never mutates the controller and is independent of the on-screen render list
// (collapse state is ignored; every group is included).
//
// Pure data — no Flutter here.
// ============================================================

import 'super_row.dart';

/// A const, type-erased empty children list. Used as the default for
/// [SuperGroupAggregate.children] so the constructor can stay `const` without
/// naming the type variable `R` in a constant expression (which Dart forbids).
const List<Never> _noGroupChildren = [];

/// One group node from [groupAggregates]: a bucket of rows that share the same
/// value of one grouping column, with its rolled-up [aggregates] and any nested
/// [children] (the next grouping level).
class SuperGroupAggregate<R> {
  /// The key of the column this level groups by.
  final String columnKey;

  /// That column's display label (convenience for building headers).
  final String columnLabel;

  /// The shared group value, as display text (e.g. `'Raw Material'`).
  final String value;

  /// Nesting depth — 0 for a top-level group, 1 for its children, …
  final int depth;

  /// A stable path identifier for this node (`'/0:Raw Material/1:Steel'`),
  /// matching the render-list group path so UI and data can be correlated.
  final String path;

  /// How many rows fell into this group (including all descendants).
  final int count;

  /// The rows in this group (all descendants, in source order).
  final List<SuperRow<R>> rows;

  /// `columnKey → aggregate value` for every requested aggregate column. A
  /// value is null when the column has no aggregate (or it is a no-op).
  final Map<String, num?> aggregates;

  /// The next-level subgroups, or empty when this is the deepest level.
  final List<SuperGroupAggregate<R>> children;

  const SuperGroupAggregate({
    required this.columnKey,
    required this.columnLabel,
    required this.value,
    required this.depth,
    required this.path,
    required this.count,
    required this.rows,
    required this.aggregates,
    this.children = _noGroupChildren,
  });

  /// Whether this is a leaf group (no nested subgroups).
  bool get isLeaf => children.isEmpty;

  /// The aggregate computed for [columnKey] in this group (null if absent).
  num? aggregate(String columnKey) => aggregates[columnKey];

  /// Flatten this node and all descendants into a single list (pre-order).
  List<SuperGroupAggregate<R>> flatten() => [
        this,
        for (final child in children) ...child.flatten(),
      ];

  /// A JSON view of the group (rows are summarised by [count], not serialised).
  Map<String, dynamic> toJson() => {
        'column': columnKey,
        'value': value,
        'depth': depth,
        'path': path,
        'count': count,
        'aggregates': aggregates,
        if (children.isNotEmpty) 'children': [for (final c in children) c.toJson()],
      };

  @override
  String toString() =>
      'SuperGroupAggregate($columnKey=$value, count: $count, aggregates: $aggregates'
      '${children.isEmpty ? '' : ', children: ${children.length}'})';
}
