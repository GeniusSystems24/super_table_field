// ============================================================
// features/super_table/domain/usecases/super_column_logic.dart
// ------------------------------------------------------------
// The pure, framework-free logic behind every column type: number
// parsing/formatting/clamping, semantic tone maps, value→text serialisation,
// enum/color display resolution, sort comparison, type validation, paste
// coercion, aggregation, input masks, and **advanced-filter clause evaluation**.
// The view and controller call these; nothing here imports Flutter widgets
// (only `Color`). Operates on the 0.4.0 [SuperRow] / [SuperCell] model.
// ============================================================

import 'package:flutter/widgets.dart' show Color;

import '../entities/super_column.dart';
import '../entities/super_columns.dart';
import '../entities/super_filter.dart';
import '../entities/super_row.dart';

/// Outcome of coercing a pasted value against a column type.
class CoerceResult {
  final bool ok;
  final Object? value;
  final String? error;
  const CoerceResult.ok(this.value)
      : ok = true,
        error = null;
  const CoerceResult.fail(this.error)
      : ok = false,
        value = null;
}

/// Pure column-type logic shared across the SuperTable.
abstract final class SuperColumnLogic {
  // ── semantic tone maps (ported 1:1) ──
  static const Map<String, Color> typeTones = {
    'Asset': Color(0xFF4A7CFF),
    'Liability': Color(0xFFE0A23B),
    'Equity': Color(0xFF8B5CF6),
    'Revenue': Color(0xFF1DB88A),
    'Expense': Color(0xFFEF4444),
  };
  static const Map<String, Color> statusTones = {
    'In Stock': Color(0xFF1DB88A), 'Active': Color(0xFF1DB88A), 'Reconciled': Color(0xFF1DB88A), 'Available': Color(0xFF1DB88A),
    'Low': Color(0xFFE0A23B), 'Low Stock': Color(0xFFE0A23B), 'Pending': Color(0xFFE0A23B), 'Reorder': Color(0xFFE0A23B), 'Open': Color(0xFFE0A23B),
    'Out of Stock': Color(0xFFEF4444), 'Flagged': Color(0xFFEF4444), 'Discontinued': Color(0xFFEF4444), 'Blocked': Color(0xFFEF4444),
    'Draft': Color(0xFF8C92A4), 'Archived': Color(0xFF8C92A4), 'Review': Color(0xFF8C92A4),
  };
  static const List<Color> defaultPalette = [
    Color(0xFF4A7CFF), Color(0xFF1DB88A), Color(0xFFE0A23B), Color(0xFF8B5CF6),
    Color(0xFFEF4444), Color(0xFF06B6D4), Color(0xFFEC4899),
  ];
  static const List<Color> swatches = [
    Color(0xFF4A7CFF), Color(0xFF3D6DEB), Color(0xFF06B6D4), Color(0xFF1DB88A),
    Color(0xFF22C55E), Color(0xFFE0A23B), Color(0xFFF97316), Color(0xFFEF4444),
    Color(0xFFEC4899), Color(0xFF8B5CF6), Color(0xFF6366F1), Color(0xFF8C92A4),
  ];

  /// The pill tone for an enum display value: override ▸ status ▸ type ▸ palette.
  static Color? toneFor(SuperColumn col, String v) {
    if (col.tones != null && col.tones![v] != null) return col.tones![v];
    if (statusTones[v] != null) return statusTones[v];
    if (typeTones[v] != null) return typeTones[v];
    if (col.opts != null) {
      final i = col.opts!.indexOf(v);
      if (i >= 0) return defaultPalette[i % defaultPalette.length];
    }
    return null; // caller falls back to fg3
  }

  // ── enum/combo display resolution ──
  /// Map a raw cell value to its display string for an enum/combo column.
  static String displayOf(SuperColumn col, Object? value) {
    final ov = col.optValues;
    final opts = col.opts;
    if (ov != null && opts != null) {
      final i = ov.indexWhere((e) => e == value);
      if (i >= 0 && i < opts.length) return opts[i];
    }
    return value == null ? '' : '$value';
  }

