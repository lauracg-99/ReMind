import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/presentation/auth/widgets/reset_text_field.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../styles/sizes.dart';
import '../../utils/dialogs.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/loading_indicators.dart';
import '../providers/auth_provider.dart';



class ResetFormComponent extends HookConsumerWidget {
  const ResetFormComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final resetFormKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController(text: '');


    return Form(
      key: resetFormKey,
      child: Column(
        children: [
          ResetTextFieldsSection(
            emailController: emailController,
            /*onFieldSubmitted: (value) {
              if (resetFormKey.currentState!.validate()) {
                ref.read(authProvider.notifier).sendPasswordResetEmail(
                    email: emailController.text,
                );
              }
            },*/
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
                text: tr(context).reset,
                onPressed: () {
                  if (resetFormKey.currentState!.validate()) {
                    ref.watch(authProvider.notifier)
                        .sendPasswordResetEmail(
                      email: emailController.text,
                    ).then(
                            (value) =>
                            value.fold(
                                    (failure) {
                                  AppDialogs.showErrorDialog(context, message: failure.message);
                                },
                                    (success) {
                                  AppDialogs.showErrorDialog(context, message: tr(context).reset);
                                  NavigationService.pushReplacement(
                                    context,
                                    isNamed: true,
                                    page: RoutePaths.authLogin,
                                  );
                                }
                            )
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