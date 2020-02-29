import 'dart:convert';

import 'package:logger/logger.dart';
// ignore: implementation_imports
import 'package:logger/src/ansi_color.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

final logger = Logger(printer: FancyPrinter());

/// A [LogPrinter] similar to [PrettyPrinter], but with less vertical space.
class FancyPrinter extends LogPrinter {
  static final levelEmojis = {
    Level.verbose: '💤',
    Level.debug: '🐛',
    Level.info: '💡',
    Level.warning: '⚠️',
    Level.error: '⛔',
    Level.wtf: '👾',
  };

  static final timeFormat =
      LocalTimePattern.createWithInvariantCulture('HH:mm:ss;fff');
  static const stackTraceMethodCount = 10;

  static const verticalSpace = '   ';
  static const verticalLine = ' │ ';
  static const middleCorner = ' ├─';
  static const bottomCorner = ' └─';

  @override
  void log(LogEvent event) {
    final messageStr = stringifyMessage(event.message) ?? '';
    final timeStr = timeFormat.format(Instant.now().inLocalZone().clockTime);
    String stackTraceStr;
    if (event.stackTrace != null ||
        [Level.error, Level.wtf, Level.warning].contains(event.level)) {
      stackTraceStr = _formatStackTrace(event.stackTrace ?? StackTrace.current);
    }
    final errorStr = stringifyMessage(event.error);
    formatAndPrint(event.level, messageStr, timeStr, errorStr, stackTraceStr);
  }

  String stringifyMessage(dynamic message) {
    if (message == null) {
      return null;
    } else if (message is Map || message is Iterable) {
      return JsonEncoder.withIndent('  ').convert(message);
    } else {
      return message.toString();
    }
  }

  String _formatStackTrace(StackTrace stackTrace) {
    final formatted = <String>[];
    var count = 0;
    for (final line in stackTrace.toString().split('\n')) {
      final match = PrettyPrinter.stackTraceRegex.matchAsPrefix(line);
      if (match == null) {
        formatted.add(line);
        continue;
      }

      final method = match[1];
      final package = match[2];
      if (method == 'FancyPrinter.log' ||
          package.startsWith('package:logger')) {
        continue;
      }

      final newLine = '#$count  $method ($package)';
      formatted.add(newLine.replaceAll('<anonymous closure>', '()'));
      if (++count == stackTraceMethodCount) {
        break;
      }
    }
    return formatted.join('\n');
  }

  void formatAndPrint(Level level, String message, String time, String error,
      String stackTrace) {
    final color = PrettyPrinter.levelColors[level];

    final messageFirstLinebreakIndex = message.indexOf('\n');
    final title = messageFirstLinebreakIndex >= 0
        ? message.substring(0, messageFirstLinebreakIndex)
        : message;
    _printSection(
      title: ' $time: $title',
      content: messageFirstLinebreakIndex >= 0
          ? message.substring(messageFirstLinebreakIndex)
          : '',
      firstLinePrefix: levelEmojis[level],
      isLastSection: error == null && stackTrace == null,
      color: color,
    );

    _printSection(
      title: 'Error:',
      content: error,
      isLastSection: stackTrace == null,
      color: color,
    );
    _printSection(
      title: 'Stack trace:',
      content: stackTrace,
      firstLinePrefix: bottomCorner,
      isLastSection: true,
      color: color,
    );
  }

  void _printSection({
    @required String title,
    String firstLinePrefix,
    String content,
    @required bool isLastSection,
    @required AnsiColor color,
  }) {
    if (content == null) {
      return;
    }

    firstLinePrefix ??= isLastSection ? bottomCorner : middleCorner;
    println(color('$firstLinePrefix $title'));

    if (content.isNotEmpty) {
      final prefix = isLastSection ? verticalSpace : verticalLine;
      for (final line in content.split('\n')) {
        println(color('$prefix $line'));
      }
    }
  }
}
