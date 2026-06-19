// ============================================================
// features/super_table/domain/entities/super_change.dart
// ------------------------------------------------------------
// The change-tracking value types for SuperTable 1.0.0.
//
// ERP grids are almost always a staging surface for a backend write: the user
// edits a journal / inventory issue / settlement, then the app posts *only the
// delta* (the rows that were added, the cells that changed, the rows that were
// removed). These types model that delta.
//
// Opt in with `SuperTableController(trackChanges: true)`. The controller then
// captures a per-cell *baseline* and exposes [SuperChangeSet] through
// `controller.changes` (plus `hasChanges`, `isRowDirty`, `isCellDirty`,
// `acceptChanges`, `rejectChanges`).
//
// Pure data — no Flutter here.
// ============================================================

import 'super_row.dart';

/// The tracked state of a row relative to the last accepted baseline.
enum SuperRowState {
  /// Unchanged since the baseline.
  pristine,

  /// Created after the baseline (a brand-new row not yet persisted).
  added,

  /// Existed at the baseline but has at least one changed cell.
  modified,

  /// Existed at the baseline and was removed.
  deleted,
}

/// One changed cell within a [SuperRowChange]: the column [columnKey] plus its
/// [oldValue] (baseline) and [newValue] (current).
class SuperCellChange {
  final String columnKey;
  final Object? oldValue;
  final Object? newValue;
  const SuperCellChange({required this.columnKey, this.oldValue, this.newValue});

  Map<String, dynamic> toJson() => {
        'column': columnKey,
        'old': oldValue,
        'new': newValue,
      };

  @override
  String toString() => 'SuperCellChange($columnKey: $oldValue → $newValue)';
}

/// One changed row: its [state], the backing [row], and (for [SuperRowState.modified])
/// the per-column [cellChanges].
class SuperRowChange<R> {
  final SuperRowState state;
  final SuperRow<R> row;
  final List<SuperCellChange> cellChanges;
  const SuperRowChange({required this.state, required this.row, this.cellChanges = const []});

  /// A `{columnKey: value}` snapshot of the row's current cell values.
  Map<String, Object?> get snapshot => row.snapshot;

  /// A compact JSON delta for this row: the row id, its state, the current
  /// values, and (when modified) the changed columns.
  Map<String, dynamic> toJson() => {
        'id': row.id,
        'state': state.name,
        'values': snapshot,
        if (cellChanges.isNotEmpty) 'changes': [for (final c in cellChanges) c.toJson()],
      };
}

/// The complete set of edits since the last accepted baseline, partitioned into
/// [added] / [modified] / [deleted]. Hand `toJson()` straight to a backend, or
/// iterate the partitions to build your own persistence payload.
class SuperChangeSet<R> {
  final List<SuperRowChange<R>> added;
  final List<SuperRowChange<R>> modified;
  final List<SuperRowChange<R>> deleted;

  const SuperChangeSet({this.added = const [], this.modified = const [], this.deleted = const []});

  /// Every change, in `added ▸ modified ▸ deleted` order.
  List<SuperRowChange<R>> get all => [...added, ...modified, ...deleted];

  /// Total number of changed rows.
  int get count => added.length + modified.length + deleted.length;

  bool get isEmpty => count == 0;
  bool get isNotEmpty => count > 0;

  Map<String, dynamic> toJson() => {
        'added': [for (final r in added) r.toJson()],
        'modified': [for (final r in modified) r.toJson()],
        'deleted': [for (final r in deleted) r.toJson()],
      };

  @override
  String toString() =>
      'SuperChangeSet(added: ${added.length}, modified: ${modified.length}, deleted: ${deleted.length})';
}
