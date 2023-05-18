import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind/presentation/tasks/components/repe_noti_component.dart';
import 'package:remind/presentation/tasks/components/switch_setting_section_component.dart';
import 'package:remind/presentation/tasks/components/time_picker_component.dart';
import '../../../common/storage_keys.dart';
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
import '../../widgets/loading_indicators.dart';
import '../providers/multi_choice_provider.dart';
import '../providers/repe_noti_provider.dart';
import '../providers/task_provider.dart';
import '../providers/time_range_picker_provider.dart';
import '../providers/toggle_theme_provider.dart';
import '../utils/utilities.dart';
import 'card_red_button_component.dart';


class ToggleChoiceComponent extends ConsumerWidget {
  ToggleChoiceComponent( {required this.context,required this.taskModel,Key? key})
      : super(key: key);

  final TaskModel taskModel;
  BuildContext context;

  @override
  Widget build(BuildContext context, ref) {
    final toggleValue = ref.watch(toggleButtonProviderAdd);
    var taskRepo = ref.watch(taskProvider.notifier);
    var days = ref.read(selectDaysMultiChoice.notifier);
    var range = ref.read(timeRangeButtonProvider.notifier);
    var repetitions = ref.read(timeRepetitionProvider.notifier);


    return Container(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          //eleccion días
          (toggleValue == 0)
            ? Card(
              shadowColor: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                  ? AppColors.lightThemePrimary
                  : AppColors.darkThemePrimary,
                  elevation: 6,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Sizes.cardRadius(context)),
                  ),
                  child: Column(

                      children:[
                        SizedBox(
                          height: Sizes.vMarginSmall(context),
                        ),
                        //SizedBox(height: Sizes.vMarginSmallest(context),),
                        ChooseDaySectionComponent([]),

                        SizedBox(height: Sizes.vMarginMedium(context),),

                        Row(
                            children: [
                              SizedBox(width: Sizes.vMarginHighest(context)*1.2,),
                              CupertinoButton(
                                  child: CustomText.h4(context,'Cancelar',color: AppColors.red),
                                  onPressed: (){
                                    NavigationService.goBack(context,rootNavigator: true);
                                  }),
                              SizedBox(width: Sizes.vMarginHighest(context)*3.3,),
                              Consumer(
                                  builder: (context, ref, child) {
                                    final taskLoading = ref.watch(
                                      taskProvider.select((state) =>
                                          state.maybeWhen(loading: () => true, orElse: () => false)),
                                    );
                                    return taskLoading
                                        ? LoadingIndicators.instance.smallLoadingAnimation(
                                      context,
                                      width: Sizes.loadingAnimationButton(context),
                                      height: Sizes.loadingAnimationButton(context),
                                    )
                                  : CupertinoButton(
                                  child: CustomText.h4(context,'Ok',

                                    color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                                      ? AppColors.accentColorLight
                                      : AppColors.darkThemeIconColor,),
                                  onPressed: () async {
                                    //para luego poder cancelar las notificaciones
                                    //si no es supervisor activamos las notis
                                    if(GetStorage().read('uidSup') != ''){
                                      //disp boss no hay notis
                                      //taskRepo.cancelNotification(taskModel.idNotification!);
                                      taskRepo.updateTaskBoss(context,{
                                        'idNotification': [],
                                        'days': saveDays(days.tags.toString()),
                                        'lastUpdate': Timestamp.fromDate(DateTime.now()),
                                        'isNotificationSet': StorageKeys.falso,},
                                          taskId: taskModel.taskId
                                      );
                                    }else{
                                      //se cambian días, borramos notificacion y cambiamos días, si es oneTime y su ultima mod
                                      taskRepo.cancelNotification(taskModel.idNotification!);
                                      taskRepo.updateTask(context,{
                                        'days': saveDays(days.tags.toString()),
                                        'lastUpdate': Timestamp.fromDate(DateTime.now()),
                                        'isNotificationSet': StorageKeys.falso,
                                      },
                                          taskId: taskModel.taskId
                                      );
                                    }
                                  });
                                  })
                            ]
                        ),



                      ])
          )
          : SizedBox(),
          //eleccion rango
          (toggleValue == 1)
              ? Card(
              elevation: 6,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(Sizes.cardRadius(context)),
              ),
              child: Container(

                  child: Card(
                    elevation: 6,
                      shadowColor: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                          ? AppColors.lightThemePrimary
                          : AppColors.darkThemePrimary,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(Sizes.cardRadius(context)),
                    ),
                    child: Column(children:[
                      TimePickerComponent('${taskModel.begin!} - ${taskModel.end!}'),
                      SizedBox(height: Sizes.vMarginMedium(context),),

                      Row(
                          children: [
                            SizedBox(width: Sizes.vMarginHighest(context)*1.2,),
                            CupertinoButton(
                                child: CustomText.h4(context,'Cancelar',color: AppColors.red),
                                onPressed: (){
                                  NavigationService.goBack(context,rootNavigator: true);
                                }),
                            SizedBox(width: Sizes.vMarginHighest(context)*3.3,),
                            Consumer(
                                builder: (context, ref, child) {
                                  final taskLoading = ref.watch(
                                    taskProvider.select((state) =>
                                        state.maybeWhen(loading: () => true, orElse: () => false)),
                                  );
                                  return taskLoading
                                      ? LoadingIndicators.instance.smallLoadingAnimation(
                                    context,
                                    width: Sizes.loadingAnimationButton(context),
                                    height: Sizes.loadingAnimationButton(context),
                                  )
                                      : CupertinoButton(
                                child: CustomText.h4(context,'Ok',color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                                    ? AppColors.accentColorLight
                                    : AppColors.darkThemeIconColor),
                                onPressed: (){
                                  if(GetStorage().read('uidSup') != ''){
                                    //disp boss no hay notis
                                    //taskRepo.cancelNotification(taskModel.idNotification!);
                                    taskRepo.updateTaskBoss(context,{
                                      'begin': range.getIniHour(),
                                      'end': range.getfinHour(),
                                      'idNotification': [],
                                      'lastUpdate': Timestamp.fromDate(DateTime.now()),
                                      'isNotificationSet': StorageKeys.falso,
                                    },
                                        taskId: taskModel.taskId
                                    );

                                  }else{
                                    //se cambian días, borramos notificacion y cambiamos días, si es oneTime y su ultima mod
                                    taskRepo.cancelNotification(taskModel.idNotification!);
                                    taskRepo.updateTask(context,{
                                      'begin': range.getIniHour(),
                                      'end': range.getfinHour(),
                                      'lastUpdate': Timestamp.fromDate(DateTime.now()),
                                      'isNotificationSet': StorageKeys.falso,
                                    },
                                        taskId: taskModel.taskId
                                    );

                                  }
                                });})
                          ]
                      ),
                    ])
                  )),
          )
              : SizedBox(),
          //eleccion de repeticion
          (toggleValue == 2)
              ? Card(
            elevation: 6,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(Sizes.cardRadius(context)),
            ),
            child: Container(
                child: Card(
                  elevation: 6,
                  shadowColor: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                      ? AppColors.lightThemePrimary
                      : AppColors.darkThemePrimary,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(Sizes.cardRadius(context)),
                  ),
                  child: Column(children:[
                    RepeNotiComponent(modo: 'mod',),
                    SizedBox(height: Sizes.vMarginMedium(context),),

                    Row(
                        children: [
                          SizedBox(width: Sizes.vMarginHighest(context)*1.2,),
                          CupertinoButton(
                              child: CustomText.h4(context,'Cancelar',color: AppColors.red),
                              onPressed: (){
                                NavigationService.goBack(context,rootNavigator: true);
                              }),
                          SizedBox(width: Sizes.vMarginHighest(context)*3.3,),
                          Consumer(
                              builder: (context, ref, child) {
                                final taskLoading = ref.watch(
                                  taskProvider.select((state) =>
                                      state.maybeWhen(loading: () => true, orElse: () => false)),
                                );
                                return taskLoading
                                    ? LoadingIndicators.instance.smallLoadingAnimation(
                                  context,
                                  width: Sizes.loadingAnimationButton(context),
                                  height: Sizes.loadingAnimationButton(context),
                                )
                                    : CupertinoButton(
                                    child: CustomText.h4(context,'Ok',color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                                        ? AppColors.accentColorLight
                                        : AppColors.darkThemeIconColor),
                                    onPressed: (){
                                      if(GetStorage().read('uidSup') != ''){

                                        log('**** TOGGLE CHOICE REPETITION ${repetitions.getHr()}');
                                        /*notiHours: notiHours(range.getIniHour(),
                                            range.getfinHour(), repetitions.getBt()),*/
                                        if(range.getIniHour() != taskModel.begin || range.getfinHour() != taskModel.end){
                                          log('**** error');
                                        } else {
                                          taskRepo.updateTaskBoss(context,{
                                            'idNotification': [],
                                            'lastUpdate': Timestamp.fromDate(DateTime.now()),
                                            'isNotificationSet': StorageKeys.falso,
                                            'numRepetition' : repetitions.getBoth()
                                          }, taskId: taskModel.taskId
                                          );
                                        }

                                } else {
                                        if(range.getIniHour() != taskModel.begin || range.getfinHour() != taskModel.end){
                                          log('**** error2');
                                        } else{
                                          taskRepo.updateTask(context,{
                                            'idNotification': [],
                                            'lastUpdate': Timestamp.fromDate(DateTime.now()),
                                            'isNotificationSet': StorageKeys.falso,
                                            'numRepetition' : repetitions.getBoth()
                                          }, taskId: taskModel.taskId
                                          );
                                        }

                                      }
                              });})
                        ]
                    ),
                  ]),
                )),
          )
              : SizedBox(),
          SizedBox(
            height: Sizes.vMarginMedium(context),
          ),
        ]));
  }

  static List<String> daysList = [
    "Lunes",
    "Martes",
    "Miércoles",
    "Jueves",
    "Viernes",
    "Sábado",
    "Domingo",
    "Todos los días"
  ];

  // multiple choice value
  List<String> tags = [];

  List<dynamic> sortDay(List<String> selectedDia) {
    List<dynamic> numbers = [];

    for (var element in selectedDia) {
      numbers.add(mapDays[element]);
    }
    numbers.sort();
    return numbers;
  }


  List<String> getDiasString(List<dynamic> numeros) {
    List<String> tags = [];
    numeros.forEach((element) {
      //print(element.toString());
      if (element < 8) {
        //va de 0..7 no de 1..8
        tags.add(daysList.elementAt(element - 1));
      } else {
        tags.add("Todos los días");
      }
    });
    return tags;
  }

  static Map<String, dynamic> mapDays = {
    "Lunes": 1,
    "Martes": 2,
    "Miércoles": 3,
    "Jueves": 4,
    "Viernes": 5,
    "Sábado": 6,
    "Domingo": 7,
    "Todos los días": 8
    //"Todos los días"
  };
}
