import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:remind/presentation/notifications/utils/utilities.dart';


Future<int> createTaskToDoNotification(int hour, int minute, String taskName) async {
  int idNotification = createUniqueId();
//todo: poner mejor notis
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: idNotification,
      channelKey: 'basic_channel',
      title:
      'Oye haz esto!!!',
      body: '${taskName}',
      //bigPicture: 'asset://assets/notification_map.png',
      notificationLayout: NotificationLayout.BigText,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'MARK_DONE',
        label: 'Hecho',
      ),
    ],
    schedule: NotificationCalendar(
      weekday: DateTime.now().weekday,
      hour: hour,
      minute: minute,
      second: 0,
      millisecond: 0,
      repeats: true,
    ),
  );
  return idNotification;
}


Future<int> createReminderNotification( int day, int hour, int minute, String taskName) async {
  int idNotification = DateTime.now().millisecondsSinceEpoch.remainder(100000);

  log('**** createReminderNotification ${idNotification} ${taskName}');

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: idNotification,
      channelKey: 'scheduled_channel',
      title: 'Do ${taskName}',
      body: 'venga va que toca',//'Rango horario ${taskModel.begin} ${taskModel.end}',
      notificationLayout: NotificationLayout.Default,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'MARK_DONE',
        label: 'Hecho',
      ),
    ],
    schedule: NotificationCalendar(
      weekday: day,
      hour: hour,
      minute: minute,
      second: 0,
      millisecond: 0,
      repeats: true,
    ),
  );

  return idNotification;
}

Future<int> reCreateReminderNotification(int day, String hour) async {
  int idNotification = createUniqueId();
  var hs = hour.split(':');
  int h = int.parse(hs[0]);
  int m = int.parse(hs[1]);
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: idNotification,
      channelKey: 'scheduled_channel',
      title: 'Do this',
      //title: '${Emojis.wheater_droplet} Add some water to your plant!',
      body: 'Venga va haz esto que toca',
      notificationLayout: NotificationLayout.Default,
    ),
    schedule: NotificationCalendar(
      weekday: day,
      hour: h,
      minute: m,
      second: 0,
      millisecond: 0,
      repeats: true,
    ),
  );
  log('id recreate notification en notification $idNotification');
  return idNotification;
}

Future<void> cancelScheduledNotifications() async {
  //await AwesomeNotifications().cancelAllSchedules();
  await AwesomeNotifications().cancelNotificationsByChannelKey('scheduled_channel');
}

Future<void> cancelScheduledNotification(int id) async {
  await AwesomeNotifications().cancel(id);
}
