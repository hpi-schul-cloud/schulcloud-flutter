import 'dart:async';

import 'package:logger/logger.dart';
import 'package:sentry/sentry.dart' hide User;
import 'package:sentry_flutter/sentry_flutter.dart';

import 'logger.dart';
import 'services.dart';
import 'services/storage.dart';

const _sentryDsn =
    'https://2d9dda495b8f4626b01e28e24c19a9b5@sentry.schul-cloud.dev/7';

Future<void> runWithErrorReporting(Future<void> Function() appRuner) async {
  logger.d('1');

  final isSentryEnabled = await _enableSentry();
  if (isSentryEnabled) {
    await SentryFlutter.init((options) => options.dsn = _sentryDsn);
  }

  await runZonedGuarded(() async {
    await appRuner();
  }, (exception, stackTrace) async {
    if (isSentryEnabled) {
      logger.e('Uncaught error:', exception, stackTrace);
      return;
    }

    final event = SentryEvent(
      throwable: ThrowableMechanism(
        Mechanism(type: 'runZonedGuarded', handled: true),
        exception,
      ),
      level: SentryLevel.fatal,
    );
    await Sentry.captureEvent(event);
  });
}

bool get isInDebugMode {
  var inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

Future<bool> _enableSentry() async {
  if (isInDebugMode) return false;

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
  return storage != null && storage.errorReportingEnabled.getValue();
}

Future<void> reportLogEvent(
  Level level,
  dynamic message,
  dynamic error,
  StackTrace stackTrace,
) async {
  const _loggerLevelToSentryLevel = {
    Level.verbose: SentryLevel.debug,
    Level.debug: SentryLevel.debug,
    Level.info: SentryLevel.info,
    Level.warning: SentryLevel.warning,
    Level.error: SentryLevel.error,
    Level.wtf: SentryLevel.fatal,
    Level.nothing: SentryLevel.debug,
  };

  final event = SentryEvent(
    level: _loggerLevelToSentryLevel[level],
    message: Message(message?.toString()),
    exception: error,
    // stackTrace: stackTrace,
    tags: {'source': 'logger'},
  );
  await Sentry.captureEvent(event, stackTrace: stackTrace);
}
