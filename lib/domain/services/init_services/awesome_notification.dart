import 'package:awesome_notifications/awesome_notifications.dart';

class AweNotification{
  AweNotification._();
  static final instance = AweNotification._();

  init(){
    AwesomeNotifications().initialize(
      'resource://drawable/res_notification_app_icon',
      [
        /*NotificationChannel(
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
        ),*/
      ],
    );

  }


}