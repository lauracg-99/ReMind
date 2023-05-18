import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/data/firebase/repo/firestore_paths.dart';
import '../../../../common/storage_keys.dart';
import '../../../../data/firebase/repo/firebase_caller.dart';
import '../../../../data/tasks/models/task_model.dart';
import '../../../../domain/services/localization_service.dart';
import '../../../notifications/utils/notifications.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/sizes.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/loading_indicators.dart';
import '../../components/card_item_component.dart';
import '../../providers/task_provider.dart';
import '../../providers/task_to_do.dart';

class ShowTasks extends HookConsumerWidget {
  const ShowTasks({Key? key}) : super(key: key);
  static bool supervisor = false;


  setSupervisor(bool set){
    supervisor = set;
  }
  @override
  Widget build(BuildContext context, ref) {

    GetStorage().write('screen','show');
    var uidUser = GetStorage().read('uidUsuario');
    final firestore = ref.watch(firebaseProvider);
    useEffect(() {
      final subscription = firestore
          .collection(FirestorePaths.taskPath(uidUser))
          .snapshots()
          .listen((querySnapshot) {
              querySnapshot.docChanges.forEach((change) {
          if (change.type == DocumentChangeType.modified) {
            final modifiedDocument = change.doc;
            final modifiedDocumentId = modifiedDocument.id;
            final modifiedDocumentData = modifiedDocument.data();

            // Aquí puedes usar modifiedDocumentId para obtener el UID del documento que ha cambiado
            log('UID del documento modificado: $modifiedDocumentId');
            var task = TaskModel.fromMap(
                modifiedDocumentData!, modifiedDocumentId);

            //la tarea se ha marcado como hecha => no necesitamos las notis de ese día
            if (task.done == StorageKeys.verdadero) {
              AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
            }
            //la tarea se ha modificado y aún no está hecha => establecemos las notificaciones
            if (task.done == StorageKeys.falso) {
              //borramos notificación
              AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
              //ponemos el grupo
              Notifications().setNotification(task);
            }
          }
        });
          });
          final firebase2 = firestore
              .collection(FirestorePaths.taskPathBoss(uidUser))
              .snapshots()
              .listen((querySnapshot) {
            querySnapshot.docChanges.forEach((change) {
              if (change.type == DocumentChangeType.modified) {
                final modifiedDocument = change.doc;
                final modifiedDocumentId = modifiedDocument.id;
                final modifiedDocumentData = modifiedDocument.data();

                // Aquí puedes usar modifiedDocumentId para obtener el UID del documento que ha cambiado
                log('UID del documento modificado: $modifiedDocumentId');
                var task = TaskModel.fromMap(modifiedDocumentData!, modifiedDocumentId);

                //la tarea se ha marcado como hecha => no necesitamos las notis de ese día
                if(task.done == StorageKeys.verdadero){
                  AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
                }
                //la tarea se ha modificado y aún no está hecha => establecemos las notificaciones
                if(task.done == StorageKeys.falso){
                  //borramos notificación
                  AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
                  //ponemos el grupo
                  Notifications().setNotification(task);
                }
              }
            });

      });

      /*return () {
        subscription.cancel(); // Cancelar la suscripción al salir del widget
      };*/
    }, []);

    final taskToDoStreamAll = ref.watch(taskMultipleAll);

    if (GetStorage().read('rol') != 'supervisor') {
      setSupervisor(false);
    } else {
      setSupervisor(true);
    }
    final cron = Cron();
    //seteamos el crono una vez y si no somos supervisores

    if(!supervisor && GetStorage().read('CronSet') == StorageKeys.falso) {
      GetStorage().write('CronSet',StorageKeys.verdadero);
      // a las 00:00h se ejecutará esto todos los días
      cron.schedule(Schedule.parse('00 00 * * *'), () async {
        GetStorage().write('reset',StorageKeys.verdadero);
      });
    }

    return taskToDoStreamAll.when(
      data: (taskToDo) {
        if(GetStorage().read('reset') == StorageKeys.verdadero){
          _resetTasks(ref, taskToDo);
        }
        return (taskToDo.isEmpty || (taskToDo[0].length == 0 && taskToDo[1].length == 0) )
        ? CustomText.h4(
            context,
            tr(context).noTask,
            color: AppColors.grey,
            alignment: Alignment.center,
          )
        : ListView.separated(
          padding: EdgeInsets.symmetric(
            vertical: Sizes.screenVPaddingDefault(context),
            horizontal: Sizes.screenHPaddingMedium(context),
          ),
          separatorBuilder: (context, index) => SizedBox(height: Sizes.vMarginHigh(context),),
          itemCount: taskToDo[0].length + taskToDo[1].length,
          itemBuilder: (context, index) {
            List<Widget> list = [];
            if(index != taskToDo[0].length + taskToDo[1].length) {
                    var supervised = taskToDo[0].length;
                    var boss = taskToDo[1].length;
                    // supervised es 2 -> index: 0,1
                    if (index < supervised) {
                      //supervisado
                      if(taskToDo[0][index].cancelNoti == StorageKeys.verdadero && taskToDo[0][index].isNotificationSet == StorageKeys.verdadero){
                        ref.read(taskProvider.notifier).deleteSingleTask(taskModel: taskToDo[0][index]);
                      }
                      list.add(CardItemComponent(
                        taskModel: taskToDo[0][index],
                      ));

                    } else {
                      if (index - supervised  < boss) {
                        var indexBoss = index - supervised;
                        // tengo que esperar a que este activada si no no borra nada y no se desactiva
                        if(taskToDo[1][indexBoss].cancelNoti == StorageKeys.verdadero && taskToDo[1][indexBoss].isNotificationSet == StorageKeys.verdadero){
                          ref.read(taskProvider.notifier).deleteTaskbyBoss(taskModel: taskToDo[1][indexBoss]);
                        }
                        list.add(CardItemComponent(
                          taskModel: taskToDo[1][indexBoss],
                        ));
                      }
                    }
                  }

                return Column(children:list);
            },

      );
    },
    error: (err, stack) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText.h4(
                    context,
                    tr(context).somethingWentWrong + '\n' + tr(context).pleaseTryAgainLater,
                    color: AppColors.grey,
                    alignment: Alignment.center,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Sizes.vMarginMedium(context),),
                  CustomButton(
                      text: tr(context).recharge,
                      onPressed: (){
                        ref.refresh(taskMultipleToDoStreamProviderNOTDONE);
                        ref.refresh(taskMultipleToDoStreamProviderDONE);
                        ref.refresh(taskMultipleAll);
                      })
                ]),
    loading: () => LoadingIndicators.instance.smallLoadingAnimation(context)


    );
  }

  static void _resetTasks(WidgetRef ref, List<List<TaskModel>> taskToDo){
    for (var listas in taskToDo) {
      for (var element in listas) {
        if (element.done == StorageKeys.verdadero) {
          if(element.editable == StorageKeys.verdadero) {
            ref.watch(taskProvider.notifier).resetTask(task: element);
          } else {
            ref.watch(taskProvider.notifier).resetTaskBoss(task: element);
          }
        }
      }
    }
    GetStorage().write('reset',StorageKeys.falso);
    GetStorage().write('CronSet',StorageKeys.falso);
    ref.refresh(taskMultipleAll);
  }


}