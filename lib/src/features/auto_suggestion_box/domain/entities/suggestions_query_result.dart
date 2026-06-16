// ============================================================
// features/auto_suggestion_box/domain/entities/suggestions_query_result.dart
// ------------------------------------------------------------
// A two-phase query outcome. A source may resolve a query in one shot (return a
// plain list) OR progressively: hand back the items it can produce *now*
// (e.g. the local in-memory matches) plus an optional [loadMore] thunk that
// fetches the rest from a remote backend. The controller renders the immediate
// items right away and, when [loadMore] is present, shows a "loading more"
// indicator above them while the remote call is in flight, then merges the
// result in (de-duplicated by value).
//
// This powers the "fetch from Remote only when local matches are X or fewer"
// behaviour without ever blanking the list behind a full-screen spinner.
// ============================================================

import 'dart:async';

import 'auto_suggestion.dart';

/// The outcome of a progressive query (see [AutoSuggestionsSource.progressive]).
class SuggestionsQueryResult<T> {
  /// Matches available immediately (typically the local, in-memory hits).
  final List<AutoSuggestion<T>> items;

  /// When non-null, a lazy remote fetch the controller invokes (after its
  /// debounce) to load more rows. Its result is merged after [items],
  /// de-duplicated by value. When null, [items] is the complete answer.
  final Future<List<AutoSuggestion<T>>> Function()? loadMore;

  const SuggestionsQueryResult({required this.items, this.loadMore});

  /// A complete (single-phase) result — no remote follow-up.
  const SuggestionsQueryResult.complete(this.items) : loadMore = null;
}
