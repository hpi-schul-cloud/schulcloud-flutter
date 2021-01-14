import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

extension IntInstantParser on int {
  // ignore: use_to_and_as_if_applicable
  Instant parseInstant() => Instant.fromEpochMilliseconds(this);
}

extension StringInstantParser on String {
  Instant parseInstant() => InstantPattern.extendedIso.parse(this).value;

  Instant tryParseInstant() {
    final result = InstantPattern.extendedIso.parse(this);
    return result.success ? result.value : null;
  }
}

extension UserInstantFormatting on Instant {
  LocalDateTime get _localDateTime => inLocalZone().localDateTime;

  String get shortDateString => _localDateTime.calendarDate.shortString;
  String get longDateString => _localDateTime.calendarDate.longString;

  String get shortDateTimeString => _localDateTime.shortString;
  String get longDateTimeString => _localDateTime.longString;
}

extension UserLocalDateTimeFormatting on LocalDateTime {
  String get shortString =>
      LocalDateTimePattern.createWithCurrentCulture('g').format(this);
  String get longString =>
      LocalDateTimePattern.createWithCurrentCulture('f').format(this);
}

extension UserLocalDateFormatting on LocalDate {
  String get shortString =>
      LocalDatePattern.createWithCurrentCulture('d').format(this);
  String get longString =>
      LocalDatePattern.createWithCurrentCulture('D').format(this);
}

extension TimeMachineInterop on DateTime {
  LocalDate get asLocalDate => LocalDate.dateTime(this);
}
