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
// 1.0.0 adds the ERP essentials: opt-in **change tracking** (add/modify/delete
// deltas via `controller.changes`), **CSV/TSV/JSON export**, **custom + min/max
// aggregations**, **selection statistics**, **per-cell edit locking**, and
// **manual row reordering**.
//
// 2.1.0 adds the forms & views layer: a table-wide **validation summary**
// (`validateAll` / `isValid` / `unique:` columns / `showSuperValidationPanel`),
// **saved views** (`viewStateJson` / `applyViewJson`), **fill down / fill
// right** (⌘D/⌘R), **Σ group footers** (`SuperTable(groupFooters:)`), and
// **per-cell / per-row revert** on top of change tracking.
//
// In EDITABLE mode, `SuperColumnType.combo` cells are edited through the
// design-system-native `AutoSuggestionsBox` (see `super_cell.dart`): type to
// filter, ↑/↓ to move, Enter/click to pick, or type a free value and commit.
// ============================================================

export 'domain/entities/super_row_expansion.dart';
export 'domain/entities/super_column.dart';
export 'domain/entities/super_columns.dart';
export 'domain/entities/super_row.dart';
export 'domain/entities/super_style.dart';
export 'domain/entities/super_change.dart';
export 'domain/entities/super_filter.dart';
export 'domain/entities/super_group.dart';
export 'domain/entities/super_table_state.dart';
export 'domain/entities/super_validation.dart';
export 'domain/entities/super_view_state.dart';
export 'domain/usecases/super_column_logic.dart';
export 'presentation/controllers/super_table_controller.dart';
export 'presentation/widgets/super_table_skin.dart';
export 'presentation/widgets/super_cell.dart';
export 'presentation/widgets/super_table_overlays.dart';
export 'presentation/widgets/super_table.dart';
export 'presentation/pages/super_table_demo.dart';
