import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:remind/presentation/tasks/providers/tarea_state.dart';
import '../../../data/auth/providers/auth_provider.dart';
import '../../../data/auth/repo/auth_repo.dart';
import '../../../data/error/failures.dart';
import '../../../data/firebase/repo/firebase_caller.dart';
import '../../../data/firebase/repo/firestore_paths.dart';
import '../../../data/firebase/repo/i_firebase_caller.dart';
import '../../../data/tasks/models/task_model.dart';
import '../../../data/tasks/providers/task_provider.dart';
import '../../../data/tasks/repo/task_repo.dart';
import '../../../domain/auth/repo/user_repo.dart';
import '../../../domain/services/localization_service.dart';
import '../../providers/main_core_provider.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../utils/dialog_message_state.dart';
import '../../utils/dialogs.dart';
import '../../widgets/dialog_widget.dart';


final taskProvider =
StateNotifierProvider.autoDispose<TaskNotifier, TareaState>((ref) {
  return TaskNotifier(ref);
});

class TaskNotifier extends StateNotifier<TareaState> {
  TaskNotifier(this.ref) : super(const TareaState.available()) {
    _mainCoreProvider = ref.watch(mainCoreProvider);
    _authRepo = ref.watch(authRepoProvider);
    _userRepo = ref.watch(userRepoProvider);
    _firebaseCaller = ref.watch(firebaseCaller);
  }


  final Ref ref;
  late MainCoreProvider _mainCoreProvider;
  late AuthRepo _authRepo;
  late UserRepo _userRepo;
  late IFirebaseCaller _firebaseCaller;


  static bool supervisor = false;


  setSupervisor(bool set){
    supervisor = set;
  }
  static bool aceptar = false;

