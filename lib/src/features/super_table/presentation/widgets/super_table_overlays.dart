// ============================================================
// features/super_table/presentation/widgets/super_table_overlays.dart
// ------------------------------------------------------------
// Floating chrome for the SuperTable, ported from the React tool:
//   • SuperPopMenu / SuperMenuItem — the header + row context menus.
//   • showSuperConfirm             — the delete-row confirm dialog.
//   • showSuperShortcuts           — the keyboard-shortcuts reference dialog.
//   • SuperCellErrorBadge          — the per-cell validation badge whose tooltip
//                                     escapes the cell's clip via an overlay.
// Pure presentation; all behaviour is passed in as callbacks.
// ============================================================

import 'package:flutter/material.dart';

import 'super_table_skin.dart';

/// A single popup-menu entry.
class SuperMenuEntry {
  final IconData? icon;
  final String label;
  final String? hint;
  final bool danger;
  final bool checked;
  final bool disabled;
  final bool separatorBefore;
  final VoidCallback onTap;
  const SuperMenuEntry({
    this.icon,
    required this.label,
    this.hint,
    this.danger = false,
    this.checked = false,
    this.disabled = false,
    this.separatorBefore = false,
    required this.onTap,
  });
}

/// Shows a floating menu at [globalPos], flipping to stay on screen.
Future<void> showSuperMenu(
  BuildContext context, {
  required Offset globalPos,
  required List<SuperMenuEntry> entries,
  double width = 216,
}) {
  final skin = SuperTableSkin.of(context);
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final size = overlay.size;
  var left = globalPos.dx;
  var top = globalPos.dy;
  // estimate height to flip if needed
  final estH = entries.length * 38 + entries.where((e) => e.separatorBefore).length * 11 + 10;
  if (left + width > size.width - 8) left = size.width - width - 8;
  if (left < 8) left = 8;
  if (top + estH > size.height - 8) top = (globalPos.dy - estH).clamp(8, size.height - 8);

  return showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    builder: (ctx) => Stack(children: [
      Positioned(
        left: left,
        top: top,
        width: width,
        child: _MenuPanel(skin: skin, entries: entries),
      ),
    ]),
  );
}

class _MenuPanel extends StatelessWidget {
  final SuperTableSkin skin;
  final List<SuperMenuEntry> entries;
  const _MenuPanel({required this.skin, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: skin.surface,
          border: Border.all(color: skin.borderStrong),
          borderRadius: BorderRadius.circular(9),
          boxShadow: skin.popShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in entries) ...[
              if (e.separatorBefore)
                Container(height: 1, margin: const EdgeInsets.fromLTRB(4, 5, 4, 5), color: skin.border),
              _MenuRow(skin: skin, entry: e),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatefulWidget {
  final SuperTableSkin skin;
  final SuperMenuEntry entry;
  const _MenuRow({required this.skin, required this.entry});
  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.skin;
    final e = widget.entry;
    final fg = e.disabled ? s.fg4 : (e.danger ? s.danger : s.fg1);
    return MouseRegion(
      cursor: e.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: e.disabled
            ? null
            : () {
                Navigator.of(context).pop();
                e.onTap();
              },
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: !e.disabled && _h ? (e.danger ? s.tint(s.danger, 0.12) : s.hover) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(children: [
            SizedBox(width: 16, child: e.icon != null ? Icon(e.icon, size: 15, color: fg) : null),
            const SizedBox(width: 10),
            Expanded(
              child: Text(e.label,
                  style: TextStyle(fontFamily: SuperTokensFonts.body, fontSize: 13, color: fg)),
            ),
            if (e.checked) Icon(Icons.check_rounded, size: 14, color: s.accent),
            if (e.hint != null)
              Text(e.hint!, style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 11, color: s.fg4)),
          ]),
        ),
      ),
    );
  }
}

/// Confirm dialog (delete row).
Future<bool> showSuperConfirm(
  BuildContext context, {
  required String title,
  required String body,
  String confirmLabel = 'Delete',
  bool danger = true,
}) async {
  final skin = SuperTableSkin.of(context);
  final res = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (ctx) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: skin.surface,
            border: Border.all(color: skin.borderStrong),
            borderRadius: BorderRadius.circular(12),
            boxShadow: skin.popShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: danger ? skin.tint(skin.danger, 0.14) : skin.accentWash(0.14),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(danger ? Icons.delete_outline_rounded : Icons.warning_amber_rounded,
                      size: 19, color: danger ? skin.danger : skin.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: TextStyle(fontFamily: SuperTokensFonts.display, fontWeight: FontWeight.w800, fontSize: 16, color: skin.fg1)),
                ),
              ]),
              const SizedBox(height: 12),
              Text(body, style: TextStyle(fontSize: 13, height: 1.55, color: skin.fg3)),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                _DialogBtn(skin: skin, label: 'Cancel', onTap: () => Navigator.pop(ctx, false)),
                const SizedBox(width: 9),
                _DialogBtn(
                  skin: skin,
                  label: confirmLabel,
                  filled: true,
                  danger: danger,
                  icon: danger ? Icons.delete_outline_rounded : Icons.check_rounded,
                  onTap: () => Navigator.pop(ctx, true),
                ),
              ]),
            ],
          ),
        ),
      ),
    ),
  );
  return res ?? false;
}

