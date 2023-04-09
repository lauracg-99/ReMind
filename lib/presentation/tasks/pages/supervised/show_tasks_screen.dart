import 'dart:developer';
import 'package:cron/cron.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../data/tasks/models/task_model.dart';
import '../../../../domain/services/localization_service.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/sizes.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/loading_indicators.dart';
import '../../components/card_item_component.dart';
import '../../providers/task_provider.dart';
import '../../providers/task_to_do.dart';

class ShowTasks extends HookConsumerWidget {
  const ShowTasks({Key? key}) : super(key: key);
  static bool supervisor = false;


  setSupervisor(bool set){
    supervisor = set;
  }
  @override
  Widget build(BuildContext context, ref) {

    GetStorage().write('screen','show');

    final taskToDoStreamAll = ref.watch(taskMultipleAll);

    if (GetStorage().read('rol') != 'supervisor') {
      setSupervisor(false);
    } else {
      setSupervisor(true);
    }
    final cron = Cron();
    //seteamos el crono una vez y si no somos supervisores

    if(!supervisor && GetStorage().read('CronSet') == 'false') {
      GetStorage().write('CronSet','true');
      // a las 00:00h se ejecutará esto todos los días
      cron.schedule(Schedule.parse('00 00 * * *'), () async {
        GetStorage().write('reset','true');
      });
    }

        return taskToDoStreamAll.when(
        data: (taskToDo) {
          if(GetStorage().read('reset') == 'true'){
            _resetTasks(ref, taskToDo);
          }
          return (taskToDo.isEmpty || (taskToDo[0].length == 0 && taskToDo[1].length == 0) )
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
            itemCount: taskToDo[0].length + taskToDo[1].length,
            itemBuilder: (context, index) {
              List<Widget> list = [];
              if(index != taskToDo[0].length + taskToDo[1].length) {
                      var supervised = taskToDo[0].length;
                      var boss = taskToDo[1].length;
                      // supervised es 2 -> index: 0,1
                      if (index < supervised) {
                        //supervisado
                        if(taskToDo[0][index].cancelNoti == 'true' && taskToDo[0][index].isNotificationSet == 'true'){
                          ref.read(taskProvider.notifier).deleteSingleTask(taskModel: taskToDo[0][index]);
                        }
                        list.add(CardItemComponent(
                          taskModel: taskToDo[0][index],
                        ));

                        //si la notificacion está desactivada y no somos supervisores
                        if ((taskToDo[0][index].isNotificationSet == 'false') && (!supervisor)) {
                          var selectTask = taskToDo[0][index];
                          //hacemos las notis y obtenemos su id
                          ref.read(taskProvider.notifier).setNotification(selectTask);
                          ref.read(taskProvider.notifier).updateNotificationInfo(task: selectTask);
                        }
                      } else {
                        if (index - supervised  < boss) {
                          var indexBoss = index - supervised;
                          // tengo que esperar a que este activada si no no borra nada y no se desactiva
                          if(taskToDo[1][indexBoss].cancelNoti == 'true' && taskToDo[1][indexBoss].isNotificationSet == 'true'){
                            log('**** entramos');
                            ref.read(taskProvider.notifier).deleteTaskbyBoss(taskModel: taskToDo[1][indexBoss]);
                          }
                          list.add(CardItemComponent(
                            taskModel: taskToDo[1][indexBoss],
                          ));
                          //si la notificacion está desactivada y no somos supervisores

                          if ((taskToDo[1][indexBoss].isNotificationSet == 'false') && (GetStorage().read('uidSup') == '')) {
                           // _taskRepo.checkSetNotiBoss(task: taskToDo[1][indexBoss]);
                            //de esta task
                            var selectTask = taskToDo[1][indexBoss];
                            ref.read(taskProvider.notifier).setNotification(selectTask);
                            ref.read(taskProvider.notifier).updateNotificationInfoBoss(task: selectTask);
                          }
                        }
                      }
                    }

                    return Column(children:list);
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
                        ref.refresh(taskMultipleToDoStreamProviderNOTDONE);
                        ref.refresh(taskMultipleToDoStreamProviderDONE);
                        ref.refresh(taskMultipleAll);
                      })
                ]),
    loading: () => LoadingIndicators.instance.smallLoadingAnimation(context)


    );
  }

  static void _resetTasks(WidgetRef ref, List<List<TaskModel>> taskToDo){
    for (var listas in taskToDo) {
      for (var element in listas) {
        if (element.done == 'true') {
          if(element.editable == 'true') {
            ref.watch(taskProvider.notifier).resetTask(task: element);
          } else {
            ref.watch(taskProvider.notifier).resetTaskBoss(task: element);
          }
        }
      }
    }
    GetStorage().write('reset','false');
    GetStorage().write('CronSet','false');
    ref.refresh(taskMultipleAll);
  }


}