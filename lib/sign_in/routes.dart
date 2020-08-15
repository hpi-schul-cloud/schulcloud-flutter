import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/module.dart';

import 'widgets/sign_in_screen.dart';
import 'widgets/sign_out_screen.dart';

final signInRoutes = FancyRoute(
  routes: [
    FancyRoute(
      matcher: Matcher.path('login'),
      builder: (_, result) => SignInScreen(),
    ),
    FancyRoute(
      matcher: Matcher.path('logout'),
      builder: (_, result) => SignOutScreen(),
    ),
  ],
);