  questionCheck(BuildContext context,{required TaskModel taskModel}) async {
    //await AppDialogs.showCheckDialog(context);
    await DialogWidget.showCustomDialog(
        context: context,
        dialogWidgetState: DialogWidgetState.question,
        title: tr(context).oops,
        description: '${tr(context).somethingWentWrong}\n${ tr(context).pleaseTryAgainLater}',
        textButton: tr(context).oK,
        textButton2: tr(context).cancel,
        onPressed: () {
          log('aceptar');
          checkTask( context,taskModel: taskModel);
          NavigationService.goBack(context,rootNavigator: true);

        },
        onPressed2: (){
          log('NO aceptar');
          NavigationService.goBack(context,rootNavigator: true);
        }
    );
  }
  checkTask(BuildContext context,{required TaskModel taskModel}) async {
    state = const TareaState.loading();
      await cancelNotification(taskModel.idNotification!);
      return await _firebaseCaller.updateData(
        path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,
            taskId: taskModel.taskId),
        data: {
          'done': 'true',
          'isSetNotification': 'false',
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

  //cancelamos notificaciones, deseteamos y borramos ids
  checkTaskBoss({required TaskModel taskModel}) async {
    await cancelNotification(taskModel.idNotification!);
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario')!,
          taskId: taskModel.taskId),
      data: {
        'done': 'true',
        'isSetNotification': 'false',
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

  Future<Either<Failure, bool>> undoCheckTaskBoss({required TaskModel taskModel}) async {

      return await _firebaseCaller.updateData(
        path: FirestorePaths.taskBossById(GetStorage().read('uidSup')!,
            taskId: taskModel.taskId),
        data: {
          'done': 'false',
          'isSetNotification': 'false',
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

  Future<Either<Failure, bool>> undoCheckTask({required TaskModel taskModel}) async {
    if(taskModel.editable == 'false') {
      return await _firebaseCaller.updateData(
        path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario')!,
            taskId: taskModel.taskId),
        data: {
          'done': 'false',
          'isSetNotification': 'false',
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
    } else {
      return await _firebaseCaller.updateData(
        path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,
            taskId: taskModel.taskId),
        data: {
          'done': 'false',
          'isSetNotification': 'false',
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
  }
  //-------------------
   addDocToFirebase(BuildContext context, TaskModel taskModel) async {
    // nos da el uid de la tarea
    state = const TareaState.loading();
    taskModel.taskId = await _firebaseCaller.addDataToCollection(
        path: FirestorePaths.taskPath(GetStorage().read('uidUsuario')), ///tasks
        data: taskModel.toMap()
    );
    /*taskModel.taskId = await setTaskDoc(taskModel,GetStorage().read('uidUsuario')).then(
            (value) => taskModel.taskId = value
    );*/


    final result = await _firebaseCaller.setData(
        path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,
            taskId: taskModel.taskId),
        data: taskModel.toMap(),
        builder: (data) {
          if (data is! ServerFailure && data == true) {
            return Right(data);
          } else {
            return Left(data);
          }
        }
    );

    //final result = await addSingleTask(task: taskModel);
    return await result.fold(
          (failure) {
            state =  TareaState.error(errorText: failure.message);
            AppDialogs.showErrorDialog(context, message: failure.message);
          },
          (taskModel) async {
            state = TareaState.available();
            AppDialogs.addTaskOK(context,
                message: tr(context).addTaskDone);
      },
    );
  }

   /*showCheckTestDone(BuildContext context, TaskModel taskModel) async {
    await DialogWidget.showCustomDialog(
      context: context,
      dialogWidgetState: DialogWidgetState.question, // todo: tr
      title: tr(context).oops,
      description: '¿Estas seguro?',
      textButton: tr(context).oK,
      textButton2: tr(context).cancel,
      onPressed: () {
        if(taskModel.editable=='true'){
          checkTask(taskModel: taskModel);
        }
        else {
          checkTaskBoss(taskModel: taskModel);
        }
        NavigationService.goBack(context,rootNavigator: true);
      },
    onPressed2: (){
      NavigationService.goBack(context,rootNavigator: true);
    }
    );


    *//*return await result.fold(
          (failure) {
        state =  TareaState.error(errorText: failure.message);
        //AppDialogs.showErrorDialog(context, message: failure.message);
      },
          (taskModel) async {
        state = TareaState.available();
        //AppDialogs.addTaskOK(context, message: tr(context).addTaskDone);
      },
    );*//*

  }*/



  //--------------------

   addDocToFirebaseBoss(BuildContext context,TaskModel taskModel) async {
    state = TareaState.loading();
    log('**** ADD DOC TO FB BOSS');
    taskModel.taskId = await _firebaseCaller.addDataToCollection(
        path: FirestorePaths.taskPathBoss(GetStorage().read('uidSup')), ///tasks
        data: taskModel.toMap()
    );
    final result = await _firebaseCaller.setData(
        path: FirestorePaths.taskBossById(GetStorage().read('uidSup'),taskId: taskModel.taskId),
        data: taskModel.toMap(),
        builder: (data) {
          if (data is! ServerFailure && data == true) {
            //taskModel = task;
            return Right(data);
          } else {
            return Left(data);
          }
        }
    );

    //final result = await addSingleTaskBoss(task: taskModel);
    return await result.fold(
          (failure) {
            state = TareaState.error(errorText: failure.message);
            AppDialogs.showErrorDialog(context, message: failure.message);
            //return Left(failure);
          },

          (taskModel) async {
            state = TareaState.available();
            log('**** ADD DOC TO FB BOSS 2');
            AppDialogs.addTaskOK(context,
                message: tr(context).addTaskDone);

      },
    );
  }

   updateTask(BuildContext context,Map<String, dynamic> datos,{required String taskId,}) async {
    log('**** UPDATE TASK ${GetStorage().read('uidUsuario')} ${taskId}');
     final result = await _firebaseCaller.updateData(
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

     return await result.fold(
           (failure) {
         state = TareaState.error(errorText: failure.message);
         AppDialogs.showErrorDialog(context, message: failure.message);
         //return Left(failure);
       },

           (taskModel) async {
         state = TareaState.available();
         AppDialogs.addTaskOK(context,
             message: tr(context).modTaskDone).then((value) => NavigationService.goBack(context,rootNavigator: true));
       },
     );
  }

   updateTaskBoss(BuildContext context,Map<String, dynamic> datos,{required String taskId,}) async {
    final result = await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read('uidSup')!,taskId: taskId),
      data: datos,
      builder: (data) {
        if (data is! ServerFailure && data == true) {
          return Right(data);
        } else {
          return Left(data);
        }
      },
    );

    return await result.fold(
          (failure) {
        state = TareaState.error(errorText: failure.message);
        AppDialogs.showErrorDialog(context, message: failure.message);
        //return Left(failure);
      },

          (taskModel) async {
        state = TareaState.available();
        AppDialogs.addTaskOK(context,
            message: tr(context).modTaskDone).then((value) => NavigationService.goBack(context,rootNavigator: true));
      },
    );
  }

//-----------------------

  Future<void> deleteSingleTask({required TaskModel taskModel}) async {
    log('**** deleteSingleTask ${taskModel.idNotification?.length}');
    await cancelNotification(taskModel.idNotification!);
    return await _firebaseCaller.deleteData(
        path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,taskId: taskModel.taskId)
    );
  }

  Future<void> deleteTaskbyBoss({required TaskModel taskModel}) async {
    log('**** deleteTaskbyBoss ${taskModel.idNotification?.length}');
    await cancelNotification(taskModel.idNotification!);
    return await _firebaseCaller.deleteData(
        path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario')!,taskId: taskModel.taskId)
    );
  }

  cancelNotification(List<dynamic> listId){
    log('eliminando notis ${listId.length}');
    listId.forEach((element) {
      log('cancelar notis ${element}');
      AwesomeNotifications().cancelSchedule(element);
      AwesomeNotifications().cancel(element);
    }
    );
  }

  Future<void> deleteSingleTaskBoss({required TaskModel taskModel}) async {
    cancelNotification(taskModel.idNotification!);
    //borramos da
    return await _firebaseCaller.deleteData(
        path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario')!,
            taskId: taskModel.taskId));
  }

  ///-------------------------NOTIFICATION--------------------------------------
  /// esto nos sirve para cancelar las notificaciones en el supervisado
  void checkDeleteNoti({required TaskModel taskModel}) async {
    if(taskModel.editable == 'true') {
      await _firebaseCaller.updateData(
        path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,
            taskId: taskModel.taskId),
        data: {
          'cancelNoti': 'true',
        },
        builder: (data) {
          if (data is! ServerFailure && data == true) {
            return Right(data);
          } else {
            return Left(data);
          }
        },
      );
    } else{
      await _firebaseCaller.updateData(
        path: FirestorePaths.taskBossById(GetStorage().read('uidSup')!,
            taskId: taskModel.taskId),
        data: {
          'cancelNoti': 'true',
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
  }

   Future<List<int>> setNotification(TaskModel taskModel) async {
     log('**** SET NOTIFICATION');
     List<int> allIds = [];
     var splitIni = taskModel.begin?.split(':');
     //pasamos all a minutos
     int iniH = int.parse(splitIni![0])*60 + int.parse(splitIni[1]);

     var splitFin = taskModel.end?.split(':');
     //pasamos all a minutos
     int finH = int.parse(splitFin![0])*60 + int.parse(splitFin[1]);

     int? cantDias = taskModel.days?.length;
     //notificacion por cada día
     for(int j = 0; j< cantDias!;j++) {

       int chooseDay = getNumDay(taskModel.days?.elementAt(j));

       // 13:00 hasta 14:00 cada 4 min
       for (int i = iniH; i <= finH; i += taskModel.numRepetition!) {
         int idNotification = DateTime.now().millisecondsSinceEpoch.remainder(100000);
         allIds.add(idNotification);
         var duration = Duration(minutes: i);
          await makeNotiAwesome(idNotification,taskModel.taskName,
              chooseDay, duration.inHours,(duration.inMinutes-60*duration.inHours));
       }
     }

     if(taskModel.editable == 'true') {
      await _firebaseCaller.updateData(
        path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,
            taskId: taskModel.taskId),
        data: {
          'idNotification': allIds,
        },
        builder: (data) {
          if (data is! ServerFailure && data == true) {
            return Right(data);
          } else {
            return Left(data);
          }
        },
      );
    } else{
       await _firebaseCaller.updateData(
         path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario')!,
             taskId: taskModel.taskId),
         data: {
           'idNotification': allIds,
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

    return allIds;

  }

  makeNotiAwesome(int idNotification, String taskName, int day, int hour, int minute ) async {
    //int idNotification, String taskName, int day, int hour, int minute

    log('**** MAKENOTI ${idNotification} ${taskName} ${day} ${hour} ${minute}');
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: idNotification,
        channelKey: 'scheduled_channel',
        title: 'Do ${taskName} ',
        body: 'venga va que toca',//'Rango horario ${taskModel.begin} ${taskModel.end}',
        notificationLayout: NotificationLayout.Default,
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'MARK_DONE',
          label: 'Hecho',
        ),
      ],
      schedule: NotificationCalendar(
        weekday: day,
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        preciseAlarm: true,
      ),
    );
  }

  int getNumDay(String day){
    int num = 0;
    switch(day){
      case 'Lunes': num = 1; break;
      case 'Martes': num = 2; break;
      case 'Miércoles': num = 3; break;
      case 'Jueves': num = 4; break;
      case 'Viernes': num = 5; break;
      case 'Sábado': num = 6; break;
      case 'Domingo': num = 7; break;
    }

    return num;
  }


  Future<Either<Failure, bool>> updateNotificationInfo({required TaskModel task}) async {
    //state = const TareaState.loading();
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,taskId: task.taskId),
      data: {
        'idNotification': task.idNotification,
        'isNotificationSet': 'true',
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

  Future<Either<Failure, bool>> updateNotificationInfoBoss({required TaskModel task}) async {
    //state = const TareaState.loading();
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario')!,taskId: task.taskId),
      data: {
        'idNotification': task.idNotification,
        'isNotificationSet': 'true',
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

  Future<Either<Failure, bool>> resetTask({required TaskModel task}) async {
    await cancelNotification(task.idNotification!);
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskById(GetStorage().read('uidUsuario')!,taskId: task.taskId),
      data: {
        'isNotificationSet': 'false',
        'done': 'false',
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
    await cancelNotification(task.idNotification!);
    return await _firebaseCaller.updateData(
      path: FirestorePaths.taskBossById(GetStorage().read('uidUsuario')!,taskId: task.taskId),
      data: {
        'isNotificationSet': 'false',
        'done': 'false',
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


//-------------------------------------------------------------------------------


  navigationToHomeScreen(BuildContext context) {
    NavigationService.pushReplacementAll(
      context,
      isNamed: true,
      page: RoutePaths.home,
    );
  }

  subscribeUserToTopic() {
    /*FirebaseMessagingService.instance.subscribeToTopic(
      topic: 'general',
    );*/
  }


  navigationToCheckScreen(BuildContext context) {
    NavigationService.pushReplacementAll(
      context,
      isNamed: true,
      page: RoutePaths.verifyEmail,
    );
  }

  navigationToLogin(BuildContext context) {
    NavigationService.pushReplacementAll(
      context,
      isNamed: true,
      page: RoutePaths.authLogin,
    );
  }
}
