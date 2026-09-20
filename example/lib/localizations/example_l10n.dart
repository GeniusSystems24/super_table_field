import 'package:flutter/widgets.dart';
import 'package:super_table_field_example/localizations/generated/l10n.dart';

/// Gives example-only objects that are created outside a build method access to
/// the localization instance that belongs to the active MaterialApp locale.
///
/// [bind] is called by MaterialApp.builder before example routes are built.
abstract final class ExampleL10n {
  static SuperTableExampleLocalization? _current;

  static SuperTableExampleLocalization get current {
    final value = _current;
    if (value == null) {
      throw StateError(
        'ExampleL10n is not bound yet. Keep ExampleL10n.bind(context) in '
        'MaterialApp.builder.',
      );
    }
    return value;
  }

  static void bind(BuildContext context) {
    _current = SuperTableExampleLocalization.of(context);
  }
}

extension ExampleLocalizationContext on BuildContext {
  SuperTableExampleLocalization get exampleL10n =>
      SuperTableExampleLocalization.of(this);
}
