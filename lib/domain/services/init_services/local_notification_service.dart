/*
import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../presentation/routes/navigation_service.dart';
import '../../../presentation/routes/route_paths.dart';
import '../../../presentation/styles/app_colors.dart';


class LocalNotificationService {
  LocalNotificationService._();

  static final instance = LocalNotificationService._();

  factory LocalNotificationService(ProviderContainer container) {
    instance._container = container;
    return instance;
  }

  late ProviderContainer _container;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future init() async {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('notification_icon');
    const IOSInitializationSettings iosInitializationSettings =
    IOSInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: false,
    );
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      //onSelectNotification: onSelectNotification,
    );
  }

  onSelectNotification(String? payload) async {
    if (FirebaseAuth.instance.currentUser == null) return;

    if (payload != null) {
      final decodedPayload = jsonDecode(payload) as Map<String, dynamic>;
      if (decodedPayload.isNotEmpty) {
       // final notificationModel = NotificationModel.fromMap(decodedPayload);
        NavigationService.pushReplacement(
          NavigationService.context,
          isNamed: true,
          //si clickamos en la notificacion nos vamos a la pagina de inicio
          page: RoutePaths.homeBase,
        );
        */
/*if (_notificationModel.data?.containsKey('orderId') ?? false) {
          _container
              .read(notificationOrderViewModel)
              .navigateToNotificationOrder(_notificationModel.data!['orderId']);
        }*//*

      }
    }
  }

  Future showInstantNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      _notificationDetails(),
      payload: payload,
    );
  }

  _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'local_push_notification',
        'ReMind Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
        color: AppColors.lightThemePrimary,
        playSound: true,
      ),
      iOS: IOSNotificationDetails(),
    );
  }
}
*/
