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

Future<void> testRepository<T>({
  @required Repository<T> repository,
  @required T item,
  @required T otherItem,
}) async {
  final repo = repository;
  final id = Id<T>("item");

  // First, there are no items yet.
  expect(repo.fetch(id), emitsInOrder([]));

  // After an item was added, it can be fetched.
  await repo.update(id, item);
  expect(repo.fetch(id), emitsInOrder([item]));

  // You can get multiple streams of the same item simultaneously.
  var item1 = await repo.fetch(id).first;
  var item2 = await repo.fetch(id).first;
  expect(item1, equals(item));
  expect(item2, equals(item));

  // As the data changes, the fetched streams update live.
  expect(repo.fetch(id), emitsInOrder([item, otherItem]));
  repo.update(id, otherItem);
}

void main() {
  group("Repositories", () {
    test("InMemoryStorage", () async {
      await testRepository<String>(
        repository: InMemoryStorage<String>(),
        item: "This is an item.",
        otherItem: "This is another item.",
      );
    });

    test("JsonToStringTransformer", () async {
      await testRepository<Map<String, dynamic>>(
        repository: JsonToStringTransformer(source: InMemoryStorage<String>()),
        item: {'hey': 'foo'},
        otherItem: {'hey': 'bar'},
      );
    });

    test("ObjectToJsonTransformer", () async {
      await testRepository<SampleUser>(
        repository: ObjectToJsonTransformer<SampleUser>(
          source: JsonToStringTransformer(source: InMemoryStorage<String>()),
          serializer: SampleUserSerializer(),
        ),
        item: SampleUser("Marcel", "password"),
        otherItem: SampleUser("Grit", "someOtherPassword"),
      );
    });

    /*test("everything", () {
      CachedRepository<SampleUser>(
        source: ArticleDownloader(),
        cache: ObjectToJsonTransformer(
          serializer: SampleUserSerializer(),
          source: JsonToStringTransformer(source: InMemoryStorage()),
        ),
      );
    });*/
  });
}
