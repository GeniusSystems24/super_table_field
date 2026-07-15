// ============================================================
// features/super_table/presentation/widgets/super_cell.dart
// ------------------------------------------------------------
// The per-cell display renderer + type-specific inline editors for SuperTable
// 0.4.0. Reads the generic [SuperRow] / [SuperCell] model. Display is pure
// (with optional conditional-style overrides handed in by the grid); editors
// drive the controller's draft + commit.
//
// `combo` cells are edited through the design-system-native AutoSuggestionsBox.
// In 0.4.0 the box's source + controller can be supplied per-cell by the
// column's `sourceController` / `cellController` builders and are rebuilt
// whenever the row's `fingerPrint` changes (cached on the SuperTableController).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../super_table_field.dart';

/// A small status/enum pill (mirrors the DS Pill).
class SuperPill extends StatelessWidget {
  final String text;
  final Color color;
  final bool dot;
  const SuperPill({super.key, required this.text, required this.color, this.dot = true});
  @override
  Widget build(BuildContext context) {
    final skin = SuperTableSkin.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: skin.tint(color, 0.18), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (dot) ...[
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
        ],
        Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

/// Renders the read display of a cell value for [col]. [fg]/[weight] are
/// conditional-style overrides resolved by the grid (row + cell styles).
class SuperCellDisplay extends StatelessWidget {
  final SuperColumn col;
  final SuperRow row;
  final Color? fg;
  final FontWeight? weight;
  const SuperCellDisplay({super.key, required this.col, required this.row, this.fg, this.weight});

  @override
  Widget build(BuildContext context) {
    final skin = SuperTableSkin.of(context);
    final v = col.rawValue(row);
    final baseColor = fg ?? skin.fg1;
    final mono = TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 12.5, color: baseColor, fontWeight: weight);
    final body = TextStyle(fontFamily: SuperTokensFonts.body, fontSize: 12.5, color: baseColor, fontWeight: weight);

    // An explicit column formatter wins over the built-in type rendering and
    // shows its returned string as plain text (display-only — see [SuperColumnFormatter]).
    final fmt = col.formatter;
    if (fmt != null) {
      return Text(fmt(v, row), maxLines: 1, overflow: TextOverflow.ellipsis, style: col.mono ? mono : body);
    }

    switch (col.type) {
      case SuperColumnType.text:
      case SuperColumnType.custom:
        final ar = SuperColumnLogic.arText(col, row);
        if (ar.isNotEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${v ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: body),
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(ar,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: SuperTokensFonts.arabic, fontSize: 11.5, color: fg ?? skin.fg3)),
              ),
            ],
          );
        }
        return Text('${v ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: col.mono ? mono : body);

      case SuperColumnType.number:
      case SuperColumnType.currency:
        final n = SuperColumnLogic.numVal(v);
        final neg = n < 0;
        final isCur = col.type == SuperColumnType.currency;
        final color = fg ??
            (col.colorSign ? (neg ? skin.danger(context) : (n > 0 ? skin.success : skin.fg3)) : skin.fg1);
        final sign = neg ? '−' : (col.colorSign && n > 0 ? '+' : '');
        final prefix = col.prefix ?? (isCur ? r'$' : '');
        final txt = '$sign$prefix${SuperColumnLogic.fmtNum(n, col)}${col.suffix != null ? (isCur ? ' ${col.suffix}' : col.suffix) : ''}';
        return Text(txt, maxLines: 1, overflow: TextOverflow.ellipsis, style: mono.copyWith(color: color));

      case SuperColumnType.enumeration:
        if (v == null || '$v'.isEmpty) return const SizedBox.shrink();
        final disp = SuperColumnLogic.displayOf(col, v);
        final tone = fg ?? SuperColumnLogic.toneFor(col, disp) ?? skin.fg3;
        return SuperPill(text: disp, color: tone, dot: col.dot);

      case SuperColumnType.combo:
        return Text(SuperColumnLogic.displayOf(col, v), maxLines: 1, overflow: TextOverflow.ellipsis, style: col.mono ? mono : body);

      case SuperColumnType.progress:
        final max = (col.max ?? 100).toDouble();
        final frac = (SuperColumnLogic.numVal(v) / (max == 0 ? 1 : max)).clamp(0.0, 1.0);
        final pct = (frac * 100).round();
        final tone = pct >= 90 ? skin.danger(context) : (pct >= 70 ? skin.warning : skin.accent(context));
        return Row(children: [
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(color: skin.inputBg, borderRadius: BorderRadius.circular(999)),
              child: FractionallySizedBox(
                alignment: AlignmentDirectional.centerStart,
                widthFactor: frac,
                child: Container(decoration: BoxDecoration(color: tone, borderRadius: BorderRadius.circular(999))),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$pct%', style: mono.copyWith(fontSize: 11, color: fg ?? skin.fg3)),
        ]);

      case SuperColumnType.color:
        final hex = SuperColumnLogic.colorHex(col, v);
        return Row(children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _parseHex(hex) ?? skin.inputBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0x40000000)),
            ),
          ),
          const SizedBox(width: 8),
          Text(hex, style: mono.copyWith(fontSize: 12)),
        ]);

      case SuperColumnType.date:
      case SuperColumnType.time:
        return Text('${v ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: mono);

      case SuperColumnType.link:
        return Text('${v ?? ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: mono.copyWith(color: fg ?? skin.accent(context), decoration: TextDecoration.underline));

      case SuperColumnType.checkbox:
        final on = v == true || v == 'true' || v == 'Yes' || v == 1;
        return Icon(on ? Icons.check_rounded : Icons.close_rounded, size: 15, color: on ? skin.success : skin.fg4);

      case SuperColumnType.readonly:
        final txt = v == null || '$v'.isEmpty ? '—' : '$v';
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.lock_outline_rounded, size: 12, color: skin.fg4),
          const SizedBox(width: 6),
          Flexible(child: Text(txt, maxLines: 1, overflow: TextOverflow.ellipsis, style: (col.mono ? mono : body).copyWith(color: fg ?? skin.fg2))),
        ]);

      case SuperColumnType.computed:
        final out = col.compute != null ? col.compute!(row) : v;
        final txt = col.format != null ? col.format!(out, row) : (out == null || '$out'.isEmpty ? '—' : '$out');
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.functions_rounded, size: 13, color: skin.fg4),
          const SizedBox(width: 6),
          Flexible(child: Text(txt, maxLines: 1, overflow: TextOverflow.ellipsis, style: mono)),
        ]);
    }
  }
}

