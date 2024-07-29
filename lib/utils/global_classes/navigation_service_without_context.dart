import 'package:flutter/material.dart';

class NavigationService {

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static final currentContext = navigatorKey.currentContext!;

  dynamic routeTo(dynamic route, {dynamic arguments}) {
    return navigatorKey.currentState?.pushNamed(route, arguments: arguments);
  }

  dynamic goBack() {
    return navigatorKey.currentState?.pop();
  }
}