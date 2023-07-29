import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../styles/app_colors.dart';
import '../../styles/font_styles.dart';
import '../../styles/sizes.dart';
import '../../widgets/custom_text.dart';

class LightButtonComponent extends StatelessWidget {
  const LightButtonComponent({
    Key? key,
    required this.text,
    this.icon,
    this.color,
    this.textColor,
  }) : super(key: key);

  final String text;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Sizes.vPaddingSmall(context),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(
          Sizes.dialogSmallRadius(context),
        ),
        border: Border.all(
          width: 1,
          color: color ?? AppColors.lightThemePrimary,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).hintColor.withOpacity(0.15),
            offset: const Offset(0, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (icon != null)
              ?Icon(
                  icon,
                  color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                      ? AppColors.lightThemeIconColor
                      : AppColors.darkThemePrimary,
                )
          : const SizedBox(),
          SizedBox(
            width: Sizes.hMarginSmall(context),
          ),
          CustomText.h4(
            context,
            text,
            alignment: Alignment.center,
            weight: FontStyles.fontWeightExtraBold,
            color: textColor ?? AppColors.lightThemePrimary,
          ),
        ],
      ),
    );
  }
}