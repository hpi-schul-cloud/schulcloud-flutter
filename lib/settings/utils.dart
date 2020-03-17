import 'package:package_info/package_info.dart';

Future<String> getAppVersion() async {
  final packageInfo = await PackageInfo.fromPlatform();
  return '${packageInfo.version}+${packageInfo.buildNumber}';
}
