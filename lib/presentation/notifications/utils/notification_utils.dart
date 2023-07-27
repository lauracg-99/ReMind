import 'package:shared_preferences/shared_preferences.dart';

class NotificationUtils {
  static const String _notificationKey = 'notification_ids';

  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Método para guardar los detalles de la notificación en SharedPreferences
  static Future<void> saveNotificationDetails(int id, int day, int hour, int minute, String taskId) async {
    final prefs = await _prefs;
    final notifications = prefs.getStringList(_notificationKey) ?? [];

    // Crea un String que contenga los detalles de la notificación
    final notificationData = '$id:$day:$hour:$minute:$taskId'; // Agrega el taskId

    // Agrega el String a la lista de notificaciones en SharedPreferences
    notifications.add(notificationData);

    // Guarda la lista actualizada en SharedPreferences
    prefs.setStringList(_notificationKey, notifications);
  }

  // Método para verificar si una notificación con los mismos detalles ya existe
  static Future<bool> doesNotificationExist(int id, int day, int hour, int minute) async {
    final prefs = await _prefs;
    final notifications = prefs.getStringList(_notificationKey) ?? [];

    // Crea un String que contenga los detalles de la notificación actual
    final notificationData = '$id:$day:$hour:$minute';

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
}