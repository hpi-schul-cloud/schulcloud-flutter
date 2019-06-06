import 'dart:async';

import 'package:flutter/foundation.dart';

abstract class Repository<T> {
  const Repository();

  Stream<T> fetch(Id<T> id);
  Stream<Iterable<T>> fetchAll();

  Stream<Iterable<T>> fetchMultiple(Iterable<Id<T>> ids) {
    Iterable<Stream<T>> allStreams = ids.map(fetch);

    StreamController<Iterable<T>> controller;
    controller = StreamController<Iterable<T>>(
      onListen: () {
        allStreams.forEach((stream) => stream.listen((T value) async {
              var valueSnapshot =
                  await Future.wait(allStreams.map((stream) => stream.first));
              controller.add(valueSnapshot);
            }));
      },
      onCancel: () => controller.close(),
    );

    return controller.stream;
  }
}

abstract class MutableRepository<T> extends Repository<T> {
  const MutableRepository();

  Future<void> update(Id<T> id, T value);
}

abstract class Dto<T extends Dto<T>> {
  Id<T> get id;

  const Dto();

  factory Dto.fromJson(Map<String, dynamic> data) {
    throw UnimplementedError(
        "Class that extends JsonSerializable doesn't override the fromJson "
        "factory constructor.");
  }

  Map<String, dynamic> toJson();
}

@immutable
class Id<T> {
  final String id;

  const Id(this.id);

  factory Id.fromJson(Map<String, dynamic> json) => Id(json['id']);
  Map<String, dynamic> toJson() => {'id': id};
}
