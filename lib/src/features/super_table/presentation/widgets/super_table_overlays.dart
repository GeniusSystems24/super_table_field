// ============================================================
// features/super_table/presentation/widgets/super_table_overlays.dart
// ------------------------------------------------------------
// Floating chrome for the SuperTable:
//   • SuperMenuEntry / showSuperMenu — header + row context menus. Entries with
//     `children` are **cascading submenus**: their branches open as a floating
//     overlayCard beside the parent row and can nest arbitrarily deep (0.4.0).
//   • showSuperConfirm     — the delete-row confirm dialog.
//   • showSuperShortcuts   — the keyboard-shortcuts reference dialog.
//   • showSuperAdvancedFilter — the cross-column advanced-filter editor (0.4.0).
//   • showSuperValidationPanel — the table-wide validation summary with
//     jump-to-cell (2.1.0).
//   • SuperCellErrorBadge  — the per-cell validation badge with an overlay tip.
// Pure presentation; all behaviour is passed in as callbacks.
// ============================================================

import 'package:flutter/material.dart';

import '../../domain/entities/super_column.dart';
import '../../domain/entities/super_filter.dart';
import '../../domain/entities/super_validation.dart';
import '../controllers/super_table_controller.dart';
import 'super_table_skin.dart';

/// A single popup-menu entry.
///
/// Set [children] to make this entry a **cascading submenu**: hovering/tapping
/// it opens a floating overlayCard with the nested entries beside this row
/// (instead of firing [onTap]). Submenus may nest arbitrarily deep.
class SuperMenuEntry {
  final IconData? icon;
  final String label;
  final String? hint;
  final bool danger;
  final bool checked;
  final bool disabled;
  final bool separatorBefore;
  final VoidCallback onTap;
  final List<SuperMenuEntry> children;
  final bool expanded; // retained for API compat; cascades open on demand
  const SuperMenuEntry({
    this.icon,
    required this.label,
    this.hint,
    this.danger = false,
    this.checked = false,
    this.disabled = false,
    this.separatorBefore = false,
    this.children = const [],
    this.expanded = false,
    this.onTap = _noop,
  });

  bool get hasChildren => children.isNotEmpty;
  static void _noop() {}
}

const double _kMenuWidth = 216;

/// Shows a floating menu at [globalPos], flipping to stay on screen. Submenus
/// cascade as overlayCards.
Future<void> showSuperMenu(
  BuildContext context, {
  required Offset globalPos,
  required List<SuperMenuEntry> entries,
  double width = _kMenuWidth,
}) {
  final skin = SuperTableSkin.of(context);
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final size = overlay.size;
  var left = globalPos.dx;
  var top = globalPos.dy;
  final estH = entries.length * 36 + entries.where((e) => e.separatorBefore).length * 11 + 10;
  if (left + width > size.width - 8) left = size.width - width - 8;
  if (left < 8) left = 8;
  if (top + estH > size.height - 8) top = (globalPos.dy - estH).clamp(8.0, size.height - 8.0);

  return showDialog<void>(
    context: context,
    barrierColor: Colors.transparent,
    barrierDismissible: true,
    builder: (ctx) => Stack(children: [
      Positioned(
        left: left,
        top: top,
        width: width,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: size.height - top - 8),
          child: _MenuPanel(skin: skin, entries: entries, width: width, screen: size),
        ),
      ),
    ]),
  );
}

/// A single menu panel (root or a cascaded child). Manages exactly one open
/// child cascade at a time.
class _MenuPanel extends StatefulWidget {
  final SuperTableSkin skin;
  final List<SuperMenuEntry> entries;
  final double width;
  final Size screen;
  const _MenuPanel({required this.skin, required this.entries, required this.width, required this.screen});

  @override
  State<_MenuPanel> createState() => _MenuPanelState();
}

class _MenuPanelState extends State<_MenuPanel> {
  SuperMenuEntry? _openEntry;
  OverlayEntry? _child;

