import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/module.dart';

import 'pages/settings.dart';

final settingsRoutes = FancyRoute(
  matcher: Matcher.path('settings'),
  builder: (_, __) => SettingsScreen(),
);
