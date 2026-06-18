// ============================================================
// features/super_table/presentation/widgets/super_table_skin.dart
// ------------------------------------------------------------
// Derives the SuperTable's extra surfaces (surface-2, accent washes, shimmer)
// from the shared core SuperThemeData so the unified grid themes from the same
// single source as the rest of the kit. A thin value object resolved once per
// build from context.
// ============================================================

import 'package:flutter/widgets.dart';

import 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

/// Resolved palette for the SuperTable, derived from the core theme.
class SuperTableSkin {
  final SuperThemeData t;
  const SuperTableSkin(this.t);

  factory SuperTableSkin.of(BuildContext context) => SuperTableSkin(context.superTheme);

  bool get isDark => t.brightness == Brightness.dark;
  Color get bg => t.bg;
  Color get surface => t.surface;
  Color get inputBg => t.inputBg;
  Color get hover => t.hover;
  Color get border => t.border;
  Color get borderStrong => t.borderStrong;
  Color get fg1 => t.fg1;
  Color get fg2 => t.fg2;
  Color get fg3 => t.fg3;
  Color get fg4 => t.fg4;
  Color get accent => SuperTokens.accent;
  Color get success => SuperTokens.success;
  Color get warning => SuperTokens.warning;
  Color get danger => SuperTokens.danger;

  /// A second surface tone (group headers, totals, gutter accents).
  Color get surface2 => isDark
      ? Color.alphaBlend(const Color(0x14FFFFFF), surface)
      : Color.alphaBlend(const Color(0x07000000), surface);

  /// `color-mix(accent N%, surface)` — the selection / active washes.
  Color accentWash(double pct) => Color.alphaBlend(accent.withOpacity(pct), surface);

  /// `color-mix(accent N%, bg)` — gutter highlight.
  Color accentWashOnBg(double pct) => Color.alphaBlend(accent.withOpacity(pct), bg);

  /// A semantic tint over the surface (enum pills, danger rows).
  Color tint(Color base, double pct) => Color.alphaBlend(base.withOpacity(pct), surface);

  /// The dimmed fill for computed / readonly cells.
  Color get dimFill => Color.alphaBlend(fg1.withOpacity(0.04), surface);

  /// Popover shadow.
  List<BoxShadow> get popShadow => const [
        BoxShadow(color: Color(0x66000000), blurRadius: 36, spreadRadius: -10, offset: Offset(0, 14)),
      ];
}