  void _closeChild() {
    _child?.remove();
    _child = null;
    _openEntry = null;
  }

  void _openCascade(SuperMenuEntry e, BuildContext rowContext) {
    if (_openEntry == e) return;
    _closeChild();
    _openEntry = e;
    final box = rowContext.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero);
    final rowH = box.size.height;
    final s = widget.screen;
    var left = origin.dx + widget.width - 6;
    final flip = left + widget.width > s.width - 8;
    if (flip) left = origin.dx - widget.width + 6;
    left = left.clamp(8.0, s.width - widget.width - 8.0);
    var top = origin.dy - 5;
    final estH = e.children.length * 36 + 10;
    if (top + estH > s.height - 8) top = (s.height - estH - 8).clamp(8.0, s.height - 8.0);

    _child = OverlayEntry(
      builder: (ctx) => Positioned(
        left: left,
        top: top,
        width: widget.width,
        child: MouseRegion(
          onExit: (_) => setState(_closeChild),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: s.height - top - 8),
            child: _MenuPanel(skin: widget.skin, entries: e.children, width: widget.width, screen: s),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_child!);
    setState(() {});
  }

  @override
  void dispose() {
    _child?.remove();
    _child = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final out = <Widget>[];
    for (final e in widget.entries) {
      if (e.separatorBefore) {
        out.add(Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5), color: widget.skin.border));
      }
      out.add(_MenuRow(
        skin: widget.skin,
        entry: e,
        open: _openEntry == e,
        onHoverEnter: (rowCtx) {
          if (e.hasChildren) {
            _openCascade(e, rowCtx);
          } else {
            _closeChild();
          }
        },
        onTap: (rowCtx) {
          if (e.hasChildren) {
            _openCascade(e, rowCtx);
          } else {
            _closeRoot(context);
            e.onTap();
          }
        },
      ));
    }
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: widget.skin.surface,
          border: Border.all(color: widget.skin.borderStrong),
          borderRadius: BorderRadius.circular(9),
          boxShadow: widget.skin.popShadow,
        ),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: out)),
      ),
    );
  }

  void _closeRoot(BuildContext context) {
    // Pop the root dialog (closes the whole cascade with it).
    Navigator.of(context, rootNavigator: false).maybePop();
  }
}

class _MenuRow extends StatefulWidget {
  final SuperTableSkin skin;
  final SuperMenuEntry entry;
  final bool open;
  final void Function(BuildContext rowContext) onHoverEnter;
  final void Function(BuildContext rowContext) onTap;
  const _MenuRow({required this.skin, required this.entry, required this.open, required this.onHoverEnter, required this.onTap});
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
    final lit = (_h || widget.open) && !e.disabled;
    return MouseRegion(
      cursor: e.disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _h = true);
        if (!e.disabled) widget.onHoverEnter(context);
      },
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: e.disabled ? null : () => widget.onTap(context),
        child: Container(
          height: 34,
          padding: const EdgeInsetsDirectional.only(start: 10, end: 10),
          decoration: BoxDecoration(
            color: lit ? (e.danger ? s.tint(s.danger, 0.12) : s.hover) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(children: [
            SizedBox(width: 16, child: e.icon != null ? Icon(e.icon, size: 15, color: fg) : null),
            const SizedBox(width: 10),
            Expanded(child: Text(e.label, style: TextStyle(fontFamily: SuperTokensFonts.body, fontSize: 13, color: fg))),
            if (e.checked) Icon(Icons.check_rounded, size: 14, color: s.accent),
            if (e.hint != null) Text(e.hint!, style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 11, color: s.fg4)),
            if (e.hasChildren) Padding(padding: const EdgeInsets.only(left: 4), child: Icon(Icons.chevron_right_rounded, size: 16, color: s.fg3)),
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
                  child: Icon(danger ? Icons.delete_outline_rounded : Icons.warning_amber_rounded, size: 19, color: danger ? skin.danger : skin.accent),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: TextStyle(fontFamily: SuperTokensFonts.display, fontWeight: FontWeight.w800, fontSize: 16, color: skin.fg1))),
              ]),
              const SizedBox(height: 12),
              Text(body, style: TextStyle(fontSize: 13, height: 1.55, color: skin.fg3)),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                _DialogBtn(skin: skin, label: 'Cancel', onTap: () => Navigator.pop(ctx, false)),
                const SizedBox(width: 9),
                _DialogBtn(skin: skin, label: confirmLabel, filled: true, danger: danger, icon: danger ? Icons.delete_outline_rounded : Icons.check_rounded, onTap: () => Navigator.pop(ctx, true)),
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
        decoration: BoxDecoration(color: bg, border: filled ? null : Border.all(color: skin.borderStrong), borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 7)],
          Text(label, style: TextStyle(fontFamily: SuperTokensFonts.body, fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
        ]),
      ),
    );
  }
}

