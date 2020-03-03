import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'theming_utils.dart';
import 'utils.dart';

@immutable
class AppConfig {
  const AppConfig({
    @required this.name,
    @required this.domain,
    @required this.title,
    @required this.primaryColor,
    @required this.secondaryColor,
    @required this.accentColor,
  })  : assert(name != null),
        assert(domain != null),
        assert(title != null),
        assert(primaryColor != null),
        assert(secondaryColor != null),
        assert(accentColor != null);

  static const darkAssets = [
    'n21/logo/logo_with_text.svg',
    'open/logo/logo_with_text.svg',
    'thr/logo/logo_with_text.svg',
  ];
  static const errorColor = Color(0xFFDC2831);

  final String name;
  final String domain;
  String get baseWebUrl => 'https://$domain';
  String webUrl(String path) => '$baseWebUrl/$path';
  String get baseApiUrl => 'https://api.$domain';

  final String title;
  final MaterialColor primaryColor;
  final MaterialColor secondaryColor;
  final MaterialColor accentColor;

  ThemeData createThemeData(Brightness brightness) {
    var theme = ThemeData(
      brightness: brightness,
      primarySwatch: primaryColor,
      accentColor: accentColor,
      errorColor: errorColor,
      scaffoldBackgroundColor:
          brightness == Brightness.light ? Colors.white : null,
      fontFamily: 'PT Sans',
      textTheme: _createTextTheme(brightness),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
    if (brightness == Brightness.dark) {
      theme = theme.copyWith(
        chipTheme: theme.chipTheme.copyWith(
          shape: StadiumBorder(
            side: BorderSide(color: theme.dividerColor),
          ),
        ),
      );
    }
    return theme.copyWith(
      // TabBar assumes a primary colored background
      tabBarTheme: theme.tabBarTheme.copyWith(
        labelColor: theme.accentColor,
        unselectedLabelColor: theme.mediumEmphasisColor,
      ),
    );
  }

  TextTheme _createTextTheme(Brightness brightness) {
    return TextTheme(
      title: TextStyle(fontWeight: FontWeight.bold),
      body1: TextStyle(fontSize: 16),
      body2: TextStyle(fontSize: 16),
      button: TextStyle(
        color: Color(0xff373a3c),
        fontFamily: 'PT Sans Narrow',
        fontWeight: FontWeight.w700,
        fontSize: 16,
        height: 1.25,
      ),
      display1: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 28,
        color: brightness.contrastColor,
      ),
      display2: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: brightness.contrastColor,
      ),
      overline: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  /// Returns the full asset name of a themed asset.
  String assetName(BuildContext context, String rawName) {
    var assetName = '$name/$rawName';
    // Fetching available assets at runtime is hard to implement at the moment.
    // Unless we want to implement the logic of AssetImage.obtainKey ourselves
    // (loading the undocumented AssetManifest.json and matching available
    // assets with the requested one, factoring in dark mode), this is the
    // easiest workaround.
    if (context.theme.isDark) {
      if (darkAssets.contains(assetName)) {
        final folder = assetName.substring(0, assetName.lastIndexOf('/'));
        final fileName = assetName.substring(assetName.lastIndexOf('/') + 1);
        assetName = '$folder/dark/$fileName';
      }
    }
    return 'assets/theme/$assetName';
  }
}

extension AppConfigGetIt on GetIt {
  AppConfig get config => get<AppConfig>();
}

String scWebUrl(String path) => services.config.webUrl(path);
