import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../domain/services/localization_service.dart';
import '../providers/home_base_nav_providers.dart';
import '../styles/app_images.dart';
import '../styles/font_styles.dart';
import '../styles/sizes.dart';
import '../widgets/custom_text.dart';
import 'main_drawer_user_info_component.dart';


//pantalla que sale de lado
//AQUI SE PONEN LOS ITEMS
class MainDrawer extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MainDrawer({
    required this.scaffoldKey,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final indexNotifier = ref.watch(HomeBaseNavProviders.currentIndex.notifier);

    return SizedBox(
      width: Sizes.mainDrawerWidth(context),
      child: Drawer(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: Sizes.mainDrawerVPadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MainDrawerUserInfoComponent(),
                SizedBox(
                  height: Sizes.vMarginHigh(context),
                ),
                DrawerItem(
                  title: tr(context).myProfile,
                  icon: AppImages.profileScreenIcon,
                  onTap: () {
                    scaffoldKey.currentState!.openEndDrawer();
                    indexNotifier.state = 0;
                  },
                ),
                DrawerItem(
                  title: tr(context).settings,
                  icon: AppImages.settingsScreenIcon,
                  onTap: () {
                    scaffoldKey.currentState!.openEndDrawer();
                    indexNotifier.state = 2;
                  },
                ),


                SizedBox(
                  height: Sizes.vMarginMedium(context),
                ),
                //const MainDrawerBottomComponent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final String icon;
  final VoidCallback onTap;

  const DrawerItem({
    required this.title,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ImageIcon(
        AssetImage(icon),
      ),
      title: CustomText.h4(
        context,
        title,
        weight: FontStyles.fontWeightMedium,
      ),
      onTap: onTap,
      horizontalTitleGap: 0,
      contentPadding: EdgeInsets.symmetric(
        horizontal: Sizes.mainDrawerHPadding(context),
      ),
    );
  }
}