// ============================================================
// Advanced (cross-column) filter editor
// ============================================================

/// A column descriptor for the advanced-filter editor (key + label).
class AdvFilterColumn {
  final String key;
  final String label;
  final bool numeric;
  const AdvFilterColumn(this.key, this.label, {this.numeric = false});
}

/// Show the advanced-filter editor. Calls [onApply] with the clause list when
/// applied (active), or [onClear] when cleared.
Future<void> showSuperAdvancedFilter(
  BuildContext context, {
  required List<AdvFilterColumn> columns,
  required List<AdvancedFilterClause> initial,
  required void Function(List<AdvancedFilterClause> clauses) onApply,
  required VoidCallback onClear,
}) {
  final skin = SuperTableSkin.of(context);
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (ctx) => Center(
      child: Material(
        color: Colors.transparent,
        child: _AdvancedFilterPanel(skin: skin, columns: columns, initial: initial, onApply: onApply, onClear: onClear),
      ),
    ),
  );
}

class _AdvancedFilterPanel extends StatefulWidget {
  final SuperTableSkin skin;
  final List<AdvFilterColumn> columns;
  final List<AdvancedFilterClause> initial;
  final void Function(List<AdvancedFilterClause>) onApply;
  final VoidCallback onClear;
  const _AdvancedFilterPanel({required this.skin, required this.columns, required this.initial, required this.onApply, required this.onClear});
  @override
  State<_AdvancedFilterPanel> createState() => _AdvancedFilterPanelState();
}

class _AdvancedFilterPanelState extends State<_AdvancedFilterPanel> {
  late List<AdvancedFilterClause> _clauses;

  @override
  void initState() {
    super.initState();
    _clauses = widget.initial.isEmpty
        ? [AdvancedFilterClause(columnKey: widget.columns.isNotEmpty ? widget.columns.first.key : '')]
        : List.of(widget.initial);
  }

  AdvFilterColumn? _col(String key) =>
      widget.columns.cast<AdvFilterColumn?>().firstWhere((c) => c!.key == key, orElse: () => null);

