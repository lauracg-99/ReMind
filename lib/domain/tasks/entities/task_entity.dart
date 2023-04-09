import 'package:cloud_firestore/cloud_firestore.dart';

class TaskEntity {
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


  TaskEntity({
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
}