import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:remind/presentation/screens/popup_page.dart';
import '../../domain/services/init_services/connectivity_service.dart';
import '../../domain/services/localization_service.dart';
import '../components/data_error_component.dart';
import '../routes/navigation_service.dart';
import '../routes/route_paths.dart';
import '../styles/sizes.dart';

class NoInternetConnection extends ConsumerWidget {
  final bool offAll;

  const NoInternetConnection({
    this.offAll = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final _connectivityService = ref.watch(connectivityService);

    return PopUpPage(
      onWillPop: () {
        NavigationService.pushReplacementAll(
          context,
          isNamed: true,
          page: RoutePaths.coreSplash,
        );
        return Future.value(true);
      },
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: Sizes.screenHPaddingDefault(context)),
        child: DataErrorComponent(
          title: tr(context).noInternetConnection,
          description: tr(context).pleaseCheckYourDeviceNetwork,
          onPressed: () {
            _connectivityService.checkIfConnected().then(
                  (value) {
                if (value) {
                  if (offAll) {
                    NavigationService.pushReplacementAll(
                      context,
                      isNamed: true,
                      page: RoutePaths.coreSplash,
                    );
                  } else {
                    //Use pop instead of maybePop to be able to back to nested navigator from this screen
                    NavigationService.goBack(context, maybePop: false);
                  }
                }
              },
            );
          },
        ),
      ),
    );
  }
}