import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

extension IntApiInstantParser on int {
  Instant parseApiInstant() =>
      Instant.fromEpochMilliseconds(this).serverTimeToActual();
}

extension StringApiInstantParser on String {
  Instant parseApiInstant() {
    final result = InstantPattern.extendedIso.parse(this);
    return result.value.serverTimeToActual();
  }

  Instant tryParseApiInstant() {
    final result = InstantPattern.extendedIso.parse(this);
    return result.success ? result.value.serverTimeToActual() : null;
  }
}

extension ApiCorrection on Instant {
  // analyzer doesn't notice we use this field in serverTimeToActual()
  // ignore: unused_field
  static final _serverDateTimeZone = DateTimeZoneProviders.defaultProvider
      .getDateTimeZoneSync('Europe/Berlin');

  Instant serverTimeToActual() {
    // The Schul-Cloud API uses tricky obfuscation: Times are said to be in UTC,
    // whereas they actually use the local time zone.
    // Hence: We interpret the returned time as UTC time, use the calculated
    // date and time in calendar terms, interpret them in our local time zone,
    // and finally store the Instant representing that point in time.
    return inUtc()
        .localDateTime
        .inZoneLeniently(_serverDateTimeZone)
        .toInstant();
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
