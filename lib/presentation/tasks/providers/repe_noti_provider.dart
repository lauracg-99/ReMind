import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';

import '../../../domain/services/localization_service.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../widgets/custom_text.dart';

//Create a Provider
final timeRepetitionProvider = StateNotifierProvider.autoDispose<TimeRepetitionButton, String>((ref) {
  return TimeRepetitionButton(ref);
});

class TimeRepetitionButton extends StateNotifier<String> {
  final Ref ref;

  String minutos_repetir = '0';

  static String hr = '';

  static String both = '';

  static String min = '';

  static bool chosen = true;

  static bool warning = false;

  static int minuteInt = 0;
  static int hourInt = 0;

  String getHr(){
    return hr;
  }

  String getBt(){
    return both;
  }
  String getMinute(){
    return min;
  }

  void setHr(String h){
     hr = h;
  }

  void setBoth(String bt){
    both = bt;
  }

  void setMin(String m){
    min = m;
  }

  void setMinuteHour(int hour, int minute){
    minuteInt = minute;
    hourInt = hour;
  }

  int getBoth(){
    log('**** HORA Y MIN ${minuteInt} + ${hourInt}');
    return minuteInt;
  }
  int getMinuteInt(){
    return minuteInt;
  }
  int getHourInt(){
    return hourInt;
  }

  String getTime(){
    var mS = minuteInt - hourInt*60;
    return (hourInt != 0)
      ?  'Cada ${hourInt} horas y ${mS} minutos'
      : 'Cada ${minuteInt} minutos';
  }

  bool getW(){
    return warning;
  }

  void setW(bool w){
    warning = w;
    ref.refresh(timeRepetitionProvider);
  }

  bool getChoosen(){
    return chosen;
  }

  void setChoosen(bool c){
    chosen = c;
    ref.refresh(timeRepetitionProvider);
  }

  clean(){
    both='';
    minuteInt = 0;
    hourInt = 0;

  }
  List<Widget> actions = [];

  TimeRepetitionButton(this.ref) : super('');



  Picker ps = Picker(
      adapter: NumberPickerAdapter(
          data: [
            const NumberPickerColumn(
              initValue: 15,
              begin: 15,
              end: 999,
            ),
          ]
      ),
      delimiter: [
        PickerDelimiter(
            child: Container(
              width: 70.0,
              alignment: Alignment.center,
              child: const Text('Minutos'),//Icon(Icons.more_vert),
            ))
      ],
      //todo: tr
      hideHeader: true,
      title: const Text("Selecciona días repetición"),
      selectedTextStyle: const TextStyle(color: Colors.blue),
      onConfirm: (Picker picker, List value) {
        log('value.toString() ${value.toString()}');
        var split = value.toString().replaceAll('[', '');
        split = split.replaceAll(']', '');
        log('esto ${split}');
        hr = split;
      }
  );

  showPicker(BuildContext context){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Cada cuantos minutos repetir"),
            actions: actions,
            content: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //CustomText.h4(context,"Cada cuantos minutos se repite cada notificacion"),
                  ps.makePicker(),
                  SizedBox(width: Sizes.vMarginHigh(context),),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center, //Center Row contents horizontally,
                      crossAxisAlignment: CrossAxisAlignment.center, //Center Row contents vertically,
                      children: [
                    CupertinoButton(
                        child: CustomText.h3(context,tr(context).cancel,color: AppColors.red),
                        onPressed: (){
                          //ref.refresh(timeRepetitionProvider);
                          navigationPop(context);
                        }),
                    SizedBox(width: Sizes.vMarginHigh(context),),
                    CupertinoButton(
                        child: CustomText.h3(context,tr(context).oK,color: AppColors.blue),
                        onPressed: (){
                          //log('okey');
                          ps.onConfirm!(ps, ps.selecteds);
                          //var inputFormat = DateFormat.Hm();
                          //var inputDateInicio = inputFormat.parse(hr);
                          ref.refresh(timeRepetitionProvider);
                          navigationPop(context);
                        })
                  ])

                ],
              ),
            ),
          );
        });
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

  navigationPop(BuildContext context) {
    Navigator.pop(context);
  }




}