import 'package:json_annotation/json_annotation.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

class InstantConverter implements JsonConverter<Instant, String> {
  const InstantConverter();

  @override
  Instant fromJson(String json) => FancyInstant.fromJson(json);
  @override
  String toJson(Instant data) => data?.toJson();
}

extension FancyInstant on Instant {
  static final _pattern = InstantPattern.extendedIso;

  static Instant fromJson(String json) =>
      json == null ? null : _pattern.parse(json).value;
  String toJson() => this == null ? null : _pattern.format(this);
}
