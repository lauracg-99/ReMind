import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/presentation/profile/components/profile_text_fields_section.dart';

import '../../../domain/auth/repo/user_repo.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../settings/components/light_button_component.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../providers/profile_provider.dart';

class ProfileFormComponent extends HookConsumerWidget {
  const ProfileFormComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final userModel = ref.watch(userRepoProvider).userModel;
    final profileFormKey = useMemoized(() => GlobalKey<FormState>());
    final nameController =
        useTextEditingController(text: userModel?.name ?? '');
    return Form(
      key: profileFormKey,
      child: Column(
        children: [
          ProfileTextFieldsSection(
            nameController: nameController,
            //mobileController: _mobileController,
          ),
          SizedBox(
            height: Sizes.vMarginHigh(context),
          ),
          PlatformWidget(
            material: (_, __) {
              return InkWell(
                onTap: (){
                  if (profileFormKey.currentState!.validate()) {
                    ref.watch(profileProvider.notifier).updateProfile(
                      context,
                      name: nameController.text,
                    );
                  }
                  NavigationService.goBack(context);
                  },
                child:   LightButtonComponent(
                  icon: PlatformIcons(context).edit,
                  text: tr(context).change,
                  color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                      ? AppColors.lightThemeIconColor
                      : AppColors.darkThemePrimary,
                  textColor: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                      ? AppColors.lightThemeIconColor
                      : AppColors.darkThemePrimary,
                ),
              );
            },
            cupertino: (_, __) {
              return GestureDetector(
                onTap: (){
                  if (profileFormKey.currentState!.validate()) {
                    ref.watch(profileProvider.notifier).updateProfile(
                      context,
                      name: nameController.text,
                    );
                  }
                  NavigationService.goBack(context);
                },
                child:  LightButtonComponent(
                  icon: Icons.check,
                  text: tr(context).change,
                ),
              );
            },
          )

        ],
      ),
    );
  }
}
