import 'package:schulcloud/main.dart' as core;

import 'main_sc.dart';

final scTestAppConfig = scAppConfig.copyWith(
  host: 'test.hpi-schul-cloud.org',
  title: 'HPI Schul-Cloud (Test)',
);

void main() => core.main(appConfig: scTestAppConfig);
