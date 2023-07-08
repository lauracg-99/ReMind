import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/data/auth/models/user_model.dart';
import 'package:remind/domain/auth/repo/user_repo.dart';

import '../../../common/storage_keys.dart';
import '../../../data/auth/providers/checkbox_provider.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../styles/sizes.dart';
import '../../utils/dialogs.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/loading_indicators.dart';
import '../providers/auth_provider.dart';
import 'customCheckbox_component.dart';

class ChooseRolFormComponent extends HookConsumerWidget {
  const ChooseRolFormComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final chooseRolFormKey = useMemoized(() => GlobalKey<FormState>());
    final checkBoxValue = ref.watch(checkBoxProvider);

    return Form(
      key: chooseRolFormKey,
      child: Column(
        children: [
          CustomCheckBoxComponent(),
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
                text: "Aceptar", // todo: tr
                onPressed: () async {
                  if (chooseRolFormKey.currentState!.validate()) {
                    var rol = (checkBoxValue)
                        ? StorageKeys.SUPERVISOR
                        : 'supervisado';
                    GetStorage().write(StorageKeys.rol, rol);
                    var userGoogle = await ref.watch(authProvider.notifier).getCurrentUser();
                    var user = UserModel.fromUserCredential(
                        userGoogle!,
                        rol,
                        GetStorage().read(StorageKeys.name), [], "", "");

                    await  ref.watch(userRepoProvider).setUserData(user)
                        .then(
                            (value) =>
                            value.fold(
                                    (failure) {
                                  AppDialogs.showErrorDialog(context, message: failure.message);
                                },
                                    (success) {
                                  AppDialogs.showErrorDialog(context, message: tr(context).reset);
                                  GetStorage().write('firstTimeLogIn', false);
                                  NavigationService.pushReplacement(
                                    context,
                                    isNamed: true,
                                    page: RoutePaths.homeBase,
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