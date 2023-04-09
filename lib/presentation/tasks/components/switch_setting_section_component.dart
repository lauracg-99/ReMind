import 'package:chips_choice_null_safety/chips_choice_null_safety.dart';
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
import '../providers/task_provider.dart';
import '../providers/time_range_picker_provider.dart';
import '../providers/toggle_theme_provider.dart';

class ChooseDaySectionComponent extends ConsumerWidget {
  ChooseDaySectionComponent(this.selectChoices, {Key? key})
      : super(key: key);
  List<String> selectChoices;

  @override
  Widget build(BuildContext context, ref) {
    //final switchValue = ref.watch(switchButtonProviderAdd);
    final multiChoiceValue = ref.watch(selectDaysMultiChoice);

    if (selectChoices.isNotEmpty) {
      //log('switch ' + getDiasString(sortDay(selectChoices)).toString());
      ref.watch(selectDaysMultiChoice.notifier)
         .setChoice(getDiasString(sortDay(selectChoices)));
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
                    borderRadius:
                        BorderRadius.circular(Sizes.cardRadius(context)),
                  ),
                  child: ChipsChoice<String>.multiple(
                    value: multiChoiceValue,
                    onChanged: (value) {
                      ref
                          .watch(selectDaysMultiChoice.notifier)
                          .changeChoice(val: value, mix: multiChoiceValue);

                      //con esto pillo los dias
                      //print(ref.read(selectDaysMultiChoice.notifier).tags);
                    },
                    choiceItems: C2Choice.listFrom<String, String>(
                      source: daysList,
                      value: (i, v) => v,
                      label: (i, v) => v,
                    ),
                    wrapped: true,
                    choiceStyle: C2ChoiceStyle(color:
                     Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                        ? AppColors.accentColorLight
                        : AppColors.darkThemePrimary,
                      ),
                    ),
                  ),
           /*: CustomText.h4(
            context,
            'Se repetirá solamente hoy ',
            color: Theme.of(context).textTheme.headline4!.color,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),*/

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
