import 'package:flutter/material.dart';
import 'package:schulcloud/app/theming/utils.dart';

@immutable
class AppConfigData {
  const AppConfigData({
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

  final String name;
  final String domain;
  String get host => 'https://$domain';
  String get apiUrl => 'https://api.$domain';

  final String title;
  final MaterialColor primaryColor;
  final MaterialColor secondaryColor;
  final MaterialColor accentColor;

  ThemeData createThemeData() {
    return ThemeData(
      primarySwatch: primaryColor,
      accentColor: accentColor,
      fontFamily: 'PT Sans',
      textTheme: _createTextTheme(Brightness.light),
    );
  }

  ThemeData createDarkThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: primaryColor,
      accentColor: accentColor,
      fontFamily: 'PT Sans',
      textTheme: _createTextTheme(Brightness.dark),
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
    if (Theme.of(context).brightness == Brightness.dark) {
      if (darkAssets.contains(assetName)) {
        final folder = assetName.substring(0, assetName.lastIndexOf('/'));
        final fileName = assetName.substring(assetName.lastIndexOf('/') + 1);
        assetName = '$folder/dark/$fileName';
      }
    }
    return 'assets/theme/$assetName';
  }
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
      color: fullOpacityOnBrightness(brightness),
    ),
    display2: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: fullOpacityOnBrightness(brightness),
    ),
  );
}

class AppConfig extends StatelessWidget {
  const AppConfig({
    Key key,
    @required this.data,
    @required this.child,
  })  : assert(child != null),
        assert(data != null),
        super(key: key);

  final AppConfigData data;
  final Widget child;

  static AppConfigData of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<_InheritedAppConfig>();
    return widget.appConfig.data;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedAppConfig(
      appConfig: this,
      child: child,
    );
  }
}

class _InheritedAppConfig extends InheritedWidget {
  const _InheritedAppConfig({
    Key key,
    @required this.appConfig,
    @required Widget child,
  })  : assert(appConfig != null),
        super(key: key, child: child);

  final AppConfig appConfig;

  @override
  bool updateShouldNotify(_InheritedAppConfig old) =>
      appConfig.data != old.appConfig.data;
}
