import 'package:flutter/material.dart';

import 'package:schulcloud/routes.dart';

/// A service that saves the active screen.
class NavigationService {
  Routes activeScreen;
}

/// An observer that observs the [MaterialApp]'s [Navigator] and saves the
/// active screen to the [NavigationService] when we navigate to a top-level
/// screen.
class MyNavigatorObserver extends RouteObserver {
  final NavigationService navigationService;

  MyNavigatorObserver({@required this.navigationService})
      : assert(navigationService != null);

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    var route = Routes.fromString(newRoute.settings.name);
    if (route != null) {
      navigationService.activeScreen = route;
    }
  }
}
