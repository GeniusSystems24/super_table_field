// ============================================================
// features/super_table/domain/entities/super_columns.dart
// ------------------------------------------------------------
// The typed column hierarchy for SuperTable 0.4.0. Each class extends the
// generic base [SuperColumn] and presets its [SuperColumnType], exposing only
// the knobs that make sense for that type plus the shared 0.4.0 hooks
// (`onChange`, `validator`, conditional `styles`, filter options).
//
//   SuperTextColumn          · SuperNumberColumn<T extends num>
//   SuperCurrencyColumn      · SuperEnumerationColumn<T>
//   SuperComboColumn<T>      · SuperProgressColumn<T extends num>
//   SuperColorColumn<T>      · SuperDateColumn
//   SuperTimeColumn          · SuperLinkColumn
//   SuperCheckboxColumn      · SuperComputedColumn<T>
//
// `SuperColumn` itself remains usable as a flexible base for custom columns.
// ============================================================

import 'package:flutter/widgets.dart';

import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';
import '../../presentation/controllers/super_table_controller.dart';
import 'super_column.dart';
import 'super_filter.dart';
import 'super_row.dart';
import 'super_style.dart';

List<String> _displays<T>(List<T> values, String Function(T)? display) {
  final String Function(T) d = display ?? ((T v) => '$v');
  return [for (final v in values) d(v)];
}

// ── text ────────────────────────────────────────────────────────────────────
/// A free-text column (`T == String`). Set [arKey] for a bilingual cell that
/// renders the Arabic value (read from that cell key) beneath the English text.
class SuperTextColumn extends SuperColumn<String> {
  SuperTextColumn({
    required String key,
    required String label,
    double width = 160,
    SuperAlign align = SuperAlign.start,
    SuperPin pin = SuperPin.none,
    bool? editable,
    bool sortable = true,
    bool groupable = true,
    bool filterable = true,
    bool required = false,
    bool mono = false,
    String? arKey,
    SuperColumnChange<String>? onChange,
    SuperColumnValidator<String>? validator,
    Map<SuperCellCondition, CellStyle>? styles,
    Object? Function(dynamic backing)? read,
    void Function(dynamic backing, String value)? write,
  }) : super(
          key: key,
          label: label,
          type: SuperColumnType.text,
          width: width,
          align: align,
          pin: pin,
          editable: editable,
          sortable: sortable,
          groupable: groupable,
          filterable: filterable,
          required: required,
          mono: mono,
          arKey: arKey,
          onChange: onChange,
          validator: validator,
          styles: styles,
          read: read,
          write: write,
        );
}

// ── number ───────────────────────────────────────────────────────────────────
/// A numeric column. `T` is the numeric value type (`int`, `double`, or `num`).
class SuperNumberColumn<T extends num> extends SuperColumn<T> {
  SuperNumberColumn({
    required String key,
    required String label,
    double width = 110,
    SuperAlign align = SuperAlign.end,
    SuperPin pin = SuperPin.none,
    SuperAgg agg = SuperAgg.none,
    bool? editable,
    bool sortable = true,
    bool groupable = true,
    bool filterable = true,
    bool required = false,
    bool colorSign = false,
    num? min,
    num? max,
    int? decimals,
    String? prefix,
    String? suffix,
    SuperAggregator? aggregator,
    String? aggLabel,
    SuperColumnChange<T>? onChange,
    SuperColumnValidator<T>? validator,
    Map<SuperCellCondition, CellStyle>? styles,
    Object? Function(dynamic backing)? read,
    void Function(dynamic backing, T value)? write,
  }) : super(
          key: key,
          label: label,
          type: SuperColumnType.number,
          width: width,
          align: align,
          pin: pin,
          agg: agg,
          editable: editable,
          sortable: sortable,
          groupable: groupable,
          filterable: filterable,
          required: required,
          mono: true,
          colorSign: colorSign,
          min: min,
          max: max,
          decimals: decimals,
          prefix: prefix,
          suffix: suffix,
          aggregator: aggregator,
          aggLabel: aggLabel,
          onChange: onChange,
          validator: validator,
          styles: styles,
          read: read,
          write: write,
        );
}

