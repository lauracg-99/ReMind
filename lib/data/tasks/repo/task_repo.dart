
import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cron/cron.dart';
import 'package:dartz/dartz.dart';
import 'package:dartz/dartz_unsafe.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../common/storage_keys.dart';
import '../../../domain/auth/repo/user_repo.dart';
import '../../../presentation/notifications/utils/notifications.dart';
import '../../../presentation/tasks/utils/utilities.dart';
import '../../auth/models/user_model.dart';
import '../../error/failures.dart';
import '../../firebase/repo/firebase_caller.dart';
import '../../firebase/repo/firestore_paths.dart';
import '../../firebase/repo/i_firebase_caller.dart';
import '../models/task_model.dart';

//manejar datos de tasks

class TasksRepo {
  TasksRepo(this.ref) {
    _firebaseCaller = ref.watch(firebaseCaller);
  }

  final Ref ref;
  late IFirebaseCaller _firebaseCaller;
  TaskModel? taskModel;

  var user = FirebaseAuth.instance.currentUser?.uid;


  Stream<List<TaskModel>> getTasksStream() {

    return  _firebaseCaller.collectionStream<TaskModel>(
      //uid de usuario
      path: FirestorePaths.taskPath(GetStorage().read(StorageKeys.uidUsuario)),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.falso),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }

  Stream<List<TaskModel>> getTasksDoneStream() {

    return  _firebaseCaller.collectionStream<TaskModel>(
      //uid de usuario
      path: FirestorePaths.taskPath(GetStorage().read(StorageKeys.uidUsuario)),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.verdadero),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }
//supervisor solo puede ver las tareas puestas por el mismo
  Stream<List<TaskModel>> getTasksStreamSup() {
    return  _firebaseCaller.collectionStream<TaskModel>(
      //uid de usuario
      path: FirestorePaths.taskPath(GetStorage().read(StorageKeys.lastUIDSup)),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.falso)
          .where("authorUID", isEqualTo: GetStorage().read(StorageKeys.uidUsuario)),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }

  Stream<List<TaskModel>> getTasksDoneStreamSup() {
    return  _firebaseCaller.collectionStream<TaskModel>(
      //uid de usuario
      path: FirestorePaths.taskPath(GetStorage().read(StorageKeys.lastUIDSup)),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.verdadero)
          .where("authorUID", isEqualTo: GetStorage().read(StorageKeys.uidUsuario)),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }

  Stream<List<TaskModel>> getTasksBossS() {
    return  _firebaseCaller.collectionStream<TaskModel>(
      //uid de usuario
      path: FirestorePaths.taskPathBoss(GetStorage().read(StorageKeys.lastUIDSup)),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.falso),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }

//PUESTAS POR EL Boss
// static String taskPathBoss(String uid) => 'users/$uid/tasksBoss';
//tareas hechas por el supervisados hechas por el mismo
  Stream<List<TaskModel>> getTasksBossStream() {
    return  _firebaseCaller.collectionStream<TaskModel>(
      path: FirestorePaths.taskPathBoss(GetStorage().read(StorageKeys.lastUIDSup)),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.falso),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }

  Stream<List<TaskModel>> getTasksDoneStreamBoss() {
    // final _userRepo = ref.watch(userRepoProvider).uidSuper;
    return  _firebaseCaller.collectionStream<TaskModel>(
      //uid de usuario
      path: FirestorePaths.taskPathBoss(GetStorage().read(StorageKeys.lastUIDSup)),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.verdadero),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }


  Stream<List<TaskModel>> getTasksDoneStreamBossS() {
    return  _firebaseCaller.collectionStream<TaskModel>(
      //uid de usuario
      path: FirestorePaths.taskPathBoss(GetStorage().read(StorageKeys.lastUIDSup)),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.verdadero),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }


