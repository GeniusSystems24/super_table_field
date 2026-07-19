// ============================================================
// features/super_table/domain/entities/super_view_state.dart
// ------------------------------------------------------------
// The saved-view value type (2.1.0; +pins in 2.2.0). A [SuperViewState]
// captures everything a user personalises about a grid — column order, widths,
// runtime pin overrides, the visible-keys allow-list, sort, group-bys,
// collapsed groups, and (optionally) the whole filter state — as one
// JSON-serialisable object. Persist it per user/screen
// and restore it with `SuperTableController.applyViewState` /
// `applyViewJson`; read it back via `controller.viewState()`.
//
// Pure data — no Flutter here.
// ============================================================

import 'super_filter.dart';

/// A snapshot of a table's user-configurable view: layout (order / widths /
/// visibility), sort, grouping, collapse state, and optional filters.
class SuperViewState {
  /// User order of the unpinned columns (keys). Null = leave untouched.
  final List<String>? order;

  /// Column width overrides (`columnKey → px`). Empty = no overrides.
  final Map<String, double> widths;

  /// The visible-keys allow-list, or null for "all renderable columns".
  final List<String>? visibleKeys;

  /// Runtime pin overrides (2.2.0): `columnKey → 'left' | 'right' | 'none'`.
  /// Only columns whose live pin differs from their declaration appear here.
  /// Empty = no overrides. Stored as strings to keep this entity Flutter-free.
  final Map<String, String> pins;

  /// Active sort (null [sortKey] = unsorted).
  final String? sortKey;
  final bool sortAscending;

  /// Active group-by column keys (may include `hidden:` columns).
  final List<String> groupKeys;

  /// Collapsed group paths (as produced by the grid's grouping).
  final List<String> collapsedPaths;

  /// The full filter state, or null when the view was captured without
  /// filters (`viewState(includeFilters: false)`).
  final SuperFilterState? filters;

  const SuperViewState({
    this.order,
    this.widths = const {},
    this.visibleKeys,
    this.pins = const {},
    this.sortKey,
    this.sortAscending = true,
    this.groupKeys = const [],
    this.collapsedPaths = const [],
    this.filters,
  });

  bool get isEmpty =>
      order == null &&
      widths.isEmpty &&
      visibleKeys == null &&
      pins.isEmpty &&
      sortKey == null &&
      groupKeys.isEmpty &&
      collapsedPaths.isEmpty &&
      (filters == null || filters!.isEmpty);

  SuperViewState copyWith({
    List<String>? order,
    Map<String, double>? widths,
    List<String>? visibleKeys,
    Map<String, String>? pins,
    String? sortKey,
    bool? sortAscending,
    List<String>? groupKeys,
    List<String>? collapsedPaths,
    SuperFilterState? filters,
  }) => SuperViewState(
    order: order ?? this.order,
    widths: widths ?? this.widths,
    visibleKeys: visibleKeys ?? this.visibleKeys,
    pins: pins ?? this.pins,
    sortKey: sortKey ?? this.sortKey,
    sortAscending: sortAscending ?? this.sortAscending,
    groupKeys: groupKeys ?? this.groupKeys,
    collapsedPaths: collapsedPaths ?? this.collapsedPaths,
    filters: filters ?? this.filters,
  );

  Map<String, dynamic> toJson() => {
    'v': 1,
    if (order != null) 'order': order,
    if (widths.isNotEmpty) 'widths': widths,
    if (visibleKeys != null) 'visible': visibleKeys,
    if (pins.isNotEmpty) 'pins': pins,
    if (sortKey != null) 'sort': {'key': sortKey, 'asc': sortAscending},
    if (groupKeys.isNotEmpty) 'groups': groupKeys,
    if (collapsedPaths.isNotEmpty) 'collapsed': collapsedPaths,
    if (filters != null) 'filters': filters!.toJson(),
  };

  factory SuperViewState.fromJson(Map<String, dynamic> j) {
    final sort = j['sort'];
    return SuperViewState(
      order: (j['order'] as List?)?.map((e) => '$e').toList(),
      widths: {
        for (final e in ((j['widths'] as Map?) ?? const {}).entries)
          '${e.key}': (e.value as num).toDouble(),
      },
      visibleKeys: (j['visible'] as List?)?.map((e) => '$e').toList(),
      pins: {
        for (final e in ((j['pins'] as Map?) ?? const {}).entries)
          '${e.key}': '${e.value}',
      },
      sortKey: sort is Map ? sort['key'] as String? : null,
      sortAscending: sort is Map ? sort['asc'] != false : true,
      groupKeys: [for (final k in (j['groups'] as List? ?? const [])) '$k'],
      collapsedPaths: [
        for (final p in (j['collapsed'] as List? ?? const [])) '$p',
      ],
      filters: j['filters'] is Map
          ? SuperFilterState.fromJson(
              (j['filters'] as Map).cast<String, dynamic>(),
            )
          : null,
    );
  }
}
