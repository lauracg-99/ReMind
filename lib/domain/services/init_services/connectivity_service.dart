import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../presentation/routes/navigation_service.dart';
import '../../../presentation/routes/route_paths.dart';
import '../data_connection_service.dart';


final connectivityService = Provider<IConnectivityService>(
      (ref) => ConnectivityService(),
);

abstract class IConnectivityService {
  init();

  Future<bool> checkIfConnectedByConnectivity();

  Future<bool> checkIfConnected();
}

class ConnectivityService implements IConnectivityService {
  //`_isInitialized` is used to ensure that the listeners are only called once
  bool _isInitialized = false;

  //`_isInitialized` is used to prevent duplicate navigation from the two stream
  bool _isConnected = true;

  @override
  init() {
    if (_isInitialized) return;
    _initConnectivityStream();
    _initInternetCheckerStream();
    log("Connectivity stream has been initialized!!");
    _isInitialized = true;
  }

  //connectivity_plus: check for cellular and wifi connection "Does not guarantee connection to Internet".
  _initConnectivityStream() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      log("Connection status changed: $result");
      if (result == ConnectivityResult.none && _isConnected == true) {
        _isConnected = false;
        _navigateToNoInternetScreen();
      }
    });
  }

  //Checks for an internet (data) connection, by opening a socket to a list of addresses. DEFAULT_INTERVAL is 10 seconds which is the time between automatic checks.
  //Add <uses-permission android:name="android.permission.INTERNET"/> in AndroidManifest to work
  _initInternetCheckerStream() async {
    //Some delay to fix the exception happening if the app started with no connection as the DataConnectionChecker doesn't wait till Flutter is ready to navigate "till it renders its first frames".
    await Future.delayed(const Duration(seconds: 5));

    DataConnectionChecker().onStatusChange.listen((status) {
      log("Connection status changed : $status");
      if (status == DataConnectionStatus.disconnected && _isConnected == true) {
        _isConnected = false;
        _navigateToNoInternetScreen();
      }
    });
  }

  _navigateToNoInternetScreen() {
    NavigationService.push(
      NavigationService.context,
      isNamed: true,
      page: RoutePaths.coreNoInternet,
      arguments: {'offAll': false},
    );
  }

  @override
  Future<bool> checkIfConnectedByConnectivity() async {
    _isConnected =
        await Connectivity().checkConnectivity() != ConnectivityResult.none;
    return _isConnected;
  }

  @override
  Future<bool> checkIfConnected() async {
    _isConnected = await DataConnectionChecker().hasConnection;
    return _isConnected;
  }
}
