import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/module.dart';

import 'pages/sign_in/page.dart';
import 'pages/sign_out.dart';

final authRoutes = FancyRoute(
  routes: [
    FancyRoute(
      matcher: Matcher.path('login'),
      builder: (_, result) => SignInPage(),
    ),
    FancyRoute(
      matcher: Matcher.path('logout'),
      builder: (_, result) => SignOutPage(),
    ),
  ],
);
