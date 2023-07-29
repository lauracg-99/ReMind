import 'package:flutter/material.dart';

import '../../styles/app_colors.dart';
import '../../styles/font_styles.dart';
import '../../styles/sizes.dart';
import '../../widgets/buttons/custom_outlined_button.dart';
import '../../widgets/custom_text.dart';


class CardRedButtonComponent extends StatelessWidget {
  final String title;
  final bool isColored;
  final VoidCallback? onPressed;

  const CardRedButtonComponent({
    required this.title,
    required this.isColored,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomOutlinedButton(
      height: Sizes.roundedButtonMediumHeight(context),
      width: Sizes.roundedButtonMediumWidth(context),
      side: isColored ? null : const BorderSide(color: AppColors.carbonic),
      buttonColor: isColored ? null : Colors.red,
      splashColor: isColored ? null : AppColors.lightThemePrimary,
      onPressed: onPressed,
      child: CustomText.h5(
        context,
        title,
        color: isColored
            ? Theme.of(context).textTheme.headline4!.color
            : AppColors.white,
        weight: FontStyles.fontWeightBold,
        alignment: Alignment.center,
      ),
    );
  }
}
