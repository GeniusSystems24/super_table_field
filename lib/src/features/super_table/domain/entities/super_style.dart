// ============================================================
// features/super_table/domain/entities/super_style.dart
// ------------------------------------------------------------
// Conditional styling value types for SuperTable (readable mode).
//
//   • [SuperRowStyle]  — background / foreground / weight applied to a whole
//                        row when a row-level condition matches. Row styles take
//                        priority over column (cell) styles.
//   • [CellStyle]      — background / foreground / weight / align applied to one
//                        cell when a cell-level condition matches.
//
// Conditions are plain functions (see the `styles:` maps on `SuperTable` and on
// each `SuperColumn`); the first matching entry wins. Pure data.
// ============================================================

import 'package:flutter/widgets.dart' show Color, FontWeight, TextAlign;

/// Visual overrides for a whole row, applied when a row condition matches.
/// Row styles take priority over per-column [CellStyle]s.
class SuperRowStyle {
  /// Row background fill (drawn behind every cell, under selection washes).
  final Color? background;

  /// Text color applied to every cell unless the cell overrides it.
  final Color? foreground;

  /// Font weight applied to every cell's text.
  final FontWeight? fontWeight;

  /// Optional accent bar color drawn at the row's leading edge (gutter side).
  final Color? accentBar;

  const SuperRowStyle({this.background, this.foreground, this.fontWeight, this.accentBar});

  /// Merge [other] over this style (other wins where non-null).
  SuperRowStyle merge(SuperRowStyle? other) => other == null
      ? this
      : SuperRowStyle(
          background: other.background ?? background,
          foreground: other.foreground ?? foreground,
          fontWeight: other.fontWeight ?? fontWeight,
          accentBar: other.accentBar ?? accentBar,
        );
}

/// Visual overrides for a single cell, applied when a cell condition matches.
class CellStyle {
  /// Cell background fill.
  final Color? background;

  /// Cell text color.
  final Color? foreground;

  /// Cell text weight.
  final FontWeight? fontWeight;

  /// Cell text alignment override (else the column's alignment is used).
  final TextAlign? align;

  const CellStyle({this.background, this.foreground, this.fontWeight, this.align});

  /// Merge [other] over this style (other wins where non-null).
  CellStyle merge(CellStyle? other) => other == null
      ? this
      : CellStyle(
          background: other.background ?? background,
          foreground: other.foreground ?? foreground,
          fontWeight: other.fontWeight ?? fontWeight,
          align: other.align ?? align,
        );
}
