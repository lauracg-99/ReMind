import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../notifications/utils/notification_utils.dart';
import '../../notifications/utils/notifications.dart';
import '../../providers/main_core_provider.dart';
import '../../routes/navigation_service.dart';
import '../../routes/route_paths.dart';

final settingsViewModel =
    Provider<SettingsViewModel>((ref) => SettingsViewModel(ref));

class SettingsViewModel {
  SettingsViewModel(this.ref) {
    _mainCoreProvider = ref.watch(mainCoreProvider);
  }

  final Ref ref;
  late MainCoreProvider _mainCoreProvider;

  signOut() async {
    AwesomeNotifications().cancelAll();

    GetStorage().write('firstTimeLogIn', true);
    NavigationService.pushReplacementAll(
      NavigationService.context,
      isNamed: true,
      rootNavigator: true,
      page: RoutePaths.authLogin,
    );
    final prefs = await SharedPreferences.getInstance();
    var boss = prefs.getBool('is_SUPERVISOR') ?? false;
    if(!boss){
      await NotificationUtils.cancelNotiStateFBAll();
    }

    //Delay until NavigationFadeTransition is done
    await Future.delayed(const Duration(seconds: 1));

    await _mainCoreProvider.logoutUser();

  }

  deleteAccount() async {
    Notifications().cancelScheduledNotifications();

    NavigationService.pushReplacementAll(
      NavigationService.context,
      isNamed: true,
      rootNavigator: true,
      page: RoutePaths.authLogin,
    );
    //Delay until NavigationFadeTransition is done
    await Future.delayed(const Duration(seconds: 1));

    await _mainCoreProvider.deleteAccount();

  }

}
