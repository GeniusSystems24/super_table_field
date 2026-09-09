/// Super Table Field — a GeniusLink design-system Flutter package providing the
/// unified **SuperTable** data grid, wired to the **SuperAutoSuggestionsBox** typeahead
/// from the companion `super_auto_suggestion_box` package.
///
/// In editable mode, the table's `combo` columns are edited through the real
/// `SuperAutoSuggestionsBox` (filter · arrow-navigate · pick · free-text commit),
/// so the two components are wired together out of the box.
///
/// Architecture: Clean Architecture per feature
///   data/        — datasources, models (DTOs), repository implementations
///   domain/      — entities, repository contracts, usecases (pure Dart)
///   presentation/— controllers (Model / state), widgets + pages (the View)
///
/// Companion packages are implementation dependencies, not part of this
/// library's export surface. Import `super_core`,
/// `super_auto_suggestion_box`, or `super_form_field` directly when app
/// code references one of their public APIs.
library super_table_field;

// ── Feature ─────────────────────────────────────────────────────────────────
export 'localization/generated/l10n.dart';
export 'localization/super_table_localizations.dart';
export 'src/features/super_table/super_table.dart';
