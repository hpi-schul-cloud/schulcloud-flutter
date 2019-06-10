import 'dart:async';

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
///
/// If [isFinite] is true, the fetchAll() method should be implemented.
/// If [isMutable] is true, the update() method should be implemented.
///
/// For convenience, you can provide a source repository. It will be disposed
/// when this one gets disposed and if not specified otherwise, this repository
/// inherits the [isFinite] and [isMutable] properties from the source.
///
/// When overriding methods, they should not call super.
abstract class Repository<Item> {
  // Reasons why this is a kind of monolithic class instead of splitting it up
  // into smaller classes like a MutableRepository and FiniteRepository etc.:
  //
  // When implementing repositories, they often accept a source repository and
  // their [isFinite] and [isMutable] properties depend on the source
  // repository's properties. So you would have to do many manual checks.
  //
  // "But I'm losing my type safety!" Well, the pattern observed using a modular
  // architecture was a lot of unsafe typecasting similar to the following:
  // ```dart
  // bool get isFinite => source.isFinite;
  // ...
  // if (isFinite) {
  //   final source = this.source as FiniteRepository;
  // }
  // ```

  /// An optional source repository.
  final Repository source;

  /// Whether this repository is finite. If set to true, the [fetchAll] method
  /// should be overriden and not call [super.fetchAll()].
  bool get isFinite => _isFinite;
  bool _isFinite;

  /// Whether this repository is mutable. If set to true, the [update] method
  /// should be overridden and not call [super.update()];
  bool get isMutable => _isMutable;
  bool _isMutable;

  /// Constructor for a repository.
  ///
  /// By default, it's not mutable.
  /// If a [source] repository is provided, finitability and mutability are
  /// equal to the [source]'s, unless overridden here.
  Repository({
    this.source,
    bool isFinite,
    bool isMutable,
  }) {
    _isMutable = isMutable ?? source?.isMutable ?? false;
    _isFinite = isFinite ?? source?.isFinite ?? false;
  }

  /// Fetches a single item with the given [id].
  Stream<Item> fetch(Id<Item> id);

  /// Fetches multiple items with the given [ids].
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

  /// Fetches all items. May only be called if this [isFinite].
  Stream<Iterable<Item>> fetchAll() {
    if (isFinite) {
      throw UnimplementedError(
          "fetchAll was called on repository $this. It's finite, so that "
          "should be possible. Make sure you implement the fetchAll method and "
          "don't call the superclass's fetchAll method.");
    } else {
      throw UnsupportedError(
          "fetchAll was called on repository $this, altough it's not finite. "
          "Don't do that.");
    }
  }

  /// Updates an item. May only be called if this [isMutable].
  Future<void> update(Id<Item> id, Item value) {
    if (isMutable) {
      throw UnimplementedError(
          "update was called on repository $this. It's mutable, so that "
          "should be possible. Make sure you implement the update method and "
          "don't call the superclass's update method.");
    } else {
      throw UnsupportedError(
          "update was called on repository $this, altough it's not mutable. "
          "Don't do that.");
    }
  }

  /// Disposes the repository.
  void dispose() => source?.dispose();
}

mixin SourceRepository<RepositoryType extends Repository<SourceItem>,
    SourceItem> on Repository {
  RepositoryType source;

  void useSource(RepositoryType source) {
    assert(source != null);
    this.source = source;
  }

  @override
  bool get isMutable => source.isMutable;

  @override
  bool get isFinite => source.isFinite;

  @override
  void dispose() => source.dispose();
}
