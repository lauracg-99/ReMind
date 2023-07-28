import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:remind/presentation/notifications/utils/notification_utils.dart';
import 'package:remind/presentation/notifications/utils/notifications.dart';
import 'package:remind/presentation/styles/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'common/storage_keys.dart';
import 'data/firebase/repo/firestore_paths.dart';
import 'data/tasks/models/task_model.dart';
import 'domain/services/data_connection_service.dart';
import 'firebase_options.dart';



@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() async {
  log('*** callbackDispatcher');
  WidgetsFlutterBinding.ensureInitialized();
  await DataConnectionChecker().hasConnection;
  Workmanager().executeTask((task, inputData) async {
    log('*** exc task $task ${DateTime.now().toString()}');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
    switch (task) {
      case 'resetTask':
        await FirestoreService().updateFirebaseData();
        final now = DateTime.now();
        final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0, 0);
        final initialDelay = nextMidnight.difference(now);

        Workmanager().registerOneOffTask(
          'reset_task',
          'resetTask',
        initialDelay: initialDelay,
        );
        break ;
      case 'checkDB':
        await FirestoreService().startMonitoringChanges();
        break;
      default: break;
    }
    return Future.value(true);
  });
}

void registerBackgroundTask() async {
  final prefs = await SharedPreferences.getInstance();
  final isDailyTaskScheduled = prefs.getBool('daily_task_scheduled') ?? false;
  final isCheckDBTaskScheduled = prefs.getBool('check_DB_scheduled') ?? false;
  final isSUPERVISOR = prefs.getBool('is_SUPERVISOR') ?? false;
  log('${isDailyTaskScheduled} ${isCheckDBTaskScheduled} $isSUPERVISOR');

  if(!isSUPERVISOR) {
    if (!isDailyTaskScheduled) {
      // run at midnight
      final now = DateTime.now();
      final nextMidnight =
          DateTime(now.year, now.month, now.day + 1, 0, 0, 0, 0);
      final initialDelay = nextMidnight.difference(now);

      Workmanager().registerOneOffTask(
        'reset_task',
        'resetTask',
        initialDelay: initialDelay,
      );

      // Mark the "daily_task" as scheduled for today
      prefs.setBool('daily_task_scheduled', true);
    }

    if (!isCheckDBTaskScheduled) {
      Workmanager().registerPeriodicTask(
        'check_DB',
        'checkDB',
        frequency: Duration(minutes: 15),
      );

      prefs.setBool('check_DB_scheduled', true);
    }
  }
}

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

  Future<void> updateFirebaseData() async {
    await DataConnectionChecker().hasConnection;
    try {
      var uid = await FirebaseAuth.instance.currentUser;
      log('*** con uid ${uid?.uid}');
      //FXlCiIL5Una5vScaijO15D4ZUdY2
      await FirestoreService().firestoreInstance.collection(FirestorePaths.taskPath(uid!.uid))
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          for (var taskDocument in querySnapshot.docs) {
            Map<String, dynamic> taskData = taskDocument.data();
            taskData['done'] = 'false';
            taskDocument.reference.update(taskData);
          }
        } else {
          log('*** oh');
        }
      });
    } catch (e) {
      print('Error al actualizar los datos de Firebase: $e');
    }
  }

  Future<void> startMonitoringChanges() async {
    log('*** startMonitoringChanges');
    await DataConnectionChecker().hasConnection;
    var uid = await FirebaseAuth.instance.currentUser;
    log('*** con uid ${uid?.uid}');
    var noSupervisor = GetStorage().read(StorageKeys.rol) != StorageKeys.SUPERVISOR;
    log('no sup $noSupervisor');

    await FirestoreService().firestoreInstance.collection(FirestorePaths.taskPath(uid!.uid))
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        log('nour empty');
      }
      querySnapshot.docChanges.forEach((change) async {
        log('*** change.type ${change.type}');
        if (change.type == DocumentChangeType.added) {
          final modifiedDocument = change.doc;
          final modifiedDocumentId = modifiedDocument.id;
          final modifiedDocumentData = modifiedDocument.data();

          log('UID del documento añadido: $modifiedDocumentId');
          var task = TaskModel.fromMap(modifiedDocumentData!, modifiedDocumentId);
          if (task.done == StorageKeys.falso && task.isNotiSet == StorageKeys.falso) {
            await Notifications().setNotification(task).then((value) async {
              await NotificationUtils.setNotiStateFB(uid.uid, task.taskId, 'true');
            });
          }
        }

        if (change.type == DocumentChangeType.modified) {
          final modifiedDocument = change.doc;
          final modifiedDocumentId = modifiedDocument.id;
          final modifiedDocumentData = modifiedDocument.data();
          // Aquí puedes usar modifiedDocumentId para obtener el UID del documento que ha cambiado
          log('UID del documento modificado: $modifiedDocumentId');
          var task = TaskModel.fromMap(
              modifiedDocumentData!, modifiedDocumentId);

          //la tarea se ha marcado como hecha => no necesitamos las notis de ese día
          if (task.done == StorageKeys.verdadero) {
            AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
            NotificationUtils.removeNotificationDetailsByTaskId(task.taskId);
            await NotificationUtils.setNotiStateFB(uid.uid, task.taskId, 'false');
          }
          //la tarea se ha modificado y aún no está hecha => establecemos las notificaciones
          if (task.done == StorageKeys.falso && task.isNotiSet == StorageKeys.falso) {
            //borramos notificación
            AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
            NotificationUtils.removeNotificationDetailsByTaskId(task.taskId);
            //ponemos el grupo
            await Notifications().setNotification(task).then((value) async {
              await NotificationUtils.setNotiStateFB(uid.uid, task.taskId, 'true');
            });
          }
        }

        //si se borra por lo que sea cancelamos notis
        if (change.type == DocumentChangeType.removed) {
          final modifiedDocument = change.doc;
          final modifiedDocumentId = modifiedDocument.id;
          final modifiedDocumentData = modifiedDocument.data();
          var task = TaskModel.fromMap(
              modifiedDocumentData!, modifiedDocumentId);
          AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
          NotificationUtils.removeNotificationDetailsByTaskId(task.taskId).then((value) async {
            await NotificationUtils.setNotiStateFB(uid.uid, task.taskId, 'false');
          });
        }
      });
    });
  }



}




