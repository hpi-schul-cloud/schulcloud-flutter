import 'package:flutter_deep_linking/flutter_deep_linking.dart';

import 'widgets/settings_screen.dart';

final settingsRoutes = Route(
  matcher: Matcher.path('settings'),
  materialBuilder: (_, __) => SettingsScreen(),
);
