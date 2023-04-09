import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:remind/presentation/widgets/platform_widgets/platform_circular_progress_indicator.dart';
import '../styles/app_colors.dart';
import '../styles/app_images.dart';
import '../styles/font_styles.dart';
import '../styles/sizes.dart';
import 'custom_text.dart';

class LoadingIndicators {
  LoadingIndicators._();

  static final instance = LoadingIndicators._();

  Widget defaultLoadingIndicator(
    BuildContext context, {
    String? message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const PlatformCircularProgressIndicator(
            strokeWidth: 3,
            backgroundColor: Colors.transparent,
            color: AppColors.lightThemePrimary,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.lightThemePrimary,
            ),
            radius: 20,
          ),
          if (message != null)
            CustomText.h5(
              context,
              message,
              alignment: Alignment.center,
              weight: FontStyles.fontWeightMedium,
              color: Theme.of(context).textTheme.headline4!.color,
              margin: EdgeInsets.only(top: Sizes.vMarginHigh(context)),
            ),
        ],
      ),
    );
  }

  Widget smallLoadingAnimation(
    BuildContext context, {
    double? height,
    double? width,
  }) {
    return Center(
      child: Container(
        color: Colors.transparent,
        child: Lottie.asset(
          AppImages.loadingAnimation,
          //height: height ?? Sizes.loadingAnimationDefaultHeight(context),
          //width: width ?? Sizes.loadingAnimationDefaultWidth(context),
        ),
      ),
    );
  }
}
