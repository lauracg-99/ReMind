import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocalizationService {
  LocalizationService._();

  static final instance = LocalizationService._();

  bool isGl(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'gl';
  }
}

AppLocalizations tr(BuildContext context) {
  return AppLocalizations.of(context)!;
}