class _DialogBtn extends StatelessWidget {
  final SuperTableSkin skin;
  final String label;
  final bool filled;
  final bool danger;
  final IconData? icon;
  final VoidCallback onTap;
  const _DialogBtn({required this.skin, required this.label, this.filled = false, this.danger = false, this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final bg = filled ? (danger ? skin.danger : skin.accent) : Colors.transparent;
    final fg = filled ? Colors.white : skin.fg1;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: bg,
          border: filled ? null : Border.all(color: skin.borderStrong),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 7)],
          Text(label, style: TextStyle(fontFamily: SuperTokensFonts.body, fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
        ]),
      ),
    );
  }
}

/// Keyboard-shortcuts reference dialog.
Future<void> showSuperShortcuts(BuildContext context) {
  final skin = SuperTableSkin.of(context);
  final groups = <(String, List<(String, String)>)>[
    ('Navigate', [
      ('↑ ↓ ← →', 'Move between cells'),
      ('Tab / ⇧Tab', 'Next / previous cell'),
      ('Home / End', 'First / last column'),
      ('⌘Home / ⌘End', 'First / last cell'),
    ]),
    ('Edit', [
      ('Type', 'Overwrite the cell'),
      ('Enter / F2', 'Edit, or open a select'),
      ('Enter↓ · Tab→', 'Commit & move'),
      ('Tab at end', 'Append a new row'),
      ('⌫ / Delete', 'Clear the cell'),
      ('Esc', 'Cancel editing'),
    ]),
    ('Rows & clipboard', [
      ('⌘Enter', 'Add a row'),
      ('⌘D', 'Duplicate row'),
      ('⌘⌫', 'Delete row'),
      ('⌘C', 'Copy selection as JSON'),
      ('⌘X / ⌘V', 'Cut / paste (validated)'),
      ('⌘Z / ⌘⇧Z', 'Undo / redo'),
    ]),
  ];
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (ctx) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 640),
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 28),
          decoration: BoxDecoration(
            color: skin.surface,
            border: Border.all(color: skin.borderStrong),
            borderRadius: BorderRadius.circular(12),
            boxShadow: skin.popShadow,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: skin.accentWash(0.14), borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.keyboard_rounded, size: 19, color: skin.accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Keyboard shortcuts',
                        style: TextStyle(fontFamily: SuperTokensFonts.display, fontWeight: FontWeight.w800, fontSize: 19, color: skin.fg1)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: skin.inputBg, border: Border.all(color: skin.borderStrong), borderRadius: BorderRadius.circular(7)),
                      child: Icon(Icons.close_rounded, size: 16, color: skin.fg2),
                    ),
                  ),
                ]),
                const SizedBox(height: 22),
                for (final g in groups) ...[
                  Text(g.$1.toUpperCase(),
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: skin.accent)),
                  const SizedBox(height: 10),
                  for (final row in g.$2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        SizedBox(width: 186, child: _Kbd(skin: skin, text: row.$1)),
                        const SizedBox(width: 16),
                        Expanded(child: Text(row.$2, style: TextStyle(fontSize: 13, color: skin.fg3))),
                      ]),
                    ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _Kbd extends StatelessWidget {
  final SuperTableSkin skin;
  final String text;
  const _Kbd({required this.skin, required this.text});
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final part in text.split(' '))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: skin.inputBg,
              border: Border.all(color: skin.borderStrong),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(part,
                style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 11.5, fontWeight: FontWeight.w600, color: skin.fg2)),
          ),
      ],
    );
  }
}

/// Per-cell validation badge with an overlay tooltip (escapes cell clipping).
class SuperCellErrorBadge extends StatefulWidget {
  final String error;
  const SuperCellErrorBadge({super.key, required this.error});
  @override
  State<SuperCellErrorBadge> createState() => _SuperCellErrorBadgeState();
}

class _SuperCellErrorBadgeState extends State<SuperCellErrorBadge> {
  final _link = LayerLink();
  OverlayEntry? _entry;

  void _show() {
    if (_entry != null) return;
    final skin = SuperTableSkin.of(context);
    _entry = OverlayEntry(
      builder: (ctx) => Positioned(
        width: 240,
        child: CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.topCenter,
          followerAnchor: Alignment.bottomCenter,
          offset: const Offset(0, -6),
          child: Material(
            color: Colors.transparent,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: skin.danger,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Color(0x73000000), blurRadius: 32, offset: Offset(0, 12))],
                ),
                child: Text(widget.error,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, height: 1.45)),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_entry!);
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skin = SuperTableSkin.of(context);
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        onEnter: (_) => _show(),
        onExit: (_) => _hide(),
        child: Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: skin.surface, borderRadius: BorderRadius.circular(5)),
          child: Icon(Icons.error_outline_rounded, size: 15, color: skin.danger),
        ),
      ),
    );
  }
}

/// Re-export the brand font family names for terse use in this folder.
abstract final class SuperTokensFonts {
  static const String display = 'Manrope';
  static const String body = 'Inter';
  static const String mono = 'JetBrainsMono';
  static const String arabic = 'NotoNaskhArabic';
}
