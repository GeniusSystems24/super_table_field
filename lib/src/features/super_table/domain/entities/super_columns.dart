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

List<String> _displays<T>(List<T> values, String Function(T)? display) {
  final String Function(T) d = display ?? ((T v) => '$v');
  return [for (final v in values) d(v)];
}

// ── text ────────────────────────────────────────────────────────────────────
/// A free-text column (`T == String`). Set [arKey] for a bilingual cell that
/// renders the Arabic value (read from that cell key) beneath the English text.
class SuperTextColumn extends SuperColumn<String> {
  SuperTextColumn({
    required super.key,
    required super.label,
    super.hidden,
    super.unique,
    super.formatter,
    super.width = 160,
    super.align,
    super.pin,
    super.editable,
    super.sortable,
    super.groupable,
    super.filterable,
    super.required,
    super.mono,
    super.arKey,
    super.onChange,
    super.validator,
    super.styles,
    super.read,
    super.write,
  }) : super(type: SuperColumnType.text);
}

// ── number ───────────────────────────────────────────────────────────────────
/// A numeric column. `T` is the numeric value type (`int`, `double`, or `num`).
class SuperNumberColumn<T extends num> extends SuperColumn<T> {
  SuperNumberColumn({
    required super.key,
    required super.label,
    super.hidden,
    super.unique,
    super.formatter,
    super.width = 110,
    super.align = SuperAlign.end,
    super.pin,
    super.agg,
    super.editable,
    super.sortable,
    super.groupable,
    super.filterable,
    super.required,
    super.colorSign,
    super.min,
    super.max,
    super.decimals,
    super.prefix,
    super.suffix,
    super.aggregator,
    super.aggLabel,
    super.onChange,
    super.validator,
    super.styles,
    super.read,
    super.write,
  }) : super(type: SuperColumnType.number, mono: true);
}

// ── currency ──────────────────────────────────────────────────────────────────
/// A money column (`T == num`). Renders a leading [symbol] and 2-decimal
/// precision by default; pass [code] (e.g. `'SAR'`) to show a trailing code.
/// Its filter values are [FilterItem]s.
class SuperCurrencyColumn extends SuperColumn<num> {
  final String symbol;
  final String? code;

  SuperCurrencyColumn({
    required super.key,
    required super.label,
    super.hidden,
    super.unique,
    super.formatter,
    super.width = 130,
    super.align = SuperAlign.end,
    super.pin,
    super.agg = SuperAgg.sum,
    super.editable,
    super.sortable,
    super.filterable,
    super.required,
    super.colorSign,
    super.min,
    super.max,
    int super.decimals = 2,
    this.symbol = r'$',
    this.code,
    super.filterItems,
    super.filterSource,
    super.aggregator,
    super.aggLabel,
    super.onChange,
    super.validator,
    super.styles,
    super.read,
    super.write,
  }) : super(
         type: SuperColumnType.currency,
         mono: true,
         prefix: symbol,
         suffix: code,
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
    required super.key,
    required super.label,
    super.hidden,
    super.unique,
    super.formatter,
    required this.values,
    String Function(T value)? display,
    super.width,
    super.align,
    super.pin,
    super.editable,
    super.sortable,
    super.groupable,
    super.filterable,
    super.required,
    super.dot,
    super.tones,
    super.filterItems,
    super.filterSource,
    super.onChange,
    super.validator,
    super.styles,
    super.read,
    super.write,
  }) : display = display ?? ((T v) => '$v'),
       super(
         type: SuperColumnType.enumeration,
         opts: _displays(values, display),
         optValues: values,
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
  final Widget Function(BuildContext, AutoSuggestionsBoxController<T>)?
  advancedSearchBuilder;
  final Widget Function(BuildContext, AutoSuggestion<T>, bool highlighted)?
  itemBuilder;
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
    BuildContext context,
    SuperTableController<T> controller,
    SuperRow row,
    SuperCell cell,
  )?
  sourceController;
  final AutoSuggestionsBoxController<T> Function(
    BuildContext context,
    SuperTableController<T> controller,
    SuperRow row,
    SuperCell cell,
  )?
  cellController;

  SuperComboColumn({
    required super.key,
    required super.label,
    super.hidden,
    super.unique,
    super.formatter,
    this.values = const [],
    String Function(T value)? display,
    super.width = 150,
    super.align,
    super.pin,
    super.editable,
    super.sortable,
    super.groupable,
    super.filterable,
    super.required,
    super.mono,
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
    super.filterItems,
    super.filterSource,
    super.onChange,
    super.validator,
    super.styles,
    super.read,
    super.write,
  }) : display = display ?? ((T v) => '$v'),
       super(
         type: SuperColumnType.combo,
         opts: _displays(values, display),
         optValues: values,
       );
}

