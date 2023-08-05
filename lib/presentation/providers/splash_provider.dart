import 'package:get_storage/get_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../common/storage_keys.dart';
import '../../domain/services/init_services/services_initializer.dart';
import '../../firebase_checker.dart';
import '../routes/navigation_service.dart';
import '../routes/route_paths.dart';
import 'main_core_provider.dart';

final splashProvider =
Provider.autoDispose<SplashProvider>((ref) => SplashProvider(ref));

class SplashProvider {
  SplashProvider(this.ref) {
    _mainCoreProvider = ref.watch(mainCoreProvider);
    init();
  }

  final Ref ref;
  late MainCoreProvider _mainCoreProvider;
  late String secondPage;

  init() async {
    _mainCoreProvider.isConnectedToInternet().then((value) async {
      if (value) {
        initializeData().then(
              (_) async {
                GetStorage().write('reset',StorageKeys.falso);
                await _mainCoreProvider.initUser();
                NavigationService.pushReplacementAll(
                  NavigationService.context,
                  isNamed: true,
                  page: secondPage,
                );
          },
        );
      } else {
        NavigationService.pushReplacementAll(
          NavigationService.context,
          isNamed: true,
          page: RoutePaths.coreNoInternet,
          arguments: {'offAll': true},
        );
      }
    });
  }

  Future initializeData() async {
    List futures = [
      Future.delayed(const Duration(milliseconds: 1000)), //Min Time of splash
      ServicesInitializer.instance.initializeServices(),
      ServicesInitializer.instance.initializeData(),
    ];
    await Future.wait<dynamic>([...futures]);
    await checkForCachedUser();
  }

  Future checkForCachedUser() async {
    bool hasValidAuth = await _mainCoreProvider.checkValidAuth();

    if (hasValidAuth) {
      registerBackgroundTask();
      secondPage = RoutePaths.homeBase;
    } else {
      //recheck notification
      secondPage = RoutePaths.authLogin;
    }
  }
}
