import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/components/profile_form_component.dart';
import '../../screens/popup_page_nested.dart';
import '../../styles/app_colors.dart';
import '../../styles/app_images.dart';
import '../../styles/sizes.dart';
import '../../widgets/loading_indicators.dart';


class EditNameScreen extends StatelessWidget {
  const EditNameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopUpPageNested(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Sizes.screenVPaddingDefault(context),
            horizontal: Sizes.screenHPaddingDefault(context),
          ),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                    ? AppColors.lightThemeIconColor
                    : AppColors.darkThemePrimary,
                radius: Sizes.userImageMediumRadius(context),
                child:  Image.asset(
                  Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                      ? AppImages.nameEdit
                      : AppImages.nameEditDark,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: Sizes.vMarginMedium(context),
              ),

              const ProfileFormComponent(),

              SizedBox(
                height: Sizes.vMarginMedium(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
