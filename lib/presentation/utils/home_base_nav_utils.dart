import 'package:flutter/material.dart';
import '../routes/app_router.dart';
import '../routes/route_paths.dart';
import '../screens/nested_navigator_screen.dart';

abstract class HomeBaseNavUtils {
  static final navScreensKeys = [
    GlobalKey<NavigatorState>(debugLabel: 'page1'),
    GlobalKey<NavigatorState>(debugLabel: 'page2'),
    GlobalKey<NavigatorState>(debugLabel: 'page3'),
    GlobalKey<NavigatorState>(debugLabel: 'page4'),
  ];

  static const navScreens = [
    //Nested Navigator for persistent bottom navigation bar
    NestedNavigatorScreen(
      index: 0,
      screenPath: RoutePaths.profile,
      onGenerateRoute: AppRouter.generateProfileNestedRoute,
    ),
    NestedNavigatorScreen(
      index: 1,
      screenPath: RoutePaths.home,
      onGenerateRoute: AppRouter.generateHomeNestedRoute,
    ),
    NestedNavigatorScreen(
      index: 2,
      screenPath: RoutePaths.settings,
      onGenerateRoute: AppRouter.generateSettingsNestedRoute,
    ),

    NestedNavigatorScreen(
      index: 3,
      screenPath: RoutePaths.supervisores,
      onGenerateRoute: AppRouter.generateSettingsNestedRoute,
    ),
  ];
}