Color? _parseHex(String s) {
  final m = RegExp(r'^#?([0-9a-fA-F]{6})$').firstMatch(s.trim());
  if (m == null) return null;
  return Color(int.parse('FF${m.group(1)}', radix: 16));
}

// ============================================================
// Combo cell editor — embeds the AutoSuggestionsBox, with per-cell source +
// controller (rebuildable on fingerPrint change), cached on the table
// controller's combo registries.
// ============================================================
class _SuperComboEditor extends StatefulWidget {
  final SuperTableController controller;
  final SuperRow row;
  final SuperColumn col;
  final String value;
  final double height;
  final bool rtl;
  final ValueChanged<String> onChanged;
  final void Function({Object? override, int dr, int dc}) onCommit;
  final VoidCallback onCancel;
  const _SuperComboEditor({
    required this.controller,
    required this.row,
    required this.col,
    required this.value,
    required this.height,
    required this.rtl,
    required this.onChanged,
    required this.onCommit,
    required this.onCancel,
  });

  @override
  State<_SuperComboEditor> createState() => _SuperComboEditorState();
}

class _SuperComboEditorState extends State<_SuperComboEditor> {
  late final TextEditingController _text = TextEditingController(text: widget.value);
  late final FocusNode _focus = FocusNode(debugLabel: 'SuperCombo');
  late AutoSuggestionsBoxController _box;
  bool _ownsBox = false;

  SuperComboColumn? get _combo => widget.col is SuperComboColumn ? widget.col as SuperComboColumn : null;

