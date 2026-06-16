// ============================================================
// features/auto_suggestion_box/domain/usecases/query_suggestions.dart
// ------------------------------------------------------------
// The single business action: "give me the suggestions for this query". A thin
// wrapper over an [AutoSuggestionsSource] that the controller invokes. Keeping
// it as a usecase makes the box's one moving part swappable and testable in
// isolation, and keeps the dependency arrow pointing at the domain.
// ============================================================

import 'dart:async';

import '../entities/auto_suggestion.dart';
import '../repositories/suggestions_source.dart';

/// Resolves the suggestions for a query against a [source].
class QuerySuggestions<T> {
  const QuerySuggestions(this.source);

  final AutoSuggestionsSource<T> source;

  /// Whether the backing source resolves asynchronously.
  bool get isAsync => source.isAsync;

  /// Run the query. The result may be a synchronous list or a [Future].
  FutureOr<List<AutoSuggestion<T>>> call(String query) => source.query(query);
}
