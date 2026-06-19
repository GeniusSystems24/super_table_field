/// Super Table Field — a GeniusLink design-system Flutter package providing the
/// unified **SuperTable** data grid, wired to the **AutoSuggestionsBox** typeahead
/// from the companion `super_auto_suggestion_box` package.
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
/// The shared GeniusLink **core** foundation and the **AutoSuggestionsBox** live
/// in `super_auto_suggestion_box`, which this package depends on and re-exports —
/// so this single barrel still gives you everything:
///   `import 'package:super_table_field/super_table_field.dart';`
library super_table_field;

// ── Core + AutoSuggestionsBox (re-exported from super_auto_suggestion_box) ───
export 'package:super_core/super_core.dart';
export 'package:super_auto_suggestion_box/super_auto_suggestion_box.dart';

// ── Feature ─────────────────────────────────────────────────────────────────
export 'src/features/super_table/super_table.dart';
