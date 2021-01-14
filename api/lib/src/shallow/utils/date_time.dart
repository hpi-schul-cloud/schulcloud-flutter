import 'package:json_annotation/json_annotation.dart';
import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_text_patterns.dart';

class InstantConverter implements JsonConverter<Instant, String> {
  const InstantConverter();

  static final _pattern = InstantPattern.extendedIso;

  @override
  Instant fromJson(String json) =>
      json == null ? null : _pattern.parse(json).value;
  @override
  String toJson(Instant data) => data == null ? null : _pattern.format(data);
}
