import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';

import 'widgets/sign_in_screen.dart';
import 'widgets/sign_out_screen.dart';

final signInRoutes = Route(
  routes: [
    Route(
      matcher: Matcher.path('login'),
      builder: (result) => TopLevelPageRoute(
        builder: (_) => SignInScreen(),
        settings: result.settings,
      ),
    ),
    Route(
      matcher: Matcher.path('logout'),
      builder: (result) => TopLevelPageRoute(
        builder: (_) => SignOutScreen(),
        settings: result.settings,
      ),
    ),
  ],
);
