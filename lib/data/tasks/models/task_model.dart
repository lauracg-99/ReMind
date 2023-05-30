
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
  final String? done;
  final int? numRepetition;
  final String authorUID;
  final Timestamp? lastUpdate;

  TaskModel({
    required this.taskId,
    required this.taskName,
    required this.begin,
    required this.end,
    required this.editable,
    required this.days,
    required this.notiHours,
    required this.done,
    required this.numRepetition,
    required this.authorUID,
    this.lastUpdate,
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
    'done':done,
    'numRepetition': numRepetition,
    'authorUID': authorUID,
    'lastUpdate' :lastUpdate,
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
      done: map['done'] ?? '',
      numRepetition: map['numRepetition'] ?? '',
      authorUID: map['authorUID'] ?? '',
      lastUpdate: map['lastUpdate'],
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
      done: task.done ?? '',
      numRepetition: task.numRepetition ?? 0,
      authorUID: task.authorUID ?? '',
      lastUpdate: task.lastUpdate,
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
     String? done,
     int? numRepetition,
      String? authorUID,
     Timestamp? lastUpdate,
  }) {
    return TaskModel(
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      begin: begin ?? this.begin,
      end: end ?? this.end,
      editable: editable ?? this.editable,
      days: this.days,
      notiHours: this.notiHours,
      done: done ?? this.done,
      numRepetition: numRepetition ?? this.numRepetition,
      authorUID: authorUID ?? this.authorUID,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

