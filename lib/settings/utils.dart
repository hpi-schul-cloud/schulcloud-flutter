import 'package:package_info/package_info.dart';
import 'package:schulcloud/app/app.dart';

String get appVersion {
  final packageInfo = services.get<PackageInfo>();
  return '${packageInfo.version}+${packageInfo.buildNumber}';
}
