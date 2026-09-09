import 'package:flutter/widgets.dart';

import 'generated/l10n.dart';
import 'generated/l10n_en.dart';

export 'generated/l10n.dart';

final SuperTableLocalization superTableEnglishLocalizationFallback =
    SuperTableLocalizationEn();

extension SuperTableLocalizationBuildContext on BuildContext {
  SuperTableLocalization get superTableLocalization =>
      Localizations.of<SuperTableLocalization>(this, SuperTableLocalization) ??
      superTableEnglishLocalizationFallback;
}
