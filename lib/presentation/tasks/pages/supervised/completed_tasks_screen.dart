import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../common/storage_keys.dart';
import '../../../../domain/services/localization_service.dart';
import '../../../routes/navigation_service.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/sizes.dart';
import '../../../utils/dialogs.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/buttons/custom_text_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/loading_indicators.dart';
import '../../components/card_item_component.dart';
import '../../components/filter_days_component.dart';
import '../../providers/filter_provider.dart';
import '../../providers/task_to_do.dart';
import '../../utils/utilities.dart';

class CompletedTasks extends HookConsumerWidget {
  const CompletedTasks({Key? key}) : super(key: key);

//todo: info icon
  @override
  Widget build(BuildContext context, ref) {
    GetStorage().write('screen', 'complete');
    var gl = LocalizationService.instance.isGl(context);

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

    final taskToDoStreamAll = ref.watch(getTasksDone);
    return Column(children: [
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
            IconButton(
              alignment: Alignment.centerRight,
              onPressed: () {
                ref.watch(selectFilterProvider.notifier).clean();
                GetStorage().write('filterDayInt', 7);
                AppDialogs.showInfo(context, message: tr(context).delete_filter);
              },
              icon: Icon(
                Icons.delete_outline_outlined,
                color: Theme.of(context).textTheme.headline3?.color,
              ),
            )
          ],
        ),
      ),
      Expanded(
          child: taskToDoStreamAll.when(
              data: (taskDone) {
                taskDone = sortTasksByBegin(taskDone);
                return (taskDone.isEmpty)
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
                        itemCount: taskDone.length,
                        itemBuilder: (context, index) {
                          List<Widget> list = [];
                          var chooseDay = GetStorage().read('filterDayInt');
                          if (chooseDay == 7) {
                            //todos los días
                            filtradoVacio = false;
                            list.add(CardItemComponent(
                              taskModel: taskDone[index],
                            ));
                          } else {
                            if (taskDone[index]
                                .days!
                                .contains(checkList[chooseDay])) {
                              filtradoVacio = false;
                              list.add(CardItemComponent(
                                taskModel: taskDone[index],
                              ));
                            } else {}
                          }
                          if (index == taskDone.length - 1 && filtradoVacio) {
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
                      children: [
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
                              ref.refresh(getTasksDone);
                            })
                      ]),
              loading: () =>
                  LoadingIndicators.instance.smallLoadingAnimation(context)))
    ]);
  }

  showAlertDias(BuildContext context, WidgetRef ref) {
    // set up the buttons
    Widget okButton = CustomTextButton(
      child: CustomText.h4(context, tr(context).oK, color: AppColors.blue),
      onPressed: () {
        //ref.watch(taskProvider.notifier).deleteTask(context,taskModel);
        var day = ref.watch(selectFilterProvider);
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
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              FilterDaysComponent(),
            ]))
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
}
