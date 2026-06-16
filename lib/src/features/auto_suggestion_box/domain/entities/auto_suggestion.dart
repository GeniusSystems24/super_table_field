// ============================================================
// features/auto_suggestion_box/domain/entities/auto_suggestion.dart
// ------------------------------------------------------------
// The pure data the box renders. An [AutoSuggestion] is one row — a typed
// [value] plus the [label] shown and matched against. [HighlightSpan] is a
// `[start, end)` slice of a label that matched a query, used by the view to
// bold the hit. No I/O, no Flutter framework beyond IconData (a UI affordance
// intrinsic to the row).
// ============================================================

import 'package:flutter/widgets.dart' show IconData, immutable;

/// One suggestion row. [value] is what the host receives on select; [label] is
/// the text shown and matched against.
@immutable
class AutoSuggestion<T> {
  /// The strongly-typed payload handed back via `onSelected`.
  final T value;

  /// Primary display text — also the text matched against the query.
  final String label;

  /// Optional secondary line (e.g. a code, email, or hint).
  final String? description;

  /// Optional leading glyph.
  final IconData? icon;

  /// Optional section key. When any visible suggestion carries a [group], the
  /// list renders sticky-style section headers in first-seen order.
  final String? group;

  /// Extra haystack text matched in addition to [label] (synonyms, codes…),
  /// never shown. e.g. `keywords: ['usd', 'dollar']`.
  final List<String> keywords;

  /// When false the row is shown but cannot be picked (a header-like entry).
  final bool enabled;

  const AutoSuggestion({
    required this.value,
    required this.label,
    this.description,
    this.icon,
    this.group,
    this.keywords = const [],
    this.enabled = true,
  });

  /// The full lower-cased haystack (label + keywords) matched against a query.
  String get haystack => ([label, ...keywords]).join(' ').toLowerCase();

  AutoSuggestion<T> copyWith({
    T? value,
    String? label,
    String? description,
    IconData? icon,
    String? group,
    List<String>? keywords,
    bool? enabled,
  }) =>
      AutoSuggestion<T>(
        value: value ?? this.value,
        label: label ?? this.label,
        description: description ?? this.description,
        icon: icon ?? this.icon,
        group: group ?? this.group,
        keywords: keywords ?? this.keywords,
        enabled: enabled ?? this.enabled,
      );

  @override
  bool operator ==(Object other) =>
      other is AutoSuggestion<T> && other.value == value && other.label == label;

  @override
  int get hashCode => Object.hash(value, label);
}

/// A `[start, end)` slice of a label that matched the query — the view bolds it.
@immutable
class HighlightSpan {
  final int start;
  final int end;
  const HighlightSpan(this.start, this.end);
}
