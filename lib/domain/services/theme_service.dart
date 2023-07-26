import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../presentation/providers/app_theme_provider.dart';

class ThemeService {
  ThemeService._();

  static final instance = ThemeService._();

  late ProviderContainer _container;

  factory ThemeService(ProviderContainer container) {
    instance._container = container;
    return instance;
  }

  bool isDarkMode([ThemeMode? currentTheme, Brightness? platformBrightness]) {
    final _currentTheme = currentTheme ?? _container.read(appThemeProvider);
    if (_currentTheme == ThemeMode.system) {
      return (platformBrightness ??
          SchedulerBinding.instance!.window.platformBrightness) ==
          Brightness.dark;
    } else {
      return _currentTheme == ThemeMode.dark;
    }
  }
}
