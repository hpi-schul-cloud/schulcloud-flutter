import 'package:flutter_deep_linking/flutter_deep_linking.dart';

import 'widgets/dashboard_screen.dart';

final dashboardRoutes = Route(
  matcher: Matcher.path('dashboard'),
  materialBuilder: (_, __) => DashboardScreen(),
);