// ── currency ──────────────────────────────────────────────────────────────────
/// A money column (`T == num`). Renders a leading [symbol] and 2-decimal
/// precision by default; pass [code] (e.g. `'SAR'`) to show a trailing code.
/// Its filter values are [FilterItem]s.
class SuperCurrencyColumn extends SuperColumn<num> {
  final String symbol;
  final String? code;

  SuperCurrencyColumn({
    required String key,
    required String label,
    double width = 130,
    SuperAlign align = SuperAlign.end,
    SuperPin pin = SuperPin.none,
    SuperAgg agg = SuperAgg.sum,
    bool? editable,
    bool sortable = true,
    bool filterable = true,
    bool required = false,
    bool colorSign = false,
    num? min,
    num? max,
    int decimals = 2,
    this.symbol = r'$',
    this.code,
    List<FilterItem<num>>? filterItems,
    FilterValueSource<num>? filterSource,
    SuperAggregator? aggregator,
    String? aggLabel,
    SuperColumnChange<num>? onChange,
    SuperColumnValidator<num>? validator,
    Map<SuperCellCondition, CellStyle>? styles,
    Object? Function(dynamic backing)? read,
    void Function(dynamic backing, num value)? write,
  }) : super(
          key: key,
          label: label,
          type: SuperColumnType.currency,
          width: width,
          align: align,
          pin: pin,
          agg: agg,
          editable: editable,
          sortable: sortable,
          filterable: filterable,
          required: required,
          mono: true,
          colorSign: colorSign,
          min: min,
          max: max,
          decimals: decimals,
          prefix: symbol,
          suffix: code,
          filterItems: filterItems,
          filterSource: filterSource,
          aggregator: aggregator,
          aggLabel: aggLabel,
          onChange: onChange,
          validator: validator,
          styles: styles,
          read: read,
          write: write,
        );
}

// ── enumeration ───────────────────────────────────────────────────────────────
/// A strict, pick-only dropdown over a typed value set. Provide [values] (the
/// real values) and an optional [display] to label them; filter values are
/// [FilterItem]s derived from the same set (or supplied explicitly).
class SuperEnumerationColumn<T> extends SuperColumn<T> {
  final List<T> values;
  final String Function(T value) display;

  SuperEnumerationColumn({
    required String key,
    required String label,
    required this.values,
    String Function(T value)? display,
    double width = 140,
    SuperAlign align = SuperAlign.start,
    SuperPin pin = SuperPin.none,
    bool? editable,
    bool sortable = true,
    bool groupable = true,
    bool filterable = true,
    bool required = false,
    bool dot = true,
    Map<String, Color>? tones,
    List<FilterItem<T>>? filterItems,
    FilterValueSource<T>? filterSource,
    SuperColumnChange<T>? onChange,
    SuperColumnValidator<T>? validator,
    Map<SuperCellCondition, CellStyle>? styles,
    Object? Function(dynamic backing)? read,
    void Function(dynamic backing, T value)? write,
  })  : display = display ?? ((T v) => '$v'),
        super(
          key: key,
          label: label,
          type: SuperColumnType.enumeration,
          width: width,
          align: align,
          pin: pin,
          editable: editable,
          sortable: sortable,
          groupable: groupable,
          filterable: filterable,
          required: required,
          dot: dot,
          tones: tones,
          opts: _displays(values, display),
          optValues: values,
          filterItems: filterItems,
          filterSource: filterSource,
          onChange: onChange,
          validator: validator,
          styles: styles,
          read: read,
          write: write,
        );
}

// ── combo (AutoSuggestionsBox-backed) ─────────────────────────────────────────
/// A pick-or-type column edited (in editable mode) through the real
/// [AutoSuggestionsBox]. Carries the full set of box options — both the static
/// ones and two **rebuildable** builders ([sourceController] / [cellController])
/// that are re-invoked whenever the cell takes edit-focus AND the row's
/// [SuperRow.fingerPrint] changed (or on first build), so suggestions can depend
/// on the rest of the row.
class SuperComboColumn<T> extends SuperColumn<T> {
  // static values (optional shorthand source)
  final List<T> values;
  final String Function(T value) display;

