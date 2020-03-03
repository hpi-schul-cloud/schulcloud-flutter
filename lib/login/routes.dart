import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/login/login.dart';
import 'package:schulcloud/login/widgets/sign_out_screen.dart';

final loginRoutes = Route(
  routes: [
    Route(
      matcher: Matcher.path('login'),
      builder: (result) => TopLevelPageRoute(
        builder: (_) => LoginScreen(),
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
