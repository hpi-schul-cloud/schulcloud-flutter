import 'package:flutter/foundation.dart';

/// Identifier that uniquely identifies an item among others in the same
/// repository.
@immutable
class Id<T> {
  final String id;

  const Id(this.id);

  bool matches(String id) => this.id == id;

  Id<OtherType> cast<OtherType>() => Id<OtherType>(id);

  factory Id.fromJson(Map<String, dynamic> json) => Id(json['id']);
  Map<String, dynamic> toJson() => {'id': id};
}

/// A special kind of item that also carries its id.
@immutable
abstract class Entity<T extends Entity<T>> {
  final Id<T> id;

  const Entity(this.id) : assert(id != null);

  Map<String, dynamic> toJson();
}
