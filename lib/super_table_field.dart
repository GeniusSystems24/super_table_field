/// Super Table Field — a GeniusLink design-system Flutter package pairing the
/// unified **SuperTable** data grid with the **AutoSuggestionsBox** typeahead.
///
/// In editable mode, the table's `combo` columns are edited through the real
/// `AutoSuggestionsBox` (filter · arrow-navigate · pick · free-text commit),
/// so the two components are wired together out of the box.
///
/// Architecture: Clean Architecture per feature
///   data/        — datasources, models (DTOs), repository implementations
///   domain/      — entities, repository contracts, usecases (pure Dart)
///   presentation/— controllers (Model / state), widgets + pages (the View)
///
/// Shared, cross-feature code lives in `lib/src/core/`.
///
/// Import this single barrel to get everything:
///   `import 'package:super_table_field/super_table_field.dart';`
library super_table_field;

// ── Core (theme tokens, shared widgets, utils) ──────────────────────────────
export 'src/core/core.dart';

// ── Features ────────────────────────────────────────────────────────────────
export 'src/features/auto_suggestion_box/auto_suggestion_box.dart';
export 'src/features/super_table/super_table.dart';
