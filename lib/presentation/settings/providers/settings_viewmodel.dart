import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    cancelScheduledNotifications();

    NavigationService.pushReplacementAll(
      NavigationService.context,
      isNamed: true,
      rootNavigator: true,
      page: RoutePaths.authLogin,
    );
    //Delay until NavigationFadeTransition is done
    await Future.delayed(const Duration(seconds: 1));

    await _mainCoreProvider.logoutUser();


    log('**** signOut cool');
  }

  deleteAccount() async {
    cancelScheduledNotifications();

    NavigationService.pushReplacementAll(
      NavigationService.context,
      isNamed: true,
      rootNavigator: true,
      page: RoutePaths.authLogin,
    );
    //Delay until NavigationFadeTransition is done
    await Future.delayed(const Duration(seconds: 1));

    await _mainCoreProvider.deleteAccount();


    log('**** delete cool');
  }

}
