import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_cache/hive_cache.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart' hide User;
import 'package:system_info/system_info.dart';

import 'app_config.dart';
import 'data.dart';
import 'logger.dart';
import 'services/storage.dart';
import 'utils.dart';

final _sentry = SentryClient(
    dsn: 'https://f5a0d14ac2aa4587beeddaa3db21ba44@sentry.schul-cloud.dev/11');

Future<void> runWithErrorReporting(Future<void> Function() body) async {
  await runZoned<Future<void>>(
    () async {
      FlutterError.onError = (details) async {
        if (isInDebugMode) {
          FlutterError.dumpErrorToConsole(details);
        }
        await reportEvent(Event(
          exception: details.exception,
          stackTrace: details.stack,
          tags: {'source': 'flutter'},
        ));
      };

      Logger.addLogListener(_reportLogEvent);
      await body();
      Logger.removeLogListener(_reportLogEvent);
    },
    // ignore: avoid_types_on_closure_parameters
    onError: (dynamic error, StackTrace stackTrace) async {
      if (isInDebugMode) {
        logger.e('Uncaught exception', error, stackTrace);
      }
      await reportEvent(Event(
        exception: error,
        stackTrace: stackTrace,
        tags: {'source': 'dart'},
      ));
    },
  );
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

const _loggerLevelToSentryLevel = {
  Level.verbose: SeverityLevel.debug,
  Level.debug: SeverityLevel.debug,
  Level.info: SeverityLevel.info,
  Level.warning: SeverityLevel.warning,
  Level.error: SeverityLevel.error,
  Level.wtf: SeverityLevel.fatal,
  Level.nothing: SeverityLevel.debug,
};
Future<void> _reportLogEvent(LogEvent event) async {
  await reportEvent(Event(
    level: _loggerLevelToSentryLevel[event.level],
    message: event.message,
    exception: event.error,
    stackTrace: event.stackTrace,
    tags: {'source': 'logger'},
  ));
}

Future<bool> reportEvent(Event event) async {
  if (isInDebugMode) {
    return true;
  }

  StorageService storage;
  try {
    await services.isReady<StorageService>();
    storage = services.storage;
    // ignore: avoid_catching_errors
  } on NoSuchMethodError {
    // GetIt always asserts that a factory is already registered for that type.
    // In production code, there is no specific exception being thrown (and of
    // course no assertions), but it will crash by calling methods on the
    // non-existent (`null`) factory.
  }
  // We don't have the permission to report errors or storage is null and we
  // have a Schrödinger's cat situation in which we can't guarantee a permission
  // to do so.
  if (storage == null || !storage.errorReportingEnabled.getValue()) {
    return true;
  }

  final packageInfo = await PackageInfo.fromPlatform();
  final platformString = defaultTargetPlatform.toString();
  User user = HiveCache.isInitialized ? await storage.userFromCache : null;
  final fullEvent = Event(
    release: packageInfo.version,
    environment: isInDebugMode ? 'debug' : 'production',
    message: event.message,
    exception: event.exception,
    stackTrace: event.stackTrace,
    level: event.level,
    contexts: await _getContexts(),
    tags: {
      'platform': platformString.substring(platformString.indexOf('.') + 1),
      'flavor': services.config.name,
      if (user != null) 'schoolId': user.schoolId,
      for (final entry in event.tags?.entries ?? {}) entry.key: entry.value,
    },
    extra: {
      'locale': window.locale.toString(),
      'textScaleFactor': window.textScaleFactor,
    },
  );

  final result = await _sentry.capture(event: fullEvent);
  return result.isSuccessful;
}

Future<Contexts> _getContexts() async {
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    final app = App(
      name: packageInfo.appName,
      version: packageInfo.version,
      identifier: packageInfo.packageName,
      build: packageInfo.buildNumber,
    );
    final dartRuntime = Runtime(
      name: 'Dart',
      version: Platform.version,
    );

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      return Contexts(
        device: Device(
          model: deviceInfo.model,
          arch: SysInfo.kernelArchitecture,
          manufacturer: deviceInfo.manufacturer,
          brand: deviceInfo.brand,
          simulator: !deviceInfo.isPhysicalDevice,
          memorySize: SysInfo.getTotalPhysicalMemory(),
          freeMemory: SysInfo.getFreePhysicalMemory(),
        ),
        operatingSystem: OperatingSystem(
          name: Platform.operatingSystem,
          version: deviceInfo.version.release,
          build: deviceInfo.version.incremental,
          kernelVersion: SysInfo.kernelVersion,
          rawDescription:
              'SDK ${deviceInfo.version.sdkInt}, ${Platform.operatingSystemVersion}',
        ),
        app: app,
        runtimes: [dartRuntime],
      );
    } else if (Platform.isIOS) {
      final deviceInfo = await DeviceInfoPlugin().iosInfo;
      return Contexts(
        device: Device(
          name: deviceInfo.name,
          family: deviceInfo.utsname.machine,
          model: deviceInfo.model,
          arch: SysInfo.kernelArchitecture,
          manufacturer: 'Apple',
          brand: 'Apple',
          simulator: !deviceInfo.isPhysicalDevice,
          memorySize: SysInfo.getTotalPhysicalMemory(),
          freeMemory: SysInfo.getFreePhysicalMemory(),
        ),
        operatingSystem: OperatingSystem(
          name: deviceInfo.systemName,
          version: deviceInfo.systemVersion,
          kernelVersion: SysInfo.kernelVersion,
          rawDescription: Platform.operatingSystem,
        ),
        app: app,
        runtimes: [dartRuntime],
      );
    } else {
      return Contexts(
        device: Device(
          arch: SysInfo.kernelArchitecture,
          memorySize: SysInfo.getTotalPhysicalMemory(),
          freeMemory: SysInfo.getFreePhysicalMemory(),
        ),
        operatingSystem: OperatingSystem(
          name: Platform.operatingSystem,
          version: Platform.operatingSystemVersion,
          kernelVersion: SysInfo.kernelVersion,
        ),
        app: app,
        runtimes: [dartRuntime],
      );
    }
  } catch (e) {
    return null;
  }
}
