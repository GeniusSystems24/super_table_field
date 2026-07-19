// ============================================================
// features/super_table/domain/entities/super_row_expansion.dart
// ------------------------------------------------------------
// Configuration for expandable row panels in SuperTable Readable Mode.
//
// Pass a [SuperRowExpansion] to [SuperTable.expansion] to enable per-row
// expand/collapse panels. Each panel is built on demand by [builder] and
// animates open/closed via [animationDuration] and [animationCurve].
//
// The [mode] controls whether multiple rows can be open simultaneously
// ([SuperRowExpansionMode.multi], the default) or only one at a time
// ([SuperRowExpansionMode.single] — accordion behaviour).
//
// Per-row heights are resolved through [heightBuilder] (falls back to
// [defaultHeight] when null or not provided), making it straightforward to
// give rows with more content a taller panel without affecting others.
//
// Expansion state lives in the View's _SuperTableState (a Set<int> of
// SuperRow.id values) and is intentionally NOT exposed on the controller —
// it is purely a presentation concern, decoupled from data, undo/redo and
// selection. Editable mode is unaffected: panels never render there.
//
// Pure data + callbacks — no Flutter widget types referenced here.
// ============================================================

import 'package:flutter/services.dart'
    show KeyDownEvent, KeyEvent, KeyRepeatEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart' show BuildContext, Curve, Curves, Widget;

import '../../presentation/controllers/super_table_controller.dart';
import 'super_row.dart';

/// Content builder for a row's expanded panel. Receives the live [context],
/// the table [controller], and the [row] being expanded. The widget is
/// rendered inside a clipped, fixed-height [SizedBox] whose height is
/// resolved by [SuperRowExpansion.heightFor] — avoid putting scrollable
/// children that consume vertical gestures; wrap them in a bounded [SizedBox]
/// with `physics: NeverScrollableScrollPhysics()` if needed.
typedef SuperRowExpansionBuilder<R> =
    Widget Function(
      BuildContext context,
      SuperTableController<R> controller,
      SuperRow<R> row,
    );

/// Controls whether multiple rows may be expanded simultaneously.
enum SuperRowExpansionMode {
  /// Any number of rows may be expanded at the same time (default).
  multi,

  /// Only one row may be open at a time. Opening a new row automatically
  /// collapses the previously-expanded row (accordion behaviour).
  single,
}

// ── Keyboard shortcut types ──────────────────────────────────────────────────

/// A single keyboard shortcut: a [LogicalKeyboardKey] plus optional modifier
/// flags.
///
/// On macOS, [ctrl] matches both ⌃ Control and ⌘ Command — consistent with
/// the rest of SuperTable's keyboard handling.
///
/// Pass instances to [SuperRowExpansionKeymap.expand] and
/// [SuperRowExpansionKeymap.collapse].
class SuperExpansionShortcut {
  /// The primary key (e.g. `LogicalKeyboardKey.arrowDown`).
  final LogicalKeyboardKey key;

  /// Require Ctrl (Win/Linux) or Ctrl / ⌘ (macOS) to be held.
  final bool ctrl;

  /// Require Shift to be held.
  final bool shift;

  /// Require Alt / Option to be held.
  final bool alt;

  const SuperExpansionShortcut({
    required this.key,
    this.ctrl = false,
    this.shift = false,
    this.alt = false,
  });

  /// Returns true when [event] together with the current [pressed] set matches
  /// this shortcut definition.
  bool matches(KeyEvent event, Set<LogicalKeyboardKey> pressed) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    if (event.logicalKey != key) return false;
    final hasCtrl =
        pressed.contains(LogicalKeyboardKey.controlLeft) ||
        pressed.contains(LogicalKeyboardKey.controlRight) ||
        pressed.contains(LogicalKeyboardKey.metaLeft) ||
        pressed.contains(LogicalKeyboardKey.metaRight);
    if (ctrl != hasCtrl) return false;
    final hasShift =
        pressed.contains(LogicalKeyboardKey.shiftLeft) ||
        pressed.contains(LogicalKeyboardKey.shiftRight);
    if (shift != hasShift) return false;
    final hasAlt =
        pressed.contains(LogicalKeyboardKey.altLeft) ||
        pressed.contains(LogicalKeyboardKey.altRight);
    if (alt != hasAlt) return false;
    return true;
  }
}

