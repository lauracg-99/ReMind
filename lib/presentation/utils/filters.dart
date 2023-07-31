import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/services/localization_service.dart';
import '../routes/navigation_service.dart';
import '../styles/app_colors.dart';
import '../tasks/components/filter_days_component.dart';
import '../tasks/providers/filter_provider.dart';
import '../widgets/buttons/custom_text_button.dart';
import '../widgets/custom_text.dart';

showAlertDias(BuildContext context, WidgetRef ref) {
  // set up the buttons
  Widget okButton = CustomTextButton(
    child: CustomText.h4(context, tr(context).oK, color: AppColors.blue),
    onPressed: () {
      //ref.watch(taskProvider.notifier).deleteTask(context,taskModel);
      var day = ref.watch(selectFilterProvider);
      log('@@@ days log $day');
      GetStorage().write('filterDayInt', day);
      NavigationService.goBack(context, rootNavigator: true);
    },
  );

  Widget cancelButton = CustomTextButton(
    child: CustomText.h4(context, tr(context).cancel, color: AppColors.red),
    onPressed: () {
      NavigationService.goBack(context, rootNavigator: true);
    },
  );
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child:  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    FilterDaysComponent(),

                  ])
          )
        ]),
    actions: [
      cancelButton,
      okButton,
    ],
    shape: const RoundedRectangleBorder(
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
