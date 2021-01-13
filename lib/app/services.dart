import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info/package_info.dart';
import 'package:time_machine/time_machine.dart';

import 'banner/service.dart';
import 'hive.dart';
import 'logger.dart';
import 'services/api_network.dart';
import 'services/network.dart';
import 'services/snack_bar.dart';
import 'services/storage.dart';

final services = GetIt.instance;

Future<void> initServices() async {
  logger.d('Registering first services…');

  // We register this first as it's required for error reporting.
  services.registerSingletonAsync(StorageService.create);

  logger.d('Initializing hive…');
  await initializeHive();

  var timeZone = await FlutterNativeTimezone.getLocalTimezone();
  if (timeZone == 'GMT') timeZone = 'UTC';
  await TimeMachine.initialize({
    'rootBundle': rootBundle,
    'timeZone': timeZone,
  });

  logger.d('Registering remaining services…');
  services
    ..registerSingletonAsync(PackageInfo.fromPlatform)
    ..registerSingleton(BannerService())
    ..registerSingleton(SnackBarService())
    ..registerSingleton(NetworkService())
    ..registerSingleton(ApiNetworkService());
}

extension ServicesGetIt on GetIt {
  PackageInfo get packageInfo => get<PackageInfo>();
}
