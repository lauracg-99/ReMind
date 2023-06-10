import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../../common/storage_keys.dart';
import '../../../../data/tasks/models/task_model.dart';
import '../../../../data/tasks/providers/task_provider.dart';
import '../../../../domain/services/localization_service.dart';
import '../../../routes/navigation_service.dart';
import '../../../screens/popup_page_nested.dart';
import '../../../styles/app_colors.dart';
import '../../../styles/sizes.dart';
import '../../../utils/dialogs.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/buttons/custom_text_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/custom_tile_component.dart';
import '../../../widgets/loading_indicators.dart';
import '../../providers/multi_choice_provider.dart';
import '../../components/switch_setting_section_component.dart';
import '../../components/task_name_text_fields.dart';
import '../../components/time_picker_component.dart';
import '../../components/repe_noti_component.dart';
import '../../providers/name_task_provider.dart';
import '../../providers/repe_noti_provider.dart';
import '../../providers/time_range_picker_provider.dart';
import '../../utils/utilities.dart';

class AddTaskScreen extends HookConsumerWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    GetStorage().write('screen', 'add');
    //empezaría en true
    //var switchValue = !ref.watch(switchButtonProvider);
    var nameProvider = ref.read(nameTaskProvider.notifier);
    var days = ref.read(selectDaysMultiChoice.notifier);
    var range = ref.read(timeRangeButtonProvider.notifier);
    var repetitions = ref.read(timeRepetitionProvider.notifier);

    final nametaskFormKey = useMemoized(() => GlobalKey<FormState>());
    final nameController = useTextEditingController(text: '');

    final w = (MediaQuery.of(context).size.width)/ 3;
    Color red = Theme.of(context).inputDecorationTheme.errorBorder?.borderSide.color ?? Colors.redAccent;
    Color blue = Theme.of(context).inputDecorationTheme.focusColor ?? Colors.blue;

    if(GetStorage().read('listaDias') == null){
      GetStorage().write('listaDias',[]);
    }
