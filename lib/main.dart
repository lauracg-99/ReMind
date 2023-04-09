import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/presentation/providers/app_locale_provider.dart';
import 'package:remind/presentation/providers/app_theme_provider.dart';
import 'package:remind/presentation/routes/app_router.dart';
import 'package:remind/presentation/routes/navigation_service.dart';
import 'package:remind/presentation/routes/route_paths.dart';
import 'package:remind/presentation/styles/app_colors.dart';
import 'package:remind/presentation/styles/app_themes/dark_theme.dart';
import 'package:remind/presentation/styles/app_themes/light_theme.dart';

import 'domain/services/init_services/services_initializer.dart';
import 'domain/services/theme_service.dart';
import 'l10n/l10n.dart';

void main() async {
  //This let us access providers before runApp (read only)
  final container = ProviderContainer();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await ServicesInitializer.instance.init(widgetsBinding, container);
  await GetStorage.init();
  runApp(
    //All Flutter applications using Riverpod
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, ref) {
    final platformBrightness = usePlatformBrightness();
    final appLocale = ref.watch(appLocaleProvider);
    final appTheme = ref.watch(appThemeProvider);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Theme(
        data: ThemeService.instance.isDarkMode(appTheme, platformBrightness)
            ? DarkTheme.darkTheme
            : LightTheme.lightTheme,
        //esto nos sirve para tener cosas distintas según la plataforma
        child: PlatformApp(
          navigatorKey: NavigationService.navigationKey,
          debugShowCheckedModeBanner: false,
          color: AppColors.lightThemePrimary,
          locale: appLocale,
          supportedLocales: L10n.all,
          localizationsDelegates: L10n.localizationsDelegates,
          initialRoute: RoutePaths.coreSplash,
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    );
  }
}

//flutter packages pub run build_runner build --delete-conflicting-outputs