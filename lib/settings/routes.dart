import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/settings/settings.dart';

final settingsRoutes = Route(
  matcher: Matcher.path('settings'),
  materialPageRouteBuilder: (_, __) => SettingsScreen(),
);
