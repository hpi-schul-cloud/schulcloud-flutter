import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import 'utils.dart';

abstract class ShallowEntity<E extends ShallowEntity<E>> {
  const ShallowEntity();

  PartialEntityMetadata<E> get metadata;
}

// Some entities are missing the `createdAt` and `updatedAt` properties…

class PartialEntityMetadata<E extends ShallowEntity<E>> {
  const PartialEntityMetadata(this.id) : assert(id != null);

  factory PartialEntityMetadata.fromJson(Map<String, dynamic> json) =>
      PartialEntityMetadata<E>(Id.fromJson(json['_id'] as String));

  Map<String, dynamic> toJson() => <String, dynamic>{'_id': id.toJson()};

  final Id<E> id;

  @override
  bool operator ==(dynamic other) =>
      other is PartialEntityMetadata<E> && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

class EntityMetadata<E extends ShallowEntity<E>>
    extends PartialEntityMetadata<E> {
  const EntityMetadata(
    Id<E> id, {
    @required this.createdAt,
    @required this.updatedAt,
  })  : assert(createdAt != null),
        assert(updatedAt != null),
        super(id);

  factory EntityMetadata.fromJson(Map<String, dynamic> json) {
    final createdAt = FancyInstant.fromJson(json['createdAt'] as String);
    return EntityMetadata<E>(
      Id.fromJson(json['_id'] as String),
      createdAt: createdAt,
      // Some entities always set `updatedAt` (sometimes to the same value as
      // `createdAt`), others don't…
      updatedAt:
          FancyInstant.fromJson(json['updatedAt'] as String) ?? createdAt,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...super.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  final Instant createdAt;
  final Instant updatedAt;

  @override
  bool operator ==(dynamic other) {
    return super == other &&
        other is EntityMetadata<E> &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => super.hashCode ^ createdAt.hashCode ^ updatedAt.hashCode;
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
