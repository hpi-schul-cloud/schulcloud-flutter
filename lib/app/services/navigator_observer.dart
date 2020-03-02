import 'package:flutter/cupertino.dart';

import '../logger.dart';

class LoggingNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    logger.d(
        'Navigator didPush ${routeToString(previousRoute)} → ${routeToString(route)}');
  }

  @override
  void didPop(Route route, Route previousRoute) {
    logger.d(
        'Navigator didPush ${routeToString(previousRoute)} → ${routeToString(route)}');
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    logger.d(
        'Navigator didPush ${routeToString(previousRoute)} → ${routeToString(route)}');
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    logger.d(
        'Navigator didReplace ${routeToString(oldRoute)} → ${routeToString(newRoute)}');
  }

  String routeToString(Route<dynamic> route) => route?.settings?.name;
}
