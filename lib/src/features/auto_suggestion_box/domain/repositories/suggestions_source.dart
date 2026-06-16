// ============================================================
// features/auto_suggestion_box/domain/repositories/suggestions_source.dart
// ------------------------------------------------------------
// The repository contract. A source produces the suggestions for a query — it
// is the seam between the box and wherever its data lives (an in-memory list, a
// remote search, a database, a hybrid of both). The controller depends only on
// this abstraction; concrete implementations live in the data layer
// (`data/datasources/suggestion_sources.dart`, behind the `SuggestionSources`
// facade).
// ============================================================

import 'dart:async';

import '../entities/auto_suggestion.dart';

/// Produces suggestions for a query. Implement in the data layer (or subclass
/// for custom behaviour); construct via the `SuggestionSources` factory facade.
abstract class AutoSuggestionsSource<T> {
  const AutoSuggestionsSource();

  /// Return the matches for [query] (may be sync or a Future). An empty query
  /// is expected to return the "initial"/all set (capped by the view).
  FutureOr<List<AutoSuggestion<T>>> query(String query);

  /// Whether results arrive asynchronously (drives the loading spinner).
  bool get isAsync => false;
}