  @override
  Widget build(BuildContext context) {
    final s = widget.skin;
    return Container(
      width: 560,
      constraints: const BoxConstraints(maxHeight: 600),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: BoxDecoration(
        color: s.surface,
        border: Border.all(color: s.borderStrong),
        borderRadius: BorderRadius.circular(12),
        boxShadow: s.popShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: s.accentWash(0.14), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.tune_rounded, size: 18, color: s.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Advanced filter', style: TextStyle(fontFamily: SuperTokensFonts.display, fontWeight: FontWeight.w800, fontSize: 17, color: s.fg1)),
                Text('All conditions must match (AND). Column filters are disabled while this is active.', style: TextStyle(fontSize: 11.5, color: s.fg3)),
              ]),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: s.inputBg, border: Border.all(color: s.borderStrong), borderRadius: BorderRadius.circular(7)),
                child: Icon(Icons.close_rounded, size: 15, color: s.fg2),
              ),
            ),
          ]),
          const SizedBox(height: 18),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; i < _clauses.length; i++) _clauseRow(s, i),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _clauses.add(AdvancedFilterClause(columnKey: widget.columns.isNotEmpty ? widget.columns.first.key : ''))),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.add_rounded, size: 15, color: s.accent),
              const SizedBox(width: 6),
              Text('Add condition', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: s.accent)),
            ]),
          ),
          const SizedBox(height: 20),
          Row(children: [
            _DialogBtn(skin: s, label: 'Clear', icon: Icons.filter_alt_off_outlined, onTap: () {
              widget.onClear();
              Navigator.pop(context);
            }),
            const Spacer(),
            _DialogBtn(skin: s, label: 'Cancel', onTap: () => Navigator.pop(context)),
            const SizedBox(width: 9),
            _DialogBtn(skin: s, label: 'Apply filter', filled: true, icon: Icons.check_rounded, onTap: () {
              final valid = _clauses.where((cl) => cl.columnKey.isNotEmpty && (!cl.op.needsValue || '${cl.value ?? ''}'.trim().isNotEmpty)).toList();
              widget.onApply(valid);
              Navigator.pop(context);
            }),
          ]),
        ],
      ),
    );
  }

  Widget _clauseRow(SuperTableSkin s, int i) {
    final clause = _clauses[i];
    final col = _col(clause.columnKey);
    final numeric = col?.numeric ?? false;
    final ops = numeric
        ? [FilterOp.equals, FilterOp.notEquals, FilterOp.greaterThan, FilterOp.greaterOrEqual, FilterOp.lessThan, FilterOp.lessOrEqual, FilterOp.between, FilterOp.isEmpty, FilterOp.isNotEmpty]
        : [FilterOp.contains, FilterOp.equals, FilterOp.notEquals, FilterOp.startsWith, FilterOp.endsWith, FilterOp.isEmpty, FilterOp.isNotEmpty];
    final op = ops.contains(clause.op) ? clause.op : ops.first;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 14, child: Text('${i + 1}', style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 11, color: s.fg4))),
        const SizedBox(width: 6),
        Expanded(flex: 4, child: _miniDropdown<String>(s, value: clause.columnKey, items: [for (final c in widget.columns) (c.key, c.label)], onChanged: (v) => setState(() => _clauses[i] = clause.copyWith(columnKey: v)))),
        const SizedBox(width: 8),
        Expanded(flex: 4, child: _miniDropdown<FilterOp>(s, value: op, items: [for (final o in ops) (o, _opLabel(o))], onChanged: (v) => setState(() => _clauses[i] = clause.copyWith(op: v)))),
        const SizedBox(width: 8),
        Expanded(
          flex: 5,
          child: op.needsValue
              ? Row(children: [
                  Expanded(child: _miniField(s, value: '${clause.value ?? ''}', numeric: numeric, hint: 'value', onChanged: (v) => _clauses[i] = clause.copyWith(value: v))),
                  if (op.needsSecondValue) ...[
                    const SizedBox(width: 6),
                    Expanded(child: _miniField(s, value: '${clause.value2 ?? ''}', numeric: numeric, hint: 'to', onChanged: (v) => _clauses[i] = clause.copyWith(value2: v))),
                  ],
                ])
              : SizedBox(height: 34, child: Center(child: Text('—', style: TextStyle(color: s.fg4)))),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: _clauses.length == 1 ? null : () => setState(() => _clauses.removeAt(i)),
          child: Opacity(
            opacity: _clauses.length == 1 ? 0.3 : 1,
            child: Icon(Icons.close_rounded, size: 16, color: s.fg3),
          ),
        ),
      ]),
    );
  }

  String _opLabel(FilterOp o) => switch (o) {
        FilterOp.contains => 'contains',
        FilterOp.equals => 'equals',
        FilterOp.notEquals => 'not equals',
        FilterOp.startsWith => 'starts with',
        FilterOp.endsWith => 'ends with',
        FilterOp.greaterThan => '> greater',
        FilterOp.greaterOrEqual => '≥ at least',
        FilterOp.lessThan => '< less',
        FilterOp.lessOrEqual => '≤ at most',
        FilterOp.between => 'between',
        FilterOp.isEmpty => 'is empty',
        FilterOp.isNotEmpty => 'is not empty',
      };

  Widget _miniDropdown<T>(SuperTableSkin s, {required T value, required List<(T, String)> items, required ValueChanged<T> onChanged}) {
    return Container(
      height: 34,
      decoration: BoxDecoration(color: s.inputBg, border: Border.all(color: s.borderStrong), borderRadius: BorderRadius.circular(5)),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: items.any((e) => e.$1 == value) ? value : (items.isNotEmpty ? items.first.$1 : null),
          isExpanded: true,
          isDense: true,
          icon: Icon(Icons.expand_more_rounded, size: 16, color: s.fg3),
          dropdownColor: s.surface,
          style: TextStyle(fontFamily: SuperTokensFonts.body, fontSize: 12.5, color: s.fg1),
          items: [for (final it in items) DropdownMenuItem<T>(value: it.$1, child: Text(it.$2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: s.fg1)))],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _miniField(SuperTableSkin s, {required String value, required bool numeric, required String hint, required ValueChanged<String> onChanged}) {
    return SizedBox(
      height: 34,
      child: TextFormField(
        initialValue: value,
        keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true, signed: true) : TextInputType.text,
        onChanged: onChanged,
        style: TextStyle(fontFamily: numeric ? SuperTokensFonts.mono : SuperTokensFonts.body, fontSize: 12.5, color: s.fg1),
        cursorColor: s.accent,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
          filled: true,
          fillColor: s.inputBg,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12.5, color: s.fg4),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: s.borderStrong)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: BorderSide(color: s.accent, width: 2)),
        ),
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
      ('⌘Enter', 'Insert row after'),
      ('⌘⇧Enter', 'Insert row before'),
      ('⌘D', 'Duplicate row · fill down (multi-row range)'),
      ('⌘R', 'Fill right across the range'),
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
                  Expanded(child: Text('Keyboard shortcuts', style: TextStyle(fontFamily: SuperTokensFonts.display, fontWeight: FontWeight.w800, fontSize: 19, color: skin.fg1))),
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
                  Text(g.$1.toUpperCase(), style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: skin.accent)),
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
            decoration: BoxDecoration(color: skin.inputBg, border: Border.all(color: skin.borderStrong), borderRadius: BorderRadius.circular(5)),
            child: Text(part, style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 11.5, fontWeight: FontWeight.w600, color: skin.fg2)),
          ),
      ],
    );
  }
}

