import 'package:flutter/material.dart';

/*

A design language, such as Material, defines standard behaviors when
transitioning between routes (or screens). Sometimes, though,
a custom transition between screens can make an app more unique.
To help, PageRouteBuilder provides an Animation object.
This Animation can be used with Tween and Curve objects
to customize the transition animation.
This recipe shows how to transition between routes by animating
the new route into view from the bottom of the screen.

https://docs.flutter.dev/cookbook/animation/page-route-animation

*/

class NavigationFadeTransition extends PageRouteBuilder {
  final Widget page;

  NavigationFadeTransition(
      this.page, {
        RouteSettings? settings,
        Duration? transitionDuration,
        Duration? reverseTransitionDuration,
      }) : super(
    settings: settings,
    pageBuilder: (_, __, ___) {
      return page;
    },
    transitionsBuilder: (_, a, __, c) =>
        FadeTransition(opacity: a, child: c),
    transitionDuration:
    transitionDuration ?? const Duration(milliseconds: 200),
    reverseTransitionDuration:
    reverseTransitionDuration ?? const Duration(milliseconds: 300),
  );
}

class NavigationSlideFromSide extends PageRouteBuilder {
  final Widget page;


  NavigationSlideFromSide(this.page, {RouteSettings? settings
    ,Duration? transitionDuration,})
      : super(
    settings: settings,
    pageBuilder: (_, __, ___) {
      return page;
    },
    transitionsBuilder: (_, a, __, c) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(a),
      child: c,
    ),
    transitionDuration: transitionDuration ?? const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
  );
}
