// ============================================================
// features/super_table/domain/entities/super_filter.dart
// ------------------------------------------------------------
// The filtering value types for SuperTable 0.4.0:
//
//   • [FilterItem]          — a (display, value) pair for enumeration / currency
//                             / color filter dropdowns (replaces bare String
//                             option lists, so the shown label can differ from
//                             the matched value).
//   • [FilterValueSource]   — where a column's filter *options* come from:
//                             sync, async (Future) or stream. Built via the
//                             [FilterValueSources] facade.
//   • [FilterOp] / [AdvancedFilterClause] — the advanced (cross-column) filter
//                             model: a list of typed clauses combined with AND.
//   • [SuperFilterState]    — the whole filter state (per-column + advanced +
//                             which is active), serialisable to/from JSON for
//                             programmatic get/set and inclusion in `onLoadMore`.
//
// Pure data — no Flutter here.
// ============================================================

import 'dart:async';

/// A selectable filter value: the [display] label shown in the dropdown and the
/// underlying [value] matched against the column. Replaces the old
/// `List<String>` filter options on enumeration / currency / color columns.
class FilterItem<T> {
  final String display;
  final T value;
  const FilterItem(this.display, this.value);

  @override
  bool operator ==(Object other) =>
      other is FilterItem<T> &&
      other.display == display &&
      other.value == value;
  @override
  int get hashCode => Object.hash(display, value);
}

/// Where a column's filter *options* are sourced from. Use the
/// [FilterValueSources] facade to construct one.
abstract class FilterValueSource<T> {
  const FilterValueSource();

  /// Whether values resolve asynchronously (drives a small loading state).
  bool get isAsync => false;
}

/// Static, in-memory filter options.
class SyncFilterValueSource<T> extends FilterValueSource<T> {
  final List<FilterItem<T>> items;
  const SyncFilterValueSource(this.items);
}

/// Options fetched once via a [Future] (e.g. distinct values from an API).
class AsyncFilterValueSource<T> extends FilterValueSource<T> {
  final Future<List<FilterItem<T>>> Function() load;
  const AsyncFilterValueSource(this.load);
  @override
  bool get isAsync => true;
}

/// Options that arrive (and update) over a [Stream].
class StreamFilterValueSource<T> extends FilterValueSource<T> {
  final Stream<List<FilterItem<T>>> stream;
  const StreamFilterValueSource(this.stream);
  @override
  bool get isAsync => true;
}

/// Factory facade for the three filter-option source flavours.
abstract final class FilterValueSources {
  static FilterValueSource<T> sync<T>(List<FilterItem<T>> items) =>
      SyncFilterValueSource<T>(items);
  static FilterValueSource<T> async<T>(
    Future<List<FilterItem<T>>> Function() load,
  ) => AsyncFilterValueSource<T>(load);
  static FilterValueSource<T> stream<T>(Stream<List<FilterItem<T>>> stream) =>
      StreamFilterValueSource<T>(stream);
}

/// Comparison operators for an advanced filter clause.
enum FilterOp {
  contains('contains'),
  equals('eq'),
  notEquals('neq'),
  startsWith('startsWith'),
  endsWith('endsWith'),
  greaterThan('gt'),
  greaterOrEqual('gte'),
  lessThan('lt'),
  lessOrEqual('lte'),
  between('between'),
  isEmpty('empty'),
  isNotEmpty('notEmpty');

  const FilterOp(this.wire);
  final String wire;

  static FilterOp fromWire(String? s) => FilterOp.values.firstWhere(
    (o) => o.wire == s,
    orElse: () => FilterOp.contains,
  );

  bool get needsValue =>
      this != FilterOp.isEmpty && this != FilterOp.isNotEmpty;
  bool get needsSecondValue => this == FilterOp.between;
}

/// One clause of the advanced (cross-column) filter: `<column> <op> <value>`.
/// Clauses combine with AND.
class AdvancedFilterClause {
  final String columnKey;
  final FilterOp op;

  /// Primary comparison value (null for [FilterOp.isEmpty]/[FilterOp.isNotEmpty]).
  final Object? value;

  /// Upper bound for [FilterOp.between].
  final Object? value2;

  const AdvancedFilterClause({
    required this.columnKey,
    this.op = FilterOp.contains,
    this.value,
    this.value2,
  });

  AdvancedFilterClause copyWith({
    String? columnKey,
    FilterOp? op,
    Object? value,
    Object? value2,
  }) => AdvancedFilterClause(
    columnKey: columnKey ?? this.columnKey,
    op: op ?? this.op,
    value: value ?? this.value,
    value2: value2 ?? this.value2,
  );

  Map<String, dynamic> toJson() => {
    'column': columnKey,
    'op': op.wire,
    if (value != null) 'value': value,
    if (value2 != null) 'value2': value2,
  };

  factory AdvancedFilterClause.fromJson(Map<String, dynamic> j) =>
      AdvancedFilterClause(
        columnKey: '${j['column']}',
        op: FilterOp.fromWire(j['op'] as String?),
        value: j['value'],
        value2: j['value2'],
      );
}

/// The complete filter state of a table — serialisable for programmatic
/// get/set ([SuperTableController.filterState] / `applyFilterState`) and for
/// inclusion in the `onLoadMore` payload.
///
/// Exactly one mode is "active": when [advancedActive] is true the per-column
/// filters are ignored (and the UI disables them); otherwise [columnFilters]
/// apply.
class SuperFilterState {
  /// Per-column filters: column key → matched value (String for text/contains,
  /// or the option value for enum/currency/color).
  final Map<String, Object?> columnFilters;

  /// Advanced cross-column clauses (AND-combined).
  final List<AdvancedFilterClause> advanced;

  /// Whether the advanced filter is the active one.
  final bool advancedActive;

  /// The global free-text search (applies in both modes).
  final String search;

  const SuperFilterState({
    this.columnFilters = const {},
    this.advanced = const [],
    this.advancedActive = false,
    this.search = '',
  });

  bool get isEmpty =>
      columnFilters.isEmpty &&
      advanced.isEmpty &&
      !advancedActive &&
      search.trim().isEmpty;

  SuperFilterState copyWith({
    Map<String, Object?>? columnFilters,
    List<AdvancedFilterClause>? advanced,
    bool? advancedActive,
    String? search,
  }) => SuperFilterState(
    columnFilters: columnFilters ?? this.columnFilters,
    advanced: advanced ?? this.advanced,
    advancedActive: advancedActive ?? this.advancedActive,
    search: search ?? this.search,
  );

  /// A structured JSON object suitable for persistence or a backend query.
  Map<String, dynamic> toJson() => {
    'search': search,
    'advancedActive': advancedActive,
    'columnFilters': columnFilters,
    'advanced': [for (final c in advanced) c.toJson()],
  };

  factory SuperFilterState.fromJson(Map<String, dynamic> j) => SuperFilterState(
    search: '${j['search'] ?? ''}',
    advancedActive: j['advancedActive'] == true,
    columnFilters:
        (j['columnFilters'] as Map?)?.cast<String, Object?>() ?? const {},
    advanced: [
      for (final c in (j['advanced'] as List? ?? const []))
        AdvancedFilterClause.fromJson((c as Map).cast<String, dynamic>()),
    ],
  );
}
