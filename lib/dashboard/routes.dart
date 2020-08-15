import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/module.dart';

import 'widgets/dashboard_screen.dart';

final dashboardRoutes = FancyRoute(
  matcher: Matcher.path('dashboard'),
  builder: (_, __) => DashboardScreen(),
);
