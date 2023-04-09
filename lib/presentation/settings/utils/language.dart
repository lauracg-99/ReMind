
import 'package:flutter/material.dart';

import '../../../domain/services/localization_service.dart';
import '../../styles/app_images.dart';

enum Language {
  spanish('es', AppImages.languageIconSpanish),
  galician('gl', AppImages.languageIconGalician);

  final String code;
  final String flag;

  const Language(this.code, this.flag);
}

extension LanguageExtension on Language {
  String getCurrentLanguageName(BuildContext context) {
    switch (this) {
      case Language.galician:
        return tr(context).galician;
      case Language.spanish:
      default:
        return tr(context).spanish;
    }
  }
}
