import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:remind/presentation/notifications/utils/utilities.dart';

import '../../../data/tasks/models/task_model.dart';
import '../../tasks/utils/utilities.dart';

class Notifications {
  Future<int> createTaskToDoNotification(int hour, int minute,
      String taskName) async {
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
        weekday: DateTime
            .now()
            .weekday,
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
      ),
    );
    return idNotification;
  }

  Future<void> setNotification(TaskModel taskModel) async {
    var splitIni = taskModel.begin?.split(':');
    //pasamos all a minutos
    int iniH = int.parse(splitIni![0]) * 60 + int.parse(splitIni[1]);

    var splitFin = taskModel.end?.split(':');
    //pasamos all a minutos
    int finH = int.parse(splitFin![0]) * 60 + int.parse(splitFin[1]);

    int? cantDias = taskModel.days?.length;
    int notificationDelay = taskModel.numRepetition!;
    int currentDelay = 0; // Retraso inicial
    //notificacion por cada día
    for (int j = 0; j < cantDias!; j++) {
      int chooseDay = getNumDay(taskModel.days?.elementAt(j));

      // 13:00 hasta 14:00 cada 4 min
      for (int i = iniH; i <= finH; i += notificationDelay) {
        int idNotification = DateTime
            .now()
            .millisecondsSinceEpoch
            .remainder(100000);
        var duration = Duration(minutes: i, seconds: currentDelay);
        await makeNotiAwesome(
            idNotification, taskModel.taskName, taskModel.taskId,
            chooseDay, duration.inHours,
            (duration.inMinutes - 60 * duration.inHours));
        currentDelay += 1;
      }
    }
  }
  var ant = '';
  Future<void> makeNotiAwesome(int idNotification, String taskName,
      String taskId, int day, int hour, int minute) async {
    log('day ${day} hour ${hour} min ${minute}');
    log('ant: ${ant}');
    if('day ${day} hour ${hour} min ${minute}' != ant) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: idNotification,
          channelKey: 'scheduled_channel',
          groupKey: taskId,
          title: 'Do ${taskName} ',
          body: 'venga va que toca',
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
        ),
        /*actionButtons: [
        NotificationActionButton(
          key: 'MARK_DONE',
          label: 'Hecho',
        ),
      ],*/
        schedule: NotificationCalendar(
          weekday: day,
          hour: hour,
          minute: minute,
          second: 0,
          millisecond: 0,
          repeats: true,
          preciseAlarm: true,
        ),
      );
    }

    ant = 'day ${day} hour ${hour} min ${minute}';
  }


  Future<int> createReminderNotification(int day, int hour, int minute,
      String taskName) async {
    int idNotification = DateTime
        .now()
        .millisecondsSinceEpoch
        .remainder(100000);

    log('**** createReminderNotification ${idNotification} ${taskName}');

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: idNotification,
        channelKey: 'scheduled_channel',
        title: 'Do ${taskName}',
        body: 'venga va que toca',
        //'Rango horario ${taskModel.begin} ${taskModel.end}',
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
    await AwesomeNotifications().cancelNotificationsByChannelKey(
        'scheduled_channel');
  }

  Future<void> cancelScheduledNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }
}