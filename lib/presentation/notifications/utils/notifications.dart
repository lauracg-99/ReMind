import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:remind/common/phrases.dart';
import 'package:remind/data/auth/manage_supervised/solicitud.dart';
import 'package:remind/presentation/notifications/utils/utilities.dart';

import '../../../data/tasks/models/task_model.dart';
import '../../../domain/services/localization_service.dart';
import '../../tasks/utils/utilities.dart';

class Notifications {
  Future<void> acceptPetitionNoti(BuildContext context, Solicitud solicitud) async {
    int idNotification = createUniqueId();
    GetStorage().write('notificarPeticion', true);
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: idNotification,
            channelKey: 'petitions',
            autoDismissible: false,
            title: tr(context).attention,
            body:
            "${tr(context).user_with} ${solicitud.emailBoss} ${tr(context).user_wants}",
            //bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            //largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',
            notificationLayout: NotificationLayout.BigPicture,
            //payload: {'notificationId': '1234567890'}
        ),
        /*actionButtons: [
          NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
          *//*NotificationActionButton(
              key: 'REPLY',
              label: 'Reply Message',
              requireInputText: true,
              actionType: ActionType.SilentAction
          ),*//*
          NotificationActionButton(
              key: 'DISMISS',
              label: 'Dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ]*/
    );
  }

  Future<void> statusPetitionNoti(BuildContext context, Solicitud solicitud, String status) async {
    int idNotification = createUniqueId();
    GetStorage().write('notificarPeticion', true);
    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: idNotification,
          channelKey: 'petitions',
          autoDismissible: false,
          title: tr(context).attention,
          body:
          "${tr(context).user_with} ${solicitud.emailSup} ha ${status} ${tr(context).your_petition}",
          //bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
          //largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
          //'asset://assets/images/balloons-in-sky.jpg',
          notificationLayout: NotificationLayout.BigPicture,
          //payload: {'notificationId': '1234567890'}
        ),
      actionButtons: [

      ]
    );


  }

  Future<void> setNotification(TaskModel taskModel) async {
    var splitIni = taskModel.begin?.split(':');
    //pasamos all a minutos
    int iniH = int.parse(splitIni![0]) * 60 + int.parse(splitIni[1]);

    var splitFin = taskModel.end?.split(':');
    //pasamos all a minutos
    int finH = int.parse(splitFin![0]) * 60 + int.parse(splitFin[1]);

    int? cantDias = taskModel.days?.length;
    //notificacion por cada día
    for (int j = 0; j < cantDias!; j++) {
      int chooseDay = getNumDay(taskModel.days?.elementAt(j));

      // 13:00 hasta 14:00 cada 4 min
      for (int i = iniH; i <= finH; i += taskModel.numRepetition!) {
        int idNotification = DateTime
            .now()
            .millisecondsSinceEpoch
            .remainder(100000);
        var duration = Duration(minutes: i);
        await makeNotiAwesome(
            idNotification, taskModel.taskName, taskModel.taskId,
            chooseDay, duration.inHours,
            (duration.inMinutes - 60 * duration.inHours));
      }
    }
  }

  Future<void> makeNotiAwesome(int idNotification, String taskName,
      String taskId, int day, int hour, int minute) async {
    log('day ${day} hour ${hour} min ${minute}');
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: idNotification,
        channelKey: 'scheduled_channel',
        groupKey: taskId,
        title: '${Phrases().obtenerFraseAleatoria()} ${taskName} ',
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
        title: '${Phrases().obtenerFraseAleatoria()} ${taskName} ',
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
        body: '${Phrases().obtenerFraseAleatoria()} ',
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