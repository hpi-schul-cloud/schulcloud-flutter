import 'dart:async';

import 'package:flutter/foundation.dart';

/// Identifier that uniquely identifies a DTO and an entity among others of the
/// same type.
@immutable
class Id<T> {
  final String id;

  const Id(this.id);

  bool matches(String id) => this.id == id;

  factory Id.fromJson(Map<String, dynamic> json) => Id(json['id']);
  Map<String, dynamic> toJson() => {'id': id};
}

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

/// Error that may be thrown by a repository if the item is not available yet.
class NotLoadedYetError {}

/// Something that can fetch items. Always returns a stream of items.
abstract class Repository<Item> {
  const Repository();

  bool get isFinite => this is FiniteRepository;
  bool get isMutable => this is MutableRepository;

  Stream<Item> fetch(Id<Item> id);

  Stream<Iterable<Item>> fetchMultiple(Iterable<Id<Item>> ids) {
    Iterable<Stream<Item>> allStreams = ids.map(fetch);

    StreamController<Iterable<Item>> controller;
    controller = StreamController<Iterable<Item>>(
      onListen: () {
        allStreams.forEach((stream) => stream.listen((Item item) async {
              var itemSnapshot =
                  await Future.wait(allStreams.map((stream) => stream.first));
              controller.add(itemSnapshot);
            }));
      },
      onCancel: () => controller.close(),
    );

    return controller.stream;
  }
}

/// A repository with a finite amount of items. That means you can fetch all
/// data, if you want to.
/// Of course, all data sources are finite but the ones that are seemingly
/// infinite to the client (like, authors of news articles) should not implement
/// this class.
abstract class FiniteRepository<Item> extends Repository<Item> {
  const FiniteRepository();

  Stream<Iterable<Item>> fetchAll();
}

/// A repository with mutable items. Provides a method to update them.
abstract class MutableRepository<Item> extends Repository<Item> {
  const MutableRepository();

  Future<void> update(Id<Item> id, Item value);
}

/// A convenience class that represents a repository that's both finite and
/// mutable.
abstract class FiniteMutableRepository<Item> extends Repository<Item>
    implements FiniteRepository<Item>, MutableRepository<Item> {
  const FiniteMutableRepository();
}
