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
import '../../components/card_item_component.dart';
import '../../providers/task_to_do.dart';

class CompletedTasks extends HookConsumerWidget {
  const CompletedTasks({Key? key}) : super(key: key);
//todo: info icon
  @override
  Widget build(BuildContext context, ref) {
    GetStorage().write('screen','complete');
    final taskToDoStreamAll = ref.watch(getTasksDone);
    return taskToDoStreamAll.when(
        data: (taskDone) {
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
                    list.add(
                        CardItemComponent(
                          taskModel: taskDone[index],
                        ));
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
              SizedBox(height: Sizes.vMarginMedium(context),),
              CustomButton(
                  text: tr(context).recharge,
                  onPressed: (){
                    ref.refresh(getTasksDone);
                  })
            ]),
        loading: () =>
            LoadingIndicators.instance.smallLoadingAnimation(context));
  }
}
