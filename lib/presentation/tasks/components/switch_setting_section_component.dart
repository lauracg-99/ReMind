import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../domain/services/localization_service.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../providers/multi_choice_provider.dart';
import '../utils/utilities.dart';

class ChooseDaySectionComponent extends ConsumerWidget {
  ChooseDaySectionComponent(this.selectChoices, {Key? key}) : super(key: key);
  List<String> selectChoices;

  @override
  Widget build(BuildContext context, ref) {
    final multiChoiceValue = ref.watch(selectDaysMultiChoice);

    var gl = LocalizationService.instance.isGl(context);

    String todosLosDias = (gl) ? 'Todos os días' : 'Todos los días';

    final allDaysSelected = multiChoiceValue.contains(todosLosDias);

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

    Map<String, dynamic> mapDays = (gl)
        ? {
            "Luns": 1,
            "Martes": 2,
            "Mércores": 3,
            "Xoves": 4,
            "Venres": 5,
            "Sábado": 6,
            "Domingo": 7,
            "Todos os días": 8
          }
        : {
            "Lunes": 1,
            "Martes": 2,
            "Miércoles": 3,
            "Jueves": 4,
            "Viernes": 5,
            "Sábado": 6,
            "Domingo": 7,
            "Todos los días": 8
          };

    if (selectChoices.isNotEmpty && !allDaysSelected) {
      ref.watch(selectDaysMultiChoice.notifier).setChoice(getDiasString(
          sortDay(selectChoices, mapDays), todosLosDias, daysList));
    }

    return Container(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          /*(!switchValue)
            ?*/
          Card(
            elevation: 6,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Sizes.cardRadius(context)),
            ),
            child: ChipsChoice<String>.multiple(
              value: allDaysSelected ? [todosLosDias] : multiChoiceValue,
              onChanged: (value) {
                if (value.contains(todosLosDias)) {
                  // If "Todos los días" is selected, clear all other selections
                  value = [todosLosDias];
                } else {
                  // Remove "Todos los días" if other days are selected
                  value.remove(todosLosDias);
                }
                (gl)
                    ? ref
                        .watch(selectDaysMultiChoice.notifier)
                        .changeChoiceGal(val: value, mix: multiChoiceValue)
                    : ref
                        .watch(selectDaysMultiChoice.notifier)
                        .changeChoice(val: value, mix: multiChoiceValue);

                GetStorage().write('listaDias',
                    ordenarDias(value, todosLosDias, mapDays, daysList));
              },
              choiceItems: C2Choice.listFrom<String, String>(
                source: daysList,
                value: (i, v) => v,
                label: (i, v) => v,
              ),
              wrapped: true,
              choiceStyle: C2ChipStyle(
                iconColor: Theme.of(context).iconTheme.color ==
                        AppColors.lightThemeIconColor
                    ? AppColors.accentColorLight
                    : AppColors.darkThemePrimary,
              ),
            ),
          ),
          SizedBox(
            height: Sizes.vMarginMedium(context),
          ),
        ]));
  }

  // multiple choice value
  List<String> tags = [];

  List<dynamic> sortDay(
      List<String> selectedDia, Map<String, dynamic> mapDays) {
    List<dynamic> numbers = [];

    for (var element in selectedDia) {
      numbers.add(mapDays[element]);
    }
    numbers.sort();
    return numbers;
  }

  List<String> getDiasString(
      List<dynamic> numeros, String todosLosDias, List<String> daysList) {
    List<String> tags = [];
    for (var element in numeros) {
      //print(element.toString());
      if (element < 8) {
        //va de 0..7 no de 1..8
        tags.add(daysList.elementAt(element - 1));
      } else {
        tags.add(todosLosDias);
      }
    }
    return tags;
  }
}
