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

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Color, FontWeight, TextAlign;

/// Fixed table-style presets inspired by common office spreadsheet/table
/// treatments, resolved through the active Super design-system theme.
enum SuperTableStylePreset {
  /// Minimal table chrome with quiet borders and no banding.
  plainMinimal,

  /// Light header and soft row hierarchy.
  light,

  /// Slightly stronger header, banding, and subtotal emphasis.
  medium,

  /// Strong neutral header emphasis with restrained body fills.
  dark,

  /// Uses the host Material primary color as a calm accent family.
  accent,

  /// Alternates body-row fills.
  bandedRows,

  /// Alternates body-column fills.
  bandedColumns,

  /// Keeps body rows quiet while making the header more prominent.
  headerEmphasis,

  /// Uses clearer cell and outer borders for dense financial grids.
  gridBordered,

  /// Keeps dividers visible but low contrast.
  subtleBorders,
}

/// Office-style switches that decide where a [SuperTableStyle] is applied.
///
/// These options affect only styling. They do not create or remove headers,
/// totals, group footers, rows, columns, pagination, or grouping.
@immutable
class SuperTableStyleOptions {
  /// Apply [SuperTableStyle.headerStyle] to the rendered header row.
  final bool showHeaderRow;

  /// Apply [SuperTableStyle.footerRowStyle] to group footer/subtotal rows.
  final bool showFooterRow;

  /// Apply [SuperTableStyle.totalRowStyle] to the totals row.
  final bool showTotalRow;

  /// Apply [SuperTableStyle.groupRowStyle] to group header rows.
  final bool showGroupRows;

  /// Apply [SuperTableStyle.alternateRowStyle] to odd body rows.
  final bool bandedRows;

  /// Apply [SuperTableStyle.bandedColumnStyle] to odd body columns.
  final bool bandedColumns;

  /// Apply [SuperTableStyle.firstColumnStyle] to the first visible column.
  final bool emphasizeFirstColumn;

  /// Apply [SuperTableStyle.lastColumnStyle] to the last visible column.
  final bool emphasizeLastColumn;

  const SuperTableStyleOptions({
    this.showHeaderRow = true,
    this.showFooterRow = true,
    this.showTotalRow = true,
    this.showGroupRows = true,
    this.bandedRows = false,
    this.bandedColumns = false,
    this.emphasizeFirstColumn = false,
    this.emphasizeLastColumn = false,
  });

  /// Copy this option set with selected values replaced.
  SuperTableStyleOptions copyWith({
    bool? showHeaderRow,
    bool? showFooterRow,
    bool? showTotalRow,
    bool? showGroupRows,
    bool? bandedRows,
    bool? bandedColumns,
    bool? emphasizeFirstColumn,
    bool? emphasizeLastColumn,
  }) => SuperTableStyleOptions(
    showHeaderRow: showHeaderRow ?? this.showHeaderRow,
    showFooterRow: showFooterRow ?? this.showFooterRow,
    showTotalRow: showTotalRow ?? this.showTotalRow,
    showGroupRows: showGroupRows ?? this.showGroupRows,
    bandedRows: bandedRows ?? this.bandedRows,
    bandedColumns: bandedColumns ?? this.bandedColumns,
    emphasizeFirstColumn: emphasizeFirstColumn ?? this.emphasizeFirstColumn,
    emphasizeLastColumn: emphasizeLastColumn ?? this.emphasizeLastColumn,
  );

  /// Merge [other] over this option set.
  SuperTableStyleOptions merge(SuperTableStyleOptions? other) => other == null
      ? this
      : copyWith(
          showHeaderRow: other.showHeaderRow,
          showFooterRow: other.showFooterRow,
          showTotalRow: other.showTotalRow,
          showGroupRows: other.showGroupRows,
          bandedRows: other.bandedRows,
          bandedColumns: other.bandedColumns,
          emphasizeFirstColumn: other.emphasizeFirstColumn,
          emphasizeLastColumn: other.emphasizeLastColumn,
        );
}

/// Border and divider values for a [SuperTableStyle].
@immutable
class SuperTableBorderStyle {
  /// Outer frame color.
  final Color? outerColor;

  /// Standard cell divider color.
  final Color? dividerColor;

  /// Strong divider color used around headers, gutters, groups, and totals.
  final Color? strongDividerColor;

  /// Standard divider width.
  final double? width;

  /// Strong divider width.
  final double? strongWidth;

  const SuperTableBorderStyle({
    this.outerColor,
    this.dividerColor,
    this.strongDividerColor,
    this.width,
    this.strongWidth,
  });