/// Validation-summary panel (2.1.0). Runs `controller.validateAll()` and
/// lists every failing cell — row number, column, message — with jump-to-cell
/// on tap. Wire it to a *Validate* button or the footer's issue chip; gate
/// *Post* / *Save* on `controller.isValid`.
Future<void> showSuperValidationPanel<R>(BuildContext context, SuperTableController<R> controller) {
  final skin = SuperTableSkin.of(context);
  final issues = controller.validateAll();
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (ctx) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 560,
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 560),
          padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
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
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (issues.isEmpty ? skin.success : skin.danger).withOpacity(0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    issues.isEmpty ? Icons.check_circle_outline_rounded : Icons.rule_rounded,
                    size: 19,
                    color: issues.isEmpty ? skin.success : skin.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    issues.isEmpty ? 'All rows valid' : '${issues.length} validation issue${issues.length == 1 ? '' : 's'}',
                    style: TextStyle(fontFamily: SuperTokensFonts.display, fontWeight: FontWeight.w800, fontSize: 19, color: skin.fg1),
                  ),
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
              const SizedBox(height: 16),
              if (issues.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('Every cell passes the type rules, unique constraints and column validators.',
                      style: TextStyle(fontSize: 13, color: skin.fg3, height: 1.5)),
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final issue in issues)
                          _ValidationIssueTile(
                            skin: skin,
                            issue: issue,
                            onJump: issue.cell == null
                                ? null
                                : () {
                                    Navigator.pop(ctx);
                                    controller.selectCellAt(issue.cell!.r, issue.cell!.c);
                                  },
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ValidationIssueTile extends StatelessWidget {
  final SuperTableSkin skin;
  final SuperValidationIssue issue;
  final VoidCallback? onJump;
  const _ValidationIssueTile({required this.skin, required this.issue, this.onJump});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: GestureDetector(
        onTap: onJump,
        child: MouseRegion(
          cursor: onJump == null ? MouseCursor.defer : SystemMouseCursors.click,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: skin.tint(skin.danger, 0.05),
              border: Border.all(color: skin.danger.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: skin.inputBg, border: Border.all(color: skin.borderStrong), borderRadius: BorderRadius.circular(5)),
                child: Text('Row ${issue.sourceIndex + 1}',
                    style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 11, fontWeight: FontWeight.w600, color: skin.fg2)),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: Text(issue.columnLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: skin.fg1)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(issue.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: skin.fg2, height: 1.35)),
              ),
              if (onJump != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.arrow_outward_rounded, size: 14, color: skin.fg4),
              ],
            ]),
          ),
        ),
      ),
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
                child: Text(widget.error, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500, height: 1.45)),
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

