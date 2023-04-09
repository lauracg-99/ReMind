
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
   String taskId;
  final String taskName;
  final String? begin;
  final String? end;
  final String? editable;
  final List? days;
  final List? notiHours;
  List? idNotification;
  final String? done;
  final int? numRepetition;
  final Timestamp? lastUpdate;
  final String? isNotificationSet;
  final String? cancelNoti;


  TaskModel({
    required this.taskId,
    required this.taskName,
    required this.begin,
    required this.end,
    required this.editable,
    this.days,
    this.notiHours,
    this.idNotification,
    required this.done,
    required this.numRepetition,
    this.lastUpdate,
    this.isNotificationSet,
    this.cancelNoti,
  });

  Map<String, dynamic> toMap() {
    return {
    'taskId': taskId,
    'taskName':taskName,
    'begin':begin,
    'end':end,
    'editable':editable,
    'days':days ?? '',
    'notiHours': notiHours ?? '',
    'idNotification': idNotification ?? '',
    'done':done,
    'numRepetition': numRepetition,
    'lastUpdate' :lastUpdate,
    'isNotificationSet': isNotificationSet,
    'cancelNoti': cancelNoti,
    }..removeWhere((key, value) => value == null);
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String idTask) {
    return TaskModel(
      taskId: idTask,
      taskName: map['taskName'] ?? '',
      begin: map['begin'] ?? '',
      end: map['end'] ?? '',
      editable: map['editable'] ?? '',
      days: map['days'] ?? '',
      notiHours: map['notiHours'] ?? '',
      idNotification: map['idNotification'] ?? '',
      done: map['done'] ?? '',
      numRepetition: map['numRepetition'] ?? '',
      lastUpdate: map['lastUpdate'],
      isNotificationSet: map['isNotificationSet'],
      cancelNoti:map['cancelNoti'] ?? ''
    );
  }

  /// Google Factory
  factory TaskModel.fromUserCredential(TaskModel task) {
    return TaskModel(
      taskId: task.taskId,
      taskName: task.taskName,
      begin: task.begin ?? '',
      end: task.end ?? '',
      editable: task.editable ?? '',
      days: task.days,
      notiHours: task.notiHours,
      idNotification: task.idNotification,
      done: task.done ?? '',
      numRepetition: task.numRepetition ?? 0,
      lastUpdate: task.lastUpdate,
      isNotificationSet: task.isNotificationSet,
      cancelNoti: task.cancelNoti ?? ''
    );
  }

  TaskModel copyWith({
    String? taskId,
     String? taskName,
     String? begin,
     String? end,
     String? editable,
     List? days,
     List? notiHours,
     List? idNotification,
     String? done,
     int? numRepetition,
     Timestamp? lastUpdate,
     String? isNotificationSet,
    String? cancelNoti,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      begin: begin ?? this.begin,
      end: end ?? this.end,
      editable: editable ?? this.editable,
      days: this.days,
      notiHours: this.notiHours,
      idNotification: this.idNotification,
      done: done ?? this.done,
      numRepetition: numRepetition ?? this.numRepetition,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isNotificationSet: isNotificationSet ?? this.isNotificationSet,
      cancelNoti: cancelNoti ?? this.cancelNoti
    );
  }
}

