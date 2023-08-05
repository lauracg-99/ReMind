import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:remind/presentation/notifications/utils/notification_utils.dart';
import 'package:remind/presentation/notifications/utils/notifications.dart';
import 'package:remind/presentation/styles/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'common/storage_keys.dart';
import 'data/firebase/repo/firestore_paths.dart';
import 'data/firebase/repo/firestore_service.dart';
import 'data/tasks/models/task_model.dart';
import 'domain/services/data_connection_service.dart';
import 'firebase_options.dart';


const checkDBTaskKey = "es.udc.ReMind.checkDB";
const resetTaskKey = "es.udc.ReMind.resetTasks";

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() async {
  log('*** callbackDispatcher');
  WidgetsFlutterBinding.ensureInitialized();
  await DataConnectionChecker().hasConnection;
  final prefs = await SharedPreferences.getInstance();
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
    await FirestoreService().startMonitoringChanges();
    var time = prefs.getBool('is_time_to_reset') ?? false;
    if(time){
      await FirestoreService().resetTaskWM().then((value) => prefs.setBool('is_time_to_reset', true));
    }
    return Future.value(true);
  });

}

Timestamp getTimestampForPreviousDay() {
  // Get the current date and time
  DateTime currentDateTime = DateTime.now();

  // Calculate the previous day by subtracting one day from the current date
  DateTime previousDayDateTime = currentDateTime.subtract(Duration(days: 1));

  // Convert the previous day DateTime into a Timestamp
  Timestamp previousDayTimestamp = Timestamp.fromDate(previousDayDateTime);
  log('previousDayTimestamp $previousDayTimestamp');
  return previousDayTimestamp;
}

void resetSharedWM() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('check_DB_scheduled',false);
  registerBackgroundTask();
  log('*** reset prefs');
}

void registerBackgroundTask() async {
  final prefs = await SharedPreferences.getInstance();
  final isCheckDBTaskScheduled = prefs.getBool('check_DB_scheduled') ?? false;
  final isSUPERVISOR = prefs.getBool('is_SUPERVISOR') ?? false;

  if(FirebaseAuth.instance.currentUser?.uid != null) {

    if (!isSUPERVISOR) {
      if (!isCheckDBTaskScheduled) {
        Workmanager().registerPeriodicTask(
          checkDBTaskKey,
          checkDBTaskKey,
          frequency: const Duration(minutes: 15),
        );
        log('*** set $checkDBTaskKey ${DateTime.now().toString()}');
        prefs.setBool('check_DB_scheduled', true);
      }
    }
  }
}






