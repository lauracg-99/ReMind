import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../common/storage_keys.dart';
import '../../../../domain/services/localization_service.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/sizes.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/loading_indicators.dart';
import '../../components/card_item_boss_component.dart';
import '../../providers/task_to_do.dart';


class ShowSupervisorTasks extends HookConsumerWidget {
  const ShowSupervisorTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    GetStorage().write('screen','showBoss');
    final taskToDoStreamAllBoss = ref.watch(taskMultipleToDoStreamProviderBoss);

     int numeroListaCon = 0;
     int numeroListaSin = 0;

    //por alguna razon solo funciona si hacemos lista de tareas pero no con un
    // provider individual -> ns pq
    return taskToDoStreamAllBoss.when(
        data: (taskToDo) {
          return (taskToDo[0].isEmpty)
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
                itemCount: taskToDo[0].length,
                itemBuilder: (context, index) {
                  List<Widget> list = [];
                  if((taskToDo[0][index].cancelNoti != StorageKeys.verdadero)) {
                    numeroListaCon += 1;
                      list.add(CardItemBossComponent(
                        taskModel: taskToDo[0][index],
                      ));
                  } else {
                    numeroListaSin += 1;
                  }

                  return  (numeroListaSin == taskToDo[0].length)
                      ? CustomText.h4(
                          context,
                          tr(context).noTask,
                          color: AppColors.grey,
                          alignment: Alignment.center,
                       )
                    : Column(children: list);
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
                ref.refresh(taskMultipleToDoCompleteStreamProviderBoss);
                ref.refresh(taskMultipleToDoStreamProviderBoss);
              })
        ]),
        loading: () => LoadingIndicators.instance.smallLoadingAnimation(context)
    );
  }
}
