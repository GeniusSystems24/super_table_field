// ============================================================
// features/auto_suggestion_box/presentation/widgets/auto_suggestions_highlight.dart
// ------------------------------------------------------------
// Renders a label with the portion(s) matching the query emphasised — the
// design-system analogue of a highlighted search hit. Pure presentation over
// the domain matching engine.
// ============================================================

import 'package:flutter/material.dart';

import '../../domain/entities/auto_suggestion.dart';
import '../../domain/entities/match_strategy.dart';
import 'auto_suggestions_box_theme.dart';

/// Renders [text] with the portion(s) matching [query] emphasised.
class AutoSuggestionsHighlight extends StatelessWidget {
  final String text;
  final String query;
  final AutoSuggestionMatch match;
  final bool enabled;
  final TextStyle baseStyle;
  final Color? highlightColor;

  const AutoSuggestionsHighlight({
    super.key,
    required this.text,
    required this.query,
    required this.baseStyle,
    this.match = AutoSuggestionMatch.contains,
    this.enabled = true,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled || query.trim().isEmpty) {
      return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: baseStyle);
    }
    final spans = AutoSuggestionMatching.spans(text, query, match);
    if (spans.isEmpty) {
      return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: baseStyle);
    }
    final hi = baseStyle.copyWith(
      color: highlightColor ?? AutoSuggestionsBoxThemeData.accent,
      fontWeight: FontWeight.w700,
    );
    final pieces = <TextSpan>[];
    var cursor = 0;
    for (final HighlightSpan span in spans) {
      if (span.start > cursor) pieces.add(TextSpan(text: text.substring(cursor, span.start)));
      pieces.add(TextSpan(text: text.substring(span.start, span.end), style: hi));
      cursor = span.end;
    }
    if (cursor < text.length) pieces.add(TextSpan(text: text.substring(cursor)));

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: baseStyle, children: pieces),
    );
  }
}
