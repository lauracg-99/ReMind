import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/firebase/repo/firestore_paths.dart';
import '../../../firebase_checker.dart';

class NotificationUtils {
  static const String _notificationKey = 'notification_ids';

  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Método para guardar los detalles de la notificación en SharedPreferences
  static Future<void> saveNotificationDetails(int id, int day, int hour, int minute, String taskId) async {

    if (kDebugMode) {
      print('saveNotificationDetails $day:$hour:$minute:$taskId');
    }
    final prefs = await _prefs;
    final notifications = prefs.getStringList(_notificationKey) ?? [];

    // Crea un String que contenga los detalles de la notificación
    final notificationData = '$day:$hour:$minute:$taskId'; // Agrega el taskId

    // Agrega el String a la lista de notificaciones en SharedPreferences
    notifications.add(notificationData);

    // Guarda la lista actualizada en SharedPreferences
    prefs.setStringList(_notificationKey, notifications);
  }

  // Método para verificar si una notificación con los mismos detalles ya existe
  static Future<bool> doesNotificationExist(String taskId, int day, int hour, int minute) async {
    final prefs = await _prefs;
    final notifications = prefs.getStringList(_notificationKey) ?? [];

    // Crea un String que contenga los detalles de la notificación actual
    final notificationData = '$day:$hour:$minute:$taskId';
    if (kDebugMode) {
      print('--- notification data $notificationData');
    }
    // Verifica si el String está presente en la lista de notificaciones
    return notifications.contains(notificationData);
  }

  // Método para eliminar los detalles de una notificación en SharedPreferences
  static Future<void> removeNotificationDetailsByTaskId(String taskId) async {
    final prefs = await _prefs;
    final notifications = prefs.getStringList(_notificationKey) ?? [];

    // Filtra las notificaciones que contienen el taskId dado
    final notificationsToRemove = notifications.where((notificationData) {
      final dataParts = notificationData.split(':');
      final notificationTaskId = dataParts.last;
      return notificationTaskId == taskId;
    }).toList();

    // Remueve las notificaciones filtradas de la lista de notificaciones en SharedPreferences
    notifications.removeWhere((notificationData) => notificationsToRemove.contains(notificationData));

    // Guarda la lista actualizada en SharedPreferences
    prefs.setStringList(_notificationKey, notifications);
  }

  static Future<void> setNotiStateFB(String uid, String taskId, String estado) async {

    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirestoreService()
        .firestoreInstance
        .collection(FirestorePaths.taskPath(uid))
        .doc(taskId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> taskData = snapshot.data()!;
      taskData['isNotiSet'] = estado;
      await snapshot.reference.update(taskData);
    } else {
      if (kDebugMode) {
        print('*** error set noti');
      }
    }
  }


  static Future<void> cancelNotiStateFBAll() async {
    try {
      var uid = await FirebaseAuth.instance.currentUser;
      print('*** cancelNotiStateFBAll con uid ${uid?.uid}');
      //FXlCiIL5Una5vScaijO15D4ZUdY2
      await FirestoreService().firestoreInstance.collection(FirestorePaths.taskPath(uid!.uid))
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          for (var taskDocument in querySnapshot.docs) {
            Map<String, dynamic> taskData = taskDocument.data();
            setNotiStateFB(uid.uid, taskData['taskId'], 'false');
          }
        } else {
          if (kDebugMode) {
            print('*** oh');
          }
        }
      });
    } catch (e) {
      print('Error al actualizar los datos de Firebase: $e');
    }

  }

}