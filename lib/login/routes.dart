import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/login/login.dart';

final loginRoutes = Route(
  matcher: Matcher.path('login'),
  builder: (_) => TopLevelPageRoute(builder: (_) => LoginScreen()),
);
