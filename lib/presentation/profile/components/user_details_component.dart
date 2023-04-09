import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/auth/repo/user_repo.dart';
import '../../../domain/services/localization_service.dart';
import '../../styles/app_colors.dart';
import '../../styles/font_styles.dart';
import '../../styles/sizes.dart';
import '../../widgets/custom_text.dart';


class UserDetailsComponent extends ConsumerWidget {
  const UserDetailsComponent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final userModel = ref.watch(userRepoProvider).userModel!;

    return Column(
      children: [
        CustomText.h2(
          context,
          userModel.name!.isEmpty
              ? 'User${userModel.uId.substring(0, 6)}'
              : userModel.name!,
          weight: FontStyles.fontWeightBold,
          alignment: Alignment.center,
        ),
        SizedBox(
          height: Sizes.vMarginSmall(context),
        ),
        CustomText.h4(
          context,
          tr(context).profile_email,
          alignment: Alignment.centerLeft,
          //checkeamos si light mode
          color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
               ? AppColors.lightBlack
              : AppColors.white
        ),
        SizedBox(
          height: Sizes.vMarginSmall(context),
        ),
        CustomText.h4(
          context,
          '${userModel.email}',
          alignment: Alignment.center,
          color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
              ? AppColors.lightGray
              : AppColors.whiteGray,
        ),
        (userModel.rol != 'supervisor')
        ? SizedBox()
        : Column(
            children:
        [SizedBox(
          height: Sizes.vMarginSmall(context),
        ),
        CustomText.h4(
          context,
          tr(context).profile_rol,
        alignment: Alignment.centerLeft,
          color: //checkeamos si light mode
          Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
              ? AppColors.lightBlack
              : AppColors.white,
        ),
        SizedBox(
          height: Sizes.vMarginSmallest(context),
        ),
        CustomText.h4(
          context,
          '${userModel.rol}',
          alignment: Alignment.center,
          color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
              ? AppColors.lightGray
              : AppColors.whiteGray,
        ),

        SizedBox(
          height: Sizes.vMarginSmall(context),
        ),
        CustomText.h4(
          context,
          tr(context).profile_sup,
          alignment: Alignment.centerLeft,
          color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
              ? AppColors.lightBlack
              : AppColors.white,
        ),
        SizedBox(
          height: Sizes.vMarginSmall(context),
        ),
        CustomText.h4(
          context,
          '${userModel.emailSup}',
          alignment: Alignment.center,
          color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
              ? AppColors.lightGray
              : AppColors.whiteGray,
        ),])
      ],
    );
  }
}
