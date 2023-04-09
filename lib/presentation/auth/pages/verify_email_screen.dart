import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/auth/providers/auth_provider.dart';
import '../../../domain/auth/repo/user_repo.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../screens/popup_page.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../widgets/buttons/custom_button.dart';
import '../widgets/verifyEmailFormComponent.dart';

class VerifyEmailScreen extends ConsumerWidget {
  const VerifyEmailScreen({
    Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, ref) {
    return PopUpPage(
              body: SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                  padding: EdgeInsets.symmetric(
                    vertical: Sizes.screenVPaddingHigh(context),
                    horizontal: Sizes.screenHPaddingDefault(context),
                  ),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //const AppLogoComponent(),
                        SizedBox(
                          height: Sizes.vMarginHigh(context),
                        ),
                        //const WelcomeComponent(),
                        SizedBox(
                          height: Sizes.vMarginHigh(context),
                        ),
                        //const VerifyEmailFormComponent(),
                        VerifyEmailFormComponent(),
                        SizedBox(
                          height: Sizes.vMarginSmall(context),
                        ),
                        CustomButton(
                          text: tr(context).cancelBtn,
                          buttonColor: AppColors.lightRed,
                          onPressed: () {
                            ref.watch(userRepoProvider)
                                .deleteUidBD(GetStorage().read('uidUsuario'));
                            ref.watch(authRepoProvider).deleteUser();
                            NavigationService.push(
                              context,
                              isNamed: true,
                              page: RoutePaths.authLogin,
                            );
                          },
                        ),
                        SizedBox(
                          height: Sizes.vMarginHigh(context),
                        ),
                      ]),
                ),
              ),
            );
          }

}