  Future<Either<Failure?, TaskModel>> getTaskByName({required String taskId,}) async {
    return await _firebaseCaller.getData(
      path: FirestorePaths.taskById(GetStorage().read(StorageKeys.uidUsuario),taskId: taskId),
      builder: (data, id) {
        if (data is! ServerFailure && data != null) {
          return Right(TaskModel.fromMap(data, id!));
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure?, TaskModel>> getTaskBossByName({required String taskId,}) async {
    return await _firebaseCaller.getData(
      path: FirestorePaths.taskBossById(GetStorage().read(StorageKeys.lastUIDSup),taskId: taskId),
      builder: (data, id) {
        if (data is! ServerFailure && data != null) {
          return Right(TaskModel.fromMap(data, id!));
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure?, TaskModel>> getTaskDoneByName({required String taskId,}) async {
    return await _firebaseCaller.getData(
      path: FirestorePaths.taskDoneById(GetStorage().read(StorageKeys.uidUsuario),taskId: taskId),
      builder: (data, id) {
        if (data is! ServerFailure && data != null) {
          return Right(TaskModel.fromMap(data, id!));
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure?, TaskModel>> getTaskDoneBossByName({required String taskId,}) async {
    return await _firebaseCaller.getData(
      path: FirestorePaths.taskBossDoneById(GetStorage().read(StorageKeys.lastUIDSup),taskId: taskId),
      builder: (data, id) {
        if (data is! ServerFailure && data != null) {
          return Right(TaskModel.fromMap(data, id!));
        } else {
          return Left(data);
        }
      },
    );
  }

//------------------------- GUARDAR DATOS ---------------------------------

  Future<Either<Failure, bool>> addTask(TaskModel taskModel) async {

    taskModel.taskId = await getTaskId(taskModel);

    return (GetStorage().read(StorageKeys.rol) == StorageKeys.SUPERVISOR)
    ? await _firebaseCaller.setData(
      path: FirestorePaths.taskBossById(GetStorage().read(StorageKeys.lastUIDSup)!,taskId: taskModel.taskId),
      data: taskModel.toMap(),
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    )
    : await _firebaseCaller.setData(
      path: FirestorePaths.taskById(GetStorage().read(StorageKeys.uidUsuario)!,
          taskId: taskModel.taskId),
      data: taskModel.toMap(),
          builder: (data) {
          if (data is! ServerFailure && data == true) {
          return Right(data);
          } else {
          return Left(data);
          }
          },
    )

    ;
  }

  Future<String> getTaskId(TaskModel taskModel) async {
    return
      (GetStorage().read(StorageKeys.rol) == StorageKeys.SUPERVISOR)
      ? await _firebaseCaller.addDataToCollection(
          path: FirestorePaths.taskPath(GetStorage().read(StorageKeys.lastUIDSup)), ///tasks
          data: taskModel.toMap()
      )
      : await _firebaseCaller.addDataToCollection(
        path: FirestorePaths.taskPath(GetStorage().read(StorageKeys.uidUsuario)), ///tasks
        data: taskModel.toMap()
    );
  }

  //------------------------- DELETE DATOS ---------------------------------

  Future<void> deleteTask(TaskModel taskModel) async {
    (GetStorage().read('rol') == StorageKeys.SUPERVISOR)
          ? await _firebaseCaller.deleteData(
        path: FirestorePaths.taskBossById(
            GetStorage().read(StorageKeys.lastUIDSup)!,taskId: taskModel.taskId),
      )
          : await _firebaseCaller.deleteData(
        path: FirestorePaths.taskById(GetStorage().read(StorageKeys.uidUsuario)!,
            taskId: taskModel.taskId),
      );
  }


  // MODIFICAR ELIMINAR COSAS --------------------------------------------------

  Future<Either<Failure, bool>> resetTasks({required TaskModel taskModel}) async {
    return (GetStorage().read(StorageKeys.rol) == StorageKeys.SUPERVISOR)
     ? await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read(StorageKeys.lastUIDSup)!,taskId: taskModel.taskId),
      data: {
        'done': StorageKeys.falso,
      },
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    )
    : await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read(StorageKeys.uidUsuario)!,taskId: taskModel.taskId),
      data: {
        'done': StorageKeys.falso,
      },
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure, bool>> checkTask({required TaskModel taskModel}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(
          GetStorage().read(StorageKeys.uidUsuario)!,taskId: taskModel.taskId),
      data: {
        'done': StorageKeys.verdadero,
      },
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure, bool>> unCheckTask({required TaskModel taskModel}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read(StorageKeys.uidUsuario)!,
          taskId: taskModel.taskId),
      data: {
        'done': StorageKeys.falso,
      },
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure, bool>> checkTaskBoss({required TaskModel taskModel}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read(StorageKeys.lastUIDSup)!,taskId: taskModel.taskId),
      data: {
        'done': StorageKeys.verdadero,
      },
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure, bool>> unCheckTaskBoss({required TaskModel taskModel}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read(StorageKeys.lastUIDSup)!, taskId: taskModel.taskId),
      data: {
        'done': StorageKeys.falso,
      },
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure, bool>> updateTask(TaskModel taskModel) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read(StorageKeys.uidUsuario)!,taskId: taskModel.taskId),
      data: taskModel.toMap(),
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }
  Future<Either<Failure, bool>> updateTaskBoss(TaskModel taskModel) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read(StorageKeys.lastUIDSup)!,taskId: taskModel.taskId),
      data: taskModel.toMap(),
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }


}