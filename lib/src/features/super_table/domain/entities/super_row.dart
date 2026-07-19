// ============================================================
// features/super_table/domain/entities/super_row.dart
// ------------------------------------------------------------
// The generic row + cell model for SuperTable 0.4.0.
//
// A [SuperRow] wraps a host-owned, typed backing object [value] (the domain
// model — e.g. a `Product`) **and** a [cells] map (the editable view the grid
// reads and writes). The two are kept in sync by the controller: editing a
// cell mutates `cells[key].value`, and a column's `onChange` may push the
// change back into `value` (the host owns that object).
//
// [fingerPrint] is a *rebuild token*: when it changes, any per-row resources a
// cell editor built — most importantly a `SuperComboColumn`'s
// `AutoSuggestionsSource` / `AutoSuggestionsBoxController` — are torn down and
// rebuilt. Bump it from an `onChange` (or call [randomFingerPrint]) when a
// change to one cell should invalidate another cell's suggestion source.
//
// Pure data — no Flutter widgets here.
// ============================================================

/// One editable cell of a [SuperRow] — the live working value for a single
/// column, plus its last validation [error]. The grid reads/writes
/// `cell.value`; a column's `validator` populates `cell.error`.
class SuperCell {
  SuperCell({required this.columnKey, Object? value, this.error})
    : _value = value;

  /// The key of the column this cell belongs to.
  final String columnKey;

  Object? _value;

  /// The cell's current (draft or committed) value. Mutable — assign through
  /// the controller (so undo/redo + notifications fire) unless you are inside
  /// an `onChange`, where direct mutation of *sibling* cells is expected.
  Object? get value => _value;
  set value(Object? v) => _value = v;

  /// The last validation error code/message for this cell (null = valid).
  String? error;

  // ── change tracking (1.0.0) ──
  Object? _baseline;
  bool _hasBaseline = false;

  /// Whether a baseline has been captured for this cell (see
  /// `SuperTableController(trackChanges: true)`).
  bool get baselineSet => _hasBaseline;

  /// The last accepted value for this cell, or null if no baseline is set.
  Object? get baseline => _baseline;

  /// Whether the current [value] differs from the captured [baseline].
  /// Always false until a baseline is captured.
  bool get isDirty => _hasBaseline && _baseline != _value;

  /// Capture the current [value] as the baseline (called by the controller on
  /// construction and on `acceptChanges`).
  void markBaseline() {
    _baseline = _value;
    _hasBaseline = true;
  }

  /// Restore [value] to the captured [baseline] (no-op if none). Used by
  /// `rejectChanges`.
  void revertToBaseline() {
    if (_hasBaseline) {
      _value = _baseline;
      error = null;
    }
  }

  /// Typed read helper: `cell.as<num>()` / `cell.as<String>()`.
  V? as<V>() => _value is V ? _value as V : null;

  SuperCell copy() {
    final c = SuperCell(columnKey: columnKey, value: _value, error: error);
    c._baseline = _baseline;
    c._hasBaseline = _hasBaseline;
    return c;
  }

  @override
  String toString() =>
      'SuperCell($columnKey: $_value${error != null ? ', error: $error' : ''})';
}

/// A table row: a host-owned backing [value] of type [R] plus the editable
/// [cells] view keyed by column key.
class SuperRow<R> {
  SuperRow({
    required this.value,
    required Map<String, SuperCell> cells,
    Object? fingerPrint,
    int? id,
    this.isNew = false,
  }) : cells = cells,
       _fingerPrint = fingerPrint ?? _fpSeq++,
       id = id ?? _idSeq++;

  /// Whether this row was created after the controller's change-tracking
  /// baseline (i.e. it is an *added* row, not yet persisted). Maintained by the
  /// controller when `trackChanges` is on; ignored otherwise.
  bool isNew;

  /// Stable per-instance identity for selection / diffing (independent of
  /// [fingerPrint], which is a rebuild token, not an identity).
  final int id;
  static int _idSeq = 1;
  static int _fpSeq = 1;

  /// The host's backing domain object for this row. The host owns it; the grid
  /// never replaces it, only reads it (and lets `onChange` write into it).
  R value;

  /// The editable cell views, keyed by column key.
  final Map<String, SuperCell> cells;

  Object? _fingerPrint;

  /// Rebuild token. Changing it invalidates per-row editor resources (combo
  /// sources / controllers) so they rebuild on next edit-focus.
  Object? get fingerPrint => _fingerPrint;
  set fingerPrint(Object? v) => _fingerPrint = v;

  /// Assign a fresh, unique [fingerPrint] — convenience for "rebuild everything
  /// for this row next time it's edited".
  void randomFingerPrint() => _fingerPrint = _fpSeq++;

  /// Raw value of one cell (null if the column has no cell here).
  Object? operator [](String key) => cells[key]?.value;

  /// Set one cell's value, creating the cell if missing.
  void operator []=(String key, Object? v) =>
      (cells[key] ??= SuperCell(columnKey: key)).value = v;

  /// Build a [SuperRow] from a backing [value] and an initial map of cell
  /// values. Use this when your row is backed by a typed model.
  factory SuperRow.of(R value, Map<String, Object?> initial) => SuperRow<R>(
    value: value,
    cells: {
      for (final e in initial.entries)
        e.key: SuperCell(columnKey: e.key, value: e.value),
    },
  );

  /// Build a `Map`-backed row: `value` IS the map and cells mirror its entries.
  /// The most common path when you don't have a typed domain model.
  static SuperRow<Map<String, dynamic>> map(Map<String, dynamic> data) =>
      SuperRow<Map<String, dynamic>>(
        value: data,
        cells: {
          for (final e in data.entries)
            e.key: SuperCell(columnKey: e.key, value: e.value),
        },
      );

  /// A snapshot `{columnKey: value}` of every cell.
  Map<String, Object?> get snapshot => {
    for (final e in cells.entries) e.key: e.value.value,
  };

  /// Deep-ish copy: copies cells (and the map value when [R] is a `Map`),
  /// keeping the same backing object otherwise. Used by duplicate-row.
  SuperRow<R> copy() {
    final v = value;
    final R nextValue = v is Map<String, dynamic>
        ? Map<String, dynamic>.from(v) as R
        : v;
    return SuperRow<R>(
      value: nextValue,
      cells: {for (final e in cells.entries) e.key: e.value.copy()},
    );
  }
}