  // ── number helpers ──
  static num numVal(Object? v) {
    if (v is num) return v;
    final cleaned = '$v'.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  /// Grouped-thousands formatting honoring the column's decimals/currency.
  static String fmtNum(Object? v, SuperColumn col) {
    final n = v is num ? v : double.tryParse('$v'.replaceAll(RegExp(r'[^0-9.\-]'), ''));
    if (n == null) return '';
    final dec = col.decimals ?? (col.type == SuperColumnType.currency ? 2 : 0);
    return _grouped(n.abs(), dec);
  }

  static String _grouped(num n, int decimals) {
    final fixed = n.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    return parts.length > 1 ? '$buf.${parts[1]}' : '$buf';
  }

  /// Clamp + round a number to the column's min/max/decimals.
  static num clampNum(num n, SuperColumn col) {
    if (col.min != null && n < col.min!) n = col.min!;
    if (col.max != null && n > col.max!) n = col.max!;
    final d = col.decimals;
    if (d != null) {
      final f = _pow10(d);
      n = (n * f).round() / f;
    }
    return n;
  }

  static num _pow10(int d) {
    var r = 1.0;
    for (var i = 0; i < d; i++) {
      r *= 10;
    }
    return r;
  }

  // ── color helpers ──
  /// Resolve a color column's cell value to a hex `#RRGGBB` string.
  static String colorHex(SuperColumn col, Object? v) {
    if (v is Color) return '#${(v.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    if (v is int) return '#${(v & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    final s = '$v'.trim();
    if (RegExp(r'^#?[0-9a-fA-F]{6}$').hasMatch(s)) return s.startsWith('#') ? s.toUpperCase() : '#${s.toUpperCase()}';
    return s;
  }

  /// Coerce a `#RRGGBB` hex back into the column's declared value mode.
  static Object? colorFromHex(SuperColumn col, String hex) {
    final mode = col is SuperColorColumn ? col.valueMode : SuperColorValue.hex;
    final clean = hex.replaceAll('#', '');
    switch (mode) {
      case SuperColorValue.number:
        return int.tryParse('FF$clean', radix: 16) ?? 0xFF000000;
      case SuperColorValue.color:
        return Color(int.tryParse('FF$clean', radix: 16) ?? 0xFF000000);
      case SuperColorValue.hex:
        return '#${clean.toUpperCase()}';
    }
  }

  // ── value → plain text (sort fallback, search, clipboard TSV) ──
  static String toText(SuperColumn col, Object? value, SuperRow row) {
    switch (col.type) {
      case SuperColumnType.computed:
        final out = col.compute != null ? col.compute!(row) : value;
        if (col.format != null) return col.format!(out, row);
        return out == null || out == '' ? '' : '$out';
      case SuperColumnType.checkbox:
        final on = value == true || value == 'true' || value == 'Yes' || value == 1;
        return on ? 'Yes' : 'No';
      case SuperColumnType.enumeration:
      case SuperColumnType.combo:
        return displayOf(col, value);
      case SuperColumnType.color:
        return colorHex(col, value);
      default:
        return value == null ? '' : '$value';
    }
  }

  /// The Arabic companion text for a column's [arKey] (cell ▸ map field).
  static String arText(SuperColumn col, SuperRow row) {
    final ar = col.arKey;
    if (ar == null) return '';
    final cell = row.cells[ar];
    if (cell != null) return '${cell.value ?? ''}';
    final v = row.value;
    if (v is Map) return '${v[ar] ?? ''}';
    return '';
  }

  // ── sort comparison ──
  static int compare(SuperColumn col, Object? a, Object? b) {
    switch (col.type) {
      case SuperColumnType.number:
      case SuperColumnType.currency:
      case SuperColumnType.progress:
      case SuperColumnType.computed:
        return numVal(a).compareTo(numVal(b));
      case SuperColumnType.checkbox:
        final av = (a == true || a == 'true') ? 1 : 0;
        final bv = (b == true || b == 'true') ? 1 : 0;
        return av - bv;
      default:
        return ('${a ?? ''}').toLowerCase().compareTo(('${b ?? ''}').toLowerCase());
    }
  }

  // ── built-in type validation (editable mode; runs before column.validator) ──
  static String? validateCell(SuperColumn col, Object? v) {
    final s = (v == null ? '' : '$v').trim();
    final name = col.label.isNotEmpty ? '“${col.label}”' : 'This cell';
    if (col.required && s.isEmpty) return '$name is required';
    if (col.type.isNumeric && s.isNotEmpty && double.tryParse(s.replaceAll(RegExp(r'[^0-9.\-]'), '')) == null) {
      return '$name must be a number';
    }
    if (col.type == SuperColumnType.date && s.isNotEmpty && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
      return '$name must be a date (YYYY-MM-DD)';
    }
    if (col.type == SuperColumnType.time && s.isNotEmpty && !RegExp(r'^\d{2}:\d{2}$').hasMatch(s)) {
      return '$name must be a time (HH:mm)';
    }
    if (col.type == SuperColumnType.color && s.isNotEmpty && !RegExp(r'^#?[0-9a-fA-F]{6}$').hasMatch(s)) {
      return '$name must be a hex color (#RRGGBB)';
    }
    return null;
  }

  // ── paste coercion ──
  static CoerceResult coercePaste(SuperColumn col, Object? raw) {
    final t = col.type;
    if (t == SuperColumnType.computed || t == SuperColumnType.readonly) {
      return CoerceResult.fail('“${col.label}” is read-only');
    }
    final s = raw == null ? '' : '$raw'.trim();
    if (s.isEmpty) {
      if (col.required) return CoerceResult.fail('“${col.label}” is required');
      return const CoerceResult.ok('');
    }
    if (t.isNumeric) {
      if (double.tryParse(s.replaceAll(RegExp(r'[^0-9.\-]'), '')) == null) {
        return CoerceResult.fail('“${col.label}” expects a number — got “$s”');
      }
      return CoerceResult.ok(clampNum(numVal(s), col));
    }
    if (t == SuperColumnType.checkbox) {
      final yes = ['true', 'yes', '1'].contains(s.toLowerCase());
      final no = ['false', 'no', '0'].contains(s.toLowerCase());
      if (!yes && !no) return CoerceResult.fail('“${col.label}” expects true/false — got “$s”');
      return CoerceResult.ok(yes);
    }
    if (t == SuperColumnType.enumeration) {
      if (col.opts != null && !col.opts!.contains(s)) {
        return CoerceResult.fail('“${col.label}” must be one of: ${col.opts!.join(', ')}');
      }
      // map a display string back to its raw value where possible
      final ov = col.optValues, opts = col.opts;
      if (ov != null && opts != null) {
        final i = opts.indexOf(s);
        if (i >= 0) return CoerceResult.ok(ov[i]);
      }
      return CoerceResult.ok(s);
    }
    if (t == SuperColumnType.date && !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
      return CoerceResult.fail('“${col.label}” expects YYYY-MM-DD — got “$s”');
    }
    if (t == SuperColumnType.time && !RegExp(r'^\d{2}:\d{2}$').hasMatch(s)) {
      return CoerceResult.fail('“${col.label}” expects HH:mm — got “$s”');
    }
    if (t == SuperColumnType.color && !RegExp(r'^#?[0-9a-fA-F]{6}$').hasMatch(s)) {
      return CoerceResult.fail('“${col.label}” expects #RRGGBB — got “$s”');
    }
    return CoerceResult.ok(s);
  }

  // ── aggregation ──
  static num? aggregate(SuperColumn col, List<SuperRow> rows) {
    if (col.agg == SuperAgg.none) return null;
    if (col.agg == SuperAgg.custom) return col.aggregator?.call(rows);
    if (col.agg == SuperAgg.count) return rows.length;
    if (rows.isEmpty) return col.agg == SuperAgg.sum || col.agg == SuperAgg.avg ? 0 : null;
    final nums = rows.map((r) => numVal(col.rawValue(r)));
    switch (col.agg) {
      case SuperAgg.sum:
        return nums.fold<num>(0, (a, b) => a + b);
      case SuperAgg.avg:
        return nums.fold<num>(0, (a, b) => a + b) / rows.length;
      case SuperAgg.min:
        return nums.reduce((a, b) => a < b ? a : b);
      case SuperAgg.max:
        return nums.reduce((a, b) => a > b ? a : b);
      default:
        return null;
    }
  }

  // ── advanced-filter clause evaluation ──
  /// Evaluate one [AdvancedFilterClause] against [row] for column [col].
  static bool matchesClause(SuperColumn col, SuperRow row, AdvancedFilterClause clause) {
    final raw = col.rawValue(row);
    final text = toText(col, raw, row).toLowerCase();
    String needle() => '${clause.value ?? ''}'.toLowerCase();
    switch (clause.op) {
      case FilterOp.contains:
        return text.contains(needle());
      case FilterOp.equals:
        return text == needle();
      case FilterOp.notEquals:
        return text != needle();
      case FilterOp.startsWith:
        return text.startsWith(needle());
      case FilterOp.endsWith:
        return text.endsWith(needle());
      case FilterOp.isEmpty:
        return text.trim().isEmpty;
      case FilterOp.isNotEmpty:
        return text.trim().isNotEmpty;
      case FilterOp.greaterThan:
        return numVal(raw) > numVal(clause.value);
      case FilterOp.greaterOrEqual:
        return numVal(raw) >= numVal(clause.value);
      case FilterOp.lessThan:
        return numVal(raw) < numVal(clause.value);
      case FilterOp.lessOrEqual:
        return numVal(raw) <= numVal(clause.value);
      case FilterOp.between:
        final n = numVal(raw);
        return n >= numVal(clause.value) && n <= numVal(clause.value2);
    }
  }

  // ── input masks ──
  static String maskDate(String s) {
    final d = s.replaceAll(RegExp(r'[^\d]'), '');
    final dd = d.length > 8 ? d.substring(0, 8) : d;
    var out = dd.length >= 4 ? dd.substring(0, 4) : dd;
    if (dd.length > 4) out += '-${dd.substring(4, dd.length > 6 ? 6 : dd.length)}';
    if (dd.length > 6) out += '-${dd.substring(6)}';
    return out;
  }

  static String maskTime(String s) {
    final d = s.replaceAll(RegExp(r'[^\d]'), '');
    final dd = d.length > 4 ? d.substring(0, 4) : d;
    var out = dd.length >= 2 ? dd.substring(0, 2) : dd;
    if (dd.length > 2) out += ':${dd.substring(2)}';
    return out;
  }

  /// The 48 half-hour time options for the time picker.
  static List<String> get timeOptions {
    final a = <String>[];
    for (var h = 0; h < 24; h++) {
      for (final m in [0, 30]) {
        a.add('${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}');
      }
    }
    return a;
  }
}
