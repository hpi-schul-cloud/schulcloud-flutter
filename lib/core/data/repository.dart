import 'dart:async';

import 'package:flutter/foundation.dart';

import 'id.dart';

export 'id.dart';

/// Error that may be thrown by a repository if the item is not available yet.
class NotLoadedYetError {}

/// An entry in a repository containing an [id] and an [item]. Returned by
/// [fetchAllEntries].
@immutable
class RepositoryEntry<T> {
  final Id<T> id;
  final T item;

  RepositoryEntry({@required this.id, @required this.item})
      : assert(id != null),
        assert(item != null);

  RepositoryEntry copyWith({Id<T> id, T item}) {
    return RepositoryEntry(
      id: id ?? this.id,
      item: item ?? this.item,
    );
  }
}

/// Something that can fetch items. Always returns a stream of items.
///
/// If [isFinite] is true, the fetchAll() method should be implemented.
/// If [isMutable] is true, the update() method should be implemented.
abstract class Repository<Item> {
  // You may ask yourself why this is a single class instead of being split up
  // into smaller classes like a MutableRepository and FiniteRepository etc.
  // that inherit from a base Repository class etc.
  // When implementing repositories, they often accept a source repository and
  // their [isFinite] and [isMutable] properties depend on the source
  // repository's properties. So you would have to do many manual checks.
  //
  // "But I'm losing my type safety!" Well, the pattern observed using a modular
  // architecture included a lot of unsafe typecasting similar to the following:
  // ```dart
  // bool get isFinite => source.isFinite;
  // ...
  // if (isFinite) {
  //   final source = this.source as FiniteRepository;
  // }
  // ```

  /// Whether this repository is finite. If set to true, the [fetchAllEntries] method
  /// should be overriden.
  final bool isFinite;

  /// Whether this repository is mutable. If set to true, the [update] method
  /// should be overridden.
  final bool isMutable;

  const Repository({
    this.isFinite,
    this.isMutable,
  });

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

  /// Fetches all entries. May only be called if this [isFinite].
  Stream<List<RepositoryEntry<Item>>> fetchAllEntries() {
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

  /// Fetches all ids. May only be called if this [isFinite].
  Stream<List<Id<Item>>> fetchAllIds() =>
      fetchAllEntries().map((entries) => entries.map((entry) => entry.id));

  /// Fetches all items. May only be called if this [isFinite].
  Stream<List<Item>> fetchAllItems() =>
      fetchAllEntries().map((entries) => entries.map((entry) => entry.item));

  /// Updates an item. May only be called if this [isMutable].
  Future<void> update(Id<Item> id, Item item) {
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

  /// Frees resources.
  void dispose() {}
}

/// For convenience, you can provide a source repository. It will be disposed
/// when this one gets disposed and if not specified otherwise, this repository
/// inherits the [isFinite] and [isMutable] properties from the source.
abstract class RepositoryWithSource<Item, SourceItem> extends Repository<Item> {
  /// An optional source repository.
  final Repository<SourceItem> source;
  bool _isFinite;
  bool _isMutable;

  bool get isFinite => _isFinite;
  bool get isMutable => _isMutable;

  /// If a [source] repository is provided, finitability and mutability are
  /// equal to the [source]'s, unless overridden here.
  RepositoryWithSource(
    this.source, {
    bool isFinite,
    bool isMutable,
  }) {
    _isMutable = isMutable ?? source?.isMutable ?? false;
    _isFinite = isFinite ?? source?.isFinite ?? false;
  }

  Stream<List<RepositoryEntry<Item>>> fetchSourceEntriesAndMap(
      Item Function(SourceItem source) itemTransformer) {
    return source
        .fetchAllEntries()
        .map((entries) => entries.map((entry) => RepositoryEntry(
              id: entry.id.cast<Item>(),
              item: itemTransformer(entry.item),
            )));
  }

  void dispose() => source?.dispose();
}