//todo: info icon
    return PopUpPageNested(
      body: Flex(
          direction: Axis.vertical,
          children: [
      Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: Sizes.screenVPaddingDefault(context),
                horizontal: Sizes.screenHPaddingDefault(context),
              ),
              child: Column(
                children: <Widget>[
                  //nombre tarea
                  GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: Form(
                          key: nametaskFormKey,
                          child: NameTaskTextFieldsSection(
                            nameController: nameController,
                            onFieldSubmitted: (value) {
                              if (nametaskFormKey.currentState!.validate()) {
                                nameProvider.controllerName(nameController);
                              }
                            },
                          )
                      )

                  ),

                  SizedBox(
                    height: Sizes.vMarginSmallest(context),
                  ),
                  Wrap(
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                      alignment: WrapAlignment.center,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:[
                                GestureDetector(
                                    onTap: () {
                                      showAlertRepe(context, ref);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                                      child:Container(
                                        width: w,
                                        height: w,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.35),
                                              offset: const Offset(0, 3),
                                              blurRadius: 10,
                                            ),
                                          ],
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10.0),
                                          border: (repetitions.getBt() == '')
                                              ? Border.all(
                                            color: red,
                                            width: 2.0,
                                          )
                                              : Border.all(
                                            color: blue,
                                            width: 2.0,
                                          ),
                                        ),
                                        child:
                                        Center(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              final text = (repetitions.getBt() != '')
                                                  ? tiempo(repetitions.getBt())
                                                  : 'Elige cada cuanto repetir';
                                              final textStyle = TextStyle(
                                                color: Theme.of(context).textTheme.headline1?.color,
                                                fontSize: Sizes.fontSizes(context)['h3'],
                                              );

                                              final textWidget = Text(
                                                text,
                                                style: textStyle,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              );

                                              final textSpan = TextSpan(text: text, style: textStyle);
                                              final textPainter = TextPainter(
                                                text: textSpan,
                                                textDirection: TextDirection.ltr,
                                              );

                                              textPainter.layout();

                                              if (textPainter.width > constraints.maxWidth) {
                                                return SizedBox(
                                                  width: constraints.maxWidth,
                                                  child: textWidget,
                                                );
                                              } else {
                                                return textWidget;
                                              }
                                            },
                                          ),
                                        ),

                                      ),)
                                ),
                                GestureDetector(
                                    onTap: () {
                                      showAlertRangos(context, ref);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03), // Espacio de 8.0 puntos en todos los lados
                                      child:Container(
                                        width: w,
                                        height: w,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.35),
                                              offset: const Offset(0, 3),
                                              blurRadius: 10,
                                            ),
                                          ],
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10.0),
                                          border: ('${range.getIniHour()} - ${range.getfinHour()}' == '00:00 - 00:00')
                                              ? Border.all(
                                            color: red,
                                            width: 2.0,
                                          )
                                              : Border.all(
                                            color: blue,
                                            width: 2.0,
                                          ),
                                        ),
                                        child: Center(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              final text = ('${range.getIniHour()} - ${range.getfinHour()}' == '00:00 - 00:00')
                                                  ? 'Elige rango horario'
                                                  : 'Rango: \n ${range.getIniHour()} - ${range.getfinHour()}';

                                              final textStyle = TextStyle(
                                                color: Theme.of(context).textTheme.headline1?.color,
                                                fontSize: Sizes.fontSizes(context)['h3'],
                                              );

                                              final textWidget = Text(
                                                text,
                                                style: textStyle,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              );

                                              final textSpan = TextSpan(text: text, style: textStyle);
                                              final textPainter = TextPainter(
                                                text: textSpan,
                                                textDirection: TextDirection.ltr,
                                              );

                                              textPainter.layout();

                                              if (textPainter.width > constraints.maxWidth) {
                                                return SizedBox(
                                                  width: constraints.maxWidth,
                                                  child: textWidget,
                                                );
                                              } else {
                                                return textWidget;
                                              }
                                            },
                                          ),
                                        ),
                                      ),)
                                ),
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:[

                                GestureDetector(
                                    onTap: () {
                                      log("+++ ${
                                          GetStorage()
                                              .read('listaDias')
                                              .toString()
                                      }");
                                      showAlertDias(context, ref);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03), // Espacio de 8.0 puntos en todos los lados
                                      child:Container(
                                        width: w + 40,
                                        height: w,
                                        decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.35),
                                                offset: const Offset(0, 3),
                                                blurRadius: 10,
                                              ),
                                            ],
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10.0),
                                            border:
                                            (GetStorage().read('listaDias').toString() == '[]')
                                                ? Border.all(
                                              color: red,
                                              width: 2.0,
                                            )
                                                : Border.all(
                                              color: blue,
                                              width: 2.0,
                                            )
                                        ),
                                        child: Center(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              final text = (GetStorage().read('listaDias').toString() != '[]')
                                                  ? GetStorage().read('listaDias').toString().replaceAll('[', '').replaceAll(']', '')
                                                  : 'Elige días';

                                              final textStyle = TextStyle(
                                                color: Theme.of(context).textTheme.headline1?.color,
                                                fontSize: Sizes.fontSizes(context)['h3'],
                                              );

                                              final textWidget = Text(
                                                text,
                                                style: textStyle,
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              );

                                              final textSpan = TextSpan(text: text, style: textStyle);
                                              final textPainter = TextPainter(
                                                text: textSpan,
                                                textDirection: TextDirection.ltr,
                                              );

                                              textPainter.layout();

                                              if (textPainter.width > constraints.maxWidth) {
                                                return SizedBox(
                                                  width: constraints.maxWidth,
                                                  child: textWidget,
                                                );
                                              } else {
                                                return textWidget;
                                              }
                                            },
                                          ),
                                        ),

                                      ),)
                                ),
                              ]

                          ),
                        ])
                        ],

                  ),
                  SizedBox(height: Sizes.vMarginHigh(context),),

                  Consumer(builder: (context, ref, child) {
                    final taskLoading = ref.watch(
                      taskProvider.select((state) => state.maybeWhen(
                          loading: () => true, orElse: () => false)),
                    );
                    return taskLoading
                        ? LoadingIndicators.instance.smallLoadingAnimation(
                            context,
                            width: Sizes.loadingAnimationButton(context),
                            height: Sizes.loadingAnimationButton(context),
                          )
                        : CustomButton(
                            text: 'Añadir', //todo: lbl
                            onPressed: () async {
                              if (days.tags.toString() == '[]') {
                                days.tags
                                    .add(getStrDay(DateTime.now().weekday));
                              }
                              log('*** rango ${repetitions.getBoth()}');
                              if(GetStorage().read('listaDias').isNotEmpty && repetitions.getBoth() != 0
                                  && nameController.text.isNotEmpty && range.getHours() != "00:00 - 00:00") {
                              if (repetitions.getBoth() != 0) {
                            // if(range.getSumaRange() > repetitions.getBoth()) {
                            TaskModel task = TaskModel(
                              taskName: nameController.text,
                              days: saveDays(GetStorage().read('listaDias').toString()),
                              notiHours: notiHours(range.getIniHour(),
                                  range.getfinHour(), repetitions.getBt()),
                              begin: range.getIniHour(),
                              end: range.getfinHour(),
                              editable: StorageKeys.verdadero,
                              done: StorageKeys.falso,
                              numRepetition: repetitions.getBoth(),
                              lastUpdate: Timestamp.fromDate(DateTime.now()),
                              taskId: '',
                              authorUID: GetStorage().read('uidUsuario'),
                            );

                            ref
                                .read(taskProvider.notifier)
                                .addTask(task)
                                .then((value) => value.fold((failure) {
                                      AppDialogs.showErrorDialog(context,
                                          message: failure.message);
                                    }, (success) {
                                      log('*** add ok');
                                      AppDialogs.addTaskOK(context);
                                      nameController.clear();
                                      cleanField(ref);
                                    }));
                          } else {
                                AppDialogs.showErrorNeutral(context,
                                    message: tr(context).rangeWarning);
                              }
                               } else {
                                AppDialogs.showErrorNeutral(context,
                                    message: 'Rellena todos los campos');
                              }
                      },
                          );
                  }),

                  SizedBox(height: Sizes.vMarginHigh(context),),

                  CustomButton(
                    text: 'Borrar campos', //todo: lbl
                    buttonColor: Colors.red,
                    onPressed: ()  {
                      cleanField(ref);
                      nameController.clear();
                      AppDialogs.showInfo(context,
                          message: 'Se han limpiado todos los campos');
                    },
                  ),

                  //tasksRepoProvider
                  //
                  //const LogoutComponent(),
                ],
              ),
          )
      ))
    ])
    );
  }


  showAlertDias(BuildContext context, WidgetRef ref) {
    // set up the buttons
    Widget okButton = CustomTextButton(
      child: CustomText.h4(context, tr(context).oK, color: AppColors.blue),
      onPressed: () {
        //ref.watch(taskProvider.notifier).deleteTask(context,taskModel);
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
                  CustomTileComponent(
                    title: tr(context).repeatAdd,
                    leadingIcon: Icons.calendar_today_rounded,
                  ),
                  SizedBox(
                    height: Sizes.vMarginSmallest(context),
                  ),
                  ChooseDaySectionComponent([]),

                ]) //SwitchSettingsSectionComponent([]),
        )
      ]),
      actions: [
        cancelButton,
        okButton,
      ],
      shape: RoundedRectangleBorder(
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

  showAlertRangos(BuildContext context, WidgetRef ref) {
    // set up the buttons
    Widget okButton = CustomTextButton(
      child: CustomText.h4(context, tr(context).oK, color: AppColors.blue),
      onPressed: () {
        //ref.watch(taskProvider.notifier).deleteTask(context,taskModel);
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
      content: Column(mainAxisSize: MainAxisSize.min,

          children: [
            CustomTileComponent(
              title: tr(context).choose_range,
              leadingIcon: Icons.calendar_today_rounded,
            ),
        GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: TimePickerComponent('00:00 - 00:00'),
        )
      ]),
      actions: [
        cancelButton,
        okButton,
      ],
      shape: RoundedRectangleBorder(
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

  showAlertRepe(BuildContext context, WidgetRef ref) {
    // set up the buttons
    Widget okButton = CustomTextButton(
      child: CustomText.h4(context, tr(context).oK, color: AppColors.blue),
      onPressed: () {
        //ref.watch(taskProvider.notifier).deleteTask(context,taskModel);
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
        CustomTileComponent(
          title: 'Cada cuanto repetir', //tr(context).repeat_noti,
          leadingIcon: Icons.access_time_outlined,
        ),
        GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: RepeNotiComponent(
              modo: 'add',
            )
        )
      ]),
      actions: [
        cancelButton,
        okButton,
      ],
      shape: RoundedRectangleBorder(
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

  void cleanField(WidgetRef ref){
    ref.read(nameTaskProvider.notifier).clean();
    ref.read(selectDaysMultiChoice.notifier).clean();
    ref.read(timeRangeButtonProvider.notifier).clean();
    ref.read(timeRepetitionProvider.notifier).clean();
    GetStorage().write('listaDias',[]);
  }


}
