import 'package:flutter/material.dart' hide Route;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/settings/settings.dart';

final settingsRoutes = Route.path(
  'settings',
  builder: (_) => MaterialPageRoute(builder: (_) => SettingsScreen()),
);
