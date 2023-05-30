import 'dart:developer';

import 'package:flutter/cupertino.dart';
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
import 'card_red_button_component.dart';

import '../providers/multi_choice_provider.dart';
import '../providers/repe_noti_provider.dart';
import '../providers/time_range_picker_provider.dart';
import '../providers/toggle_theme_provider.dart';

class RepeNotiComponent extends ConsumerWidget {
  RepeNotiComponent({required this.modo, Key? key}) : super(key: key);
  String modo = '';

  @override
  Widget build(BuildContext context, ref){
    var repeNoti = ref.watch(timeRepetitionProvider.notifier);

    String range = ref.read(timeRangeButtonProvider.notifier).getHours();
    String hour = ref.watch(timeRepetitionProvider.notifier).getHr();
    String min = ref.watch(timeRepetitionProvider.notifier).getMinute();

    bool chose = ref.read(timeRepetitionProvider.notifier).getChoosen();
    //var warning =  ref.read(timeRepetitionProvider.notifier).getW();
    return Column(children:[
      SizedBox(height: Sizes.vMarginSmall(context),),
      CustomText.h3(
        context,
        tr(context).repeat_noti,
        color: Theme.of(context).textTheme.headline4!.color,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
      SizedBox(height: Sizes.vMarginSmall(context),),
      //(!ref.read(timeRepetitionProvider.notifier).getChoosen())
      (chose)
      ? CupertinoTimerPicker(
          mode: CupertinoTimerPickerMode.hm,
          onTimerDurationChanged: (value){
            //if(hours != '00:00 - 00:00'){

            /*log('VALUE Hr ${value.inHours.toString()}');
              log('VALUE MIn ${value.inMinutes.toString()}');*/

              repeNoti.setHr(value.inHours.toString());
              repeNoti.setMinuteHour(value.inHours, value.inMinutes);
              repeNoti.setMin(value.inMinutes.toString());
              var sum = value.inHours*60 + value.inMinutes;
              repeNoti.setBoth(sum.toString());

              ref.refresh(timeRepetitionProvider.notifier);

                  /*ref
                      .watch(timeRepetitionProvider.notifier)
                      .setHr(value.inMinutes.toString());
                  ref
                      .watch(timeRepetitionProvider.notifier)
                      .setW(getRange(range, repeNoti.getHr()));*/



              })
        : SizedBox(),

      //TODO STRING
      CustomText.h3(context, repeNoti.getTime()),

      /*Container(
        child: Card(
          elevation: 6,
          shadowColor: AppColors.blue,
          margin: EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(Sizes.cardRadius(context)),
          ),
          child:
            GestureDetector(
              child: Container(padding: EdgeInsets.all(10), child:CustomText.h3(context,tiempo(min))),
              onTap: (){
                ref.watch(timeRepetitionProvider.notifier).setChoosen(true);
            },),
        ),

        ),*/

      SizedBox(height: Sizes.vMarginSmall(context),),

      SizedBox(height: Sizes.vMarginMedium(context),),

      /*(modo != 'mod')
          ? Row(children: [
        SizedBox(width: Sizes.vMarginHighest(context)*1.2,),
        CupertinoButton(
            child: CustomText.h4(context,'Cancelar',color: AppColors.red),
            onPressed: (){
              ref.watch(timeRepetitionProvider.notifier).setChoosen(true);
              print(chose);
            }),
        SizedBox(width: Sizes.vMarginHighest(context)*3.3,),
        (ref.read(timeRepetitionProvider.notifier).getW() || min == '0')
            ? CupertinoButton(
            child: CustomText.h4(context,'Ok',color: AppColors.grey),
            onPressed: (){
              //nada
            })
            : CupertinoButton(
            child: CustomText.h4(context,'Ok',color: AppColors.blue),
            onPressed: (){
              ref.watch(timeRepetitionProvider.notifier).setChoosen(false);
              print(chose);
            })
      ])
          : SizedBox(),*/


    ])


    ;
  }

  String tiempo(String hr){
    String t = "";
    //print(hr);
    log('hr ${hr}');
    if(hr != '00:00 - 00:00' && hr.isNotEmpty){
    int minutos = int.parse(hr);
    int hora = 0;
      if (minutos > 60) {
        hora = (minutos / 60).truncate();
        minutos = minutos - hora * 60;
        t = 'Repetir cada ${hora} horas ${minutos} minutos';
      } else {
        t = 'Repetir cada ${minutos} minutos';
      }
    }
    return t;
  }

  bool getRange(String hours, String rep){
    bool p = false;
    String ini = hours;
    int idx = ini.indexOf("-");
    List parts = [ini.substring(0,idx).trim(), ini.substring(idx+1).trim()];
    if(parts.toString() != '[, ]'){
      int inicio = caculateMin(parts[0]);
      int fin = caculateMin(parts[1]);
      int total = fin - inicio;

      (total <= int.parse(rep))
          ? p = true
          : p = false;
    }

    return p;
  }



  //@override
  /*Widget build(BuildContext context, ref) {
    //log(modo);
    final repeNoti = ref.watch(timeRepetitionProvider.notifier);
    String hours = ref.read(timeRangeButtonProvider.notifier).getHours();
    bool go = getRange(hours, repeNoti.getHr());
    //log(hora);
    //log(repeNoti.getHr());
    return Container(
      padding: EdgeInsets.all(10),
        child: Column(
        children: [
          //todo
          (modo == 'add')
              ? CustomText.h4(
            context,
            '¿Cada cuantos minutos quieres '
                'que se repita la notificación?', //todo
            color: Theme.of(context).textTheme.headline4!.color,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          )
          : SizedBox(
            height: Sizes.vMarginSmallest(context),
          ),
          SizedBox(
            height: Sizes.vMarginMedium(context),
          ),
          Row(
          mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            (repeNoti.getHr() != '')
                ? //todo
                CustomText.h4(
                context,
                'Se te avisara cada ',
                  color: Theme.of(context).textTheme.headline4!.color,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  )
                : (modo != 'add')
                    ? CustomText.h4(
                      context,
                      'Se te avisara cada ',
                      color: Theme.of(context).textTheme.headline4!.color,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                    : CustomText.h4(context, ''),


              SizedBox(
                width: Sizes.vMarginSmallest(context),
              ),
              GestureDetector(
                  onTap: (){

                    repeNoti.showPicker(context);
                    //log(timePicker.state);
                  },
                  child: Container(
                      height: 50,
                      width: 50,
                      child: Card(
                        elevation: 6,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Sizes.cardRadius(context)),
                        ),
                        child:Center( child: CustomText.h4(
                          context,
                          (modo == 'add')
                              ? repeNoti.getHr()
                              : (repeNoti.getHr() != '')
                                  ? repeNoti.getHr()
                                  : hora,
                          color: Theme.of(context).textTheme.headline4!.color,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),)
                          //todo
                        *//*child:(repeNoti.getRange())
                            ? Center(child: CustomText.h3(context,'repeNoti.minutos_repetir'),)
                            : CustomText.h3(context,'No puedes repetirlo tantas veces'),*//*
                      )
                  )
              ),

              SizedBox(
                width: Sizes.vMarginSmallest(context),
              ),
              (repeNoti.getHr() != '')
                  ? CustomText.h4(
                            context,
                            'minutos. ',
                            color: Theme.of(context).textTheme.headline4!.color,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          )
                  : (modo != 'add')
                    ? CustomText.h4(
                          context,
                          'minutos. ',
                          color: Theme.of(context).textTheme.headline4!.color,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        )
                    :CustomText.h4(context, ''),

            ],),

        ]));

  }*/




  int caculateMin(String dots){
    int idx = dots.indexOf(":");
    List parts = [dots.substring(0,idx).trim(), dots.substring(idx+1).trim()];
    int hour = int.parse(parts[0]);
    int min = int.parse(parts[1]);
    int allMinutes = hour*60 + min;
    return allMinutes;
  }


}