  /// Merge [other] over this style.
  SuperTableBorderStyle merge(SuperTableBorderStyle? other) => other == null
      ? this
      : SuperTableBorderStyle(
          outerColor: other.outerColor ?? outerColor,
          dividerColor: other.dividerColor ?? dividerColor,
          strongDividerColor: other.strongDividerColor ?? strongDividerColor,
          width: other.width ?? width,
          strongWidth: other.strongWidth ?? strongWidth,
        );
}

/// Visual treatment for one table area, such as headers, body rows, totals, or
/// selected cells.
@immutable
class SuperTableAreaStyle {
  /// Area background fill.
  final Color? background;

  /// Text color for cells rendered in this area.
  final Color? foreground;

  /// Text weight for cells rendered in this area.
  final FontWeight? fontWeight;

  /// Optional accent bar for row-level treatments.
  final Color? accentBar;

  const SuperTableAreaStyle({
    this.background,
    this.foreground,
    this.fontWeight,
    this.accentBar,
  });

  /// Merge [other] over this style.
  SuperTableAreaStyle merge(SuperTableAreaStyle? other) => other == null
      ? this
      : SuperTableAreaStyle(
          background: other.background ?? background,
          foreground: other.foreground ?? foreground,
          fontWeight: other.fontWeight ?? fontWeight,
          accentBar: other.accentBar ?? accentBar,
        );
}

/// Optional table-wide visual style for [SuperTable].
///
/// Pass `null` to `SuperTable.style` to preserve the table's existing
/// appearance. Predefined styles are opt-in and deterministic; custom area
/// values can be layered over a preset with [copyWith].
@immutable
class SuperTableStyle {
  /// Human-readable style name for documentation, menus, and examples.
  final String name;

  /// Preset recipe used by the renderer to derive theme-aware defaults.
  final SuperTableStylePreset preset;

  /// Office-style switches controlling where style treatments apply.
  final SuperTableStyleOptions options;

  /// Border treatment for the table frame and dividers.
  final SuperTableBorderStyle borderStyle;

  /// Header row style.
  final SuperTableAreaStyle? headerStyle;

  /// Standard body row style.
  final SuperTableAreaStyle? rowStyle;

  /// Alternate body row style.
  final SuperTableAreaStyle? alternateRowStyle;

  /// Banded body column style.
  final SuperTableAreaStyle? bandedColumnStyle;

  /// Group header row style.
  final SuperTableAreaStyle? groupRowStyle;

  /// Group footer/subtotal row style.
  final SuperTableAreaStyle? footerRowStyle;

  /// Grand-total row style.
  final SuperTableAreaStyle? totalRowStyle;

  /// First visible column emphasis.
  final SuperTableAreaStyle? firstColumnStyle;

  /// Last visible column emphasis.
  final SuperTableAreaStyle? lastColumnStyle;

  /// Selected row treatment.
  final SuperTableAreaStyle? selectedRowStyle;

  /// Selected cell treatment.
  final SuperTableAreaStyle? selectedCellStyle;

  /// Hovered row treatment.
  final SuperTableAreaStyle? hoveredRowStyle;

  /// Hovered cell treatment.
  final SuperTableAreaStyle? hoveredCellStyle;

  /// Focused/current cell treatment.
  final SuperTableAreaStyle? focusedCellStyle;

  /// Disabled/read-only/computed cell treatment.
  final SuperTableAreaStyle? disabledStyle;

  const SuperTableStyle({
    required this.name,
    required this.preset,
    this.options = const SuperTableStyleOptions(),
    this.borderStyle = const SuperTableBorderStyle(),
    this.headerStyle,
    this.rowStyle,
    this.alternateRowStyle,
    this.bandedColumnStyle,
    this.groupRowStyle,
    this.footerRowStyle,
    this.totalRowStyle,
    this.firstColumnStyle,
    this.lastColumnStyle,
    this.selectedRowStyle,
    this.selectedCellStyle,
    this.hoveredRowStyle,
    this.hoveredCellStyle,
    this.focusedCellStyle,
    this.disabledStyle,
  });

  /// Plain / minimal preset.
  static const plainMinimal = SuperTableStyle(
    name: 'Plain / Minimal',
    preset: SuperTableStylePreset.plainMinimal,
  );

  /// Light preset.
  static const light = SuperTableStyle(
    name: 'Light',
    preset: SuperTableStylePreset.light,
    options: SuperTableStyleOptions(bandedRows: true),
  );

  /// Medium preset.
  static const medium = SuperTableStyle(
    name: 'Medium',
    preset: SuperTableStylePreset.medium,
    options: SuperTableStyleOptions(
      bandedRows: true,
      emphasizeFirstColumn: true,
    ),
  );

