import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/data/auth/manage_supervised/solicitud.dart';
import 'package:remind/data/firebase/repo/firestore_paths.dart';
import 'package:remind/domain/auth/repo/user_repo.dart';
import 'package:remind/firebase_checker.dart';
import 'package:remind/presentation/solicitudes/components/num_solicitudes_component.dart';
import '../../../../common/storage_keys.dart';
import '../../../../data/auth/providers/user_list_notifier.dart';
import '../../../../data/firebase/repo/firebase_caller.dart';
import '../../../../data/tasks/models/task_model.dart';
import '../../../../data/tasks/providers/task_provider.dart';
import '../../../../domain/services/localization_service.dart';
import '../../../notifications/utils/notification_utils.dart';
import '../../../notifications/utils/notifications.dart';
import '../../../routes/navigation_service.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/sizes.dart';
import '../../../utils/dialog_message_state.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/buttons/custom_text_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/dialog_widget.dart';
import '../../../widgets/loading_indicators.dart';
import '../../components/card_item_component.dart';
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
    var email = GetStorage().read('email');
    var numElementos = 0;
    var numNotis = 0;
    final firestore = ref.watch(firebaseProvider);
    useEffect(() {
      firestore
          .collection(FirestorePaths.taskPath(uidUser))
          .snapshots()
          .listen((querySnapshot) { querySnapshot.docChanges.forEach((change) {

        if (change.type == DocumentChangeType.added) {
          final modifiedDocument = change.doc;
          final modifiedDocumentId = modifiedDocument.id;
          final modifiedDocumentData = modifiedDocument.data();

          log('UID del documento añadido: $modifiedDocumentId');
          var task = TaskModel.fromMap(modifiedDocumentData!, modifiedDocumentId);
          if (task.done == StorageKeys.falso) {
            Notifications().setNotification(task);
          } else {
            AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
            NotificationUtils.removeNotificationDetailsByTaskId(task.taskId);
          }
        }

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
              NotificationUtils.removeNotificationDetailsByTaskId(task.taskId);
            }
            if (task.done == StorageKeys.falso) {
              Notifications().setNotification(task);
            }
          }

          //si se borra por lo que sea cancelamos notis
          if (change.type == DocumentChangeType.removed) {
            final modifiedDocument = change.doc;
            final modifiedDocumentId = modifiedDocument.id;
            final modifiedDocumentData = modifiedDocument.data();
            var task = TaskModel.fromMap(modifiedDocumentData!, modifiedDocumentId);
            AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
            NotificationUtils.removeNotificationDetailsByTaskId(task.taskId);
          }
              });
      });

      /*return () {
        subscription.cancel(); // Cancelar la suscripción al salir del widget
      };*/
    }, []);

    useEffect(() {
      //si estado es pendiente saca la modal
      firestore.collection(FirestorePaths.userPetitionCollection(uidUser)).snapshots().listen((querySnapshot) {
        numElementos = querySnapshot.docs.length;
        querySnapshot.docs.forEach((element) {
          if (querySnapshot.docs.isNotEmpty) {
            Solicitud solicitud = Solicitud.fromMap(element.data());
            solicitud.id = element.id;
            //si hay peticiones pendientes
            if (solicitud.estado != 'pendiente'){
              if(numElementos != 0) {
                numElementos = numElementos - 1;
                ref.watch(numSolicitudesProvider.notifier).changeState(change: numElementos);
              };
            } else {
              ref.watch(numSolicitudesProvider.notifier).changeState(change: numElementos);
            }

          }
        });

        querySnapshot.docChanges.forEach((change) {
          if (querySnapshot.docs.isNotEmpty) {
            if (change.type == DocumentChangeType.modified) {
              final modifiedDocument = change.doc;
              final documentId = modifiedDocument.id;
              final modifiedDocumentData = modifiedDocument.data();
              GetStorage().write('notificarPeticion', false);
              if(modifiedDocumentData != null) {
                Solicitud solicitud = Solicitud.fromMap(modifiedDocumentData);
                if (solicitud.estado == 'pendiente' && !GetStorage().read('notificarPeticion')) {
                  solicitud.id = documentId;
                  log('solicitud ${solicitud.id} ${solicitud
                      .emailSup} ${solicitud.estado} ${solicitud
                      .emailBoss} ${documentId}');
                  Notifications().acceptPetitionNoti(context, solicitud);
                  managePetition(context, ref, solicitud: solicitud);
                }
               if (solicitud.estado == 'borrar') {
                    solicitud.id = documentId;
                    log('solicitud ${solicitud.id} ${solicitud
                        .emailSup} ${solicitud.estado} ${solicitud
                        .emailBoss} ${documentId}');
                    ref.watch(userRepoProvider).deletePetition(solicitud);

                  }
              }
            }
            if (change.type == DocumentChangeType.added) {
              final modifiedDocument = change.doc;
              final documentId = modifiedDocument.id;
              final modifiedDocumentData = modifiedDocument.data();

              if(modifiedDocumentData != null){
                Solicitud solicitud = Solicitud.fromMap(modifiedDocumentData);
                var notiPet = GetStorage().read('notificarPeticion') ?? false;
                if (solicitud.estado == 'pendiente' && !notiPet) {
                  solicitud.id = documentId;
                  log('solicitud ${solicitud.id} ${solicitud.emailSup} ${solicitud.estado} ${solicitud.emailBoss} ${documentId}');
                  Notifications().acceptPetitionNoti(context, solicitud);
                  managePetition(context, ref, solicitud: solicitud);
                }

              }


            }
          }
        });
      });
      }, []);

    final taskToDoStreamAll = ref.watch(getTasks);

    if (GetStorage().read(StorageKeys.SUPERVISOR) != 'supervisor') {
      setSupervisor(false);
    } else {
      setSupervisor(true);
    }


    return taskToDoStreamAll.when(
      data: (taskToDo) {
        if(GetStorage().read('reset') == StorageKeys.verdadero){
          _resetTasks(ref, taskToDo);
        }
        if(GetStorage().read('firstTimeLogIn') != null) {
            if (GetStorage().read('firstTimeLogIn')) {
              setNotificationsFirstTime(taskToDo);
            }
          }
          return (taskToDo.isEmpty)
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
          itemCount: taskToDo.length,
          itemBuilder: (context, index) {
            List<Widget> list = [];
            list.add(
                CardItemComponent(
                taskModel: taskToDo[index],
                ));

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
                        ref.refresh(getTasks);
                      })
                ]),
    loading: () => LoadingIndicators.instance.smallLoadingAnimation(context)
    );
  }

  static void _resetTasks(WidgetRef ref, List<TaskModel> taskToDo){
    for (var tarea in taskToDo) {

      if (tarea.done == StorageKeys.verdadero) {
          ref.watch(taskProvider.notifier).resetTask(null,tarea);
      }

    }
    ref.refresh(taskMultipleAll);
  }


  void managePetition(BuildContext context, WidgetRef ref, {required Solicitud solicitud}) {
    // set up the buttons
    Widget okButton = CustomTextButton(
      child: CustomText.h4(
          context,
          tr(context).acept,
          color: AppColors.blue
      ),
      onPressed:  () {
        //checkTask( context,taskModel: taskModel);
        NavigationService.goBack(context,rootNavigator: true);
        solicitud.estado = 'aceptada';
        ref.watch(userRepoProvider).updatePetition(solicitud);
      },
    );

    Widget cancelButton = CustomTextButton(
      child: CustomText.h4(
          context,
          'Denegar',
          color: AppColors.red
      ),
      onPressed:  () {
        solicitud.estado = 'rechazada';
        ref.watch(userRepoProvider).updatePetition(solicitud);
        NavigationService.goBack(context,rootNavigator: true);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: CustomText.h2(context, tr(context).adv),
      content: CustomText.h3(context,'Quiere ser tu supervisor '), // todo: tr
      actions: [
        cancelButton,
        okButton,
      ],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))
      ),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  setNotificationsFirstTime(List<TaskModel> listTasks){
    log('*** primera vez');
    listTasks.forEach((task) {
      if (task.done == StorageKeys.falso) {
        Notifications().setNotification(task);
      }
    });

    GetStorage().write('firstTimeLogIn', false);
  }
}