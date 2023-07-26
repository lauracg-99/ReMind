import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:remind/presentation/notifications/utils/notifications.dart';
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

  Workmanager().executeTask((task, inputData) async {
    log('*** exc task $task ${DateTime.now().toString()}');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
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

final FirebaseFirestore _database = FirebaseFirestore.instance;


void registerBackgroundTask() async {
  final prefs = await SharedPreferences.getInstance();
  final isDailyTaskScheduled = prefs.getBool('daily_task_scheduled') ?? false;
  final isCheckDBTaskScheduled = prefs.getBool('check_DB_scheduled') ?? false;

  log('${isDailyTaskScheduled} ${isCheckDBTaskScheduled}');

  if (!isDailyTaskScheduled) {
    // run at midnight
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0, 0);
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
    try {
      var uid = await FirebaseAuth.instance.currentUser;
      log('*** con uid ${uid?.uid}');
      //FXlCiIL5Una5vScaijO15D4ZUdY2
      await FirestoreService().firestoreInstance.collection(FirestorePaths.taskPath(uid!.uid))
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((taskDocument) {
            Map<String, dynamic> taskData = taskDocument.data();
            taskData['done'] = 'false';
            taskDocument.reference.update(taskData);
          });
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
    var uid = await FirebaseAuth.instance.currentUser;
    log('*** con uid ${uid?.uid}');
    var noSupervisor = GetStorage().read(StorageKeys.rol) != StorageKeys.SUPERVISOR;
    if(noSupervisor) {
      DataConnectionChecker().hasConnection;
      _database.collection(FirestorePaths.taskPath(uid!.uid))
          .snapshots()
          .listen((querySnapshot) {
        querySnapshot.docChanges.forEach((change) {
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
            }
            //la tarea se ha modificado y aún no está hecha => establecemos las notificaciones
            if (task.done == StorageKeys.falso) {
              //borramos notificación
              AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
              //ponemos el grupo
              Notifications().setNotification(task);
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
          }
        });
      });
    }

  }
}




