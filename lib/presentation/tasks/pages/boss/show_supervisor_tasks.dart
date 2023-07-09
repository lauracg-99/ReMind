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
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/buttons/custom_text_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/loading_indicators.dart';
import '../../components/card_item_boss_component.dart';
import '../../providers/task_to_do.dart';


class ShowSupervisorTasks extends HookConsumerWidget {
  const ShowSupervisorTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    GetStorage().write('screen','showBoss');
    var uidUser = GetStorage().read('uidUsuario');
    var email = GetStorage().read('email');
    final firestore = ref.watch(firebaseProvider);
    final userProvider = ref.watch(userRepoProvider);

    final taskToDoStreamBoss = ref.watch(getTasksSup);

   List<Supervised> listaUsuarios = ref.watch(userRepoProvider).userModel?.supervisados ?? [];

    useEffect(() {
      //si estado es pendiente saca la modal
      firestore.collection(FirestorePaths.userPetitionCollection(uidUser)).snapshots().listen((querySnapshot) {

        querySnapshot.docChanges.forEach((change) {
          if (querySnapshot.docs.isNotEmpty) {
            //pasamos de pendiente a aceptada o rechazada
            if (change.type == DocumentChangeType.modified) {
              final modifiedDocument = change.doc;
              final documentId = modifiedDocument.id;
              final modifiedDocumentData = modifiedDocument.data();

              Solicitud solicitud = Solicitud.fromMap(modifiedDocumentData!);
              solicitud.id = documentId;

              GetStorage().write('notificarPeticion', false);

              if (solicitud.estado == 'aceptada'){
                log('addSupervisado');
                GetStorage().write('notificarPeticion', true);
                Notifications().statusPetitionNoti(context,solicitud, 'aceptado');
                userProvider.addNewSupervisedByUID(solicitud.uidSup);
                managePetition(context, ref, solicitud: solicitud);
              }

              if (solicitud.estado == 'borrar') {
                solicitud.id = documentId;
                log('solicitud ${solicitud.id} ${solicitud
                    .emailSup} ${solicitud.estado} ${solicitud
                    .emailBoss} ${documentId}');
                ref.watch(userRepoProvider).deletePetition(solicitud);

              }

              if (solicitud.estado == 'rechazado'){
                GetStorage().write('notificarPeticion', true);
                Notifications().statusPetitionNoti(context, solicitud, 'rechazado');
                //borramos la petición
              }
            }
          }
        });
      });
    }, []);

    return taskToDoStreamBoss.when(
        data: (taskToDo) {
          return (listaUsuarios.isEmpty)
                ? CustomText.h4(
                  context,
                  'Necesita añadir supervisados' + '\n' + 'para poder usar esta cuenta',
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
                      separatorBuilder: (context, index) =>
                          SizedBox(height: Sizes.vMarginHigh(context),),
                      itemCount: taskToDo.length,
                      itemBuilder: (context, index) {
                        List<Widget> list = [];
                        list.add(
                            CardItemBossComponent(
                          taskModel: taskToDo[index],
                        ));
                        return  Column(children: list);
                  },

                );
        },
        error: (err, stack) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
            (listaUsuarios.isEmpty)
                ? [CustomText.h4(
                    context,
                    'Necesita añadir supervisados' + '\n' + 'para poder usar esta cuenta',
                    color: AppColors.grey,
                    alignment: Alignment.center,
                    textAlign: TextAlign.center,
                  )]
                : [
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
                ref.refresh(getTasksSup);
              })
        ]),
        loading: () => LoadingIndicators.instance.smallLoadingAnimation(context)
    );
  }

  void managePetition(BuildContext context, WidgetRef ref,
      {required Solicitud solicitud}) {
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
        solicitud.estado = 'borrar';
        ref.watch(userRepoProvider).updatePetition(solicitud);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: CustomText.h2(context, tr(context).adv),
      content: CustomText.h3(context,"${tr(context).acept_pre_peti} ${solicitud.emailSup} ${tr(context).acept_peti}"),
      actions: [
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
}