  @override
  void initState() {
    super.initState();
    _resolveBox();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focus.requestFocus();
      if (_text.text.isNotEmpty) {
        _text.selection = TextSelection(baseOffset: 0, extentOffset: _text.text.length);
      }
      _box.open();
    });
  }

  /// Build (or reuse) the box source + controller for this cell. Honors the
  /// column's rebuildable `sourceController` / `cellController` builders and the
  /// row's fingerPrint (cached on the table controller).
  void _resolveBox() {
    final c = widget.controller;
    final col = _combo;
    final reuse = !c.comboNeedsRebuild(widget.row, widget.col.key);
    if (reuse) {
      final cached = c.comboControllerFor(widget.row, widget.col.key);
      if (cached != null) {
        _box = cached;
        _ownsBox = false;
        return;
      }
    }

    // Build a source: explicit sourceController ▸ static values ▸ empty.
    // Typed as <dynamic> so any SuperComboColumn<T> source slots in.
    AutoSuggestionsSource source;
    if (col?.sourceController != null) {
      source = col!.sourceController!(context, c, widget.row, widget.row.cells[widget.col.key]!);
    } else {
      final opts = widget.col.opts ?? const <String>[];
      final ovals = widget.col.optValues;
      source = SuggestionSources.list<dynamic>([
        for (var i = 0; i < opts.length; i++)
          AutoSuggestion<dynamic>(value: ovals != null && i < ovals.length ? ovals[i] : opts[i], label: opts[i]),
      ]);
    }

    // Build a controller: explicit cellController ▸ default sharing our text.
    if (col?.cellController != null) {
      _box = col!.cellController!(context, c, widget.row, widget.row.cells[widget.col.key]!);
      _ownsBox = false;
    } else {
      _box = AutoSuggestionsBoxController<dynamic>(
        source: source,
        textController: _text,
        allowFreeText: col?.allowFreeText ?? true,
      );
      _ownsBox = true;
    }
    c.registerCombo(widget.row, widget.col.key, source: source, controller: _box);
  }

  @override
  void dispose() {
    if (_ownsBox) _box.dispose();
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  AutoSuggestionsBoxThemeData _boxTheme(SuperTableSkin skin) {
    final base = skin.isDark ? AutoSuggestionsBoxThemeData.dark : AutoSuggestionsBoxThemeData.light;
    return base.copyWith(
      overlayBg: skin.surface,
      fieldBg: skin.surface,
      fieldBgFocus: skin.surface,
      hover: skin.hover,
      border: skin.border,
      borderFocus: skin.accent(context),
      fg1: skin.fg1,
      fg2: skin.fg3,
      fg3: skin.fg4,
      groupFg: skin.fg4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final skin = SuperTableSkin.of(context);
    final col = _combo;
    final opts = widget.col.opts ?? const <String>[];
    return Theme(
      data: Theme.of(context).copyWith(extensions: [_boxTheme(skin)]),
      child: AutoSuggestionsBox(
        controller: _box,
        focusNode: _focus,
        bare: true,
        autofocus: true,
        openOnFocus: true,
        scrollOnFocus: false,
        clearButton: col?.clearButton ?? false,
        fieldHeight: widget.height,
        maxVisibleRows: col?.maxVisibleRows ?? 7,
        highlightMatches: col?.highlightMatch ?? true,
        advancedSearch: col?.advancedSearch ?? false,
        advancedSearchBuilder: col?.advancedSearchBuilder,
        itemBuilder: col?.itemBuilder,
        loadingBuilder: col?.loadingBuilder,
        emptyBuilder: col?.emptyBuilder,
        leading: col?.leading,
        hintText: col?.hintText ?? (opts.isEmpty ? 'Type a value\u2026' : 'Type or pick\u2026'),
        textStyle: TextStyle(
          fontFamily: widget.col.mono ? SuperTokensFonts.mono : SuperTokensFonts.body,
          fontSize: 13,
          height: 1.2,
          color: skin.fg1,
        ),
        onChanged: widget.onChanged,
        onSelected: (s) {
          col?.onSelected?.call(s);
          widget.onChanged('${s.value}');
          widget.onCommit(override: s.value, dr: 0, dc: 0);
        },
        onSubmitted: (raw) {
          col?.onSubmitted?.call(raw);
          widget.onCommit(override: raw, dr: 0, dc: 0);
        },
        onEscape: widget.onCancel,
        onTabNext: () => widget.onCommit(override: _box.query, dr: 0, dc: 1),
        onTabPrev: () => widget.onCommit(override: _box.query, dr: 0, dc: -1),
      ),
    );
  }
}

/// The inline editor for an editing cell. Routes to a type-specific editor and
/// reports value changes / commit / cancel up to the host.
class SuperCellEditor extends StatefulWidget {
  final SuperTableController controller;
  final SuperColumn col;
  final SuperRow row;
  final String value;
  final ValueChanged<String> onChanged;
  final void Function({Object? override, int dr, int dc}) onCommit;
  final VoidCallback onCancel;
  final bool rtl;
  final double height;
  const SuperCellEditor({
    super.key,
    required this.controller,
    required this.col,
    required this.row,
    required this.value,
    required this.onChanged,
    required this.onCommit,
    required this.onCancel,
    required this.rtl,
    this.height = 40,
  });

  @override
  State<SuperCellEditor> createState() => _SuperCellEditorState();
}

class _SuperCellEditorState extends State<SuperCellEditor> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.value);
  final FocusNode _focus = FocusNode();
  final LayerLink _link = LayerLink();
  OverlayEntry? _popup;

  @override
  void initState() {
    super.initState();
    final t = widget.col.type;
    if (t == SuperColumnType.enumeration) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openPopup());
    } else if (t != SuperColumnType.checkbox && t != SuperColumnType.combo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focus.requestFocus();
        _ctrl.selection = TextSelection(baseOffset: 0, extentOffset: _ctrl.text.length);
      });
    }
  }

  @override
  void dispose() {
    _closePopup();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _set(String v) => widget.onChanged(v);

  void _maskedSet(String v, String Function(String) mask) {
    final m = mask(v);
    _ctrl.value = TextEditingValue(text: m, selection: TextSelection.collapsed(offset: m.length));
    widget.onChanged(m);
  }

  void _closePopup() {
    _popup?.remove();
    _popup = null;
  }

  /// Map an enum display string back to its raw option value.
  Object? _enumValueFor(String display) {
    final col = widget.col;
    final ov = col.optValues, opts = col.opts;
    if (ov != null && opts != null) {
      final i = opts.indexOf(display);
      if (i >= 0) return ov[i];
    }
    return display;
  }

  void _openPopup() {
    if (_popup != null) return;
    final col = widget.col;
    Widget content;
    switch (col.type) {
      case SuperColumnType.enumeration:
        content = _OptionList(
          options: col.opts ?? const [],
          selected: SuperColumnLogic.displayOf(col, _enumDraftValue()),
          keyboard: true,
          onCancel: () {
            _closePopup();
            widget.onCancel();
          },
          builder: (o) => SuperPill(text: o, color: SuperColumnLogic.toneFor(col, o) ?? SuperTableSkin.of(context).fg3, dot: col.dot),
          onPick: (o) {
            _closePopup();
            widget.onCommit(override: _enumValueFor(o));
          },
        );
        break;
      case SuperColumnType.time:
        content = _OptionList(
          options: SuperColumnLogic.timeOptions,
          selected: widget.value,
          keyboard: true,
          onCancel: () {
            _closePopup();
            widget.onCancel();
          },
          builder: (o) => Text(o, style: TextStyle(fontFamily: SuperTokensFonts.mono, fontSize: 12.5, color: SuperTableSkin.of(context).fg1)),
          onPick: (o) {
            _closePopup();
            widget.onCommit(override: o);
          },
        );
        break;
      case SuperColumnType.date:
        content = _MiniCalendar(
          value: widget.value,
          onPick: (d) {
            _closePopup();
            widget.onCommit(override: d);
          },
        );
        break;
      case SuperColumnType.color:
        content = _SwatchGrid(
          value: SuperColumnLogic.colorHex(col, _ctrl.text),
          onPick: (hex) {
            _closePopup();
            widget.onCommit(override: SuperColumnLogic.colorFromHex(col, hex));
          },
        );
        break;
      default:
        return;
    }
    final skin = SuperTableSkin.of(context);
    final width = switch (col.type) {
      SuperColumnType.date => 252.0,
      SuperColumnType.color => 184.0,
      _ => 200.0,
    };
    _popup = OverlayEntry(
      builder: (ctx) => Stack(children: [
        Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: () {
          _closePopup();
          widget.onCancel();
        })),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: widget.rtl ? Alignment.bottomRight : Alignment.bottomLeft,
          followerAnchor: widget.rtl ? Alignment.topRight : Alignment.topLeft,
          offset: const Offset(0, 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: width,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: skin.surface,
                border: Border.all(color: skin.borderStrong),
                borderRadius: BorderRadius.circular(9),
                boxShadow: skin.popShadow,
              ),
              child: content,
            ),
          ),
        ),
      ]),
    );
    Overlay.of(context).insert(_popup!);
  }

  Object? _enumDraftValue() => _enumValueFor(widget.value);

  @override
  Widget build(BuildContext context) {
    final skin = SuperTableSkin.of(context);
    final col = widget.col;

    if (col.type == SuperColumnType.combo) {
      return _SuperComboEditor(
        controller: widget.controller,
        row: widget.row,
        col: col,
        value: widget.value,
        height: widget.height,
        rtl: widget.rtl,
        onChanged: widget.onChanged,
        onCommit: widget.onCommit,
        onCancel: widget.onCancel,
      );
    }

    final align = col.align == SuperAlign.end ? TextAlign.right : TextAlign.left;
    final monoLike = col.mono || col.type.isNumeric || col.type == SuperColumnType.date || col.type == SuperColumnType.time || col.type == SuperColumnType.color;
    final style = TextStyle(
      fontFamily: monoLike ? SuperTokensFonts.mono : SuperTokensFonts.body,
      fontSize: 13,
      color: skin.fg1,
    );

    if (col.type == SuperColumnType.checkbox) {
      final on = widget.value == 'true' || widget.value == 'Yes' || widget.value == '1';
      return GestureDetector(
        onTap: () => widget.onCommit(override: !on),
        child: Container(
          color: skin.surface,
          alignment: Alignment.center,
          child: Icon(on ? Icons.check_rounded : Icons.close_rounded, size: 16, color: on ? skin.success : skin.fg4),
        ),
      );
    }

    final showTrigger = col.type == SuperColumnType.date ||
        col.type == SuperColumnType.time ||
        col.type == SuperColumnType.color;

    return CompositedTransformTarget(
      link: _link,
      child: Container(
        color: skin.surface,
        padding: EdgeInsets.zero,
        child: Row(children: [
          if (col.type == SuperColumnType.color)
            GestureDetector(
              onTap: _openPopup,
              child: Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 7),
                decoration: BoxDecoration(
                  color: _parseHex(SuperColumnLogic.colorHex(col, _ctrl.text)) ?? skin.inputBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0x40000000)),
                ),
              ),
            ),
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(skipTraversal: true),
              onKeyEvent: _onKey,
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                textAlign: align,
                style: style,
                cursorColor: skin.accent(context),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
                  hintText: _hint(col),
                  hintStyle: style.copyWith(color: skin.fg4),
                ),
                onChanged: (v) {
                  switch (col.type) {
                    case SuperColumnType.date:
                      _maskedSet(v, SuperColumnLogic.maskDate);
                      break;
                    case SuperColumnType.time:
                      _maskedSet(v, SuperColumnLogic.maskTime);
                      break;
                    default:
                      _set(v);
                  }
                },
              ),
            ),
          ),
          if (showTrigger)
            GestureDetector(
              onTap: () => _popup != null ? _closePopup() : _openPopup(),
              child: Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: skin.inputBg,
                  border: Border.all(color: skin.borderStrong),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Icon(
                  switch (col.type) {
                    SuperColumnType.date => Icons.calendar_today_rounded,
                    SuperColumnType.time => Icons.schedule_rounded,
                    _ => Icons.expand_more_rounded,
                  },
                  size: 14,
                  color: skin.fg2,
                ),
              ),
            ),
        ]),
      ),
    );
  }

  String? _hint(SuperColumn col) => switch (col.type) {
        SuperColumnType.date => 'YYYY-MM-DD',
        SuperColumnType.time => 'HH:mm',
        SuperColumnType.color => '#RRGGBB',
        _ => (col.min != null || col.max != null) ? '${col.min ?? '−∞'}…${col.max ?? '∞'}' : null,
      };

  void _onKey(KeyEvent e) {
    if (e is! KeyDownEvent) return;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      _commitClamped(dr: 1, dc: 0);
    } else if (k == LogicalKeyboardKey.tab) {
      final shift = HardwareKeyboard.instance.isShiftPressed;
      _commitClamped(dr: 0, dc: shift ? -1 : 1);
    } else if (k == LogicalKeyboardKey.escape) {
      _closePopup();
      widget.onCancel();
    }
  }

  void _commitClamped({required int dr, required int dc}) {
    _closePopup();
    if (widget.col.type.isNumeric) {
      final s = _ctrl.text.trim();
      if (s.isEmpty) {
        widget.onCommit(override: '', dr: dr, dc: dc);
      } else {
        widget.onCommit(override: SuperColumnLogic.clampNum(SuperColumnLogic.numVal(s), widget.col), dr: dr, dc: dc);
      }
      return;
    }
    widget.onCommit(override: _ctrl.text, dr: dr, dc: dc);
  }
}

