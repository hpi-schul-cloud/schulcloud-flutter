import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:schulcloud/core/data.dart';
import "package:test/test.dart";

class SampleUser {
  String username;
  String password;

  SampleUser(this.username, this.password);

  @override
  bool operator ==(Object other) =>
      other is SampleUser &&
      other.username == username &&
      other.password == password;

  @override
  int get hashCode => hashValues(username, password);

  factory SampleUser.fromJson(Map<String, dynamic> data) =>
      SampleUser(data['user'], data['password']);

  Map<String, dynamic> toJson() => {'user': username, 'password': password};
}

class SampleUserSerializer extends Serializer<SampleUser> {
  SampleUserSerializer()
      : super(
          fromJson: (data) => SampleUser.fromJson(data),
          toJson: (user) => user.toJson(),
        );
}

class SampleUserCreator extends Repository<SampleUser> {
  SampleUserCreator() : super(isMutable: false, isFinite: false);

  @override
  Stream<SampleUser> fetch(Id<SampleUser> id) async* {
    switch (id.id) {
      case 'marcel':
        yield SampleUser("Marcel", "password");
        break;
      case 'grit':
        yield SampleUser("Grit", "someOtherPassword");
        break;
    }
  }
}

Future<void> testMutableRepository<T>({
  @required Repository<T> repository,
  @required T item,
  @required T otherItem,
}) async {
  assert(repository.isMutable);

  final repo = repository;
  final id = Id<T>("item");

  // First, there are no items yet.
  expect(repo.fetch(id), emitsInOrder([]));

  // After an item was added, it can be fetched.
  await repo.update(id, item);
  expect(repo.fetch(id), emitsInOrder([item]));

  // You can get multiple streams of the same item simultaneously.
  print('Listening on the same stream twice...');
  var items = await Future.wait([repo.fetch(id).first, repo.fetch(id).first]);
  print('Done.');
  expect(items[0], equals(item));
  expect(items[1], equals(item));

  // As the data changes, the fetched streams update live.
  expect(repo.fetch(id), emitsInOrder([item, otherItem]));
  repo.update(id, otherItem);

  var stream = repo.fetch(id);
  stream.listen((_) {});
  stream.listen((_) {});
}

void main() {
  group("Repository", () {
    test("InMemoryStorage", () async {
      await testMutableRepository<String>(
        repository: InMemoryStorage<String>(),
        item: "This is an item.",
        otherItem: "This is another item.",
      );
    });

    test("JsonToStringTransformer", () async {
      await testMutableRepository<Map<String, dynamic>>(
        repository: JsonToStringTransformer(source: InMemoryStorage<String>()),
        item: {'hey': 'foo'},
        otherItem: {'hey': 'bar'},
      );
    });

    test("ObjectToJsonTransformer", () async {
      await testMutableRepository<SampleUser>(
        repository: ObjectToJsonTransformer<SampleUser>(
          source: JsonToStringTransformer(source: InMemoryStorage<String>()),
          serializer: SampleUserSerializer(),
        ),
        item: SampleUser("Marcel", "password"),
        otherItem: SampleUser("Grit", "someOtherPassword"),
      );
    });

    test("CachedRepository", () async {
      var repo = CachedRepository<SampleUser>(
        source: SampleUserCreator(),
        cache: ObjectToJsonTransformer(
          serializer: SampleUserSerializer(),
          source: JsonToStringTransformer(source: InMemoryStorage<String>()),
        ),
      );

      // Here, we get an item twice, once from the source and once from the
      // cache and then from the source.
      await Future.wait([
        repo.fetch(Id('marcel')).first,
        repo.fetch(Id('marcel')).first,
      ]);
    });
  });
}
