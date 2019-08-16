import 'dart:async';

import 'package:flutter/foundation.dart';

import '../entity.dart';
import '../repository.dart';

typedef FromJsonCallback<T> = T Function(Map<String, dynamic> data);
typedef ToJsonCallback<T> = Map<String, dynamic> Function(T value);

/// A class that can serialize and deserialize a type from and to JSON.
@immutable
abstract class Serializer<T> {
  final FromJsonCallback<T> _fromJson;
  final ToJsonCallback<T> _toJson;

  const Serializer({
    @required FromJsonCallback<T> fromJson,
    @required ToJsonCallback<T> toJson,
  })  : assert(fromJson != null),
        assert(toJson != null),
        _fromJson = fromJson,
        _toJson = toJson;

  T fromJson(Map<String, dynamic> data) => _fromJson(data);
  Map<String, dynamic> toJson(T value) => _toJson(value);
}

/// A storage that saves objects into a [Repository<Map<<String, dynamic>>>] by
/// serializing and deserializing them from and to json.
class ObjectToJsonTransformer<Item>
    extends RepositoryWithSource<Item, Map<String, dynamic>> {
  Serializer<Item> serializer;

  ObjectToJsonTransformer({
    @required Repository<Map<String, dynamic>> source,
    @required this.serializer,
  })  : assert(serializer != null),
        super(source);

  @override
  Stream<Item> fetch(Id<Item> id) =>
      source.fetch(id.cast<Map<String, dynamic>>()).map(serializer.fromJson);

  @override
  Stream<Map<Id<Item>, Item>> fetchAll() =>
      fetchSourceEntriesAndMapItems(serializer.fromJson);

  @override
  Future<void> update(Id<Item> id, Item item) =>
      source.update(id.cast<Map<String, dynamic>>(), serializer.toJson(item));

  @override
  Future<void> remove(Id<Item> id) =>
      source.remove(id.cast<Map<String, dynamic>>());
}