// ── popup option list (enum / time) ──
class _OptionList extends StatefulWidget {
  final List<String> options;
  final String selected;
  final Widget Function(String) builder;
  final ValueChanged<String> onPick;
  final bool keyboard;
  final VoidCallback? onCancel;
  const _OptionList({
    required this.options,
    required this.selected,
    required this.builder,
    required this.onPick,
    this.keyboard = false,
    this.onCancel,
  });

  @override
  State<_OptionList> createState() => _OptionListState();
}

class _OptionListState extends State<_OptionList> {
  late int _hi;
  final _scroll = ScrollController();
  static const double _rowH = 38;

  @override
  void initState() {
    super.initState();
    final i = widget.options.indexOf(widget.selected);
    _hi = i >= 0 ? i : 0;
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _move(int d) {
    if (widget.options.isEmpty) return;
    setState(() => _hi = (_hi + d).clamp(0, widget.options.length - 1));
    if (_scroll.hasClients) {
      final target = (_hi * _rowH);
      final vpH = _scroll.position.viewportDimension;
      if (target < _scroll.offset) {
        _scroll.jumpTo(target);
      } else if (target + _rowH > _scroll.offset + vpH) {
        _scroll.jumpTo((target + _rowH - vpH).clamp(0.0, _scroll.position.maxScrollExtent));
      }
    }
  }

  KeyEventResult _onKey(FocusNode n, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowDown) {
      _move(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowUp) {
      _move(-1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      if (_hi >= 0 && _hi < widget.options.length) widget.onPick(widget.options[_hi]);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.escape) {
      widget.onCancel?.call();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.tab) {
      if (_hi >= 0 && _hi < widget.options.length) widget.onPick(widget.options[_hi]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final skin = SuperTableSkin.of(context);
    final list = ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 240),
      child: SingleChildScrollView(
        controller: _scroll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.options.length; i++)
              _PopRow(
                skin: skin,
                selected: widget.options[i] == widget.selected,
                highlighted: widget.keyboard && i == _hi,
                onTap: () => widget.onPick(widget.options[i]),
                child: Row(children: [
                  Expanded(child: widget.builder(widget.options[i])),
                  if (widget.options[i] == widget.selected) Icon(Icons.check_rounded, size: 14, color: skin.accent(context)),
                ]),
              ),
          ],
        ),
      ),
    );
    if (!widget.keyboard) return list;
    return Focus(autofocus: true, onKeyEvent: _onKey, child: list);
  }
}

