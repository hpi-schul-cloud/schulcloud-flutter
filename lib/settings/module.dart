import 'package:flutter/foundation.dart';
import 'package:schulcloud/app/module.dart';

import 'licenses.dart';

export 'pages/settings.dart';
export 'routes.dart';
export 'widgets/legal_bar.dart';

void initSettings() {
  logger
    ..i('Initializing module settings…')
    ..d('Adding custom licenses to registry…');
  LicenseRegistry.addLicense(() async* {
    yield EmptyStateLicense();
  });
}
