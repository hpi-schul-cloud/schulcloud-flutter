import 'package:flutter/foundation.dart';

/// Identifier that uniquely identifies a DTO and an entity among others of the
/// same type.
@immutable
class Id<T> {
  final String id;

  const Id(this.id);

  bool matches(String id) => this.id == id;

  Id<OtherType> cast<OtherType>() => Id<OtherType>(id);

  factory Id.fromJson(Map<String, dynamic> json) => Id(json['id']);
  Map<String, dynamic> toJson() => {'id': id};
}
