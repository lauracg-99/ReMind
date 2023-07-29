import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/presentation/widgets/custom_text.dart';

import '../../../domain/services/localization_service.dart';
import '../../styles/sizes.dart';
import '../../utils/dialogs.dart';
import '../../widgets/custom_app_bar_widget.dart';


/// The default height of the toolbar component of the [AppBar].
const double kToolbarHeight = 56.0;

class PreferredAppBarSize extends Size {
  PreferredAppBarSize(this.toolbarHeight, this.bottomHeight)
      : super.fromHeight(
      (toolbarHeight ?? kToolbarHeight) + (bottomHeight ?? 0));

  final double? toolbarHeight;
  final double? bottomHeight;
}

//todo appbar
class AppBarSolicitudes extends ConsumerWidget
    implements PreferredSizeWidget, ObstructingPreferredSizeWidget {
  final double? toolbarHeight;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final String? title;
  static bool supervisor = false;

  AppBarSolicitudes({
    this.toolbarHeight,
    this.bottom,
    this.backgroundColor,
    this.scaffoldKey,
    this.title,
    Key? key,
  })  : preferredSize =
  PreferredAppBarSize(toolbarHeight, bottom?.preferredSize.height),
        super(key: key);

  setSupervisor(bool set) {
    supervisor = set;
  }

  // el app bar que enseñar según donde estés
  @override
  Widget build(BuildContext context, WidgetRef ref) {
        return CustomAppBar(
          context,
          hasBackButton: true,
            color: Theme.of(context).colorScheme.primary,
          customTitle: CustomText.h3(
              context,
              title ?? '',
              color: Theme.of(context).colorScheme.primary,
          ),
          trailingActions: [
            Container(
              padding: EdgeInsets.only(right: Sizes.vMarginMedium(context)),
              child: IconButton(
                  alignment: Alignment.center,
                  onPressed: () {
                    AppDialogs.showInfo(context,
                        message: tr(context).info_change_name);
                  },
                  icon: Icon(
                    Icons.info_outline,
                    color: Theme.of(context).iconTheme.color,
                  )),
            )
          ],
        );
    }

  @override
  final Size preferredSize;

  @override
  bool shouldFullyObstruct(BuildContext context) {
    final Color backgroundColor =
        CupertinoDynamicColor.maybeResolve(this.backgroundColor, context) ??
            CupertinoTheme.of(context).barBackgroundColor;
    return backgroundColor.alpha == 0xFF;
  }

}
