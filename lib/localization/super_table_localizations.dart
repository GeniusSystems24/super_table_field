import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/l10n.dart';

/// Localization setup for Super Table Field.
///
/// Add [localizationsDelegates] and [supportedLocales] to the host app's
/// `MaterialApp` to enable the package strings in English and Arabic.
class SuperTableLocalizations {
  const SuperTableLocalizations._();

  static const LocalizationsDelegate<SuperTableTranslation> delegate =
      SuperTableTranslation.delegate;

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        SuperTableTranslation.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static SuperTableTranslation of(BuildContext context) =>
      SuperTableTranslation.maybeOf(context) ?? SuperTableTranslation();
}

extension SuperTableLocalizationBuildContext on BuildContext {
  SuperTableTranslation get superTableTranslations =>
      SuperTableLocalizations.of(this);
}
