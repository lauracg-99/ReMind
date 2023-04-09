import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../routes/navigation_service.dart';
import '../styles/app_colors.dart';
import '../styles/font_styles.dart';
import '../styles/sizes.dart';
import 'custom_text.dart';


class CustomToast {
  CustomToast._();

  static final instance = CustomToast._();

  late FToast fToast = FToast();

  showDefaultToast(
    BuildContext context, {
    String title = '',
    String description = '',
    Color? backgroundColor,
    Gradient? backgroundGradient,
    double? borderRadius,
    BoxBorder? border,
    EdgeInsets? padding,
    EdgeInsets? margin,
    ToastGravity toastGravity = ToastGravity.TOP,
    Duration toastDuration = const Duration(seconds: 3),
    int fadeDuration = 350,
  }) {
    fToast.init(context);

    final toast = Container(
      width: double.infinity,
      margin: margin,
      padding: padding ??
          EdgeInsets.symmetric(
            vertical: Sizes.vPaddingSmall(context),
            horizontal: Sizes.hPaddingMedium(context),
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF303030),
        gradient: backgroundGradient ?? AppColors.primaryIngredientColorLight,
        borderRadius: BorderRadius.circular(
          borderRadius ?? Sizes.toastRadius(context),
        ),
        border: border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          CustomText.h4(
            context,
            title,
            weight: FontStyles.fontWeightSemiBold,
            color: AppColors.lightBlack,
          ),
          SizedBox(
            height: Sizes.vMarginTiny(context),
          ),
          CustomText.h5(
            context,
            description,
            color: AppColors.lightBlack,
          ),
        ],
      ),
    );

    fToast.removeCustomToast();
    fToast.showToast(
      child: toast,
      gravity: toastGravity,
      toastDuration: toastDuration,
      //fadeDuration: fadeDuration,
    );
  }

  Future showBackgroundToast({
    String msg = '',
    Color? backgroundColor,
    Toast toastLength = Toast.LENGTH_LONG,
    ToastGravity toastGravity = ToastGravity.TOP,
  }) async {
    await Fluttertoast.showToast(
      msg: msg,
      fontSize: Sizes.fontSizes(NavigationService.context)['h4'],
      textColor: AppColors.lightBlack,
      backgroundColor: backgroundColor ?? AppColors.toastColor,
      toastLength: toastLength,
      gravity: toastGravity,
      timeInSecForIosWeb: 1,
    );
  }
}
