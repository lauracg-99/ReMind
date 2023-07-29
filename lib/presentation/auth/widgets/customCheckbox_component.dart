import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../data/auth/providers/checkbox_provider.dart';
import '../../../domain/services/localization_service.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../widgets/custom_text.dart';

class CustomCheckBoxComponent extends ConsumerWidget {
  const CustomCheckBoxComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final checkBoxValue = ref.watch(checkBoxProvider);
    return Column(children: [
      CustomText.h3(context, tr(context).questionrol,
          color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
              ? AppColors.lightBlack
              : AppColors.white
      ),
      SizedBox(
        height: Sizes.vMarginSmall(context),
      ),
      Row(
        children: [
          const SizedBox(
            width: 65,
          ),
          Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              // CHANGE BORDER RADIUS HERE
              side: const BorderSide(width: 30, color: AppColors.red),
            ),
            activeColor: Theme.of(context).iconTheme.color,// Rounded Checkbox
            value: checkBoxValue,
            onChanged: (inputValue) {
              ref
                  .watch(checkBoxProvider.notifier)
                  .changeState(change: !checkBoxValue);
              log('${checkBoxValue.toString()}');
            },
          ),
          CustomText.h4(context, tr(context).yes),
          const SizedBox(
            width: 50,
          ),
          Checkbox(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              // CHANGE BORDER RADIUS HERE
              side: const BorderSide(width: 30, color: AppColors.red),
            ),
            activeColor: Theme.of(context).iconTheme.color,// Rounded Checkbox
            value: !checkBoxValue,
            onChanged: (inputValue) {
              ref
                  .watch(checkBoxProvider.notifier)
                  .changeState(change: !checkBoxValue);
            },
          ),
          CustomText.h4(context, tr(context).no),
        ],
      )
    ]);
  }
}
