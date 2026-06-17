// ============================================================
// features/super_table/super_table.dart
// ------------------------------------------------------------
// Public barrel for the SuperTable feature.
//
// One keyboard-first grid with `mode: readable | editable`, 13 column types,
// 4 selection modes, search, multi-level grouping with aggregates, totals,
// pagination, JSON/TSV clipboard, and undo/redo. A faithful port of the React
// `super-table` tool. Build it from a `SuperTableController` + a list of
// `SuperColumn`s over `SuperRow` (`Map<String, dynamic>`) data.
//
// In EDITABLE mode, `SuperColumnType.combo` cells are edited through the
// design-system-native `AutoSuggestionsBox` (see `super_cell.dart`): type to
// filter, ↑/↓ to move, Enter/click to pick, or type a free value and commit.
// ============================================================

export 'domain/entities/super_column.dart';
export 'domain/entities/super_columns.dart';
export 'domain/entities/super_row.dart';
export 'domain/entities/super_style.dart';
export 'domain/entities/super_filter.dart';
export 'domain/entities/super_table_state.dart';
export 'domain/usecases/super_column_logic.dart';
export 'presentation/controllers/super_table_controller.dart';
export 'presentation/widgets/super_table_skin.dart';
export 'presentation/widgets/super_cell.dart';
export 'presentation/widgets/super_table_overlays.dart';
export 'presentation/widgets/super_table.dart';
export 'presentation/pages/super_table_demo.dart';
