import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../../data/auth/providers/checkbox_provider.dart';
import '../../../domain/services/localization_service.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';
import '../../styles/app_colors.dart';
import '../../styles/sizes.dart';
import '../../utils/dialogs.dart';
import '../../widgets/buttons/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/loading_indicators.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

class VerifyEmailFormComponent extends HookConsumerWidget {
   const VerifyEmailFormComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref){
  final _authStream = ref.watch(bossValidProvider);
  return _authStream.when(
      data: (authValid) {
     if(authValid!){
       return Column(
           children: [
             Row(
               mainAxisAlignment: MainAxisAlignment.center,
                 children:[
                   Center(
                     child: CustomText.h2(
                         context, color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                         ? AppColors.darkGray
                         : AppColors.whiteGray,
                         tr(context).register_user
                     ),
                   ),
                   IconButton(
                       alignment: Alignment.center,
                       onPressed: (){
                         AppDialogs.showInfo(context,message: tr(context).info_verify);
                       },
                       icon:  Icon(Icons.info_outline, color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                           ? AppColors.darkGray
                           : AppColors.whiteGray,)
                   ),
                 ]),
             SizedBox(
               height: Sizes.vMarginMedium(context),
             ),
             Center(
               child: CustomText.h3(
                   context,
                   color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                      ? AppColors.darkGray
                          : AppColors.whiteGray,
                   tr(context).register_text),
             ),
             SizedBox(
               height: Sizes.vMarginMedium(context),
             ),
               Center(
                 child: CustomButton(
                       text: tr(context).register_user,
                       onPressed: () {
                          navigationToAddSup(context);
                       },
                     )
                  )
           ]
       );
     }
     else{
       return Column(
             children: [
               Row(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children:[
                     Center(
                 child: CustomText.h2(
                     context,
                     color:
                     Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                         ? AppColors.darkGray
                         : AppColors.whiteGray,

                     tr(context).verifyTitle),
               ),
               IconButton(
               alignment: Alignment.center,
               onPressed: (){
               AppDialogs.showInfo(context,message: tr(context).info_verify);
               },
               icon: Icon(Icons.info_outline,
                 color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                     ? AppColors.darkGray
                     : AppColors.whiteGray,)
               ),
                   ]),
               SizedBox(
                 height: Sizes.vMarginMedium(context),
               ),
               Center(
                 child: CustomText.h3(
                     context, color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                     ? AppColors.darkGray
                     : AppColors.whiteGray,
                     tr(context).verifyMessage),
               ),
               SizedBox(
                 height: Sizes.vMarginHigh(context),
               ),
               //todo: poner fotico o algo
               //boton
               CustomButton(
                 text: tr(context).send,
                 onPressed: () {
                   //ref.watch(authProvider.notifier).enviarEmailVerification(context);
                 },
               ),
               SizedBox(
                 height: Sizes.vMarginSmall(context),
               ),
             ]);
     }
      },
      error: (err, stack) => CustomText.h4(
    context,
      tr(context).somethingWentWrong + '\n' + tr(context).pleaseTryAgainLater,
      color: AppColors.grey,
      alignment: Alignment.center,
      textAlign: TextAlign.center,
    ),
      loading: () => LoadingIndicators.instance.smallLoadingAnimation(context)
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
