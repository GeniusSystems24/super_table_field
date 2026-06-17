// ============================================================
// features/auto_suggestion_box/auto_suggestion_box.dart
// ------------------------------------------------------------
// Public barrel for the AutoSuggestionsBox feature. Exports the domain
// entities + match strategy, the source contract and built-in source factory
// (SuggestionSources), the controller, and the view + theme.
// ============================================================

// Domain
export 'domain/entities/auto_suggestion.dart';
export 'domain/entities/match_strategy.dart';
export 'domain/entities/suggestions_query_result.dart';
export 'domain/repositories/suggestions_source.dart';
export 'domain/usecases/query_suggestions.dart';

// Data
export 'data/datasources/suggestion_sources.dart';

// Presentation
export 'presentation/controllers/auto_suggestions_box_controller.dart';
export 'presentation/widgets/auto_suggestions_box_theme.dart';
export 'presentation/widgets/auto_suggestions_highlight.dart';
export 'presentation/widgets/auto_suggestions_box.dart';
export 'presentation/pages/auto_suggestion_box_demo.dart';