  // ── normal AutoSuggestionsBox options (one for all cells) ──
  final bool advancedSearch;
  final Widget Function(BuildContext, AutoSuggestionsBoxController<T>)? advancedSearchBuilder;
  final Widget Function(BuildContext, AutoSuggestion<T>, bool highlighted)? itemBuilder;
  final Widget Function(BuildContext, String query)? loadingBuilder;
  final Widget Function(BuildContext, String query)? emptyBuilder;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final Widget? leading;
  final bool highlightMatch;
  final int maxVisibleRows;
  final bool clearButton;
  final ValueChanged<AutoSuggestion<T>>? onSelected;
  final bool allowFreeText;

  // ── rebuildable options (per row, re-created on fingerPrint change) ──
  final AutoSuggestionsSource<T> Function(
      BuildContext context, SuperTableController controller, SuperRow row, SuperCell cell)? sourceController;
  final AutoSuggestionsBoxController<T> Function(
      BuildContext context, SuperTableController controller, SuperRow row, SuperCell cell)? cellController;

  SuperComboColumn({
    required String key,
    required String label,
    this.values = const [],
    String Function(T value)? display,
    double width = 150,
    SuperAlign align = SuperAlign.start,
    SuperPin pin = SuperPin.none,
    bool? editable,
    bool sortable = true,
    bool groupable = true,
    bool filterable = true,
    bool required = false,
    bool mono = false,
    this.advancedSearch = false,
    this.advancedSearchBuilder,
    this.itemBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.hintText,
    this.onSubmitted,
    this.leading,
    this.highlightMatch = true,
    this.maxVisibleRows = 7,
    this.clearButton = false,
    this.onSelected,
    this.allowFreeText = true,
    this.sourceController,
    this.cellController,
    List<FilterItem<T>>? filterItems,
    FilterValueSource<T>? filterSource,
    SuperColumnChange<T>? onChange,
    SuperColumnValidator<T>? validator,
    Map<SuperCellCondition, CellStyle>? styles,
    Object? Function(dynamic backing)? read,
    void Function(dynamic backing, T value)? write,
  })  : display = display ?? ((T v) => '$v'),
        super(
          key: key,
          label: label,
          type: SuperColumnType.combo,
          width: width,
          align: align,
          pin: pin,
          editable: editable,
          sortable: sortable,
          groupable: groupable,
          filterable: filterable,
          required: required,
          mono: mono,
          opts: _displays(values, display),
          optValues: values,
          filterItems: filterItems,
          filterSource: filterSource,
          onChange: onChange,
          validator: validator,
          styles: styles,
          read: read,
          write: write,
        );
}

// ── progress ──────────────────────────────────────────────────────────────────
/// A 0…[max] progress bar column (`T extends num`). Defaults to a 0–100 scale.
class SuperProgressColumn<T extends num> extends SuperColumn<T> {
  SuperProgressColumn({
    required String key,
    required String label,
    double width = 150,
    SuperAlign align = SuperAlign.start,
    SuperPin pin = SuperPin.none,
    SuperAgg agg = SuperAgg.none,
    bool? editable,
    bool sortable = true,
    bool filterable = true,
    num min = 0,
    num max = 100,
    SuperAggregator? aggregator,
    String? aggLabel,
    SuperColumnChange<T>? onChange,
    SuperColumnValidator<T>? validator,
    Map<SuperCellCondition, CellStyle>? styles,
    Object? Function(dynamic backing)? read,
    void Function(dynamic backing, T value)? write,
  }) : super(
          key: key,
          label: label,
          type: SuperColumnType.progress,
          width: width,
          align: align,
          pin: pin,
          agg: agg,
          editable: editable,
          sortable: sortable,
          filterable: filterable,
          min: min,
          max: max,
          aggregator: aggregator,
          aggLabel: aggLabel,
          onChange: onChange,
          validator: validator,
          styles: styles,
          read: read,
          write: write,
        );
}

