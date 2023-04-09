import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/font_styles.dart';
import '../styles/sizes.dart';
import 'buttons/custom_outlined_button.dart';
import 'custom_text.dart';

class CardButtonComponent extends StatelessWidget {
  final String title;
  final bool isColored;
  final VoidCallback? onPressed;

  const CardButtonComponent({
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
      side: isColored ? null : const BorderSide(color: AppColors.grey),
      buttonColor: isColored
          ? Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
              ? AppColors.buttonLightSolid
              : AppColors.buttonDarkSolid
          : Colors.transparent,
      splashColor: isColored ? null : AppColors.lightThemePrimary,
      onPressed: onPressed,
      child: CustomText.h5(
        context,
        title,
        color: isColored
            ? AppColors.white
            : Theme.of(context).textTheme.headline4!.color,
        weight: FontStyles.fontWeightBold,
        alignment: Alignment.center,
      ),
    );
  }
}
