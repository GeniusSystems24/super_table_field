// ============================================================
// features/super_table/domain/entities/super_column.dart
// ------------------------------------------------------------
// The column model for the unified SuperTable — a 1:1 port of the React tool's
// column contract. A row is a `Map<String, dynamic>`; a [SuperColumn] declares
// how one field is typed, displayed, edited, sorted, aggregated, pinned, and
// validated. Thirteen ergonomic [SuperColumnType]s cover the GeniusLink data
// vocabulary (text … computed). Pure data — no Flutter widgets here.
// ============================================================

import 'package:flutter/widgets.dart' show Color, immutable;

/// A table row. Mirrors the React tool's plain-object rows.
typedef SuperRow = Map<String, dynamic>;

/// The thirteen column kinds. The wire [name] matches the React `type` string.
enum SuperColumnType {
  text('text'),
  number('number'),
  currency('currency'),
  enumeration('enum'), // strict dropdown
  combo('combo'), //      free text + suggestions
  progress('progress'),
  color('color'),
  date('date'), //        masked YYYY-MM-DD + calendar
  time('time'), //        masked HH:mm + clock
  link('link'),
  checkbox('bool'), //    boolean tick
  readonly('readonly'),
  computed('computed'); //derived via compute(row)

  const SuperColumnType(this.wire);

  /// The string token used in column specs and serialisation (`'enum'`, …).
  final String wire;

  /// Parse from the wire token, defaulting to [text].
  static SuperColumnType fromWire(String? s) =>
      SuperColumnType.values.firstWhere((t) => t.wire == s, orElse: () => SuperColumnType.text);

  bool get isNumeric =>
      this == number || this == currency || this == progress;
  bool get isDerived => this == computed || this == readonly;
}

/// Horizontal alignment of a column's content.
enum SuperAlign { start, center, end }

/// Whether a column is frozen to an edge (sticky) and on which side.
enum SuperPin { none, left, right }

/// The aggregate shown in the totals row / group headers for a column.
enum SuperAgg { none, sum, avg, count }

/// One column definition.
@immutable
class SuperColumn {
  final String key;
  final String label;
  final SuperColumnType type;

  /// Default width (px) before any user resize.
  final double width;
  final SuperAlign align;
  final SuperPin pin;
  final SuperAgg agg;

  /// Tri-state editability: null = inherit from mode, true/false = force.
  final bool? editable;

  /// Whether the column can be sorted (header menu / click).
  final bool sortable;

  /// Marks a required field (red asterisk + validation).
  final bool required;

  /// Force the monospace face on display.
  final bool mono;

  /// Numeric: color positive green / negative red and prefix a sign.
  final bool colorSign;

  /// Numeric clamps + precision.
  final num? min;
  final num? max;
  final int? decimals;

  /// Numeric/currency affixes (`$`, ` SAR`, `%`).
  final String? prefix;
  final String? suffix;

  /// enum / combo options.
  final List<String>? opts;

  /// enum pill tones keyed by option value (else auto-toned).
  final Map<String, Color>? tones;

  /// enum: show the leading dot in pills (default true).
  final bool dot;

  /// Bilingual pairing: the row key holding the Arabic value rendered beneath
  /// the English text in a `text` cell.
  final String? arKey;

  /// computed: derive the cell value from the whole row.
  final Object? Function(SuperRow row)? compute;

  /// Read the raw value via a custom accessor instead of `row[key]`.
  final Object? Function(SuperRow row)? accessor;

  /// computed: format the derived value for display.
  final String Function(Object? value, SuperRow row)? format;

  const SuperColumn({
    required this.key,
    required this.label,
    this.type = SuperColumnType.text,
    this.width = 140,
    this.align = SuperAlign.start,
    this.pin = SuperPin.none,
    this.agg = SuperAgg.none,
    this.editable,
    this.sortable = true,
    this.required = false,
    this.mono = false,
    this.colorSign = false,
    this.min,
    this.max,
    this.decimals,
    this.prefix,
    this.suffix,
    this.opts,
    this.tones,
    this.dot = true,
    this.arKey,
    this.compute,
    this.accessor,
    this.format,
  });

  /// The raw, untyped value of this column for [row] (compute ▸ accessor ▸ key).
  Object? rawValue(SuperRow row) {
    if (compute != null) return compute!(row);
    if (accessor != null) return accessor!(row);
    return row[key];
  }

  SuperColumn copyWith({
    SuperColumnType? type,
    double? width,
    SuperAlign? align,
    SuperPin? pin,
    SuperAgg? agg,
    int? decimals,
    bool? colorSign,
  }) =>
      SuperColumn(
        key: key,
        label: label,
        type: type ?? this.type,
        width: width ?? this.width,
        align: align ?? this.align,
        pin: pin ?? this.pin,
        agg: agg ?? this.agg,
        editable: editable,
        sortable: sortable,
        required: required,
        mono: mono,
        colorSign: colorSign ?? this.colorSign,
        min: min,
        max: max,
        decimals: decimals ?? this.decimals,
        prefix: prefix,
        suffix: suffix,
        opts: opts,
        tones: tones,
        dot: dot,
        arKey: arKey,
        compute: compute,
        accessor: accessor,
        format: format,
      );
}
