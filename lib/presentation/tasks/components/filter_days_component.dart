import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/presentation/tasks/providers/filter_provider.dart';
import '../../../domain/services/localization_service.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../providers/multi_choice_provider.dart';
import '../utils/utilities.dart';

class FilterDaysComponent extends ConsumerWidget {
  FilterDaysComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final selectValue = ref.watch(selectFilterProvider);

    var gl = LocalizationService.instance.isGl(context);

    String todosLosDias = (gl) ? 'Todos os días' : 'Todos los días';

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


    return ChipsChoice<int>.single(
      value: selectValue,
      onChanged: (value) {
        ref.watch(selectFilterProvider.notifier)
            .setChoice(value);
      },
      choiceItems: C2Choice.listFrom<int, String>(
        source: daysList,
        value: (i, v) => i,
        label: (i, v) => v,
      ),
      wrapped: true,
      choiceStyle: C2ChipStyle(
        iconColor: Theme.of(context).iconTheme.color ==
            AppColors.lightThemeIconColor
            ? AppColors.accentColorLight
            : AppColors.darkThemePrimary,
      ),
    );
  }

}