  /// Dark preset.
  static const dark = SuperTableStyle(
    name: 'Dark',
    preset: SuperTableStylePreset.dark,
    options: SuperTableStyleOptions(
      bandedRows: true,
      emphasizeFirstColumn: true,
      emphasizeLastColumn: true,
    ),
  );

  /// Accent preset.
  static const accent = SuperTableStyle(
    name: 'Accent',
    preset: SuperTableStylePreset.accent,
    options: SuperTableStyleOptions(
      bandedRows: true,
      emphasizeFirstColumn: true,
    ),
  );

  /// Banded rows preset.
  static const bandedRows = SuperTableStyle(
    name: 'Banded Rows',
    preset: SuperTableStylePreset.bandedRows,
    options: SuperTableStyleOptions(bandedRows: true),
  );

  /// Banded columns preset.
  static const bandedColumns = SuperTableStyle(
    name: 'Banded Columns',
    preset: SuperTableStylePreset.bandedColumns,
    options: SuperTableStyleOptions(bandedColumns: true),
  );

  /// Header emphasis preset.
  static const headerEmphasis = SuperTableStyle(
    name: 'Header Emphasis',
    preset: SuperTableStylePreset.headerEmphasis,
  );

  /// Grid / bordered preset.
  static const gridBordered = SuperTableStyle(
    name: 'Grid / Bordered',
    preset: SuperTableStylePreset.gridBordered,
    options: SuperTableStyleOptions(bandedRows: true),
  );

  /// Subtle borders preset.
  static const subtleBorders = SuperTableStyle(
    name: 'Subtle Borders',
    preset: SuperTableStylePreset.subtleBorders,
  );

  /// All predefined styles in gallery order.
  static const presets = <SuperTableStyle>[
    plainMinimal,
    light,
    medium,
    dark,
    accent,
    bandedRows,
    bandedColumns,
    headerEmphasis,
    gridBordered,
    subtleBorders,
  ];

  /// Copy this style with selected values replaced.
  SuperTableStyle copyWith({
    String? name,
    SuperTableStylePreset? preset,
    SuperTableStyleOptions? options,
    SuperTableBorderStyle? borderStyle,
    SuperTableAreaStyle? headerStyle,
    SuperTableAreaStyle? rowStyle,
    SuperTableAreaStyle? alternateRowStyle,
    SuperTableAreaStyle? bandedColumnStyle,
    SuperTableAreaStyle? groupRowStyle,
    SuperTableAreaStyle? footerRowStyle,
    SuperTableAreaStyle? totalRowStyle,
    SuperTableAreaStyle? firstColumnStyle,
    SuperTableAreaStyle? lastColumnStyle,
    SuperTableAreaStyle? selectedRowStyle,
    SuperTableAreaStyle? selectedCellStyle,
    SuperTableAreaStyle? hoveredRowStyle,
    SuperTableAreaStyle? hoveredCellStyle,
    SuperTableAreaStyle? focusedCellStyle,
    SuperTableAreaStyle? disabledStyle,
  }) => SuperTableStyle(
    name: name ?? this.name,
    preset: preset ?? this.preset,
    options: options ?? this.options,
    borderStyle: borderStyle ?? this.borderStyle,
    headerStyle: headerStyle ?? this.headerStyle,
    rowStyle: rowStyle ?? this.rowStyle,
    alternateRowStyle: alternateRowStyle ?? this.alternateRowStyle,
    bandedColumnStyle: bandedColumnStyle ?? this.bandedColumnStyle,
    groupRowStyle: groupRowStyle ?? this.groupRowStyle,
    footerRowStyle: footerRowStyle ?? this.footerRowStyle,
    totalRowStyle: totalRowStyle ?? this.totalRowStyle,
    firstColumnStyle: firstColumnStyle ?? this.firstColumnStyle,
    lastColumnStyle: lastColumnStyle ?? this.lastColumnStyle,
    selectedRowStyle: selectedRowStyle ?? this.selectedRowStyle,
    selectedCellStyle: selectedCellStyle ?? this.selectedCellStyle,
    hoveredRowStyle: hoveredRowStyle ?? this.hoveredRowStyle,
    hoveredCellStyle: hoveredCellStyle ?? this.hoveredCellStyle,
    focusedCellStyle: focusedCellStyle ?? this.focusedCellStyle,
    disabledStyle: disabledStyle ?? this.disabledStyle,
  );
}

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

  const SuperRowStyle({
    this.background,
    this.foreground,
    this.fontWeight,
    this.accentBar,
  });

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

  const CellStyle({
    this.background,
    this.foreground,
    this.fontWeight,
    this.align,
  });

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
