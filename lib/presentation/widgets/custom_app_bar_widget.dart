
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/material.dart';
import '../routes/navigation_service.dart';
import '../styles/app_colors.dart';
import '../styles/font_styles.dart';
import '../styles/sizes.dart';
import 'custom_text.dart';

class CustomAppBar extends PlatformAppBar {
  CustomAppBar(
      BuildContext context, {
        Key? key,
        Color? color,
        GlobalKey<ScaffoldState>? scaffoldKey,
        double? height,
        Color? appBarColor,
        String? title,
        Widget? customTitle,
        bool centerTitle = false,
        bool hasBackButton = false,
        dynamic result,
        bool hasMenuButton = false,
        Widget? customLeading,
        List<Widget>? trailingActions,
      }) : super(
    key: key,
    backgroundColor:
    appBarColor ?? Theme.of(context).appBarTheme.backgroundColor,
    leading: hasBackButton
        ? CustomBackButton(result: result, color: color,)
        : hasMenuButton
        ? _MenuButton(scaffoldKey: scaffoldKey!)
        : customLeading,
    automaticallyImplyLeading: false,
    trailingActions: [
      if (trailingActions != null) ...trailingActions,
      if (hasBackButton)
        SizedBox(
          width: Sizes.appBarBackButtonRadius(context),
        ),
      if (hasMenuButton)
        SizedBox(
          width: Sizes.appBarMenuButtonRadius(context),
        ),
    ],
    material: (_, __) {
      return MaterialAppBarData(
        elevation: 0,
        toolbarHeight: height ?? Sizes.appBarDefaultHeight(context),
        title: title != null
            ? CustomText.h2(
          context,
          title,
          weight: FontStyles.fontWeightBold,
          color: AppColors.white,
          alignment: centerTitle ? Alignment.center : null,
        )
            : customTitle,
        leadingWidth: Sizes.appBarBackButtonRadius(context) * 2,
        titleSpacing: Sizes.hPaddingMedium(context),
      );
    },
    cupertino: (_, __) {
      return CupertinoNavigationBarData(
        transitionBetweenRoutes: false,
        border: Border.all(style: BorderStyle.none),
        title: title != null
            ? CustomText.h2(
          context,
          title,
          weight: FontStyles.fontWeightBold,
          color: AppColors.white,
          alignment: Alignment.center,
        )
            : customTitle,
      );
    },
  );
}

class _MenuButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const _MenuButton({
    required this.scaffoldKey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformIconButton(
      onPressed: () {
        scaffoldKey.currentState?.openDrawer();
      },
      icon: Icon(
        Icons.menu_rounded,
        size: Sizes.appBarMenuButtonRadius(context),
        color: Theme.of(context).iconTheme.color,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.appBarMenuButtonRadius(context) / 2,
      ),
      material: (_, __) {
        return MaterialIconButtonData(
          constraints: const BoxConstraints(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        );
      },
      cupertino: (_, __) {
        return CupertinoIconButtonData(
          alignment: Alignment.center,
        );
      },
    );
  }
}

class CustomBackButton extends StatelessWidget {
  final dynamic result;
  final Color? color;

  const CustomBackButton({
    required this.result,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformIconButton(
      onPressed: () {
        NavigationService.goBack(context, result: result);
      },
      icon: Icon(
        PlatformIcons(context).back,
        color: color ?? Theme.of(context).iconTheme.color,
        size: Sizes.appBarBackButtonRadius(context),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Sizes.appBarBackButtonRadius(context) / 2,
      ),
      material: (_, __) {
        return MaterialIconButtonData(
          constraints: const BoxConstraints(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        );
      },
      cupertino: (_, __) {
        return CupertinoIconButtonData(
          minSize: 0.0,
          alignment: Alignment.center,
        );
      },
    );
  }
}
