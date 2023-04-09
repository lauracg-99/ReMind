import 'package:flutter/material.dart';

import '../../domain/services/localization_service.dart';
import '../styles/app_colors.dart';
import '../styles/sizes.dart';
import '../widgets/buttons/custom_button.dart';
import '../widgets/custom_text.dart';
import '../widgets/loading_indicators.dart';

class DataErrorComponent extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;

  const DataErrorComponent({
    required this.title,
    required this.description,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        LoadingIndicators.instance.smallLoadingAnimation(context),
        SizedBox(
          height: Sizes.vMarginHigh(context),
        ),
        CustomText.h2(
          context,
          title,
          alignment: Alignment.center,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: Sizes.vMarginSmallest(context),
        ),
        CustomText.h5(
          context,
          description,
          alignment: Alignment.center,
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: Sizes.vMarginHigh(context),
        ),
        CustomButton(
          text: tr(context).retry,
          onPressed: onPressed,
          buttonColor: AppColors.lightThemePrimary,
        ),
      ],
    );
  }
}