// ── color ─────────────────────────────────────────────────────────────────────
/// How a [SuperColorColumn] stores its cell value.
enum SuperColorValue {
  /// A `#RRGGBB` hex string (default).
  hex,

  /// An `int` ARGB / RGB value.
  number,

  /// A Flutter `Color` instance.
  color,
}

/// A color-swatch column. [valueMode] declares whether the cell value is a hex
/// string, an int, or a `Color` — display/edit/filter coerce accordingly.
class SuperColorColumn<T> extends SuperColumn<T> {
  final SuperColorValue valueMode;

  SuperColorColumn({
    required String key,
    required String label,
    this.valueMode = SuperColorValue.hex,
    double width = 130,
    SuperAlign align = SuperAlign.start,
    SuperPin pin = SuperPin.none,
    bool? editable,
    bool sortable = true,
    bool filterable = true,
    List<FilterItem<T>>? filterItems,
    FilterValueSource<T>? filterSource,
    SuperColumnChange<T>? onChange,
    SuperColumnValidator<T>? validator,
    Map<SuperCellCondition, CellStyle>? styles,
    Object? Function(dynamic backing)? read,
    void Function(dynamic backing, T value)? write,
  }) : super(
          key: key,
          label: label,
          type: SuperColumnType.color,
          width: width,
          align: align,
          pin: pin,
          editable: editable,
          sortable: sortable,
          filterable: filterable,
          mono: true,
          filterItems: filterItems,
          filterSource: filterSource,
          onChange: onChange,
          validator: validator,
          styles: styles,
          read: read,
          write: write,
        );
}

// ── date ──────────────────────────────────────────────────────────────────────
/// A masked `YYYY-MM-DD` date column with a mini-calendar picker (`T == String`).
class SuperDateColumn extends SuperColumn<String> {
  SuperDateColumn({
    required String key,
    required String label,
    double width = 140,
    SuperAlign align = SuperAlign.start,
    SuperPin pin = SuperPin.none,
    bool? editable,
    bool sortable = true,
    bool groupable = true,
    bool filterable = true,
    bool required = false,
    SuperColumnChange<String>? onChange,
    SuperColumnValidator<String>? validator,
    Map<SuperCellCondition, CellStyle>? styles,
    Object? Function(dynamic backing)? read,
    void Function(dynamic backing, String value)? write,
  }) : super(
          key: key,
          label: label,
          type: SuperColumnType.date,
          width: width,
          align: align,
          pin: pin,
          editable: editable,
          sortable: sortable,
          groupable: groupable,
          filterable: filterable,
          required: required,
          mono: true,
          onChange: onChange,
          validator: validator,
          styles: styles,
          read: read,
          write: write,
        );
}

// ── time ──────────────────────────────────────────────────────────────────────
/// A masked `HH:mm` time column with a 30-minute option list (`T == String`).
class SuperTimeColumn extends SuperColumn<String> {
  SuperTimeColumn({
    required String key,
    required String label,
    double width = 120,
    SuperAlign align = SuperAlign.start,
    SuperPin pin = SuperPin.none,
    bool? editable,
    bool sortable = true,
    bool filterable = true,
    bool required = false,
    SuperColumnChange<String>? onChange,
    SuperColumnValidator<String>? validator,
    Map<SuperCellCondition, CellStyle>? styles,
    Object? Function(dynamic backing)? read,
    void Function(dynamic backing, String value)? write,
  }) : super(
          key: key,
          label: label,
          type: SuperColumnType.time,
          width: width,
          align: align,
          pin: pin,
          editable: editable,
          sortable: sortable,
          filterable: filterable,
          required: required,
          mono: true,
          onChange: onChange,
          validator: validator,
          styles: styles,
          read: read,
          write: write,
        );
}

