import 'package:flutter/material.dart';

@immutable
class AppConfigData {
  const AppConfigData({
    @required this.name,
    @required this.title,
    @required this.primaryColor,
    @required this.secondaryColor,
    @required this.accentColor,
  })  : assert(name != null),
        assert(title != null),
        assert(primaryColor != null),
        assert(secondaryColor != null),
        assert(accentColor != null);

  final String name;
  final String title;
  final MaterialColor primaryColor;
  final MaterialColor secondaryColor;
  final MaterialColor accentColor;

  ThemeData createThemeData() {
    return ThemeData(
      primarySwatch: primaryColor,
      accentColor: accentColor,
      fontFamily: 'PT Sans',
      textTheme: _textTheme,
    );
  }

  /// Returns the full asset name of a themed asset.
  String assetName(String rawName) => 'assets/theme/$name/$rawName';
}

const _textTheme = const TextTheme(
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
    color: Colors.black,
  ),
  display2: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 32,
    color: Colors.black,
  ),
);

enum Flavor {
  schulCloud,
  brb,
  n21,
  thr,
  open,
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
    final widget = (context.inheritFromWidgetOfExactType(_InheritedAppConfig)
        as _InheritedAppConfig);
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
  })  : assert(AppConfig != null),
        super(key: key, child: child);

  final AppConfig appConfig;

  @override
  bool updateShouldNotify(_InheritedAppConfig old) =>
      appConfig.data != old.appConfig.data;
}