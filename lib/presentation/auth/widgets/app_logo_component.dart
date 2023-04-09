import 'package:flutter/material.dart';
import '../../../domain/services/localization_service.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_images.dart';
import '../../styles/sizes.dart';
import '../../utils/dialogs.dart';
import '../../widgets/custom_image.dart';
import '../../widgets/custom_text.dart';

class AppLogoComponent extends StatelessWidget {
  const AppLogoComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomImage(
          context,
          Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
              ? AppImages.loginIcon
              : AppImages.loginIconDark,

          //height: Sizes.loginLogoSize(context),
          //width: Sizes.loginLogoSize(context),
          fit: BoxFit.cover,
          //imageAndTitleAlignment: MainAxisAlignment.start,
        ),
        SizedBox(
          height: Sizes.vMarginSmallest(context),
        ),

        Row(
            //mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:[
            Container(
              child: CustomText.h1(
              context,
              //tr(context).welcome,
              alignment: Alignment.center,
              tr(context).signInToYourAccount,
              color: AppColors.grey,
            ),),
          //SizedBox(width: Sizes.vMarginExtreme(context),),
              Container(
                padding: EdgeInsets.only(
                  //top: Sizes.hMarginExtreme(context),
                  //bottom: Sizes.vMarginSmallest(context),
                  //right: Sizes.vMarginSmall(context),
                  left: Sizes.vMarginExtreme(context) + 7,
                ),
                alignment: Alignment.topRight,
                child: IconButton(
                    alignment: Alignment.center,
                    onPressed: (){
                      AppDialogs.showInfo(context,message: tr(context).info_login);
                    },
                    icon: Icon(Icons.info_outline,
                      color: Theme.of(context).iconTheme.color,
                    )
                ),
              ),
        ]),

      ],
    );
  }
}