/// Configurable keyboard shortcuts for expanding and collapsing the focused
/// row in [SuperTable] Readable Mode.
///
/// Add to [SuperRowExpansion.keymap] to opt in to keyboard control. When
/// [SuperRowExpansion.keymap] is null (the default) no shortcuts are
/// registered and existing table navigation is completely unaffected.
///
/// ### Enable built-in defaults (Ctrl/⌘+Shift+↓ / Ctrl/⌘+Shift+↑)
/// ```dart
/// SuperRowExpansion(
///   keymap: SuperRowExpansionKeymap(),
///   builder: (ctx, ctrl, row) => MyPanel(row: row),
/// )
/// ```
///
/// ### Custom key combinations
/// ```dart
/// SuperRowExpansion(
///   keymap: SuperRowExpansionKeymap(
///     expand:   SuperExpansionShortcut(key: LogicalKeyboardKey.keyE, ctrl: true),
///     collapse: SuperExpansionShortcut(key: LogicalKeyboardKey.keyW, ctrl: true),
///   ),
///   builder: (ctx, ctrl, row) => MyPanel(row: row),
/// )
/// ```
class SuperRowExpansionKeymap {
  /// Shortcut that expands the currently focused row.
  ///
  /// Defaults to **Ctrl+Shift+↓** (⌘+Shift+↓ on macOS).
  final SuperExpansionShortcut expand;

  /// Shortcut that collapses the currently focused row.
  ///
  /// Defaults to **Ctrl+Shift+↑** (⌘+Shift+↑ on macOS).
  final SuperExpansionShortcut collapse;

  const SuperRowExpansionKeymap({
    this.expand = const SuperExpansionShortcut(
      key: LogicalKeyboardKey.arrowDown,
      ctrl: true,
      shift: true,
    ),
    this.collapse = const SuperExpansionShortcut(
      key: LogicalKeyboardKey.arrowUp,
      ctrl: true,
      shift: true,
    ),
  });
}

// ── Main config class ─────────────────────────────────────────────────────────

/// Configuration for expandable row panels in [SuperTable] Readable Mode.
///
/// ### Minimal usage — uniform height, any number of rows open
/// ```dart
/// SuperTable(
///   controller: _controller,
///   expansion: SuperRowExpansion(
///     builder: (ctx, ctrl, row) => MyDetailWidget(data: row.value),
///   ),
/// )
/// ```
///
/// ### Accordion (single-open) with per-row heights
/// ```dart
/// SuperRowExpansion(
///   mode: SuperRowExpansionMode.single,
///   defaultHeight: 100,
///   heightBuilder: (row) {
///     // rows with notes need more space
///     return (row['notes'] as String?)?.isNotEmpty == true ? 200.0 : null;
///   },
///   builder: (ctx, ctrl, row) => MyDetailPanel(row: row),
/// )
/// ```
class SuperRowExpansion<R> {
  /// Required: builds the content widget shown inside the expanded panel.
  ///
  /// Called when the panel is first made visible. The widget is hosted inside
  /// a [SizedBox] of size `(double.infinity × heightFor(row))` and clipped
  /// by a [ClipRect] — it must not try to size itself larger than that.
  final SuperRowExpansionBuilder<R> builder;

  /// Expanded panel height in logical pixels when [heightBuilder] is not set
  /// or returns null. Defaults to **120**.
  final double defaultHeight;

  /// Optional per-row height override. Return null to fall back to
  /// [defaultHeight]. The value is read once per row at build time; if the
  /// row's data changes you should call `setState` (or
  /// `controller.notifyListeners()`) to trigger a rebuild.
  ///
  /// Example — rows with 4+ line items get a taller panel:
  /// ```dart
  /// heightBuilder: (row) => row.value.lines.length >= 4 ? 192.0 : null,
  /// ```
  final double? Function(SuperRow<R> row)? heightBuilder;

  /// Whether multiple rows may be expanded simultaneously ([multi], default)
  /// or only one row at a time ([single] / accordion).
  final SuperRowExpansionMode mode;

  /// Duration of the expand/collapse height animation. Defaults to 220 ms —
  /// fast enough to feel snappy, slow enough to be readable.
  final Duration animationDuration;

  /// Easing curve for the expand/collapse animation.
  /// Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  /// Optional keyboard shortcuts for expanding / collapsing the focused row
  /// (Readable mode only).
  ///
  /// When null (the default) no shortcuts are registered and existing
  /// navigation is unaffected. Pass `SuperRowExpansionKeymap()` to opt in to
  /// the built-in defaults (**Ctrl/⌘+Shift+↓** expand, **Ctrl/⌘+Shift+↑**
  /// collapse), or supply a custom [SuperRowExpansionKeymap] to override them.
  final SuperRowExpansionKeymap? keymap;

  const SuperRowExpansion({
    required this.builder,
    this.defaultHeight = 120,
    this.heightBuilder,
    this.mode = SuperRowExpansionMode.multi,
    this.animationDuration = const Duration(milliseconds: 220),
    this.animationCurve = Curves.easeInOut,
    this.keymap,
  });

  /// Resolve the expanded panel height for [row]:
  /// [heightBuilder] result if non-null, else [defaultHeight].
  double heightFor(SuperRow<R> row) =>
      heightBuilder?.call(row) ?? defaultHeight;
}
