import 'package:package_info/package_info.dart';

Future<String> get appVersion async {
  final packageInfo = await PackageInfo.fromPlatform();
  return '${packageInfo.version}+${packageInfo.buildNumber}';
}
