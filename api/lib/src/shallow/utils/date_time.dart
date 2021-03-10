import 'package:supercharged_dart/supercharged_dart.dart';

extension FancyDateTime on DateTime {
  static DateTime create({
    required int year,
    int month = 1,
    int day = 1,
    int hour = 0,
    int minute = 0,
    int second = 0,
    int millisecond = 0,
    int microsecond = 0,
    bool isUtc = true,
  }) {
    if (isUtc) {
      return DateTime.utc(
        year,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );
    }
    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  static DateTime date(int year, [int month = 1, int day = 1]) {
    final date = DateTime.utc(year, month, day);
    assert(date.isValidDate);
    return date;
  }

  static DateTime parseApiDate(String string) {
    DateTime? parse(RegExp pattern) {
      final match = pattern.firstMatch(string);
      if (match == null) return null;
      return FancyDateTime.date(
        int.parse(match.namedGroup('year')!),
        int.parse(match.namedGroup('month')!),
        int.parse(match.namedGroup('day')!),
      );
    }

    const yearMonthDay = r'(?<year>\d{4,6})-(?<month>\d{2})-(?<day>\d{2})';

    /// For some reason, the API uses a timestamp format (including date, time,
    /// and timezone) for representing dates.
    final pattern = RegExp('${yearMonthDay}T00:00:00\\.000Z');
    // Sometimes, it doesn't just misuse that format, but actually stores the
    // correct UTC time of when that day starts in the Europe/Berlin timezone…
    final alternativePattern1 = RegExp('${yearMonthDay}T22:00:00\\.000Z');
    final alternativePattern2 = RegExp('${yearMonthDay}T23:00:00\\.000Z');

    return parse(pattern) ??
        ((parse(alternativePattern1) ?? parse(alternativePattern2))! + 1.days);
  }

  static DateTime parseApiDateTime(String string) {
    const pattern = r'^(?<year>\d{4,6})-(?<month>\d{2})-(?<day>\d{2})'
        r'T(?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2})'
        r'(\.(?<fractionalSeconds>\d{0,9}))?Z$';
    final match = RegExp(pattern).firstMatch(string)!;

    final rawFractionalSeconds =
        (match.namedGroup('fractionalSeconds') ?? '').padRight(9, '0');
    return FancyDateTime.create(
      year: int.parse(match.namedGroup('year')!),
      month: int.parse(match.namedGroup('month')!),
      day: int.parse(match.namedGroup('day')!),
      hour: int.parse(match.namedGroup('hour')!),
      minute: int.parse(match.namedGroup('minute')!),
      second: int.parse(match.namedGroup('second')!),
      microsecond: int.parse(rawFractionalSeconds) ~/ 1000,
    );
  }

  static DateTime? parseNullableApiDateTime(String? string) =>
      string != null ? parseApiDateTime(string) : null;

  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
    bool? isUtc,
  }) {
    return FancyDateTime.create(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      millisecond: millisecond ?? this.millisecond,
      microsecond: microsecond ?? this.microsecond,
      isUtc: isUtc ?? this.isUtc,
    );
  }

  bool operator <(DateTime other) => isBefore(other);
  bool operator <=(DateTime other) =>
      isBefore(other) || isAtSameMomentAs(other);
  bool operator >(DateTime other) => isAfter(other);
  bool operator >=(DateTime other) => isAfter(other) || isAtSameMomentAs(other);

  Duration get timeOfDay => difference(atStartOfDay);

  DateTime get atStartOfDay =>
      copyWith(hour: 0, minute: 0, second: 0, millisecond: 0, microsecond: 0);
  bool get isAtStartOfDay => this == atStartOfDay;
  DateTime get atEndOfDay {
    return copyWith(
      hour: 23,
      minute: 59,
      second: 59,
      millisecond: 999,
      microsecond: 999,
    );
  }

  bool get isValidDateTime => isUtc;
  bool get isValidDate => isValidDateTime && isAtStartOfDay;
}
