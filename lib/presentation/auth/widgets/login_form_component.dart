import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/presentation/auth/widgets/see_password.dart';
import '../../../domain/services/localization_service.dart';
import '../../styles/sizes.dart';
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
                  context,
                  email: emailController.text,
                  password: passwordController.text,
                );
              }
            },
          ),
          SizedBox(
            height: Sizes.vMarginSmall(context),
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
                text: tr(context).signIn,
                onPressed: () {
                  if (loginFormKey.currentState!.validate()) {
                    ref.watch(authProvider.notifier)
                        .signInWithEmailAndPassword(
                      context,
                      email: emailController.text,
                      password: passwordController.text,
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}