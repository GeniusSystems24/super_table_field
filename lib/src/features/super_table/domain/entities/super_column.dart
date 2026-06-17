// ============================================================
// features/super_table/domain/entities/super_column.dart
// ------------------------------------------------------------
// The base column model for SuperTable 0.4.0 — now **generic** (`SuperColumn<T>`,
// where `T` is the cell *value* type) and the root of a typed class hierarchy
// (see `super_columns.dart`: SuperTextColumn, SuperNumberColumn<T>, …).
//
// A [SuperColumn] declares how one field is typed, displayed, edited, sorted,
// aggregated, pinned, validated, conditionally styled, and filtered. Two new
// editable-mode hooks define cell behaviour:
//
//   • [onChange]  — runs before a committed value is accepted; may mutate other
//                   cells / bump the row [fingerPrint]; returns whether the new
//                   value is allowed.
//   • [validator] — returns an error code (or null) for a value; drives the
//                   per-cell error badge.
//
// Plus conditional [styles] (cell background / fg per condition) and a
// [filterSource] (sync / async / stream filter options).
//
// Pure data + callbacks — the only Flutter types referenced are value types
// (Color, FontWeight) and BuildContext (handed to the callbacks).
// ============================================================

import 'package:flutter/widgets.dart' show BuildContext, Color;

import '../../presentation/controllers/super_table_controller.dart';
import 'super_filter.dart';
import 'super_row.dart';
import 'super_style.dart';

/// The column kinds. The wire [name] matches the React `type` string. Use the
/// typed subclasses in `super_columns.dart` rather than setting [type] directly,
/// except for [SuperColumnType.custom] (the flexible base column).
enum SuperColumnType {
  text('text'),
  number('number'),
  currency('currency'),
  enumeration('enum'), // strict dropdown
  combo('combo'), //      free text + suggestions (AutoSuggestionsBox)
  progress('progress'),
  color('color'),
  date('date'), //        masked YYYY-MM-DD + calendar
  time('time'), //        masked HH:mm + clock
  link('link'),
  checkbox('bool'), //    boolean tick
  readonly('readonly'),
  computed('computed'), // derived via compute(row)
  custom('custom'); //    flexible base column

  const SuperColumnType(this.wire);

  /// The string token used in column specs and serialisation (`'enum'`, …).
  final String wire;

  /// Parse from the wire token, defaulting to [text].
  static SuperColumnType fromWire(String? s) =>
      SuperColumnType.values.firstWhere((t) => t.wire == s, orElse: () => SuperColumnType.text);

  bool get isNumeric => this == number || this == currency || this == progress;
  bool get isDerived => this == computed || this == readonly;
}

/// Horizontal alignment of a column's content.
enum SuperAlign { start, center, end }

/// Whether a column is frozen to an edge (sticky) and on which side.
enum SuperPin { none, left, right }

/// The aggregate shown in the totals row / group headers for a column.
enum SuperAgg { none, sum, avg, count }

// ── Callback typedefs ───────────────────────────────────────────────────────

/// Runs (editable mode) when a cell is about to commit a new value. May mutate
/// sibling cells (`row.cells['k'].value = …`) or bump the row's rebuild token
/// (`row.fingerPrint = …` / `row.randomFingerPrint()`). Return `true` to accept
/// [newValue], `false` to reject it (the edit is reverted).
typedef SuperColumnChange<T> = bool Function(
  BuildContext context,
  SuperTableController controller,
  SuperRow row,
  SuperCell cell,
  T previousValue,
  T newValue,
);

/// Returns an error code/message for [value] (editable mode), or null if valid.
typedef SuperColumnValidator<T> = String? Function(
  BuildContext context,
  SuperTableController controller,
  SuperRow row,
  SuperCell cell,
  T value,
);

/// A cell-level style condition (readable mode). First match wins.
typedef SuperCellCondition = bool Function(
  BuildContext context,
  SuperTableController controller,
  SuperRow row,
  SuperCell cell,
);

/// A row-level style condition (readable mode). First match wins; row styles
/// take priority over cell styles.
typedef SuperRowCondition = bool Function(
  BuildContext context,
  SuperTableController controller,
  SuperRow row,
);

/// The flexible base column. `T` is the cell value type. Use the typed
/// subclasses (`SuperTextColumn`, `SuperNumberColumn<T>`, …) for the common
/// types; instantiate `SuperColumn` directly (with [SuperColumnType.custom] and
/// a [cellBuilder] / [format]) for bespoke columns.
class SuperColumn<T> {
  // ── identity / layout ──
  final String key;
  final String label;
  final SuperColumnType type;
  final double width;
  final SuperAlign align;
  final SuperPin pin;
  final SuperAgg agg;

  // ── behaviour flags ──
  /// Tri-state editability: null = inherit from mode, true/false = force.
  final bool? editable;
  final bool sortable;
  final bool groupable;
  final bool filterable;
  final bool required;
  final bool mono;

  // ── numeric / display knobs (used by the type logic) ──
  final bool colorSign;
  final num? min;
  final num? max;
  final int? decimals;
  final String? prefix;
  final String? suffix;

