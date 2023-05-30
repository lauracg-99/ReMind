import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/storage_keys.dart';
import '../../../data/tasks/models/task_model.dart';
import '../../../data/tasks/providers/task_provider.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../widgets/buttons/custom_text_button.dart';
import '../../widgets/card_button_component.dart';
import '../../widgets/card_user_details_component.dart';
import '../../widgets/custom_text.dart';
import 'card_red_button_component.dart';

class CardItemComponent extends ConsumerWidget {

  const CardItemComponent({
    required this.taskModel,
    Key? key,
  }) : super(key: key);

  final TaskModel taskModel;

  @override
  Widget build(BuildContext context, ref) {
    //var taskProvider = ref.watch(tasksRepoProvider);
    return Card(
      elevation: 6,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Sizes.cardRadius(context)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Sizes.cardVPadding(context),
          horizontal: Sizes.cardHRadius(context),
        ),
        child: Column(
          children: [
            SizedBox(
              height: Sizes.vMarginSmallest(context),
            ),
            //NOMBRE Y FOTO
            CardUserDetailsComponent(
              taskModel: taskModel,
            ),
            SizedBox(
              height: Sizes.vMarginComment(context),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //modificar supervisado
                (taskModel.editable == StorageKeys.verdadero)
                ? CardButtonComponent(
                  title: tr(context).mod,
                  isColored: false,
                  onPressed: () {
                    //IR A PANTALLA DE MODIFICACION DE LA TAREA
                    //TODO
                    NavigationService.push(
                      context,
                      isNamed: true,
                      page: RoutePaths.modScreen,
                      arguments: taskModel
                    );

                  },
                )
                : const SizedBox(),

                (taskModel.editable == StorageKeys.verdadero)
                    ?SizedBox(width: Sizes.hMarginSmall(context),)
                    : SizedBox(),

                //hecho
                (taskModel.done != StorageKeys.verdadero && taskModel.editable == StorageKeys.verdadero)
                  ? CardButtonComponent(
                  title: tr(context).done,
                  isColored: true,
                  onPressed: () {
                    showAlertDialogCheck(context,ref);
                  },
                )
                  : SizedBox(),
                //hecho supervisor
                (taskModel.done != StorageKeys.verdadero && taskModel.editable == StorageKeys.falso)
                    ? CardButtonComponent(
                  title: tr(context).done,
                  isColored: true,
                  onPressed: () {

                    showAlertDialogCheck(context,ref);

                  },
                )
                    : SizedBox(),

                //borrar supervisado DONE
                  (taskModel.editable == StorageKeys.verdadero && taskModel.done == StorageKeys.verdadero)
                      ? CardRedButtonComponent(
                    title: tr(context).delete,
                    isColored: false,
                    onPressed: () {
                      showAlertDialogDelete(context,ref);
                    },
                  )
                      : const SizedBox(),
              ],
            ),
            SizedBox(
              height: Sizes.vMarginSmallest(context),
            ),

            //delete
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [(
                //borrar supervisado
                    (taskModel.editable == StorageKeys.verdadero && taskModel.done == StorageKeys.falso)
                      ? CardRedButtonComponent(
                        title: tr(context).delete,
                        isColored: false,
                        onPressed: () {
                          //TODO
                          showAlertDialogDelete(context,ref);
                          //ref.watch(notiControlProvider.notifier).deleteNotiControlWT(taskModel: taskModel);
                          //ref.read(taskProvider.notifier).deleteSingleTask(taskModel: taskModel);
                       },
                      )
                      : const SizedBox()),

                      (taskModel.editable == StorageKeys.verdadero && taskModel.done == StorageKeys.verdadero)
                        ? CardButtonComponent(
                      title: 'Deshacer', //todo: tr
                      isColored: false,
                      onPressed: () {
                        ref.read(taskProvider.notifier).unCheckTask(context,taskModel);
                      },
                    )
                        : const SizedBox()
                ]
            )
          ],
        ),
      ),
    );
  }

  showAlertDialogCheck(BuildContext context, WidgetRef ref) {

    // set up the buttons
    Widget okButton = CustomTextButton(
      child: CustomText.h4(
          context,
          tr(context).oK,
          color: AppColors.blue
      ),
      onPressed:  () {
        if (taskModel.editable == StorageKeys.verdadero){
          ref.read(taskProvider.notifier).checkTask(context, taskModel);
        }else{
          ref.read(taskProvider.notifier).checkTaskBoss(context, taskModel);
        }

        NavigationService.goBack(context,rootNavigator: true);
      },
    );

    Widget cancelButton = CustomTextButton(
      child: CustomText.h4(
          context,
          tr(context).cancel,
          color: AppColors.red
      ),
      onPressed:  () {
        NavigationService.goBack(context,rootNavigator: true);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: CustomText.h2(context, tr(context).adv),
      content: CustomText.h3(context,tr(context).adv_done), // todo: tr
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

  showAlertDialogDelete(BuildContext context, WidgetRef ref) {
    // set up the buttons
    Widget okButton = CustomTextButton(
      child: CustomText.h4(
          context,
          tr(context).delete,
          color: AppColors.blue
      ),
      onPressed:  () {
        ref.read(taskProvider.notifier).deleteTask(context, taskModel);
        NavigationService.goBack(context,rootNavigator: true);
      },
    );

    Widget cancelButton = CustomTextButton(
      child: CustomText.h4(
          context,
          tr(context).cancel,
          color: AppColors.red
      ),
      onPressed:  () {
        NavigationService.goBack(context,rootNavigator: true);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: CustomText.h2(context, tr(context).adv),
      content: CustomText.h3(context,tr(context).adv_delete), // todo: tr
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
}
