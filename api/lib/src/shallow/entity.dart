import 'package:meta/meta.dart';

abstract class ShallowEntity<E extends ShallowEntity<E>> {
  const ShallowEntity();

  Id<E> get id;
}

@immutable
class Id<E extends ShallowEntity<E>> {
  const Id(this.value) : assert(value != null);
  factory Id.orNull(String value) => value == null ? null : Id<E>(value);
  factory Id.fromJson(String json) => Id(json);

  final String value;

  Id<S> cast<S extends ShallowEntity<S>>() => Id<S>(value);

  @override
  bool operator ==(dynamic other) => other is Id<E> && other.value == value;
  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
  String toJson() => value;
}
