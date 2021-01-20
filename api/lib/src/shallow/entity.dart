import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';
import 'package:time_machine/time_machine.dart';

import 'utils.dart';

part 'entity.freezed.dart';

abstract class ShallowEntity<E extends ShallowEntity<E>> {
  const ShallowEntity();

  EntityMetadata<E> get metadata;
}

// Users are missing the `createdAt` and `updatedAt` properties…

@freezed
abstract class EntityMetadata<E extends ShallowEntity<E>>
    implements _$EntityMetadata<E> {
  const factory EntityMetadata.partial(Id<E> id) = PartialEntityMetadata;
  const factory EntityMetadata.full(
    Id<E> id, {
    @required Instant createdAt,
    @required Instant updatedAt,
  }) = FullEntityMetadata;
  const EntityMetadata._();

  static PartialEntityMetadata<E> partialFromJson<E extends ShallowEntity<E>>(
    Map<String, dynamic> json,
  ) =>
      PartialEntityMetadata(Id.fromJson(json['_id'] as String));
  static FullEntityMetadata<E> fullFromJson<E extends ShallowEntity<E>>(
    Map<String, dynamic> json,
  ) {
    final createdAt = FancyInstant.fromJson(json['createdAt'] as String);
    return FullEntityMetadata(
      Id.fromJson(json['_id'] as String),
      createdAt: createdAt,
      // Some entities always set `updatedAt` (sometimes to the same value as
      // `createdAt`), others don't…
      updatedAt:
          FancyInstant.fromJson(json['updatedAt'] as String) ?? createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return map(
      partial: (it) => <String, dynamic>{'_id': it.id.toJson()},
      full: (it) => <String, dynamic>{
        '_id': it.id.toJson(),
        'createdAt': it.createdAt.toJson(),
        'updatedAt': it.updatedAt.toJson(),
      },
    );
  }
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
