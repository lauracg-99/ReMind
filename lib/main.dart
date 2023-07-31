import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/firebase_checker.dart';
import 'package:remind/presentation/providers/app_locale_provider.dart';
import 'package:remind/presentation/providers/app_theme_provider.dart';
import 'package:remind/presentation/routes/app_router.dart';
import 'package:remind/presentation/routes/navigation_service.dart';
import 'package:remind/presentation/routes/route_paths.dart';
import 'package:remind/presentation/styles/app_colors.dart';
import 'package:remind/presentation/styles/app_themes/dark_theme.dart';
import 'package:remind/presentation/styles/app_themes/light_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'data/auth/manage_supervised/send_notification.dart';
import 'data/firebase/repo/firestore_paths.dart';
import 'domain/services/data_connection_service.dart';
import 'domain/services/init_services/services_initializer.dart';
import 'domain/services/localization_service.dart';
import 'domain/services/theme_service.dart';
import 'firebase_options.dart';
import 'l10n/l10n.dart';


void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase here
  FirestoreService();
  final container = ProviderContainer();
  await ServicesInitializer.instance.init(widgetsBinding, container);
  bool hasPermissions = await FlutterBackground.hasPermissions;
  if(!hasPermissions){
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "ReMind",
      notificationText: "Esta app necesita permisos para trabajar en segundo plano",
      notificationImportance: AndroidNotificationImportance.Default,
      notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'), // Default is ic_launcher from folder mipmap
    );
    bool success = await FlutterBackground.initialize(androidConfig: androidConfig);
  }
  await GetStorage.init();
  SystemChannels.textInput.invokeMethod('TextInput.hide');
  GetStorage().write('selectUser', false);
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic Notifications',
        defaultColor: AppColors.blue,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        channelDescription: 'Basic Notifications',
      ),
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notifications',
        defaultColor: AppColors.blue,
        locked: true,
        importance: NotificationImportance.High,
        soundSource: 'resource://raw/res_custom_notification',
        channelDescription: 'Scheduled Notifications',
      ),
      NotificationChannel(
        channelKey: 'petitions',
        channelName: 'Solicitudes',
        channelDescription: 'Canal para solicitudes de supervisor',
        defaultColor: Colors.blue,
        ledColor: Colors.blue,
        importance: NotificationImportance.High,
        channelShowBadge: true,
      ),
    ],
  );
AwesomeNotifications().requestPermissionToSendNotifications();
  Workmanager().initialize(
    callbackDispatcher, // The top level function, aka callbackDispatcher
    isInDebugMode: false, // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );

  registerBackgroundTask();

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