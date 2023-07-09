import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/presentation/auth/widgets/see_password.dart';
import 'package:remind/presentation/styles/app_colors.dart';
import 'package:remind/presentation/styles/app_images.dart';
import 'package:remind/presentation/widgets/custom_image.dart';
import 'package:remind/presentation/widgets/custom_text.dart';
import '../../../data/error/exceptions.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../styles/sizes.dart';
import '../../utils/dialogs.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/loading_indicators.dart';
import '../providers/auth_provider.dart';
import 'login_text_fields.dart';


class LoginFormComponent extends HookConsumerWidget {
  const LoginFormComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final loginFormKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController(text: '');
    final passwordController = useTextEditingController(text: '');
    final seeValue = ref.watch(seePasswordLoginProvider);
    GetStorage().write('firstTimeLogIn', true);
    return Form(
      key: loginFormKey,
      child: Column(
        children: [
          LoginTextFieldsSection(
            emailController: emailController,
            passwordController: passwordController,
            see: seeValue,
            iconButton: IconButton(
              padding: EdgeInsets.only(left: 16, right: 0),
              alignment: Alignment.centerRight,
              icon: Icon(
                  (seeValue) ? PlatformIcons(context).eyeSlashSolid : PlatformIcons(context).eyeSolid
              ),
              onPressed: () {
                ref.watch(seePasswordProvider.notifier)
                    .changeState(change: !seeValue);
              },),
            onFieldSubmitted: (value) {
              if (loginFormKey.currentState!.validate()) {
                ref.read(authProvider.notifier).signInWithEmailAndPassword(
                  email: emailController.text,password: passwordController.text,
                ).then(
                        (value) =>
                            value.fold(
                                    (failure) {
                                      AppDialogs.showErrorDialog(context, message: failure.message);
                                    },
                                    (success) {
                                      NavigationService.pushReplacement(
                                      context,
                                      isNamed: true,
                                      page: RoutePaths.home,
                                      );
                            }
                        )
                );
              }
            },
          ),
          SizedBox(
            height: Sizes.vMarginMedium(context),
          ),
          //boton
          Consumer(
            builder: (context, ref, child) {
              final authLoading = ref.watch(
                authProvider.select((state) =>
                    state.maybeWhen(loading: () => true, orElse: () => false)),
              );
              return authLoading
                  ? LoadingIndicators.instance.smallLoadingAnimation(
                context,
                width: Sizes.loadingAnimationButton(context),
                height: Sizes.loadingAnimationButton(context),
              )
                  : CustomButton(
                width: Sizes.availableScreenWidth(context)/1.5,
                text: tr(context).signIn,
                onPressed: () {
                  if (loginFormKey.currentState!.validate()) {
                    ref.watch(authProvider.notifier)
                        .signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    ).then(
                            (value) =>
                            value.fold(
                                    (failure) {
                                  AppDialogs.showErrorDialog(context, message: failure.message);
                                },
                                    (success) {
                                  NavigationService.pushReplacement(
                                    context,
                                    isNamed: true,
                                    page: RoutePaths.home,
                                  );
                                }
                            )
                    );
                  }
                },
              );
            },
          ),

          SizedBox(
            height: Sizes.vMarginHigh(context),
          ),
          CustomButton(
            width: Sizes.availableScreenWidth(context)/1.5,
            text: tr(context).register,
            onPressed: () {
              NavigationService.push(
                context,
                isNamed: true,
                page: RoutePaths.authRegister,
              );
            },
          ),
          SizedBox(
            height: Sizes.vMarginMedium(context),
          ),
          InkWell(
            child: Container(
                width: Sizes.availableScreenWidth(context)/1.5,
                height: Sizes.availableScreenHeight(context)/18,
                margin: EdgeInsets.only(top: 0),
                child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CustomText.h4(
                          context,
                          tr(context).reset,
                          color: Theme.of(context).iconTheme.color,
                          underline: true,
                        ),
                      ],
                    )
                )
            ),
            onTap: () {
                NavigationService.push(
                context,
                isNamed: true,
                page: RoutePaths.authReset,
                );
            },
          ),
          SizedBox(
            height: Sizes.vMarginSmall(context),
          ),
          Container(
            width: Sizes.availableScreenWidth(context)/2,
            child: Divider(
              color: Theme.of(context).dividerColor,
              thickness: 1,
            ),
          ),
          SizedBox(
            height: Sizes.vMarginMedium(context),
          ),
          InkWell(
            child: Container(
                width: Sizes.availableScreenWidth(context)/1.5,
                height: Sizes.availableScreenHeight(context)/18,
                margin: EdgeInsets.only(top: 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color:AppColors.grayWhite,
                  border: Border.all(
                    width: 1,
                    color: AppColors.grey,
                  ),
                ),
                child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CustomImage.s5(
                          context,
                          AppImages.googleLogo,
                          fit: BoxFit.cover,
                          //imageAndTitleAlignment: MainAxisAlignment.start,
                        ),
                        CustomText.h3(
                          context,
                          'Inicia sesión con Google', // todo: tr
                          color: AppColors.grey,
                        ),
                      ],
                    )
                )
            ),
            onTap: () async{
              ref.watch(authProvider.notifier)
                  .signInWithGoogle().then(
                      (value) =>
                      value.fold(
                              (failure) {
                            log('*** noup');
                            ref.watch(authProvider.notifier).deleteGoogleAccount();
                            AppDialogs.showErrorDialog(context, message: failure.message);
                          },

                              (success) {
                            final firstTimeLogIn = GetStorage().read('firstTimeLogIn');
                            log('*** firstTimeLogIn ${firstTimeLogIn}');
                            if (firstTimeLogIn){
                              NavigationService.push(
                                context,
                                isNamed: true,
                                page: RoutePaths.chooseRol,
                              );
                            } else {
                              NavigationService.pushReplacement(
                                context,
                                isNamed: true,
                                page: RoutePaths.home,
                              );
                            }

                          }
                      )
              );
            },
          ),
        ],
      ),
    );
  }
}