/// Column manager (2.2.0) — drag to reorder, toggle visibility, pin to an edge.
/// Drives the controller's column-config API (`setManagedOrder` / `moveColumn`,
/// `toggleColumnVisible` / `showColumn` / `hideColumn`, `setColumnPin`). Wire it
/// to a *Columns* button, or reach it from any header menu (*Manage columns…*).
Future<void> showSuperColumnManager<R>(BuildContext context, SuperTableController<R> controller) {
  final skin = SuperTableSkin.of(context);
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (ctx) => Center(
      child: Material(
        color: Colors.transparent,
        child: _ColumnManagerPanel<R>(skin: skin, controller: controller),
      ),
    ),
  );
}

class _ColumnManagerPanel<R> extends StatefulWidget {
  final SuperTableSkin skin;
  final SuperTableController<R> controller;
  const _ColumnManagerPanel({required this.skin, required this.controller});
  @override
  State<_ColumnManagerPanel<R>> createState() => _ColumnManagerPanelState<R>();
}

class _ColumnManagerPanelState<R> extends State<_ColumnManagerPanel<R>> {
  SuperTableController<R> get c => widget.controller;

  @override
  void initState() {
    super.initState();
    c.addListener(_onModel);
  }

  @override
  void dispose() {
    c.removeListener(_onModel);
    super.dispose();
  }

