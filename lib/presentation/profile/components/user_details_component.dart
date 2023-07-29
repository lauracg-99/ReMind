import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
    var listSuper = ref.watch(userRepoProvider).usersSupervised;
    final userProvider = ref.watch(userRepoProvider);
    userProvider.getUserData(userModel.uId);
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
        ? const SizedBox()
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
          '${userModel.rol?.toUpperCase()}',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: listSuper.map((supervised) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText.h4(
                    context,
                    supervised.email,
                    alignment: Alignment.center,
                    color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                        ? AppColors.lightGray
                        : AppColors.whiteGray,
                  ),
                  SizedBox(height: Sizes.vMarginSmall(context)),
                ],
              );
            }).toList(),
          ),
        ])
      ],
    );
  }
}
