import 'package:flutter/foundation.dart';

import 'id.dart';

/// A data transfer object. Can be serialized and deserialized from and to JSON.
@immutable
abstract class Dto<T extends Dto<T>> {
  Id<T> get id;

  const Dto();

  Map<String, dynamic> toJson();
}

abstract class Serializer<T> {
  T fromJson(Map<String, dynamic> data);
}