// ── progress ──────────────────────────────────────────────────────────────────
/// A 0…[max] progress bar column (`T extends num`). Defaults to a 0–100 scale.
class SuperProgressColumn<T extends num> extends SuperColumn<T> {
  SuperProgressColumn({
    required super.key,
    required super.label,
    super.hidden,
    super.formatter,
    super.width = 150,
    super.align,
    super.pin,
    super.agg,
    super.editable,
    super.sortable,
    super.filterable,
    num super.min = 0,
    num super.max = 100,
    super.aggregator,
    super.aggLabel,
    super.onChange,
    super.validator,
    super.styles,
    super.read,
    super.write,
  }) : super(type: SuperColumnType.progress);
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
    required super.key,
    required super.label,
    super.hidden,
    super.formatter,
    this.valueMode = SuperColorValue.hex,
    super.width = 130,
    super.align,
    super.pin,
    super.editable,
    super.sortable,
    super.filterable,
    super.filterItems,
    super.filterSource,
    super.onChange,
    super.validator,
    super.styles,
    super.read,
    super.write,
  }) : super(type: SuperColumnType.color, mono: true);
}

// ── date ──────────────────────────────────────────────────────────────────────
/// A masked `YYYY-MM-DD` date column with a mini-calendar picker (`T == String`).
class SuperDateColumn extends SuperColumn<String> {
  SuperDateColumn({
    required super.key,
    required super.label,
    super.hidden,
    super.unique,
    super.formatter,
    super.width,
    super.align,
    super.pin,
    super.editable,
    super.sortable,
    super.groupable,
    super.filterable,
    super.required,
    super.onChange,
    super.validator,
    super.styles,
    super.read,
    super.write,
  }) : super(type: SuperColumnType.date, mono: true);
}

// ── time ──────────────────────────────────────────────────────────────────────
/// A masked `HH:mm` time column with a 30-minute option list (`T == String`).
class SuperTimeColumn extends SuperColumn<String> {
  SuperTimeColumn({
    required super.key,
    required super.label,
    super.hidden,
    super.unique,
    super.formatter,
    super.width = 120,
    super.align,
    super.pin,
    super.editable,
    super.sortable,
    super.filterable,
    super.required,
    super.onChange,
    super.validator,
    super.styles,
    super.read,
    super.write,
  }) : super(type: SuperColumnType.time, mono: true);
}

// ── link ──────────────────────────────────────────────────────────────────────
/// A clickable link column (`T == String`). [onOpen] is invoked when the cell's
/// link is activated (readable mode).
class SuperLinkColumn extends SuperColumn<String> {
  final void Function(String value, SuperRow row)? onOpen;

  SuperLinkColumn({
    required super.key,
    required super.label,
    super.hidden,
    super.unique,
    super.formatter,
    super.width = 180,
    super.align,
    super.pin,
    super.editable,
    super.sortable,
    super.filterable,
    this.onOpen,
    super.onChange,
    super.validator,
    super.styles,
    super.read,
    super.write,
  }) : super(type: SuperColumnType.link, mono: true);
}

// ── checkbox ──────────────────────────────────────────────────────────────────
/// A boolean tick column (`T == bool`).
class SuperCheckboxColumn extends SuperColumn<bool> {
  SuperCheckboxColumn({
    required super.key,
    required super.label,
    super.hidden,
    super.formatter,
    super.width = 90,
    super.align = SuperAlign.center,
    super.pin,
    super.editable,
    super.sortable,
    super.groupable,
    super.filterable,
    super.onChange,
    super.validator,
    super.styles,
    super.read,
    super.write,
  }) : super(type: SuperColumnType.checkbox);
}

// ── computed ──────────────────────────────────────────────────────────────────
/// A derived, read-only column. [compute] produces the value from the whole
/// row; [format] turns it into display text.
class SuperComputedColumn<T> extends SuperColumn<T> {
  SuperComputedColumn({
    required super.key,
    required super.label,
    super.hidden,
    super.formatter,
    required Object? Function(SuperRow row) super.compute,
    super.format,
    super.width,
    super.align,
    super.pin,
    super.agg,
    super.aggregator,
    super.aggLabel,
    super.sortable,
    super.filterable,
    super.styles,
  }) : super(type: SuperColumnType.computed, editable: false, mono: true);
}

// ── readonly ──────────────────────────────────────────────────────────────────
/// A non-editable display column (`T == String`), shown with a lock affordance.
class SuperReadonlyColumn extends SuperColumn<String> {
  SuperReadonlyColumn({
    required super.key,
    required super.label,
    super.hidden,
    super.formatter,
    super.width,
    super.align,
    super.pin,
    super.sortable,
    super.filterable,
    super.mono,
    super.accessor,
    super.styles,
  }) : super(type: SuperColumnType.readonly, editable: false);
}
