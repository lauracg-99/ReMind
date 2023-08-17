import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/data/auth/manage_supervised/solicitud.dart';
import 'package:remind/data/firebase/repo/firestore_paths.dart';
import 'package:remind/domain/auth/repo/user_repo.dart';
import 'package:remind/firebase_checker.dart';
import 'package:remind/presentation/solicitudes/components/num_solicitudes_component.dart';
import 'package:remind/presentation/tasks/providers/filter_provider.dart';
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
import '../../../utils/dialogs.dart';
import '../../../utils/filters.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/buttons/custom_text_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/dialog_widget.dart';
import '../../../widgets/loading_indicators.dart';
import '../../components/card_item_component.dart';
import '../../components/filter_days_component.dart';
import '../../components/switch_setting_section_component.dart';
import '../../providers/multi_choice_provider.dart';
import '../../providers/task_to_do.dart';
import '../../utils/utilities.dart';

class ShowTasks extends HookConsumerWidget {
  const ShowTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {

    GetStorage().write('screen','show');
    var uidUser = GetStorage().read('uidUsuario');
    var numElementos = 0;
    final firestore = ref.watch(firebaseProvider);
    useEffect(() {
      firestore
          .collection(FirestorePaths.taskPath(uidUser))
          .snapshots()
          .listen((querySnapshot) { for (var change in querySnapshot.docChanges) {

        if (change.type == DocumentChangeType.added) {
          final modifiedDocument = change.doc;
          final modifiedDocumentId = modifiedDocument.id;
          final modifiedDocumentData = modifiedDocument.data();

          var task = TaskModel.fromMap(modifiedDocumentData!, modifiedDocumentId);

          if (task.done == StorageKeys.falso && task.isNotiSet == StorageKeys.falso) {
            Notifications().setNotification(task).then((value) async {
              Map<String, dynamic> taskData = modifiedDocument.data()!;
              taskData['isNotiSet'] = 'true';
              await modifiedDocument.reference.update(taskData);
            });
          }
          if (task.done == StorageKeys.verdadero && task.isNotiSet == StorageKeys.falso) {
            AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
            NotificationUtils.removeNotificationDetailsByTaskId(task.taskId).then((value) async {
              Map<String, dynamic> taskData = modifiedDocument.data()!;
              taskData['isNotiSet'] = 'false';
              await modifiedDocument.reference.update(taskData);
            });
          }
        }

          if (change.type == DocumentChangeType.modified) {
            final modifiedDocument = change.doc;
            final modifiedDocumentId = modifiedDocument.id;
            final modifiedDocumentData = modifiedDocument.data();
            // Aquí puedes usar modifiedDocumentId para obtener el UID del documento que ha cambiado

            var task = TaskModel.fromMap(
                modifiedDocumentData!, modifiedDocumentId);
            if (kDebugMode) {
              print('UID del documento modificado: $modifiedDocumentId ${task.done} ${task.isNotiSet} ${task.taskName}');
            }
            //la tarea se ha marcado como hecha => no necesitamos las notis de ese día
            if (task.done == StorageKeys.verdadero && task.isNotiSet == StorageKeys.falso) {
              AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
              NotificationUtils.removeNotificationDetailsByTaskId(task.taskId).then((value) async {
                Map<String, dynamic> taskData = modifiedDocument.data()!;
                taskData['isNotiSet'] = 'false';
                await modifiedDocument.reference.update(taskData);

              });
            }
            if (task.done == StorageKeys.falso && task.isNotiSet == StorageKeys.falso) {
              Notifications().setNotification(task).then((value) async {
                Map<String, dynamic> taskData = modifiedDocument.data()!;
                taskData['isNotiSet'] = 'true';
                await modifiedDocument.reference.update(taskData);
              });
            }
          }

          //si se borra por lo que sea cancelamos notis
          if (change.type == DocumentChangeType.removed) {
            final modifiedDocument = change.doc;
            final modifiedDocumentId = modifiedDocument.id;
            final modifiedDocumentData = modifiedDocument.data();
            var task = TaskModel.fromMap(modifiedDocumentData!, modifiedDocumentId);
            AwesomeNotifications().cancelNotificationsByGroupKey(task.taskId);
            NotificationUtils.removeNotificationDetailsByTaskId(task.taskId).then((value) async {
              Map<String, dynamic> taskData = modifiedDocument.data()!;
              taskData['isNotiSet'] = 'false';
              await modifiedDocument.reference.update(taskData);
            });
          }
              }
      });
    }, []);

    useEffect(() {
      //si estado es pendiente saca la modal
      firestore.collection(FirestorePaths.userPetitionCollection(uidUser)).snapshots().listen((querySnapshot) {
        numElementos = querySnapshot.docs.length;
        for (var element in querySnapshot.docs) {
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
        }

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
    var gl = LocalizationService.instance.isGl(context);

    String todosLosDias = (gl) ? 'Todos os días' : 'Todos los días';

    var checkList = [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
      ''
    ];
    var daysList = (gl)
        ? [
      'Luns',
      'Martes',
      'Mércores',
      'Xoves',
      'Venres',
      'Sábado',
      'Domingo',
      'Todos os días'
    ]
        : [
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
      'Domingo',
      'Todos los días'
    ];

    var filtradoVacio = true;
    if(GetStorage().read('filterDayInt') == null){
      GetStorage().write('filterDayInt', 7);
    }
    return Column(
      children: [
        Container(
          color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
              ? AppColors.lightThemePrimary.withOpacity(0.7)
              : AppColors.darkThemePrimary.withOpacity(0.7), // Light gray background color
          padding: EdgeInsets.symmetric(horizontal: 16.0), // Optional padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                child: CustomText.h3(context, daysList[GetStorage().read('filterDayInt') ?? 7]),
                onPressed: () {
                  showAlertDias(context, ref);
                },
              ),
              (GetStorage().read('filterDayInt') != 7)
                  ? IconButton(
                alignment: Alignment.centerRight,
                onPressed: () {
                  ref.watch(selectFilterProvider.notifier).clean();
                  GetStorage().write('filterDayInt', 7);
                  AppDialogs.showInfo(context,
                      message: tr(context).delete_filter);
                },
                icon: Icon(
                  Icons.delete_outline_outlined,
                  color: Theme.of(context).textTheme.headline3?.color,
                ),
              )
                  : const SizedBox()
            ],
          ),
        ),

      Expanded( child: taskToDoStreamAll.when(
      data: (taskToDo) {
        taskToDo = sortTasksByBegin(taskToDo);
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
            var chooseDay = GetStorage().read('filterDayInt');
            if(chooseDay == 7){ //todos los días
              filtradoVacio = false;
              list.add(
                  CardItemComponent(
                    taskModel: taskToDo[index],
                  ));
            } else {
              if(taskToDo[index].days!.contains(checkList[chooseDay])){
                filtradoVacio = false;
                list.add(
                    CardItemComponent(
                      taskModel: taskToDo[index],
                    ));
              }
            }
            if(index == taskToDo.length -1 && filtradoVacio){
              list.add(CustomText.h4(
                context,
                tr(context).noTask,
                color: AppColors.grey,
                alignment: Alignment.center,
              ));
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
                          ref.refresh(getTasks);
                        })
                  ]),
      loading: () => LoadingIndicators.instance.smallLoadingAnimation(context)
      )
    )
    ]);
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
      content: CustomText.h3(context,tr(context).user_wants),
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

  void setNotificationsFirstTime(List<TaskModel> listTasks){
    log('*** primera vez');
    listTasks.forEach((task) {
      log('*** primera vez ${task.taskName}');
      if (task.done == StorageKeys.falso) {
        Notifications().setNotification(task);
      }
    });

    GetStorage().write('firstTimeLogIn', false);
  }



}