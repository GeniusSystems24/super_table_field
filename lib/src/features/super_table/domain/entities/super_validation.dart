// ============================================================
// features/super_table/domain/entities/super_validation.dart
// ------------------------------------------------------------
// The validation-summary value type (2.1.0). One [SuperValidationIssue] is
// produced by `SuperTableController.validateAll()` per failing cell — the
// built-in type rules, the `unique:` constraint, and the column `validator`
// all report through it. ERP forms gate their *Post* / *Save* actions on
// `controller.isValid` and list the issues with jump-to-cell.
//
// Pure data — no Flutter here.
// ============================================================

import 'super_row.dart';
import 'super_table_state.dart';

/// One failing cell found by `SuperTableController.validateAll()`.
class SuperValidationIssue<R> {
  /// The row holding the failing cell.
  final SuperRow<R> row;

  /// Index of [row] within `controller.rows` (source order, 0-based).
  final int sourceIndex;

  /// Index of [row] within the live view (post filter/sort/page), or null when
  /// the row is currently filtered or paged out of view.
  final int? viewRow;

  /// Index of the column within `controller.cols`, or null when the column is
  /// hidden or excluded by the visible-keys allow-list.
  final int? colIndex;

  /// The failing column's key and label.
  final String columnKey;
  final String columnLabel;

  /// The error code/message (from the built-in rules, the `unique:` check, or
  /// the column `validator`).
  final String message;

  const SuperValidationIssue({
    required this.row,
    required this.sourceIndex,
    required this.columnKey,
    required this.columnLabel,
    required this.message,
    this.viewRow,
    this.colIndex,
  });

  /// The cell's view coordinate for jump-to-cell
  /// (`controller.selectCellAt(cell.r, cell.c)`), or null when the cell is not
  /// currently on screen.
  CellPos? get cell =>
      viewRow == null || colIndex == null ? null : CellPos(viewRow!, colIndex!);

  Map<String, dynamic> toJson() => {
        'row': sourceIndex,
        'column': columnKey,
        'message': message,
      };

  @override
  String toString() => 'SuperValidationIssue(row $sourceIndex, $columnKey: $message)';
}
