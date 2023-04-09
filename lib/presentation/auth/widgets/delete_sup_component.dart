import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/auth/repo/user_repo.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/custom_text.dart';


class DeleteSupComponent extends HookConsumerWidget {
  const DeleteSupComponent({Key? key}) : super(key: key);
//todo: tr
  @override
  Widget build(BuildContext context, ref){
            return Column(
                children: [
                  Center(
                    child: CustomText.h2(
                        context, color: AppColors.darkGray,
                        tr(context).error_sup),
                  ),
                  SizedBox(
                    height: Sizes.vMarginMedium(context),
                  ),
                  Center(
                    child: CustomText.h3(
                        context, color: AppColors.darkGray,
                        tr(context).info_error_sup),
                  ),
                  SizedBox(
                    height: Sizes.vMarginHigh(context),
                  ),
                  CustomButton(
                    text: 'Volver',
                    onPressed: () {

                      ref.watch(userRepoProvider)
                          .deleteSupUid(GetStorage().read('uidSup'));

                      GetStorage().write('emailSup', '');
                      GetStorage().write('passwSup', '');
                      GetStorage().write('uidSup', '');

                      navigationToAddSup(context);
                    },
                  ),
                  SizedBox(
                    height: Sizes.vMarginSmall(context),
                  ),
                ]
            );

  }

  navigationToAddSup(BuildContext context) {
    NavigationService.pushReplacementAll(
      context,
      isNamed: true,
      page: RoutePaths.addSup,
    );
  }
}
