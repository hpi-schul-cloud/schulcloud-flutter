import 'dart:async';

import 'package:flutter/foundation.dart';

import 'id.dart';

/// Something that can fetch items. Always returns a stream of items.
///
/// If [isFinite] is true, the fetchAll() method should be implemented.
/// If [isMutable] is true, the update() method should be implemented.
abstract class Repository<Item> {
  // You may ask yourself why this is a single class instead of being split up
  // into smaller classes like a MutableRepository and FiniteRepository etc.
  // that inherit from a base Repository class. "I'm losing my type safety!",
  // you might think. Indeed, a call to [fetchAllEntries] may immediately throw
  // an error if the repository is not finite and that doesn't align well with
  // how methods should work.
  // The problem is, when implementing repositories, they often accept a source
  // repository and their [isFinite] and [isMutable] properties depend on the
  // source repository's properties. That leads to patterns like the following:
  //
  // ```dart
  // bool get isFinite => source.isFinite;
  // ...
  // Stream<List<RepositoryEntryyT>>> fetchAllEntries() {
  //   if (isFinite) {
  //     final source = this.source as FiniteRepository;
  //     source.fetchAllEntries()....
  //   }
  // }
  // ```
  //
  // As you see, there's a lot of unsafe typecasting necessary to make it work.
  // That's why I opted for the simpler alternative of condensing everything
  // into a repository base class.

  /// Whether this repository is finite. If set to true, the [fetchAll]
  /// method should be overriden.
  final bool isFinite;

  /// Whether this repository is mutable. If set to true, the [update] and
  /// [remove] method should be overridden.
  final bool isMutable;

  const Repository({
    @required this.isFinite,
    @required this.isMutable,
  })  : assert(isFinite != null),
        assert(isMutable != null);

  /// Fetches a single item with the given [id].
  Stream<Item> fetch(Id<Item> id);

  /// Fetches multiple items with the given [ids].
  Stream<List<Item>> fetchMultiple(Iterable<Id<Item>> ids) {
    StreamController<List<Item>> controller;
    List<Stream<Item>> allStreams = ids.map(fetch);

    // Helping method that takes a snapshot of every item and adds it to the the
    // controller.
    final sendSnapshot = () async {
      var snapshot =
          await Future.wait(allStreams.map((stream) => stream.first));
      controller.add(snapshot);
    };

    controller = StreamController<List<Item>>(
      onListen: () =>
          allStreams.forEach((stream) => stream.listen((_) => sendSnapshot())),
      onCancel: () => controller.close(),
    );

    return controller.stream;
  }

  /// Fetches all entries. May only be called if this [isFinite].
  Stream<Map<Id<Item>, Item>> fetchAll() {
    if (isFinite) {
      throw UnimplementedError(
          "A fetchAll method was called on repository $this. It's finite, so "
          "that should be possible. Make sure you implement the fetchAll "
          "method of ${this.runtimeType} and don't call super.fetchAll.");
    } else {
      throw UnsupportedError(
          "fetchAll was called on repository $this, altough it's not finite. "
          "Don't do that.");
    }
  }

  /// Fetches all ids. May only be called if this [isFinite].
  Stream<List<Id<Item>>> fetchAllIds() =>
      fetchAll().map((all) => all.keys.toList());

  /// Fetches all items. May only be called if this [isFinite].
  Stream<List<Item>> fetchAllItems() =>
      fetchAll().map((all) => all.values.toList());

  /// Updates an item. May only be called if this [isMutable].
  Future<void> update(Id<Item> id, Item item) {
    if (isMutable) {
      throw UnimplementedError(
          "update was called on repository $this. It's mutable, so that should "
          "be possible. Make sure you implement the update method of "
          "${this.runtimeType} and don't call super.update.");
    } else {
      throw UnsupportedError(
          "update was called on repository $this, altough it's not mutable. "
          "Don't do that.");
    }
  }

  Future<void> remove(Id<Item> id) {
    if (isMutable) {
      throw UnimplementedError(
          "remove was called on repository $this. It's mutable, so that should "
          "be possible. Make sure you implement the remove method of "
          "${this.runtimeType} and don't call super.remove.");
    } else {
      throw UnsupportedError(
          "remove was called on repository $this, altough it's not mutable. "
          "Don't do that.");
    }
  }

  /// Clears all the items. May only be called if this [isMutable] and [isFinite].
  Future<void> clear() =>
      fetchAllIds().first.then((ids) => ids.forEach((id) => remove(id)));

  /// Frees resources.
  void dispose() {}
}

/// For convenience, you can provide a source repository. It will be disposed
/// when this one gets disposed and if not specified otherwise, this repository
/// inherits the [isFinite] and [isMutable] properties from the source.
abstract class RepositoryWithSource<Item, SourceItem> extends Repository<Item> {
  /// An optional source repository.
  final Repository<SourceItem> source;

  /// Finitability and mutability are equal to the [source]'s, unless overridden
  /// here.
  RepositoryWithSource(
    this.source, {
    bool isFinite,
    bool isMutable,
  })  : assert(source != null),
        super(
          isFinite: isFinite ?? source.isFinite,
          isMutable: isMutable ?? source.isMutable,
        );

  Stream<Map<Id<Item>, Item>> fetchSourceEntriesAndMapItems(
      Item Function(SourceItem source) itemTransformer) {
    return source.fetchAll().map((all) => {
          for (var entry in all.entries)
            entry.key.cast<Item>(): itemTransformer(entry.value),
        });
  }

  void dispose() => source.dispose();
}

mixin SourceRepositoryForwarder<Item> on RepositoryWithSource<Item, Item> {
  @override
  Stream<Item> fetch(Id<Item> id) => source.fetch(id);

  @override
  Stream<Map<Id<Item>, Item>> fetchAll() => source.fetchAll();

  @override
  Future<void> update(Id<Item> id, Item item) => source.update(id, item);
}
