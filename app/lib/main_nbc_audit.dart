import 'package:schulcloud/main.dart' as core;

import 'main_n21.dart';

final nbcAuditAppConfig = n21AppConfig.copyWith(
  name: 'nbc_audit',
  host: 'nbc-audit.hpi-schul-cloud.org',
  title: 'NBC Audit',
);

void main() => core.main(appConfig: nbcAuditAppConfig);
