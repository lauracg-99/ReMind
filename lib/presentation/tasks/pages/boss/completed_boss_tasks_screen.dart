import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../common/storage_keys.dart';
import '../../../../data/auth/models/supervised.dart';
import '../../../../data/auth/models/user_model.dart';
import '../../../../domain/auth/repo/user_repo.dart';
import '../../../../domain/services/localization_service.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/sizes.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/loading_indicators.dart';
import '../../components/card_item_boss_component.dart';
import '../../providers/task_to_do.dart';
import '../../utils/utilities.dart';


class CompletedBossTasks extends HookConsumerWidget {
  const CompletedBossTasks({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    GetStorage().write('screen','completeBoss');
    final taskToDoStreamAllCompleted = ref.watch(getTasksSupDone);
    List<Supervised> listaUsuarios = ref.watch(userRepoProvider).userModel?.supervisados ?? [];
    return taskToDoStreamAllCompleted.when(
        data: (taskToDo) {
          taskToDo = sortTasksByBegin(taskToDo);
          return (listaUsuarios.isEmpty)
              ? CustomText.h4(
                  context,
                  'Necesita añadir supervisados\npara poder usar esta cuenta', // TODO: tr
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
                      separatorBuilder: (context, index) => SizedBox(height: Sizes.vMarginHigh(context),),
                      itemCount: taskToDo.length,
                      itemBuilder: (context, index) {
                        List<Widget> list = [];
                        list.add(CardItemBossComponent(taskModel: taskToDo[index],));
                        return Column(children: list);
                      },

              );
        },
        error: (err, stack) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
            (listaUsuarios.isEmpty)
                ? [CustomText.h4(
              context,
              'Necesita añadir supervisados\npara poder usar esta cuenta', // TODO: tr
              color: AppColors.grey,
              alignment: Alignment.center,
              textAlign: TextAlign.center,
            )]
                : [
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
                    ref.refresh(getTasksSupDone);
                  })
            ]),
        loading: () => LoadingIndicators.instance.smallLoadingAnimation(context)


    );
  }
}
