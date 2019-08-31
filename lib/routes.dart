/// This class emulates an enum of routes.
/// The choice of implementing it this way was made in order to
/// allow for routes to easily be interpreted as strings
/// while maintaining type safety for navigation

class Routes {
  final String _name;
  const Routes._internal(this._name);
  toString() => 'Routes.$_name';

  static const splashScreen = const Routes._internal('splashScreen');
  static const login = const Routes._internal('login');
  static const dashboard = const Routes._internal('dashboard');
  static const news = const Routes._internal('news');
  static const courses = const Routes._internal('courses');
  static const files = const Routes._internal('files');

  static List<Routes> get values =>
      [splashScreen, login, dashboard, news, courses, files];
  String get name => _name;
  static Routes fromString(String name) =>
      values.firstWhere((route) => route.name == name);
}
