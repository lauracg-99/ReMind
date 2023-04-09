import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:remind/presentation/screens/popup_page.dart';
import '../../domain/services/localization_service.dart';
import '../hooks/fade_in_controller_hook.dart';
import '../providers/splash_provider.dart';
import '../styles/app_images.dart';
import '../styles/sizes.dart';
import '../styles/font_styles.dart';
import '../widgets/custom_text.dart';


//pantalla de carga
class SplashScreen extends HookConsumerWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final fadeController = useFadeInController();
    ref.watch(splashProvider);

    return PopUpPage(
      body: FadeIn(
        curve: Curves.easeIn,
        controller: fadeController,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  AppImages.splashAnimation,
                  width: Sizes.splashLogoSize(context),
                ),
                SizedBox(
                  height: Sizes.vMarginSmallest(context),
                ),
                CustomText.h1(
                  context,
                  tr(context).appName,
                  weight: FontStyles.fontWeightExtraBold,
                  alignment: Alignment.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
