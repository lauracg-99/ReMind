import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/data/auth/models/user_model.dart';
import 'package:remind/domain/auth/repo/user_repo.dart';
import 'package:remind/presentation/notifications/utils/notifications.dart';
import '../../../../common/storage_keys.dart';
import '../../../../data/auth/manage_supervised/solicitud.dart';
import '../../../../data/auth/models/supervised.dart';
import '../../../../data/firebase/repo/firebase_caller.dart';
import '../../../../data/firebase/repo/firestore_paths.dart';
import '../../../../domain/services/localization_service.dart';
import '../../../routes/navigation_service.dart';
import '../../../routes/route_paths.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/sizes.dart';
import '../../../utils/dialogs.dart';
import '../../../utils/filters.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/buttons/custom_text_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/loading_indicators.dart';
import '../../components/card_item_boss_component.dart';
import '../../components/filter_days_component.dart';
import '../../providers/filter_provider.dart';
import '../../providers/task_to_do.dart';
import '../../utils/utilities.dart';

class ShowSupervisorTasks extends HookConsumerWidget {
  const ShowSupervisorTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    GetStorage().write('screen', 'showBoss');
    var uidUser = GetStorage().read('uidUsuario');
    final firestore = ref.watch(firebaseProvider);
    final userProvider = ref.watch(userRepoProvider);

    final taskToDoStreamBoss = ref.watch(getTasksSup);
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
    if (GetStorage().read('filterDayInt') == null) {
      GetStorage().write('filterDayInt', 7);
    }
    List<Supervised> listaUsuarios =
        ref.watch(userRepoProvider).userModel?.supervisados ?? [];

    useEffect(() {
      //si estado es pendiente saca la modal
      firestore
          .collection(FirestorePaths.userPetitionCollection(uidUser))
          .snapshots()
          .listen((querySnapshot) {
        for (var change in querySnapshot.docChanges) {
          if (querySnapshot.docs.isNotEmpty) {
            //pasamos de pendiente a aceptada o rechazada
            if (change.type == DocumentChangeType.modified) {
              final modifiedDocument = change.doc;
              final documentId = modifiedDocument.id;
              final modifiedDocumentData = modifiedDocument.data();

              Solicitud solicitud = Solicitud.fromMap(modifiedDocumentData!);
              solicitud.id = documentId;

              GetStorage().write('notificarPeticion', false);

              if (solicitud.estado == 'aceptada') {
                log('addSupervisado');
                GetStorage().write('notificarPeticion', true);
                Notifications()
                    .statusPetitionNoti(context, solicitud, 'aceptado');
                userProvider.addNewSupervisedByUID(solicitud.uidSup);
                userProvider.getUserData(solicitud.uidBoss);
                managePetition(context, ref, solicitud: solicitud);
              }

              if (solicitud.estado == 'borrar') {
                solicitud.id = documentId;
                log('solicitud ${solicitud.id} ${solicitud.emailSup} ${solicitud.estado} ${solicitud.emailBoss} ${documentId}');
                ref.watch(userRepoProvider).deletePetition(solicitud);
                userProvider.getUserData(solicitud.uidBoss);
              }

              if (solicitud.estado == 'rechazado') {
                GetStorage().write('notificarPeticion', true);
                Notifications()
                    .statusPetitionNoti(context, solicitud, 'rechazado');
                //borramos la petición
              }
            }
          }
        }
      });
    }, []);
    return Column(children: [
      Container(
        color:
            Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                ? AppColors.lightThemePrimary.withOpacity(0.7)
                : AppColors.darkThemePrimary.withOpacity(0.7),
        // Light gray background color
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        // Optional padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: CustomText.h3(
                  context, daysList[GetStorage().read('filterDayInt') ?? 7]),
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
      Expanded(
          child: taskToDoStreamBoss.when(
              data: (taskToDo) {
                taskToDo = sortTasksByBegin(taskToDo);
                return (listaUsuarios.isEmpty)
                    ? CustomText.h4(
                        context,
                        tr(context).warn_add_sup,
                        color: AppColors.grey,
                        alignment: Alignment.center,
                        textAlign: TextAlign.center,
                      )
                    : (taskToDo.isEmpty)
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
                            separatorBuilder: (context, index) => SizedBox(
                              height: Sizes.vMarginHigh(context),
                            ),
                            itemCount: taskToDo.length,
                            itemBuilder: (context, index) {
                              List<Widget> list = [];
                              //CardItemBossComponent
                              var chooseDay = GetStorage().read('filterDayInt');
                              if (chooseDay == 7) {
                                //todos los días
                                filtradoVacio = false;
                                list.add(CardItemBossComponent(
                                  taskModel: taskToDo[index],
                                ));
                              } else {
                                if (taskToDo[index]
                                    .days!
                                    .contains(checkList[chooseDay])) {
                                  filtradoVacio = false;
                                  list.add(CardItemBossComponent(
                                    taskModel: taskToDo[index],
                                  ));
                                }
                              }
                              if (index == taskToDo.length - 1 &&
                                  filtradoVacio) {
                                list.add(CustomText.h4(
                                  context,
                                  tr(context).noTask,
                                  color: AppColors.grey,
                                  alignment: Alignment.center,
                                ));
                              }

                              return Column(children: list);
                            },
                          );
              },
              error: (err, stack) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: (listaUsuarios.isEmpty)
                      ? [
                          CustomText.h4(
                            context,
                            tr(context).warn_add_sup,
                            color: AppColors.grey,
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                          )
                        ]
                      : [
                          CustomText.h4(
                            context,
                            '${tr(context).somethingWentWrong}\n${tr(context).pleaseTryAgainLater}',
                            color: AppColors.grey,
                            alignment: Alignment.center,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: Sizes.vMarginMedium(context),
                          ),
                          CustomButton(
                              text: tr(context).recharge,
                              onPressed: () {
                                ref.refresh(getTasksSup);
                              })
                        ]),
              loading: () =>
                  LoadingIndicators.instance.smallLoadingAnimation(context)))
    ]);
  }

  void managePetition(BuildContext context, WidgetRef ref,
      {required Solicitud solicitud}) {
    // set up the buttons
    Widget okButton = CustomTextButton(
      child: CustomText.h4(context, tr(context).acept, color: AppColors.blue),
      onPressed: () {
        //checkTask( context,taskModel: taskModel);
        NavigationService.goBack(context, rootNavigator: true);
        solicitud.estado = 'borrar';
        ref.watch(userRepoProvider).updatePetition(solicitud);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: CustomText.h2(context, tr(context).adv),
      content: CustomText.h3(context,
          "${tr(context).acept_pre_peti} ${solicitud.emailSup} ${tr(context).acept_peti}"),
      actions: [
        okButton,
      ],
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
