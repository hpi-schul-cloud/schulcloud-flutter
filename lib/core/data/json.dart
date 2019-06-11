import 'package:flutter/foundation.dart';

typedef FromJsonCallback<T> = T Function(Map<String, dynamic> data);
typedef ToJsonCallback<T> = Map<String, dynamic> Function(T value);

/// A class that can serialize and deserialize a type from and to JSON.
@immutable
class Serializer<T> {
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
