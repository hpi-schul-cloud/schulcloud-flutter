import 'dart:convert';

import 'package:logger/logger.dart';
// ignore: implementation_imports
import 'package:logger/src/ansi_color.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

import 'error_reporting.dart';

final logger = _FancyLogger();

/// The new logger package doesn't offer a way to access raw [LogEvent]s with
/// their error and stack trace fields, but only formatted output after
/// [LogPrinter]s.
class _FancyLogger extends Logger {
  _FancyLogger() : super(filter: _FancyFilter(), printer: _FancyPrinter());

  @override
  void log(
    Level level,
    dynamic message, [
    dynamic error,
    StackTrace stackTrace,
  ]) {
    super.log(level, message, error, stackTrace);
    reportLogEvent(level, message, error, stackTrace);
  }
}

class _FancyFilter extends LogFilter {
  static const _prodMinLevel = Level.error;

  @override
  bool shouldLog(LogEvent event) {
    if (!isInDebugMode) return event.level.index >= _prodMinLevel.index;
    return true;
  }
}

/// A [LogPrinter] similar to [PrettyPrinter], but using less vertical space.
class _FancyPrinter extends LogPrinter {
  static final levelEmojis = {
    ...PrettyPrinter.levelEmojis,
    Level.verbose: '💤',
  };

  static final timeFormat =
      LocalTimePattern.createWithInvariantCulture('HH:mm:ss;fff');
  static const stackTraceMethodCount = 10;

  static const verticalSpace = '   ';
  static const verticalLine = ' │ ';
  static const middleCorner = ' ├─';
  static const bottomCorner = ' └─';

  final _prettyPrinter = PrettyPrinter();

  @override
  List<String> log(LogEvent event) {
    final messageStr = stringifyMessage(event.message) ?? '';
    final timeStr = timeFormat.format(Instant.now().inLocalZone().clockTime);

    final level = event.error is AssertionError ? Level.wtf : event.level;

    String stackTrace;
    if (event.stackTrace != null || [Level.error, Level.wtf].contains(level)) {
      stackTrace = _prettyPrinter.formatStackTrace(
        event.stackTrace ?? StackTrace.current,
        stackTraceMethodCount,
      );
    }
    final errorStr = stringifyMessage(event.error);
    return format(level, messageStr, timeStr, errorStr, stackTrace).toList();
  }

  String stringifyMessage(dynamic message) {
    if (message == null) return null;
    if (message is String) return message;

    dynamic toEncodable(dynamic object) {
      try {
        return object.toJson();
      } catch (_) {
        try {
          return '$object';
        } catch (_) {
          return object.runtimeType;
        }
      }
    }

    return JsonEncoder.withIndent('  ', toEncodable).convert(message);
  }

  Iterable<String> format(
    Level level,
    String message,
    String time,
    String error,
    String stackTrace,
  ) sync* {
    final color = PrettyPrinter.levelColors[level];

    final messageFirstLinebreakIndex = message.indexOf('\n');
    final title = messageFirstLinebreakIndex >= 0
        ? message.substring(0, messageFirstLinebreakIndex)
        : message;
    yield* _formatSection(
      title: '$time: $title',
      content: messageFirstLinebreakIndex >= 0
          ? message.substring(messageFirstLinebreakIndex + 1)
          : '',
      firstLinePrefix: levelEmojis[level],
      isLastSection: error == null && stackTrace == null,
      color: color,
    );

    yield* _formatSection(
      title: 'Error:',
      content: error,
      isLastSection: stackTrace == null,
      color: color,
    );
    yield* _formatSection(
      title: 'Stack trace:',
      content: stackTrace,
      firstLinePrefix: bottomCorner,
      isLastSection: true,
      color: color,
    );
  }

  Iterable<String> _formatSection({
    @required String title,
    String firstLinePrefix,
    String content,
    @required bool isLastSection,
    @required AnsiColor color,
  }) sync* {
    if (content == null) {
      return;
    }

    firstLinePrefix ??= isLastSection ? bottomCorner : middleCorner;
    yield color('$firstLinePrefix \t$title');

    if (content.isNotEmpty) {
      final prefix = isLastSection ? verticalSpace : verticalLine;
      for (final line in content.split('\n')) {
        yield color('$prefix \t$line');
      }
    }
  }
}
