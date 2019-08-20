import 'package:flutter/foundation.dart';

/// Identifier that uniquely identifies an item among others in the same
/// repository.
@immutable
class Id<T> {
  final String id;

  const Id(this.id);

  bool matches(String id) => this.id == id;

  Id<OtherType> cast<OtherType>() => Id<OtherType>(id);

  operator ==(Object other) => other is Id<T> && other.id == id;
  int get hashCode => id.hashCode;

  factory Id.fromJson(Map<String, dynamic> json) => Id(json['id']);
  Map<String, dynamic> toJson() => {'id': id};

  String toString() => id;
}
