
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
    _userRepo = ref.watch(userRepoProvider);
    _firebaseCaller = ref.watch(firebaseCaller);
  }

  final Ref ref;
  late UserRepo _userRepo;
  late IFirebaseCaller _firebaseCaller;
  TaskModel? taskModel;

  var user = FirebaseAuth.instance.currentUser?.uid;

  // OBTECIÓN DE DATOS ---------------------------------------------------------


//------------------------- OBTENER DATOS ---------------------------------

//SUPERVISADO
//SELF PUESTAS
//tareas sin hacer supervisado hechas por el mismo
//static String taskPath(String uid) => 'users/$uid/tasks';

  Stream<List<TaskModel>> getTasksStream() {

    return  _firebaseCaller.collectionStream<TaskModel>(
      //uid de usuario
      path: FirestorePaths.taskPath(GetStorage().read('uidUsuario')),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.falso),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }

  Stream<List<TaskModel>> getTasksBossS() {
    return  _firebaseCaller.collectionStream<TaskModel>(
      //uid de usuario
      path: FirestorePaths.taskPathBoss(GetStorage().read('uidUsuario')),
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
      path: FirestorePaths.taskPathBoss(GetStorage().read('uidSup')),
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
      path: FirestorePaths.taskPathBoss(GetStorage().read('uidSup')),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.verdadero),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }

  Stream<List<TaskModel>> getTasksDoneStream() {
    return  _firebaseCaller.collectionStream<TaskModel>(
      //uid de usuario
      path: FirestorePaths.taskPath(GetStorage().read('uidUsuario')),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.verdadero),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }
 Future<String?> getUIDSup()async{
   return await _userRepo.getUidSup();
 }


  Stream<List<TaskModel>> getTasksDoneStreamBossS() {
    return  _firebaseCaller.collectionStream<TaskModel>(
      //uid de usuario
      path: FirestorePaths.taskPathBoss(GetStorage().read('uidUsuario')),
      queryBuilder: (query) => query
          .where("done", isEqualTo: StorageKeys.verdadero),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }


  Future<Either<Failure?, TaskModel>> getTaskByName({required String taskId,}) async {
    return await _firebaseCaller.getData(
      path: FirestorePaths.taskById(GetStorage().read('uidUsuario'),taskId: taskId),
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
      path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario'),taskId: taskId),
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
      path: FirestorePaths.taskDoneById(GetStorage().read('uidUsuario'),taskId: taskId),
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
      path: FirestorePaths.taskBossDoneById(GetStorage().read('uidUsuario'),taskId: taskId),
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

  Future<String> setTaskDoc(TaskModel taskData, String uid) async {
    return await _firebaseCaller.addDataToCollection(
        path: FirestorePaths.taskPath(GetStorage().read('uidUsuario')), ///tasks
        data: taskData.toMap()
    );
  }

  Future<Either<Failure, bool>> addSingleTask({ required TaskModel task,}) async {

    /*final _userRepo = ref.watch(userRepoProvider).uidSuper;
    var usuario = await getUsuario();
    var uid = usuario?.uId;*/
    return await (_userRepo != '')
        ?    _firebaseCaller.setData(
        path: FirestorePaths.taskBossById(GetStorage().read('uidSup')!,taskId: task.taskId),
        data: task.toMap(),
        builder: (data) {
          if (data is! ServerFailure && data == true) {
            taskModel = task;
            return Right(data);
          } else {
            return Left(data);
          }
        }
        )
        :  _firebaseCaller.setData(
        path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,taskId: task.taskId),
        data: task.toMap(),
        builder: (data) {
          if (data is! ServerFailure && data == true) {
            taskModel = task;
            return Right(data);
          } else {
            return Left(data);
          }
        }
    );




  }

  Future<Either<Failure, bool>> addDocToFirebase(TaskModel taskModel) async {
    // nos da el uid de la tarea

     taskModel.taskId = await setTaskDoc(taskModel,user!).then(
            (value) => taskModel.taskId = value
    );

    final result = await addSingleTask(task: taskModel);
    return await result.fold(
          (failure) {
        return Left(failure);
      },
          (taskModel) async {
        if (taskModel == null) {
          return Right(taskModel);
        } else {
          return const Right(true);
        }
      },
    );
  }

//boss

  Future<String> setTaskDocBoss(TaskModel taskData, String uid) async {
    return await _firebaseCaller.addDataToCollection(
        path: FirestorePaths.taskPathBoss(uid), ///tasks
        data: taskData.toMap()
    );
  }

  Future<Either<Failure, bool>> addSingleTaskBoss({ required TaskModel task,}) async {
    //var usuario = await getUsuario();
    //var uid = usuario?.uId;
    return await _firebaseCaller.setData(
        path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario'),taskId: task.taskId),
        data: task.toMap(),
        builder: (data) {
          if (data is! ServerFailure && data == true) {
            taskModel = task;
            return Right(data);
          } else {
            return Left(data);
          }
        }
    );
  }

  Future<Either<Failure, bool>> addDocToFirebaseBoss(TaskModel taskModel) async {
    // nos da el uid de la tarea
    taskModel.taskId = await setTaskDocBoss(taskModel,user!).then(
            (value) => taskModel.taskId = value
    );

    final result = await addSingleTaskBoss(task: taskModel);
    return await result.fold(
          (failure) {
        return Left(failure);
      },
          (taskModel) async {
        if (taskModel == null) {
          return Right(taskModel);
        } else {
          return const Right(true);
        }
      },
    );
  }


//------------------------- Copiar DATOS ---------------------------------


  //static String taskById(String uid,{required String taskId}) => 'users/$uid/tasks/$taskId';

  //static String taskDoneById(String uid,{required String taskId}) => 'users/$uid/tasksDone/$taskId';

  Future<Either<Failure, bool>> copyDataSupervised (TaskModel taskModel) async {

    final result = await addSingleTaskDone(task: taskModel);
    return await result.fold(
          (failure) {
        return Left(failure);
      },
          (taskModel) async {
        if (taskModel == null) {
          return Right(taskModel);
        } else {
          return const Right(true);
        }
      },
    );
  }

  Future<Either<Failure, bool>> addSingleTaskDone({ required TaskModel task,}) async {
    /*var usuario = await getUsuario();
    var uid = usuario?.uId;*/
    return await _firebaseCaller.setData(
        path: FirestorePaths.taskDoneById(GetStorage().read('uidUsuario'),taskId: task.taskId),
        data: task.toMap(),
        builder: (data) {
          if (data is! ServerFailure && data == true) {
            taskModel = task;
            return Right(data);
          } else {
            return Left(data);
          }
        }
    );
  }

  //------------------------- DELETE DATOS ---------------------------------

  Future<void> deleteSingleTask({required TaskModel taskModel}) async {
    cancelNotification(taskModel.idNotification!);
    return await _firebaseCaller.deleteData(
        path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,taskId: taskModel.taskId));
  }

  Future<void> deleteSingleTaskDone({required TaskModel taskModel}) async {
    return await _firebaseCaller.deleteData(
        path: FirestorePaths.taskDoneById(GetStorage().read('uidUsuario')!,taskId: taskModel.taskId));
  }

  Future<void> deleteSingleTaskBoss({required TaskModel taskModel}) async {
    cancelNotification(taskModel.idNotification!);
    return await _firebaseCaller.deleteData(
        path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario')!,taskId: taskModel.taskId));
  }

  Future<void> deleteSingleTaskDoneBoss({required TaskModel taskModel}) async {
    return await _firebaseCaller.deleteData(
        path: FirestorePaths.taskBossDoneById(GetStorage().read('uidUsuario')!,taskId: taskModel.taskId));
  }


  Stream<List<TaskModel>> getNotiTaskStream() {
    Notifications().cancelScheduledNotifications();
    var actualHour = DateTime.now();
    var actualDay = getTranslateDay();

    var formatter = DateFormat('hh:mm');
    String formattedDate = formatter.format(actualHour);

    return  _firebaseCaller.collectionStream<TaskModel>(
      path: FirestorePaths.taskPath(GetStorage().read('uidUsuario')!),
      queryBuilder: (query) => query
          .where("days", arrayContains: actualDay)
          .where("done", isEqualTo: StorageKeys.falso),
      builder: (snapshotData, snapshotId) {
        log('getNoti task repo 1');
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }

  Stream<List<TaskModel>> getNotModTasksStream() {
    return _firebaseCaller.collectionStream<TaskModel>(
      path: FirestorePaths.taskPath(GetStorage().read('uidUsuario')!),
      queryBuilder: (query) => query
          .where('editable', isEqualTo: StorageKeys.falso),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }

  //tareas hechas
  Stream<List<TaskModel>> getTasksCompletedStream() {
    return _firebaseCaller.collectionStream<TaskModel>(
      path: FirestorePaths.taskPath(GetStorage().read('uidUsuario')!),
      queryBuilder: (query) => query
          .where('done', isEqualTo: StorageKeys.verdadero),
      builder: (snapshotData, snapshotId) {
        return TaskModel.fromMap(snapshotData!, snapshotId);
      },
    );
  }


  UserModel? returnUsuario() {
    UserModel? user;
    getUsuario().then((value) => user = value);
    return user;
  }

  Future<UserModel?> getUsuario() async {
    final result = await _userRepo.getUserData(GetStorage().read('uidUsuario')!);
    return result.fold(
          (failure) {
            return null;
          },
          (userModel) {
            return userModel;
      },
    );
  }

  //obtenemos la informacion de nuestro supervisado mediante su uid
  Future<UserModel?> getInfoSupervisado(String uid) async {
    final result = await _userRepo.getUserData(uid);
    return result.fold(
          (failure) {
        return null;
      },
          (userModel) {
        return userModel;
      },
    );
  }

  Future<Either<Failure, UserModel>> getUser() async {
    final result = await _userRepo.getUserData(GetStorage().read('uidUsuario')!);
    return result.fold(
      (failure) {
        return  Left(failure);
      },
      (userModel) {
        return Right(userModel!);
      },
    );
  }

  // MODIFICAR ELIMINAR COSAS --------------------------------------------------

  //cancelar todas las notificaciones, borrar ids, marcar done false
   void resetTasks(TaskModel taskModel) async {

    //obtenemos tareas, cancelamos sus notificaciones, ponemos isNotificationSet
     // a false y cambiamos a no hechas todas
     log("**** INSIDE SET CRON ${GetStorage().read('CronSet')}");
    //diferenciamos si es tarea de supervisor o no
    if (taskModel.editable == StorageKeys.verdadero)
    {
      log("**** CRON RESETEAMOS CON ${GetStorage().read('uidUsuario')}");
      await resetTask(task: taskModel);
    } else {
      log("**** BOSS CRON RESETEAMOS CON ${GetStorage().read('uidUsuario')}");
      await await resetTaskBoss(task: taskModel);
    }

  }

  Future<Either<Failure, bool>> resetTask({required TaskModel task}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,taskId: task.taskId),
      data: {
        'isNotificationSet': StorageKeys.falso,
        'done': StorageKeys.falso,
        'idNotification': [],
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

  Future<Either<Failure, bool>> resetTaskBoss({required TaskModel task}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario')!,taskId: task.taskId),
      data: {
        'isNotificationSet': StorageKeys.falso,
        'done': StorageKeys.falso,
        'idNotification': [],
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

  Future<Either<Failure, bool>> checkTask({required TaskModel task}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,taskId: task.taskId),
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

  Future<Either<Failure, bool>> checkTaskBoss({required TaskModel task}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario')!,taskId: task.taskId),
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

  Future<Either<Failure, bool>> checkSetNoti({required TaskModel task}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read('uidUsuario'),taskId: task.taskId),
      data: {
        'isNotificationSet': StorageKeys.verdadero,
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

  Future<Either<Failure, bool>> checkSetNotiBoss({required TaskModel task}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario'),taskId: task.taskId),
      data: {
        'isNotificationSet': StorageKeys.verdadero,
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

  Future<Either<Failure, bool>> addNotification(TaskModel task) async {
    List<int> list = await setNotiInSupervised(task);
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read('uidUsuario'),taskId: task.taskId),
      data: {
        'idNotification': list,
        'isNotificationSet': StorageKeys.verdadero,
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

  Future<Either<Failure, bool>> addNotificationBoss(TaskModel task, List<int> ids) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario'),taskId: task.taskId),
      data: {
        'idNotification': ids,
        'isNotificationSet': StorageKeys.verdadero,
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

  Future<Either<Failure, bool>> cancelTodayNotifications({required TaskModel task}) async {
    var now = DateTime.now().weekday;
    //si nos quedan ids de notificacion o no
    //if(task.idNotification?.length != 0) {
    //numero de ids que tenemos que borrar
    var numDelete = task.notiHours?.length;
    //borramos desde el primero hasta el numero de ids que correspondan a ese día
    Iterable? idCancel = task.idNotification;

    //cancelamos esas notificaciones
    idCancel?.forEach((element) {
      Notifications().cancelScheduledNotification(element);
    });


    List<int> ids = [];

    //quitamos el día que hemos hecho
    List? taskMinusDay = task.days;

    //si estamos en ultimo día de rep de esa semana
    if(taskMinusDay?.length == 1){
      //notificaciones de 0
      await makesNewNotification(task.days!, task.notiHours!)
          .then((value) => ids = value
      );
    } else{
      taskMinusDay?.remove(getStrDay(now));
      await makesNewNotification(taskMinusDay!, task.notiHours!)
          .then((value) => ids = value
      );
    }


    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!, taskId: task.taskId),
      data: {
        'idNotification': ids
      },
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
    // }

  }

  //TODO
  Future<Either<Failure, bool>> updateIds({required TaskModel task}) async {
    List<int> ids = [];


    await makesNewNotification(task.days!, task.notiHours!)
        .then((value) => ids = value
    );

    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,taskId: task.taskId),
      data: {
        'idNotification': ids
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


  Future<Either<Failure, bool>> updateTask(Map<String, dynamic> datos,{required String taskId,}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,taskId: taskId),
      data: datos,
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }

  Future<Either<Failure, bool>> updateTaskBoss(Map<String, dynamic> datos,{required String taskId,}) async {
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario')!,taskId: taskId),
      data: datos,
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );
  }


  cancelNotification(List<dynamic> listId){
    listId.forEach((element) { AwesomeNotifications().cancel(element);});
  }

  Future<List<int>> makesNewNotification(List<dynamic> days, List<dynamic> hour) async {
   List<int> reIds = [];
    for (var element in days) {
      for (var element2 in hour) {
        await Notifications().reCreateReminderNotification(
            getNumDay(element),element2)
            .then((value) => reIds.add(value)
        );
      }
    }
    return reIds;
  }

}