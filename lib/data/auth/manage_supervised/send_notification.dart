import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationManager {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void iniciarEscuchaNotificaciones() {
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then((token) {
      log('Token del dispositivo: $token');
      // Aquí puedes enviar el token a tu backend para guardarlo o manejarlo según tus necesidades
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Notificación recibida en primer plano: ${message.notification?.body}');

      // Aquí puedes enviar una notificación de vuelta al remitente con el token del dispositivo actual
      //enviarNotificacionDeVuelta(message);
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    print('Notificación recibida en segundo plano: ${message.notification?.body}');

    // Aquí puedes enviar una notificación de vuelta al remitente con el token del dispositivo actual
    //enviarNotificacionDeVuelta(message);
  }

  Future<void> enviarNotificacion(String token, String titulo, String mensaje) async {

    await _firebaseMessaging.getToken().then((token) async {
      log('Token del dispositivo: $token');
      if (token != null) {
        log('Token del dispositivo: $token');
        await _firebaseMessaging.sendMessage(to: token);
        // Aquí puedes enviar el token a tu backend para guardarlo o manejarlo según tus necesidades
      } else {
        log('El token es nulo');
      }
      // Aquí puedes enviar el token a tu backend para guardarlo o manejarlo según tus necesidades
    });
  //var es = await _firebaseMessaging.sendMessage(to: 'c1rQ0DkhSQqRdGJ8C2iAeh:APA91bF9AIspnfw74WmO4Dc4BqObemlcGW1gQkOMSYxoksmjf6iq6_QsyreLiMFXrt5qkq_D2yEVBSzWNEjVnG-74AWSGMHJyKgnPFQCXIrrvlM8C9WB3JtI7pvWgqnHTER0c7Q_QW7A');
    log('notificacion ${''}');
    //await _firebaseMessaging.sendMessage(to: "eyJhbGciOiJSUzI1NiIsImtpZCI6ImQwZTFkMjM5MDllNzZmZjRhNzJlZTA4ODUxOWM5M2JiOTg4ZjE4NDUiLCJ0eXAiOiJKV1QifQ");
    //await _firebaseMessaging.sendMessage(to:token,data: notificacion);
  }

  void enviarNotificacionDeVuelta(RemoteMessage message) {
    final String remitenteToken = message.data['remitenteToken'];

    final notificacion = {
     // 'notification': {
        'title': 'Respuesta automática',
        'body': 'Mi token es: $remitenteToken',
      //},
      //'to': remitenteToken,
    };

    _firebaseMessaging.sendMessage(to:'token',data: notificacion);
  }
}

// Ejemplo de uso:
//final notificationManager = NotificationManager();
//notificationManager.iniciarEscuchaNotificaciones();



// Ejemplo de uso:
//final notificationSender = NotificationSender();

// Llama a la función enviarNotificacion con los datos necesarios
//notificationSender.enviarNotificacion('TOKEN_DEL_USUARIO_DESTINATARIO', 'Título de la notificación', 'Mensaje de la notificación');