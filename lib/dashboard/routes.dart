import 'package:flutter/material.dart' hide Route;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';

import 'widgets/dashboard_screen.dart';

final dashboardRoutes = Route.path(
  'dashboard',
  builder: (_) => MaterialPageRoute(builder: (_) => DashboardScreen()),
);
