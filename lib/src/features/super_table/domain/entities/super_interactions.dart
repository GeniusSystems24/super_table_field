// ============================================================
// features/super_table/domain/entities/super_interactions.dart
// ------------------------------------------------------------
// Host interaction callbacks for the SuperTable (2.2.0). A single immutable
// [SuperInteractions] bag is handed to `SuperTable(interactions:)`; the View
// fires each callback in response to pointer taps, keyboard activation, and
// selection / sort changes — WITHOUT altering the grid's own behaviour (the
// table still selects, edits, sorts, and opens its menus exactly as before).
//
// Use them to drive the surrounding screen: open a detail drawer when a row is
// activated, mirror the cursor into a preview pane, log an audit trail, sync a
// URL query, enable a toolbar button when a selection exists, etc.
//
// Every callback receives a small, self-contained *details* object carrying the
// view + source coordinates, the live [SuperRow] / [SuperColumn] / [SuperCell],
// the raw value, the controller, and (for pointer events) the global position —
// so a host can pop its own menu or overlay at the tap point.
//
// Pure data + callbacks; the only Flutter type referenced is [Offset].
// ============================================================

import 'package:flutter/widgets.dart' show Offset;

import '../../presentation/controllers/super_table_controller.dart';
import 'super_column.dart';
import 'super_row.dart';
import 'super_table_state.dart';

/// Details for a **cell** pointer interaction (tap / double-tap / secondary).
class SuperCellInteraction<R> {
  /// Row index in the *view* (post filter / sort / paginate) space.
  final int rowIndex;

  /// Visible column index (matches [SuperTableController.cols]).
  final int columnIndex;

  /// Index of the row in the original, unfiltered `controller.rows` list.
  final int sourceIndex;

  /// The column that was hit.
  final SuperColumn column;

  /// The row that was hit.
  final SuperRow<R> row;

  /// The editable cell data (`value` + `error`), or null if the row has no
  /// cell for this column yet.
  final SuperCell? cell;

  /// The column's raw value for this row (compute ▸ accessor ▸ cell).
  final Object? value;

  /// The live controller — call mutators or read further state from it.
  final SuperTableController<R> controller;

  /// The global pointer position of the gesture (for popping host overlays).
  final Offset globalPosition;

  const SuperCellInteraction({
    required this.rowIndex,
    required this.columnIndex,
    required this.sourceIndex,
    required this.column,
    required this.row,
    required this.cell,
    required this.value,
    required this.controller,
    required this.globalPosition,
  });

  /// The cursor coordinate for this cell.
  CellPos get pos => CellPos(rowIndex, columnIndex);
}

/// Details for a **row** interaction: a row-number gutter tap ([onRowTap]) or a
/// row activation ([onRowActivate] — double-tap a row / Enter in readable mode).
class SuperRowInteraction<R> {
  /// Row index in the view space.
  final int rowIndex;

  /// Index of the row in the original `controller.rows` list.
  final int sourceIndex;

  /// The row that was hit / activated.
  final SuperRow<R> row;

  /// The live controller.
  final SuperTableController<R> controller;

  /// The global pointer position — null for keyboard activation.
  final Offset? globalPosition;

  const SuperRowInteraction({
    required this.rowIndex,
    required this.sourceIndex,
    required this.row,
    required this.controller,
    this.globalPosition,
  });
}

/// A snapshot of the grid's selection at the moment it changed — passed to
/// [SuperInteractions.onSelectionChanged].
class SuperSelectionSnapshot<R> {
  /// The active cursor cell.
  final CellPos cursor;

  /// The range anchor (equal to [cursor] when there is no range).
  final CellPos anchor;

  /// Whole-row selection (row-selection modes) or the row band lit from the
  /// gutter (cell modes).
  final Set<int> selectedRows;

  /// Every currently-selected cell coordinate (range + discrete + rows).
  final List<CellPos> cells;

  /// The running numeric aggregate over the selection, or null when fewer than
  /// one numeric cell is selected (mirrors `controller.selectionStats`).
  final SuperSelectionStats? stats;

  const SuperSelectionSnapshot({
    required this.cursor,
    required this.anchor,
    required this.selectedRows,
    required this.cells,
    required this.stats,
  });

  /// Whether more than one cell is selected.
  bool get isRange => cells.length > 1;
}

/// A snapshot of the active sort — passed to [SuperInteractions.onSortChanged].
class SuperSortSnapshot {
  /// The sorted column key, or null when the table returned to natural order.
  final String? columnKey;

  /// The sorted column's label (null when unsorted or the column is gone).
  final String? columnLabel;

  /// Sort direction (meaningless when [columnKey] is null).
  final bool ascending;

  const SuperSortSnapshot({
    required this.columnKey,
    required this.columnLabel,
    required this.ascending,
  });

  /// Whether a sort is currently applied.
  bool get isSorted => columnKey != null;
}

/// A cell-interaction handler (see [SuperInteractions]).
typedef SuperCellInteractionCallback<R> =
    void Function(SuperCellInteraction<R> details);

/// A row-interaction handler (see [SuperInteractions]).
typedef SuperRowInteractionCallback<R> =
    void Function(SuperRowInteraction<R> details);

/// The set of host interaction callbacks for a [SuperTable]. All optional; a
/// null callback is simply never invoked (and costs nothing). Pass the ones you
/// need to `SuperTable(interactions: SuperInteractions(...))`.
///
/// These are *observers* — they never change what the grid does in response to
/// the same gesture. `onCellTap` fires **after** the cell has been selected;
/// `onCellDoubleTap` fires alongside the editor opening (editable mode) or the
/// row activating (readable mode); `onCellSecondaryTap` fires alongside the
/// context menu; selection / sort callbacks fire after the controller settles,
/// so they also catch **programmatic** changes (`selectCellAt`, `sortBy`, …).
class SuperInteractions<R> {
  /// A single (primary) tap on a body cell — fires after selection moves.
  final SuperCellInteractionCallback<R>? onCellTap;

  /// A double-tap / double-click on a body cell.
  final SuperCellInteractionCallback<R>? onCellDoubleTap;

  /// A secondary (right-click) tap on a body cell — fires alongside the row
  /// context menu.
  final SuperCellInteractionCallback<R>? onCellSecondaryTap;

  /// A tap on the row-number gutter cell (which selects the whole row).
  final SuperRowInteractionCallback<R>? onRowTap;

  /// A canonical row **activation**: a double-tap on a readable-mode row, or
  /// pressing Enter with the cursor on a row in readable mode. The natural
  /// "open this record" hook. (In editable mode a double-tap opens the cell
  /// editor instead; activation there is a no-op.)
  final SuperRowInteractionCallback<R>? onRowActivate;

  /// The selection changed (cursor moved, range grew, rows toggled) — by
  /// pointer, keyboard, or a programmatic selection call.
  final void Function(SuperSelectionSnapshot<R> selection)? onSelectionChanged;

  /// The sort column or direction changed (header click, header menu, or
  /// `controller.sortBy` / `clearSort`).
  final void Function(SuperSortSnapshot sort)? onSortChanged;

  const SuperInteractions({
    this.onCellTap,
    this.onCellDoubleTap,
    this.onCellSecondaryTap,
    this.onRowTap,
    this.onRowActivate,
    this.onSelectionChanged,
    this.onSortChanged,
  });

  /// True when no callback is set — the View can skip all interaction work.
  bool get isEmpty =>
      onCellTap == null &&
      onCellDoubleTap == null &&
      onCellSecondaryTap == null &&
      onRowTap == null &&
      onRowActivate == null &&
      onSelectionChanged == null &&
      onSortChanged == null;
}