  // ── enum / combo options ──
  /// Display strings for the options (enum / combo). For typed subclasses these
  /// are derived from the typed values via the subclass's `display`.
  final List<String>? opts;

  /// Raw option values aligned 1:1 with [opts] (null → the display IS the value).
  final List<Object?>? optValues;

  /// enum pill tones keyed by display value (else auto-toned).
  final Map<String, Color>? tones;

  /// enum: show the leading dot in pills (default true).
  final bool dot;

  // ── bilingual ──
  /// The row cell key holding the Arabic value rendered beneath the English text.
  final String? arKey;

  // ── derived ──
  final Object? Function(SuperRow row)? compute; // computed value
  final Object? Function(SuperRow row)? accessor; // custom raw read (sort/search)
  final String Function(Object? value, SuperRow row)? format; // computed display

  // ── value ⇄ backing projection ──
  /// Project the backing object → this cell's initial value. Defaults to
  /// `backing[key]` when the backing is a `Map`.
  final Object? Function(dynamic backingValue)? read;

  /// Push a committed cell value back into the backing object. Defaults to
  /// `backing[key] = value` when the backing is a `Map`.
  final void Function(dynamic backingValue, T value)? write;

  // ── 0.4.0 hooks ──
  /// Editable-mode pre-commit hook (see [SuperColumnChange]).
  final SuperColumnChange<T>? onChange;

  /// Editable-mode validator (see [SuperColumnValidator]).
  final SuperColumnValidator<T>? validator;

  /// Conditional cell styles (readable mode); first matching condition wins.
  final Map<SuperCellCondition, CellStyle>? styles;

  /// Where this column's filter *options* come from (enum / currency / color).
  final FilterValueSource<T>? filterSource;

  /// Static filter items (enum / currency / color) — an alternative to
  /// [filterSource] for in-memory option lists.
  final List<FilterItem<T>>? filterItems;

  const SuperColumn({
    required this.key,
    required this.label,
    this.type = SuperColumnType.custom,
    this.width = 140,
    this.align = SuperAlign.start,
    this.pin = SuperPin.none,
    this.agg = SuperAgg.none,
    this.editable,
    this.sortable = true,
    this.groupable = true,
    this.filterable = true,
    this.required = false,
    this.mono = false,
    this.colorSign = false,
    this.min,
    this.max,
    this.decimals,
    this.prefix,
    this.suffix,
    this.opts,
    this.optValues,
    this.tones,
    this.dot = true,
    this.arKey,
    this.compute,
    this.accessor,
    this.format,
    this.read,
    this.write,
    this.onChange,
    this.validator,
    this.styles,
    this.filterSource,
    this.filterItems,
  });

  /// The raw, untyped value of this column for [row]: compute ▸ accessor ▸ cell.
  Object? rawValue(SuperRow row) {
    if (compute != null) return compute!(row);
    if (accessor != null) return accessor!(row);
    return row.cells[key]?.value;
  }

  /// Project the backing object → this cell's initial value (read hook ▸ map).
  Object? readBacking(dynamic backing) {
    if (read != null) return read!(backing);
    if (backing is Map) return backing[key];
    return null;
  }

  /// Push a committed value back into the backing object (write hook ▸ map).
  void writeBacking(dynamic backing, Object? value) {
    if (write != null) {
      write!(backing, value as T);
      return;
    }
    if (backing is Map) backing[key] = value;
  }

  /// Resolve the effective filter items: explicit [filterItems], else a sync
  /// [filterSource], else derived from [opts]/[optValues] (enum), else null.
  List<FilterItem<T>>? get resolvedFilterItems {
    if (filterItems != null) return filterItems;
    final src = filterSource;
    if (src is SyncFilterValueSource<T>) return src.items;
    if (opts != null) {
      return [
        for (var i = 0; i < opts!.length; i++)
          FilterItem<T>(opts![i], (optValues != null ? optValues![i] : opts![i]) as T),
      ];
    }
    return null;
  }

  SuperColumn<T> copyWith({
    SuperColumnType? type,
    double? width,
    SuperAlign? align,
    SuperPin? pin,
    SuperAgg? agg,
    int? decimals,
    bool? colorSign,
  }) =>
      SuperColumn<T>(
        key: key,
        label: label,
        type: type ?? this.type,
        width: width ?? this.width,
        align: align ?? this.align,
        pin: pin ?? this.pin,
        agg: agg ?? this.agg,
        editable: editable,
        sortable: sortable,
        groupable: groupable,
        filterable: filterable,
        required: required,
        mono: mono,
        colorSign: colorSign ?? this.colorSign,
        min: min,
        max: max,
        decimals: decimals ?? this.decimals,
        prefix: prefix,
        suffix: suffix,
        opts: opts,
        optValues: optValues,
        tones: tones,
        dot: dot,
        arKey: arKey,
        compute: compute,
        accessor: accessor,
        format: format,
        read: read,
        write: write,
        onChange: onChange,
        validator: validator,
        styles: styles,
        filterSource: filterSource,
        filterItems: filterItems,
      );
}