  void _onModel() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.skin;
    final cols = c.managedColumns;
    final shown = cols.where((col) => c.isColumnVisible(col.key)).length;
    return Container(
      width: 480,
      constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
      decoration: BoxDecoration(
        color: s.surface,
        border: Border.all(color: s.borderStrong),
        borderRadius: BorderRadius.circular(12),
        boxShadow: s.popShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: s.accentWash(0.14), borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.view_column_rounded, size: 18, color: s.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Manage columns', style: TextStyle(fontFamily: SuperTokensFonts.display, fontWeight: FontWeight.w800, fontSize: 17, color: s.fg1)),
                Text('Drag to reorder · toggle visibility · pin to an edge', style: TextStyle(fontSize: 11.5, color: s.fg3)),
              ]),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: s.inputBg, border: Border.all(color: s.borderStrong), borderRadius: BorderRadius.circular(7)),
                child: Icon(Icons.close_rounded, size: 15, color: s.fg2),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Flexible(
            child: ReorderableListView.builder(
              shrinkWrap: true,
              buildDefaultDragHandles: false,
              itemCount: cols.length,
              onReorder: (oldI, newI) {
                if (newI > oldI) newI -= 1;
                final keys = c.managedColumns.map((e) => e.key).toList();
                final k = keys.removeAt(oldI);
                keys.insert(newI, k);
                c.setManagedOrder(keys);
              },
              proxyDecorator: (child, index, anim) => Material(
                color: Colors.transparent,
                child: child,
              ),
              itemBuilder: (ctx, i) => _ColumnManagerRow<R>(
                key: ValueKey(cols[i].key),
                skin: s,
                controller: c,
                col: cols[i],
                index: i,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Text('$shown of ${cols.length} shown', style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 11.5, color: s.fg3)),
            const Spacer(),
            _DialogBtn(skin: s, label: 'Reset', icon: Icons.restart_alt_rounded, onTap: () => c.resetViewState(clearFilters: false)),
            const SizedBox(width: 9),
            _DialogBtn(skin: s, label: 'Done', filled: true, icon: Icons.check_rounded, onTap: () => Navigator.pop(context)),
          ]),
        ],
      ),
    );
  }
}

class _ColumnManagerRow<R> extends StatelessWidget {
  final SuperTableSkin skin;
  final SuperTableController<R> controller;
  final SuperColumn col;
  final int index;
  const _ColumnManagerRow({super.key, required this.skin, required this.controller, required this.col, required this.index});

  @override
  Widget build(BuildContext context) {
    final s = skin;
    final visible = controller.isColumnVisible(col.key);
    final pin = controller.pinOf(col);
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Container(
        height: 46,
        padding: const EdgeInsetsDirectional.only(start: 8, end: 8),
        decoration: BoxDecoration(
          color: s.inputBg,
          border: Border.all(color: s.borderStrong),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          ReorderableDragStartListener(
            index: index,
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.drag_indicator_rounded, size: 17, color: s.fg4),
              ),
            ),
          ),
          const SizedBox(width: 4),
          _MgrIconToggle(
            skin: s,
            icon: visible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            active: visible,
            tooltip: visible ? 'Hide column' : 'Show column',
            onTap: () => controller.toggleColumnVisible(col.key),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              col.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: SuperTokensFonts.body,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: visible ? s.fg1 : s.fg4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _PinSegment(skin: s, pin: pin, onChanged: (p) => controller.setColumnPin(col.key, p)),
        ]),
      ),
    );
  }
}

class _MgrIconToggle extends StatelessWidget {
  final SuperTableSkin skin;
  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;
  const _MgrIconToggle({required this.skin, required this.icon, required this.active, required this.tooltip, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final s = skin;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? s.accentWash(0.14) : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 16, color: active ? s.accent : s.fg4),
          ),
        ),
      ),
    );
  }
}

/// A three-way segmented control for a column's pin: left · none · right.
class _PinSegment extends StatelessWidget {
  final SuperTableSkin skin;
  final SuperPin pin;
  final ValueChanged<SuperPin> onChanged;
  const _PinSegment({required this.skin, required this.pin, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = skin;
    Widget seg(SuperPin p, IconData icon, String tip) {
      final on = pin == p;
      return Tooltip(
        message: tip,
        child: GestureDetector(
          onTap: () => onChanged(p),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: 30,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? s.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(icon, size: 14, color: on ? Colors.white : s.fg3),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: s.surface,
        border: Border.all(color: s.borderStrong),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg(SuperPin.left, Icons.first_page_rounded, 'Pin left'),
        seg(SuperPin.none, Icons.remove_rounded, 'Unpinned'),
        seg(SuperPin.right, Icons.last_page_rounded, 'Pin right'),
      ]),
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
