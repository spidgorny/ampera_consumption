import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState.pushNamed(routeName);
  }

  Future<dynamic> push(MaterialPageRoute route) {
    return navigatorKey.currentState.push(route);
  }

  Future<dynamic> replace(MaterialPageRoute route) {
    return navigatorKey.currentState.pushReplacement(route);
  }

  bool goBack() {
    return navigatorKey.currentState.pop();
  }
}
