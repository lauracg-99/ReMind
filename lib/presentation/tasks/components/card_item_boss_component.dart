import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/data/tasks/providers/task_provider.dart';
import '../../../common/storage_keys.dart';
import '../../../data/tasks/models/task_model.dart';
import '../../../domain/services/localization_service.dart';
import '../../notifications/utils/notification_utils.dart';
import '../../routes/navigation_service.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../widgets/buttons/custom_text_button.dart';
import '../../widgets/card_button_component.dart';
import '../../widgets/card_user_details_component.dart';
import '../../widgets/custom_text.dart';
import 'card_red_button_component.dart';


class CardItemBossComponent extends ConsumerWidget {

  const CardItemBossComponent({
    required this.taskModel,
    Key? key,
  }) : super(key: key);

  final TaskModel taskModel;

  @override
  Widget build(BuildContext context, ref) {
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
              height: Sizes.vMarginSmall(context),
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
                // borrar supervisor
                CardRedButtonComponent(
                  title: tr(context).delete,
                  isColored: false,
                  onPressed: () {
                    showAlertDialogDelete(context,ref);
                  },
                ),
                SizedBox(width: Sizes.hMarginSmall(context)),
                //está hecha o no
                  (taskModel.done == StorageKeys.verdadero)
                    ? CardButtonComponent(
                  title: 'Deshacer', // TODO: tr
                  isColored: false,
                  onPressed: () {
                    showAlertDialogUnCheck(context, ref);
                  },
                )
                    :const SizedBox()
              ],
            ),

        ]),
      ),
    );
  }

  showAlertDialogUnCheck(BuildContext context, WidgetRef ref) {

    // set up the buttons
    Widget okButton = CustomTextButton(
      child: CustomText.h4(
          context,
          tr(context).oK,
          color: AppColors.blue
      ),
      onPressed:  () {
        ref.read(taskProvider.notifier).unCheckTaskBoss(context, taskModel).then((value) async {
          await NotificationUtils.setNotiStateFB(GetStorage().read(StorageKeys.lastUIDSup), taskModel.taskId, 'false');
        });
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
      content: CustomText.h3(context,tr(context).adv_undo),
      actions: [
        cancelButton,
        okButton,
      ],
      shape: const RoundedRectangleBorder(
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
        ref.watch(taskProvider.notifier).deleteTask(context,taskModel);
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
      content: CustomText.h3(context,tr(context).adv_delete),
      actions: [
        cancelButton,
        okButton,

      ],
      shape: const RoundedRectangleBorder(
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
