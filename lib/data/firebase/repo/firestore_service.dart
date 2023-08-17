import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/storage_keys.dart';
import '../../../domain/services/data_connection_service.dart';
import '../../../presentation/notifications/utils/notification_utils.dart';
import '../../../presentation/notifications/utils/notifications.dart';
import '../../tasks/models/task_model.dart';
import 'firestore_paths.dart';

class FirestoreService {
  static final FirestoreService _singleton = FirestoreService._internal();

  factory FirestoreService() {
    return _singleton;
  }

  FirestoreService._internal() {
    // Inicializar Firebase si aún no está inicializado
    if (!Firebase.apps.isEmpty) {
      Firebase.initializeApp();
    }
  }

  FirebaseFirestore get firestoreInstance => FirebaseFirestore.instance;

  bool isTimestampFromPreviousDay(Timestamp? timestamp) {
    if (timestamp == null) {
      // Handle the case when the timestamp is null (or return false if you prefer)
      return false;
    }

    // Create DateTime objects from Timestamps
    DateTime currentDateTime = DateTime.now();
    DateTime timestampDateTime = timestamp.toDate();

    log('time $timestampDateTime ${currentDateTime.year == timestampDateTime.year &&
        currentDateTime.month == timestampDateTime.month &&
        currentDateTime.day == timestampDateTime.day}');

    // Compare their dates (year, month, and day)
    if (currentDateTime.year == timestampDateTime.year &&
        currentDateTime.month == timestampDateTime.month &&
        currentDateTime.day == timestampDateTime.day) {
      // The timestamps are from the same day
      return false;
    } else {
      // The timestamps are from different days
      // Check if the timestamp is from the previous day
      DateTime previousDayDateTime = currentDateTime.subtract(Duration(days: 1));

      log('previus $previousDayDateTime ${previousDayDateTime.year == timestampDateTime.year &&
          previousDayDateTime.month == timestampDateTime.month &&
          previousDayDateTime.day == timestampDateTime.day}');
      if (previousDayDateTime.year == timestampDateTime.year &&
          previousDayDateTime.month == timestampDateTime.month &&
          previousDayDateTime.day == timestampDateTime.day) {
        // The timestamp is from the previous day
        return true;
      } else {
        // The timestamp is from a day before the previous day
        return false;
      }
    }
  }

  Future<void> startMonitoringChanges() async {
    log('*** startMonitoringChanges');
    await DataConnectionChecker().hasConnection;
    var uid = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();
    await firestoreInstance.collection(FirestorePaths.taskPath(uid!.uid))
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docChanges.forEach((change) async {
          log('*** change.type ${change.type}');
          final modifiedDocument = change.doc;
          final modifiedDocumentId = modifiedDocument.id;
          final modifiedDocumentData = modifiedDocument.data();
          Map<String, dynamic> taskData = modifiedDocument.data()!;
          var task = TaskModel.fromMap(modifiedDocumentData!, modifiedDocumentId);
          log('FIRESTORE SERVICE UID del documento: ${taskData['taskId']} ${task.taskId}');

          if (change.type == DocumentChangeType.added) {
            if (isTimestampFromPreviousDay(task.lastUpdate) && afterMidnight()) {
              //prefs.setBool('is_time_to_reset', true);
              if(isTimestampFromPreviousDay(taskData['lastUpdate'])){
                taskData['done'] = 'false';
                taskData['isNotiSet'] = 'false';
                taskData['lastUpdate'] = Timestamp.fromDate(DateTime.now());
              }
            }

            if (task.done == StorageKeys.falso && task.isNotiSet == StorageKeys.falso) {
              await Notifications().setNotification(task).then((value) async {
                taskData['isNotiSet'] = 'true';
              });
            }

            if (change.type == DocumentChangeType.modified) {
              //la tarea se ha marcado como hecha => no necesitamos las notis de ese día
              if (task.done == StorageKeys.verdadero) {
                AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
                NotificationUtils.removeNotificationDetailsByTaskId(task.taskId);
                taskData['isNotiSet'] = 'false';
              }
              //la tarea se ha modificado y aún no está hecha => establecemos las notificaciones
              if (task.done == StorageKeys.falso && task.isNotiSet == StorageKeys.falso) {
                //borramos notificación
                AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
                NotificationUtils.removeNotificationDetailsByTaskId(task.taskId);
                //ponemos el grupo
                await Notifications().setNotification(task).then((value) async {
                  taskData['isNotiSet'] = 'true';
                });
              }
            }

            //si se borra por lo que sea cancelamos notis
            if (change.type == DocumentChangeType.removed) {
              AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
              NotificationUtils.removeNotificationDetailsByTaskId(task.taskId).then((value) async {
                taskData['isNotiSet'] = 'false';
              });
            }
            log('taskdata $taskData');
            await modifiedDocument.reference.update(taskData);

          }}
        );
      }
    });
  }


  /*Future<void> resetTaskWM() async {
    log('*** resetTaskWM');
    await DataConnectionChecker().hasConnection;
    var uid = FirebaseAuth.instance.currentUser;
    await firestoreInstance.collection(FirestorePaths.taskPath(uid!.uid))
        .get().then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            querySnapshot.docs.forEach((element) async {
              Map<String, dynamic> taskData = element.data();
              if(isTimestampFromPreviousDay(taskData['lastUpdate'])){
              taskData['done'] = StorageKeys.falso;
              taskData['isNotiSet'] = StorageKeys.falso;
              taskData['lastUpdate'] = Timestamp.fromDate(DateTime.now());
              log('taskdata $taskData');
              await element.reference.update(taskData);
              }
            });

          }
    });
  }*/

  bool afterMidnight() {
    DateTime horaActual = DateTime.now();
    DateTime midnight = DateTime(horaActual.year, horaActual.month, horaActual.day, 0, 0, 0, 0);
    log('hora actual $horaActual midnight $midnight ${horaActual.isAfter(midnight)}');
    return horaActual.isAfter(midnight);
  }
}