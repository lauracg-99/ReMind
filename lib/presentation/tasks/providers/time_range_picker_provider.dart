import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/services/localization_service.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../widgets/custom_text.dart';

//Create a Provider
final timeRangeButtonProvider = StateNotifierProvider.autoDispose<TimeRangeButton, String>((ref) {
  return TimeRangeButton(ref);
});

class TimeRangeButton extends StateNotifier<String> {
  final Ref ref;

  String horaInicial = '00:00';
  String horaFinal = '00:00';

  static String hf = '00:00';
  static String hi = '00:00';

  static int sumaRange = 0;

  //static bool oneTime = false;

  int getSumaRange(){
    var ini = hi.split(':');
    var iniS = int.parse(ini[0]) * 60 +  int.parse(ini[1]);
    var fin = hf.split(':');
    var iniF = int.parse(fin[0]) * 60 +  int.parse(fin[1]);
    log('**** INIs ${iniS} y INIF ${iniF}');
    if(iniF - iniS < 0){
      return 0;
    }else {
      return iniF - iniS;
    }

  }
  String getIniHour(){
    return hi;
  }

  String getfinHour(){
    return hf;
  }

  /*void setOneTime(bool value){
    oneTime = value;
  }*/

  clean(){
    hi='';
    hf ='';
  }

  Picker ps = Picker(
      hideHeader: true,
      adapter: DateTimePickerAdapter(
          type: PickerDateTimeType.kHM_AP),
      onConfirm: (Picker picker, List value) {
        var ini= (picker.adapter as DateTimePickerAdapter).value;
         hi = parsearHora(ini!);
        //valorINICIAL = ini!.hour.toString() +':'+ ini.minute.toString();
      });
  Picker pe = Picker(
      hideHeader: true,
      adapter: DateTimePickerAdapter(type: PickerDateTimeType.kHM_AP) ,
      onConfirm: (Picker picker, List value) {
        var ini= (picker.adapter as DateTimePickerAdapter).value;
        hf = parsearHora(ini!);
        //ini!.hour.toString() +':'+ ini.minute.toString();
      });

  List<Widget> actions = [];

  TimeRangeButton(this.ref) : super('');

  String getHours(){
    return hi +' - ' + hf;
  }

  static String parsearHora(DateTime date){
    var control = '';
    String hora = '';
    if (date.minute.toString().length == 1) {
      control = '0${date.minute}';
    } else {
      control = date.minute.toString();
    }
    hora = ('${date.hour}:$control');
    return hora;
  }

  showPicker(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(tr(context).choose_range),
            actions: actions,
            content: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                   Text(tr(context).ini_range),
                  ps.makePicker(),
                   Text(tr(context).fin_range),
                  pe.makePicker(),

                  SizedBox(
                    height: Sizes.vMarginSmall(context),
                  ),

                  Row(
                      children: [
                        SizedBox(
                            height: 50,
                            width: 120,
                            child: CupertinoButton(

                                child: CustomText.h4(context,'Cancelar',color: AppColors.red,),
                                onPressed: (){
                                  // todo borrar hora no valida
                                  ref.refresh(timeRangeButtonProvider);
                                  navigationPop(context);
                                })),

                        SizedBox(
                          width: Sizes.vMarginSmallest(context),
                        ),

                        SizedBox(
                        height: 50,
                        width: 120,
                        child: CupertinoButton(
                          child: CustomText.h4(context,'Guardar',color: AppColors.blue,),
                          onPressed: (){
                            //log('okey');

                            ps.onConfirm!(ps, ps.selecteds);
                            pe.onConfirm!(pe, pe.selecteds);


                            horaInicial = hi;
                            horaFinal = hf;

                            var inputFormat = DateFormat.Hm();
                            var inputDateInicio = inputFormat.parse(hi);
                            var inputDateFin = inputFormat.parse(hf);

                            //if(inputDateInicio.isAfter(inputDateFin)){//AppDialogs.showErrorNeutral(context,message: tr(context).rangeWarning);}

                            //log('oneTime TRPP ${!oneTime}');
                            /*if(!oneTime) {
                              if(inputDateInicio.minute <= DateTime.now().minute) {
                                //log(' first if ${inputDateInicio.minute} ${DateTime.now().minute}');
                                if(inputDateInicio.hour <= DateTime.now().hour){
                                  //log(' second if ${inputDateInicio.hour} ${DateTime.now().hour}');
                                  //navigationPop(context);
                                  AppDialogs.showErrorNeutral(context,
                                      message: 'Si es para hoy no se puede viajar al pasado, '
                                          'tiene que ser antes de: '
                                          '${DateTime.now().hour} : ${DateTime.now().minute} o elige otro día');
                                  //navigationPop(context);
                                }else{
                                  ref.refresh(timeRangeButtonProvider);
                                  navigationPop(context);
                                }
                              }else{
                                ref.refresh(timeRangeButtonProvider);
                                navigationPop(context);
                              }

                            }else{*/
                              ref.refresh(timeRangeButtonProvider);
                              navigationPop(context);


                            //state = '$horaInicial - $horaFinal';
                            //log(state);
                            //ref.refresh(timeRangeButtonProvider);
                            //navigationPop(context);
                          }),),



                    ]),
            ],
              ),
            ),
          );
        });
  }

  navigationPop(BuildContext context) {
    Navigator.pop(context);
  }

  firstPicker(Picker ps){
     ps = Picker(
        hideHeader: true,
        adapter: DateTimePickerAdapter(
            type: PickerDateTimeType.kHM_AP),
        onConfirm: (Picker picker, List value) {
          print((picker.adapter as DateTimePickerAdapter).value);
          var ini= (picker.adapter as DateTimePickerAdapter).value;
          horaInicial = parsearHora(ini!);
          //valorINICIAL = ini!.hour.toString() +':'+ ini.minute.toString();
        });
    ps.makePicker();
  }



}