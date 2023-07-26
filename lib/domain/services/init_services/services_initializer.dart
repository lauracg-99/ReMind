import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/domain/services/init_services/storage_service.dart';
import 'package:workmanager/workmanager.dart';
import '../../../firebase_checker.dart';
import '../../../firebase_options.dart';
import '../../../presentation/providers/app_theme_provider.dart';
import '../../../presentation/routes/navigation_service.dart';
import '../../../presentation/styles/app_colors.dart';
import '../../../presentation/styles/app_images.dart';
import '../theme_service.dart';
import 'local_notification_service.dart';
import 'connectivity_service.dart';


class ServicesInitializer {
  ServicesInitializer._();

  static final ServicesInitializer instance = ServicesInitializer._();

  late ProviderContainer container;

  init(WidgetsBinding widgetsBinding, ProviderContainer container) async {
    this.container = container;
    //Init FirebaseApp instance before runApp
   // await _initFirebase();
    //await _iniNoti();
    //_iniNoti();
    //This Prevent closing splash screen until we finish initializing our services.
    //App layout will be built but not displayed.
    widgetsBinding.deferFirstFrame();
    widgetsBinding.addPostFrameCallback((_) async {
      //Run any function you want to wait for before showing app layout
      //await _initializeServices(); init services at custom splash
      _initializeServicesRef();
      BuildContext? context = widgetsBinding.renderViewElement;
      if (context != null) {
        await _initializeCustomSplashImages(context);
      }
      // Closes splash screen, and show the app layout.
      widgetsBinding.allowFirstFrame();
    });

    //registerBackgroundTask();
  }

  _iniNoti(){
    AwesomeNotifications().initialize(
      'resource://drawable/res_notification_app_icon',
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          defaultColor: AppColors.blue,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          channelDescription: '',
        ),
        NotificationChannel(
          channelKey: 'scheduled_channel',
          channelName: 'Scheduled Notifications',
          defaultColor: AppColors.blue,
          locked: true,
          importance: NotificationImportance.High,
          soundSource: 'resource://raw/res_custom_notification',
          channelDescription: '',
        ),
      ],
    );
  }

  _initializeStorage(){
    var storage = GetStorage();
    storage.write('notificarPeticion', false);
    storage.write('valorText', '');
    storage.write('uidSelected', '');
    storage.write('uidSelectedFoto', '');
    storage.write('pendingSolicitudes', 0);
    storage.write('userSelected', false);
  }

  _initializeServicesRef() {
    final themeService = ThemeService(ProviderContainer());
  }

  _initializeCustomSplashImages(BuildContext context) async {
    await precacheImage( AssetImage(AppImages.appLogoIcon), context);
  }

  initializeServices() async {
    await _initStorageService();
    await _initTheme();
    //await _initFirebase();
    await _initConnectivity();
    await _initializeStorage();
    //await _initNotificationSettings();
    //await _initFirebaseMessaging();
  }

  _initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  _initStorageService() async {
    await container.read(storageService).init();
  }
  _initTheme() async {
    await container.read(appThemeProvider.notifier).init();
  }

  _initConnectivity() async {
    container.read(connectivityService).init();
  }

  _initNotificationSettings() async {
    //await LocalNotificationService(container).init();
  }

  Future initializeData() async {
    List futures = [
      _cacheDefaultImages(),
    ];
    List<dynamic> result = await Future.wait<dynamic>([...futures]);
    return result;
  }

  _cacheDefaultImages() async {
    final context = NavigationService.context;
    await precacheImage( const AssetImage(AppImages.appLogoIcon), context);
  }
}
