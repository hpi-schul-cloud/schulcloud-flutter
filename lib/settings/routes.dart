import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';

import 'widgets/settings_screen.dart';

final settingsRoutes = FancyRoute(
  matcher: Matcher.path('settings'),
  builder: (_, __) => SettingsScreen(),
);
