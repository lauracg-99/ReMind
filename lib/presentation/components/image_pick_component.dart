import 'package:flutter/material.dart';
import '../../domain/services/localization_service.dart';
import '../routes/navigation_service.dart';
import '../styles/app_colors.dart';
import '../styles/app_images.dart';
import '../styles/sizes.dart';
import '../widgets/custom_text.dart';


class ImagePickComponent extends StatelessWidget {
  const ImagePickComponent({
    required this.pickFromCameraFunction,
    required this.pickFromGalleryFunction,
    Key? key,
  }) : super(key: key);

  final Function pickFromCameraFunction;
  final Function pickFromGalleryFunction;

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      padding: EdgeInsets.symmetric(
        vertical: Sizes.vPaddingSmallest(context),
        horizontal: Sizes.hPaddingSmallest(context),
      ),
      constraints: const BoxConstraints(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      onPressed: () {
        FocusScope.of(context).requestFocus(FocusNode());
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: CustomText.h3(
                context,
                tr(context).chooseOption,
                color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                    ? AppColors.accentColorLight
                    : AppColors.darkThemePrimary,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(
                    height: 1,
                  ),
                  Material(
                    color: Theme.of(context).primaryColor,
                    child: ListTile(
                      onTap: () async {
                        try {
                          pickFromCameraFunction();
                          NavigationService.goBack(context);
                        } catch (error) {
                          NavigationService.goBack(context);
                        }
                      },
                      title: CustomText(
                        context,
                        tr(context).camera,
                      ),
                      leading:  Icon(
                        Icons.camera,
                        color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                            ? AppColors.accentColorLight
                            : AppColors.darkThemePrimary,
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                  ),
                  Material(
                    color: Theme.of(context).primaryColor,
                    child: ListTile(
                      onTap: () async {
                        try {
                          pickFromGalleryFunction();
                          NavigationService.goBack(context);
                        } catch (error) {
                          NavigationService.goBack(context);
                        }
                      },
                      title: CustomText(
                        context,
                        tr(context).gallery,
                      ),
                      leading:  Icon(
                        Icons.account_box,
                        color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
                            ? AppColors.accentColorLight
                            : AppColors.darkThemePrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      shape: const CircleBorder(),
      fillColor: Theme.of(context).primaryColor,
      elevation: 1,
      child: ImageIcon(
        const AssetImage(AppImages.cameraIcon),
        size: Sizes.iconsSizes(context)['s7'],
        color: Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
            ? AppColors.grey
            : AppColors.white
      ),
    );
  }
}
