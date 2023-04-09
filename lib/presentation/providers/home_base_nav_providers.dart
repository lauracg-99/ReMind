import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../routes/navigation_route_observer.dart';
import '../routes/route_paths.dart';

class HomeBaseNavProviders {
  static final currentIndex = StateProvider.autoDispose<int>((ref) => 1);

  static final routes = [
    StateProvider.autoDispose<String>((ref) => RoutePaths.profile),
    StateProvider.autoDispose<String>((ref) => RoutePaths.home),
    StateProvider.autoDispose<String>((ref) => RoutePaths.settings),

    ///nav bar
    StateProvider.autoDispose<String>((ref) => RoutePaths.navBar),

    StateProvider.autoDispose<String>((ref) => RoutePaths.modScreen),

  ];

  static final routeObservers = [
    Provider.autoDispose<NavigatorRouteObserver>(
      (ref) => NavigatorRouteObserver(
        routesStackCallBack: (List<Route> _routes) {
          ref.watch(routes[0].notifier).state = _routes.last.settings.name!;
        },
      ),
    ),
    Provider.autoDispose<NavigatorRouteObserver>(
      (ref) => NavigatorRouteObserver(
        routesStackCallBack: (List<Route> _routes) {
          ref.watch(routes[1].notifier).state = _routes.last.settings.name!;
        },
      ),
    ),
    Provider.autoDispose<NavigatorRouteObserver>(
      (ref) => NavigatorRouteObserver(
        routesStackCallBack: (List<Route> _routes) {
          ref.watch(routes[2].notifier).state = _routes.last.settings.name!;
        },
      ),
    ),

    Provider.autoDispose<NavigatorRouteObserver>(
          (ref) => NavigatorRouteObserver(
        routesStackCallBack: (List<Route> _routes) {
          ref.watch(routes[4].notifier).state = _routes.last.settings.name!;
        },
      ),
    ),

  ];
}
