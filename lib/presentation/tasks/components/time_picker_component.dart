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

class TimePickerComponent extends ConsumerWidget {
  TimePickerComponent(this.horas, {Key? key}) : super(key: key);
  String horas = '';

  // bool oneTime;
  @override
  Widget build(BuildContext context, ref) {
    final timePicker = ref.watch(timeRangeButtonProvider.notifier);
    // timePicker.setOneTime(oneTime);
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(children: [
          GestureDetector(
              onTap: () {
                timePicker.showPicker(context);
                //log(timePicker.state);
              },
              child: Container(
                  height: 50,
                  width: 200,
                  child: Card(
                      elevation: 6,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Sizes.cardRadius(context)),
                      ),
                      child: Center(
                        child: (timePicker.getHours() == '00:00 - 00:00')
                            ? CustomText.h3(context, horas)
                            : CustomText.h3(context, timePicker.getHours()),
                      )))),
        ]));
  }
}
