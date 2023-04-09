import 'dart:developer';
import 'package:flutter/material.dart';

import '../../domain/services/localization_service.dart';
import '../routes/navigation_service.dart';
import '../routes/route_paths.dart';
import '../styles/app_colors.dart';
import '../tasks/providers/task_provider.dart';
import '../widgets/dialog_widget.dart';
import 'dialog_message_state.dart';

class AppDialogs {
  static Future showErrorDialog(BuildContext context, {String? message}) async {
    await DialogWidget.showCustomDialog(
      context: context,
      dialogWidgetState: DialogWidgetState.error,
      title: tr(context).oops,
      description: '${tr(context).somethingWentWrong}\n${message ?? tr(context).pleaseTryAgainLater}',
      textButton: tr(context).oK,
      onPressed: () {
        NavigationService.goBack(context,rootNavigator: true);
      },
    );
  }

  static Future showCheckDialog(BuildContext context, {String? message}) async {
    await DialogWidget.showCustomDialog(
      context: context,
      dialogWidgetState: DialogWidgetState.question,
      title: tr(context).oops,
      description: '${tr(context).somethingWentWrong}\n${message ?? tr(context).pleaseTryAgainLater}',
      textButton: tr(context).oK,
      textButton2: tr(context).cancel,
      onPressed: () {
        log('aceptar');
        TaskNotifier.aceptar = true;
        NavigationService.goBack(context,rootNavigator: true);
      },
      onPressed2: (){
        log('NO aceptar');
        TaskNotifier.aceptar = false;
        NavigationService.goBack(context,rootNavigator: true);
      }
    );
  }

  static Future showErrorNeutral(BuildContext context, {String? message}) async {
    await DialogWidget.showCustomDialog(
      context: context,
      dialogWidgetState: DialogWidgetState.error,
      title: tr(context).oops,
      description: message!,
      textButton: tr(context).oK,
      onPressed: () {
        NavigationService.goBack(context,rootNavigator: true);
      },
    );
  }

  static Future showInfo(BuildContext context, {String? message}) async {
    await DialogWidget.showCustomDialog(
      context: context,
      dialogWidgetState:
      Theme.of(context).iconTheme.color == AppColors.lightThemeIconColor
          ? DialogWidgetState.info
          : DialogWidgetState.infoDark,
      title: tr(context).info,
      description: message!,
      backgroundColor: AppColors.lightThemePrimaryColor,
      textButton: tr(context).oK,
      onPressed: () {
        NavigationService.goBack(context,rootNavigator: true);
      },
    );
  }

  static Future addTaskOK(BuildContext context, {String? message}) async {
    await DialogWidget.showCustomDialog(
      context: context,
      dialogWidgetState: DialogWidgetState.correct,
      title: message,
      textButton: tr(context).oK,
      onPressed: () {
        NavigationService.goBack(context,rootNavigator: true);
      },
    );
  }

  static Future signOutOk(BuildContext context, {String? message}) async {
    await DialogWidget.showCustomDialog(
      context: context,
      dialogWidgetState: DialogWidgetState.correct,
      title: message,
      textButton: tr(context).oK,
      onPressed: () {
        //NavigationService.goBack(context,rootNavigator: true);
        //Phoenix.rebirth(context);
        NavigationService.pushReplacementAll(
          NavigationService.context,
          isNamed: true,
          rootNavigator: true,
          page: RoutePaths.authLogin,
        );
      },
    );
  }


  static Future showWarning(BuildContext context, {String? message}) async {
    await DialogWidget.showCustomDialog(
      context: context,
      dialogWidgetState: DialogWidgetState.warning,
      title: tr(context).fill_core,
      textButton: tr(context).oK,
      onPressed: () {
        NavigationService.goBack(context,rootNavigator: true);
      },
    );
  }

  static Future showWarningAddRange(BuildContext context, {String? message}) async {
    await DialogWidget.showCustomDialog(
      context: context,
      dialogWidgetState: DialogWidgetState.warning,
      title: tr(context).rangeAdd,
      textButton: tr(context).oK,
      onPressed: () {
        NavigationService.goBack(context,rootNavigator: true);
      },
    );
  }


}