class _PopRow extends StatefulWidget {
  final SuperTableSkin skin;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;
  final Widget child;
  const _PopRow({required this.skin, required this.selected, this.highlighted = false, required this.onTap, required this.child});
  @override
  State<_PopRow> createState() => _PopRowState();
}

class _PopRowState extends State<_PopRow> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.skin;
    final lit = _h || widget.highlighted;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: lit ? s.hover : (widget.selected ? s.accentWash(context, 0.12) : Colors.transparent),
            borderRadius: BorderRadius.circular(6),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ── color swatch grid ──
class _SwatchGrid extends StatelessWidget {
  final String value;
  final ValueChanged<String> onPick;
  const _SwatchGrid({required this.value, required this.onPick});
  @override
  Widget build(BuildContext context) {
    final skin = SuperTableSkin.of(context);
    String hex(Color c) => '#${(c.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in SuperColumnLogic.swatches)
              GestureDetector(
                onTap: () => onPick(hex(c)),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: hex(c).toLowerCase() == value.toLowerCase() ? skin.fg1 : const Color(0x40000000),
                      width: hex(c).toLowerCase() == value.toLowerCase() ? 2 : 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ── mini month calendar ──
class _MiniCalendar extends StatefulWidget {
  final String value;
  final ValueChanged<String> onPick;
  const _MiniCalendar({required this.value, required this.onPick});
  @override
  State<_MiniCalendar> createState() => _MiniCalendarState();
}

class _MiniCalendarState extends State<_MiniCalendar> {
  late int _y;
  late int _m;
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _dow = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  @override
  void initState() {
    super.initState();
    final valid = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(widget.value);
    final init = valid ? DateTime.parse(widget.value) : DateTime.now();
    _y = init.year;
    _m = init.month;
  }

  String _iso(int d) => '$_y-${_m.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}';

  void _step(int delta) {
    setState(() {
      var m = _m + delta;
      var y = _y;
      if (m < 1) {
        m = 12;
        y--;
      }
      if (m > 12) {
        m = 1;
        y++;
      }
      _m = m;
      _y = y;
    });
  }

  @override
  Widget build(BuildContext context) {
    final skin = SuperTableSkin.of(context);
    final days = DateTime(_y, _m + 1, 0).day;
    final startDow = DateTime(_y, _m, 1).weekday % 7;
    final now = DateTime.now();
    final todayIso = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final cells = <int?>[for (var i = 0; i < startDow; i++) null, for (var d = 1; d <= days; d++) d];

    Widget navBtn(IconData ic, VoidCallback onTap) => GestureDetector(
          onTap: onTap,
          child: Container(width: 24, height: 24, alignment: Alignment.center, child: Icon(ic, size: 15, color: skin.fg2)),
        );

    return SizedBox(
      width: 240,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            navBtn(Icons.chevron_left_rounded, () => _step(-1)),
            Text('${_months[_m - 1]} $_y', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: skin.fg1)),
            navBtn(Icons.chevron_right_rounded, () => _step(1)),
          ]),
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          childAspectRatio: 1.15,
          children: [
            for (final d in _dow)
              Center(child: Text(d, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: skin.fg4))),
            for (final d in cells)
              if (d == null)
                const SizedBox.shrink()
              else
                _CalDay(
                  skin: skin,
                  day: d,
                  selected: _iso(d) == widget.value,
                  today: _iso(d) == todayIso,
                  onTap: () => widget.onPick(_iso(d)),
                ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            GestureDetector(
              onTap: () => widget.onPick(todayIso),
              child: Text('Today', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: skin.accent(context))),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _CalDay extends StatefulWidget {
  final SuperTableSkin skin;
  final int day;
  final bool selected;
  final bool today;
  final VoidCallback onTap;
  const _CalDay({required this.skin, required this.day, required this.selected, required this.today, required this.onTap});
  @override
  State<_CalDay> createState() => _CalDayState();
}

class _CalDayState extends State<_CalDay> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.skin;
    final bg = widget.selected ? s.accent(context) : (_h ? s.hover : Colors.transparent);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: widget.today && !widget.selected ? Border.all(color: s.borderStrong) : null,
          ),
          child: Text('${widget.day}',
              style: TextStyle(
                  fontFamily: SuperTokensFonts.mono,
                  fontSize: 12.5,
                  color: widget.selected ? Colors.white : s.fg1)),
        ),
      ),
    );
  }
}
