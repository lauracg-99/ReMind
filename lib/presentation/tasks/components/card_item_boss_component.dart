import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/tasks/models/task_model.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../widgets/buttons/custom_text_button.dart';
import '../../widgets/card_button_component.dart';
import '../../widgets/card_user_details_component.dart';
import '../../widgets/custom_text.dart';
import '../providers/task_provider.dart';
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
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CardButtonComponent(
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
                ),

                // borrar supervisor
                CardRedButtonComponent(
                  title: tr(context).delete,
                  isColored: false,
                  onPressed: () {

                    showAlertDialogDelete(context,ref);
                    },
                )
              ],
            ),
          (taskModel.done == 'true')
                ? SizedBox(
            height: Sizes.vMarginSmallest(context),
          )
          : SizedBox(),
          (taskModel.done == 'true')
          //desmarcar el hecho
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CardButtonComponent(
                    title: 'Deshacer',
                    isColored: false,
                    onPressed: () {
                      ref.read(taskProvider.notifier).undoCheckTaskBoss(taskModel: taskModel);
                    },
                  ),
                  ])
              : SizedBox()
        ]),
      ),
    );
  }

  showAlertDialogDelete(BuildContext context, ref) {
    // set up the buttons
    Widget okButton = CustomTextButton(
      child: CustomText.h4(
          context,
          tr(context).delete,
          color: AppColors.blue
      ),
      onPressed:  () {
        ref.read(taskProvider.notifier).checkDeleteNoti(taskModel: taskModel);

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
