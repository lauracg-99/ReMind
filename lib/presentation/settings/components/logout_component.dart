import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../domain/services/localization_service.dart';
import '../../styles/app_colors.dart';
import '../../styles/font_styles.dart';
import '../../styles/sizes.dart';
import '../../widgets/custom_text.dart';

import '../providers/settings_viewmodel.dart';

class LogoutComponent extends ConsumerWidget {
  const LogoutComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final settingsVM = ref.watch(settingsViewModel);

    return PlatformWidget(
      material: (_, __) {
        return InkWell(
          onTap: () async {
            await settingsVM.signOut();
          },
          child: const _SharedItemComponent(),
        );
      },
      cupertino: (_, __) {
        return GestureDetector(
          onTap: () async {
            await settingsVM.signOut();

          },
          child: const _SharedItemComponent(),
        );
      },
    );
  }
}


class _SharedItemComponent extends StatelessWidget {
  const _SharedItemComponent({
        Key? key,
      }) : super(key: key);

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
          color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
              ? AppColors.lightThemePrimary
              : AppColors.darkThemePrimary,
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
           Icon(
            Icons.logout,
            color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                ? AppColors.lightThemePrimary
                : AppColors.darkThemePrimary,
          ),
          SizedBox(
            width: Sizes.hMarginSmall(context),
          ),
          CustomText.h4(
            context,
            tr(context).logOut,
            alignment: Alignment.center,
            weight: FontStyles.fontWeightExtraBold,
            color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                ? AppColors.lightThemePrimary
                : AppColors.darkThemePrimary,
          ),
        ],
      ),
    );
  }
}