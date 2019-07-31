import 'package:flutter/material.dart';

import 'package:schulcloud/routes.dart';

class NavigationService {
  Routes activeScreen;
}

class MyNavigatorObserver extends RouteObserver {
  final NavigationService navigationService;

  MyNavigatorObserver({this.navigationService});

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    print('Navigated to ${Routes.fromString(newRoute.settings.name)}');
    navigationService.activeScreen = Routes.fromString(newRoute.settings.name);
  }
}