// ── link ──────────────────────────────────────────────────────────────────────
/// A clickable link column (`T == String`). [onOpen] is invoked when the cell's
/// link is activated (readable mode).
class SuperLinkColumn extends SuperColumn<String> {
  final void Function(String value, SuperRow row)? onOpen;

  SuperLinkColumn({
    required String key,
    required String label,
    double width = 180,
    SuperAlign align = SuperAlign.start,
    SuperPin pin = SuperPin.none,
    bool? editable,
    bool sortable = true,
    bool filterable = true,
    this.onOpen,
    SuperColumnChange<String>? onChange,
    SuperColumnValidator<String>? validator,
    Map<SuperCellCondition, CellStyle>? styles,
    Object? Function(dynamic backing)? read,
    void Function(dynamic backing, String value)? write,
  }) : super(
          key: key,
          label: label,
          type: SuperColumnType.link,
          width: width,
          align: align,
          pin: pin,
          editable: editable,
          sortable: sortable,
          filterable: filterable,
          mono: true,
          onChange: onChange,
          validator: validator,
          styles: styles,
          read: read,
          write: write,
        );
}

// ── checkbox ──────────────────────────────────────────────────────────────────
/// A boolean tick column (`T == bool`).
class SuperCheckboxColumn extends SuperColumn<bool> {
  SuperCheckboxColumn({
    required String key,
    required String label,
    double width = 90,
    SuperAlign align = SuperAlign.center,
    SuperPin pin = SuperPin.none,
    bool? editable,
    bool sortable = true,
    bool groupable = true,
    bool filterable = true,
    SuperColumnChange<bool>? onChange,
    SuperColumnValidator<bool>? validator,
    Map<SuperCellCondition, CellStyle>? styles,
    Object? Function(dynamic backing)? read,
    void Function(dynamic backing, bool value)? write,
  }) : super(
          key: key,
          label: label,
          type: SuperColumnType.checkbox,
          width: width,
          align: align,
          pin: pin,
          editable: editable,
          sortable: sortable,
          groupable: groupable,
          filterable: filterable,
          onChange: onChange,
          validator: validator,
          styles: styles,
          read: read,
          write: write,
        );
}

// ── computed ──────────────────────────────────────────────────────────────────
/// A derived, read-only column. [compute] produces the value from the whole
/// row; [format] turns it into display text.
class SuperComputedColumn<T> extends SuperColumn<T> {
  SuperComputedColumn({
    required String key,
    required String label,
    required Object? Function(SuperRow row) compute,
    String Function(Object? value, SuperRow row)? format,
    double width = 140,
    SuperAlign align = SuperAlign.start,
    SuperPin pin = SuperPin.none,
    SuperAgg agg = SuperAgg.none,
    SuperAggregator? aggregator,
    String? aggLabel,
    bool sortable = true,
    bool filterable = true,
    Map<SuperCellCondition, CellStyle>? styles,
  }) : super(
          key: key,
          label: label,
          type: SuperColumnType.computed,
          width: width,
          align: align,
          pin: pin,
          agg: agg,
          aggregator: aggregator,
          aggLabel: aggLabel,
          editable: false,
          sortable: sortable,
          filterable: filterable,
          mono: true,
          compute: compute,
          format: format,
          styles: styles,
        );
}

// ── readonly ──────────────────────────────────────────────────────────────────
/// A non-editable display column (`T == String`), shown with a lock affordance.
class SuperReadonlyColumn extends SuperColumn<String> {
  SuperReadonlyColumn({
    required String key,
    required String label,
    double width = 140,
    SuperAlign align = SuperAlign.start,
    SuperPin pin = SuperPin.none,
    bool sortable = true,
    bool filterable = true,
    bool mono = false,
    Object? Function(SuperRow row)? accessor,
    Map<SuperCellCondition, CellStyle>? styles,
  }) : super(
          key: key,
          label: label,
          type: SuperColumnType.readonly,
          width: width,
          align: align,
          pin: pin,
          editable: false,
          sortable: sortable,
          filterable: filterable,
          mono: mono,
          accessor: accessor,
          styles: styles,
        );
}
