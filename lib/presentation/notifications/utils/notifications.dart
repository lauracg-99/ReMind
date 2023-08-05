import 'dart:developer';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:remind/common/phrases.dart';
import 'package:remind/data/auth/manage_supervised/solicitud.dart';
import '../../../data/tasks/models/task_model.dart';
import '../../../domain/services/localization_service.dart';
import '../../tasks/utils/utilities.dart';
import 'notification_utils.dart';

class Notifications {

  int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

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

    // Comprobar si el día actual está en la lista de días de la tarea
    // Obtenemos el número de día de la semana actual (1 para Lunes, 7 para Domingo)
    int currentDay = DateTime.now().weekday;

    //notificacion por cada día
    for (int j = 0; j < cantDias!; j++) {

      int chooseDay = getNumDay(taskModel.days?.elementAt(j));
      if (kDebugMode) {
        print('set ${taskModel.taskId} $currentDay $chooseDay');
      }
      // Verificamos si el día actual está en la lista de días
      if (currentDay == chooseDay) {
        // El día actual está en la lista, procedemos a configurar las notificaciones
        for (int i = iniH; i <= finH; i += taskModel.numRepetition!) {
          var random = Random();
          int idNotification = random.nextInt(100000);
          var duration = Duration(minutes: i);
          if (kDebugMode) {
            print('pre-make');
          }
          await makeNotiAwesome(
            idNotification,
            taskModel.taskName,
            taskModel.taskId,
            chooseDay,
            duration.inHours,
            (duration.inMinutes - 60 * duration.inHours),
          );
        }
      }
    }


  }
  String randomCat() {
    var urlCat = 'assets/images/cats/';
    List<String> cats = [
      '${urlCat}cat1.JPEG',
      '${urlCat}cat2.JPEG',
      '${urlCat}cat3.JPG',
      '${urlCat}cat4.JPG',
      '${urlCat}cat5.JPG',
      '${urlCat}cat6.JPG',
      '${urlCat}cat7.JPG',
      '${urlCat}cat8.JPG',
      '${urlCat}cat9.JPG',
      '${urlCat}cat10.JPG'
    ];

    // Generar un índice aleatorio dentro del rango de la lista
    Random random = Random();
    int randomIndex = random.nextInt(cats.length);

    // Obtener el elemento aleatorio de la lista y retornarlo
    String cat = cats[randomIndex];
    return cat;
  }

  Future<void> makeNotiAwesome(int idNotification, String taskName,
      String taskId, int day, int hour, int minute) async {

    // Verifica si una notificación con los mismos detalles ya existe
    if (await NotificationUtils.doesNotificationExist(taskId, day, hour, minute)) {
      // Si la notificación ya existe, no se crea una nueva
      if (kDebugMode) {
        print('@@@ existe asi que noup $day:$hour:$minute:$taskId');
      }
      return;
    }

    // Guarda los detalles de la notificación en SharedPreferences

    await NotificationUtils.saveNotificationDetails(idNotification, day, hour, minute, taskId);
    var gatito = 'asset://${randomCat()}';
    if (kDebugMode) {
      print(gatito);
    }
    var gato = await fetchRandomCatImage() ?? gatito;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: idNotification,
        channelKey: 'scheduled_channel',
        groupKey: taskId,
        title: "${Emojis.body_eyes} ${Emojis.transport_police_car_light} ReMind",
        body: '${Phrases().obtenerFraseAleatoria()} $taskName ',
        bigPicture: gato,
        notificationLayout: NotificationLayout.BigPicture,
        wakeUpScreen: true,
      ),
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

  Future<void> resetTaskOkNoti(String message) async {

    var gatito = 'asset://${randomCat()}';
    if (kDebugMode) {
      print(gatito);
    }
    var gato = await fetchRandomCatImage() ?? gatito;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'basic_channel',
          autoDismissible: false,
          title: 'Aviso',
          body: message,
          bigPicture: gato,
          notificationLayout: NotificationLayout.BigPicture,
        ),
    );
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
