import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';

@immutable
class Color {
  const Color(this.value);
  factory Color.fromJson(String json) =>
      Color(int.parse(json.removePrefix('#').padLeft(8, 'f'), radix: 16));

  final int value;

  @override
  bool operator ==(dynamic other) => other is Color && other.value == value;
  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '#${value.toRadixString(16).padLeft(8, '0')}';
  String toJson() => toString();
}
