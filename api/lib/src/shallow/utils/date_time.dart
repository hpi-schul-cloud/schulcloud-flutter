import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

extension FancyInstant on Instant {
  static final _pattern = InstantPattern.extendedIso;

  static Instant fromJson(String json) =>
      json == null ? null : _pattern.parse(json).value;
  String toJson() => this == null ? null : _pattern.format(this);
}

extension FancyLocalDate on LocalDate {
  /// For some reason, the API uses a timestamp format (including date, time,
  /// and timezone) for representing dates.
  static final _pattern =
      LocalDatePattern.createWithInvariantCulture('yyyy-MM-dd"T00:00:00.000Z"');
  // Sometimes, it doesn't just misuse that format, but actually stores the
  // correct UTC time of when that day starts in the Europe/Berlin timezone.
  static final _alternativePattern =
      LocalDatePattern.createWithInvariantCulture('yyyy-MM-dd"T22:00:00.000Z"');

  static LocalDate fromJson(String json) {
    if (json == null) return null;

    final result = _pattern.parse(json);
    if (result.success) return result.value;

    return _alternativePattern.parse(json).value.addDays(1);
  }

  String toJson() => this == null ? null : _pattern.format(this);
}
