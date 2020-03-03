import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:grec_minimal/grec_minimal.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/news/news.dart';
import 'package:time_machine/time_machine.dart';

import 'data.dart';

/// An [Entity].
abstract class Entity<T extends Entity<T>> {
  const Entity();

  Id<T> get id;
}

extension SaveableEntity<T extends Entity<T>> on Entity<T> {
  void saveToCache() => HiveCache.put(this);
}

/// An [Id] that identifies an [Entity] among all other [Entity]s.
class Id<T extends Entity<T>> {
  const Id(this.value);

  final String value;

  Type get type => T;
  int get typeId => HiveCache.typeIdByType<T>();

  CacheController<T> get controller {
    return SimpleCacheController<T>(
      saveToCache: HiveCache.put,
      loadFromCache: () => HiveCache.get(this) ?? (throw NotInCacheException()),
      fetcher: () => HiveCache.fetch(this),
    );
  }

  Id<S> cast<S extends Entity<S>>() => Id<S>(value);

  @override
  bool operator ==(other) => other is Id<T> && other.value == value;
  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class AdapterForId extends TypeAdapter<Id<dynamic>> {
  @override
  int get typeId => TypeId.typeId;

  @override
  void write(BinaryWriter writer, Id<dynamic> id) => writer
    ..writeInt(id.typeId)
    ..writeString(id.value);

  @override
  Id<dynamic> read(BinaryReader reader) =>
      HiveCache._createIdOfTypeId(reader.readInt(), reader.readString());
}

/// A wrapper around multiple [Id]s.
class IdCollection<T extends Entity<T>> implements Entity<IdCollection<T>> {
  IdCollection({@required this.id, @required this.childrenIds});

  @override
  final Id<IdCollection<T>> id;
  final List<Id<T>> childrenIds;

  int get typeId => HiveCache.typeIdByType<T>();
}

class AdapterForIdCollection extends TypeAdapter<IdCollection<dynamic>> {
  @override
  int get typeId => TypeId.typeCollection;

  @override
  void write(BinaryWriter writer, IdCollection<dynamic> collection) => writer
    ..writeInt(collection.typeId)
    ..writeString(collection.id.value)
    ..writeStringList(collection.childrenIds.map((id) => id.value).toList());

  @override
  IdCollection<dynamic> read(BinaryReader reader) =>
      HiveCache._createCollectionOfTypeId(
        reader.readInt(),
        reader.readString(),
        reader.readStringList(),
      );
}

/// A fetcher for an [IdCollection].
class LazyIds<T extends Entity<T>> {
  LazyIds({@required this.collectionId, @required this.fetcher});

  final String collectionId;
  // Id<IdCollection<T>> get _id => Id<IdCollection<T>>(collectionId);

  final FutureOr<List<T>> Function() fetcher;

  CacheController<List<T>> get controller {
    return SimpleCacheController<List<T>>(
      fetcher: fetcher,
      loadFromCache: () async {
        // TODO(marcelgarus): Activate the cache.
        throw NotInCacheException();

        // final ids = HiveCache.get(_id) ?? (throw NotInCacheException());
        // return [
        //   for (final itemId in ids.childrenIds)
        //     HiveCache.get(itemId) ?? (throw NotInCacheException()),
        // ];
      },
      saveToCache: (items) {
        // TODO(marcelgarus): Activate the cache.
        return;

        // final collection = IdCollection<T>(
        //   id: _id,
        //   childrenIds: items.map((item) => item.id).toList(),
        // );
        // HiveCache.put<IdCollection<T>>(collection);
        // items.forEach(HiveCache.put);
      },
    );
  }
}

extension ListOfIds<T extends Entity<T>> on List<Id<T>> {
  CacheController<List<T>> get controller {
    return CacheController.combiningControllers(
      map((id) => id.controller).toList(),
    );
  }
}

extension IdParsingList on List<dynamic> {
  List<Id<T>> castIds<T extends Entity<T>>() {
    return map((id) => Id<T>(id as String)).toList();
  }
}

// ignore: non_constant_identifier_names
final HiveCache = HiveCacheImpl();

class Fetcher<T extends Entity<T>> {
  Fetcher(this.fetch);

  final Future<T> Function(Id<T> id) fetch;

  Id<T> _createId(String id) => Id<T>(id);
  IdCollection<T> _createCollection(String id, List<String> children) {
    return IdCollection<T>(
      id: Id<IdCollection<T>>(id),
      childrenIds: children.map((child) => Id<T>(child)).toList(),
    );
  }
}

class HiveCacheImpl {
  final _fetchers = <int, Fetcher>{};
  Box<dynamic> _box;

  Future<T> fetch<T extends Entity<T>>(Id<T> id) {
    for (final fetcher in _fetchers.values) {
      if (fetcher is Fetcher<T>) {
        return fetcher.fetch(id);
      }
    }
    throw UnsupportedError("We don't know how to fetch $T. Are you sure you "
        'registered the type $T?');
  }

  Future<void> initialize() async => _box = await Hive.openBox('cache');

  void registerEntityType<T extends Entity<T>>(
      int typeId, Future<T> Function(Id<T> id) fetch) {
    _fetchers[typeId] = Fetcher<T>(fetch);
  }

  int typeIdByType<T extends Entity<T>>() {
    try {
      return _fetchers.entries
          .singleWhere((entry) => entry.value is Fetcher<T>)
          .key;
      // Unlike Exceptions, Errors indicate that the programmer did something
      // wrong. Generally, they should not be caught during runtime. In this
      // case, however, we throw another Error with more information, so it's
      // okay to catch the error here.
      // ignore: avoid_catching_errors
    } on StateError {
      throw UnsupportedError('No id for type $T found. Did you forget to '
          'register the type $T?');
    }
  }

  Fetcher<dynamic> _getFetcherOfTypeId(int id) =>
      _fetchers[id] ?? (throw UnsupportedError('Unknown type id $id.'));
  Id<dynamic> _createIdOfTypeId(int typeId, String id) =>
      _getFetcherOfTypeId(typeId)._createId(id);
  IdCollection<dynamic> _createCollectionOfTypeId(
          int typeId, String id, List<String> children) =>
      _getFetcherOfTypeId(typeId)._createCollection(id, children);

  void put<T extends Entity<T>>(T entity) {
    // print('Entity: $entity with id ${entity.id.value}');
    if (entity is IdCollection) {
      _box.put(entity.id.value, entity);
    }
    _box.put(entity.id.value, entity);
  }

  T get<T extends Entity<T>>(Id<T> id) => _box.get(id.value) as T;
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = TypeId.typeColor;

  @override
  Color read(BinaryReader reader) => Color(reader.readInt());

  @override
  void write(BinaryWriter writer, Color color) => writer.writeInt(color.value);
}

class InstantAdapter extends TypeAdapter<Instant> {
  @override
  final int typeId = TypeId.typeInstant;

  @override
  Instant read(BinaryReader reader) =>
      Instant.fromEpochMilliseconds(reader.readInt());

  @override
  void write(BinaryWriter writer, Instant obj) =>
      writer.writeInt(obj.epochMilliseconds);
}

class RecurrenceRuleAdapter extends TypeAdapter<RecurrenceRule> {
  @override
  final int typeId = TypeId.typeRecurrenceRule;

  @override
  RecurrenceRule read(BinaryReader reader) =>
      GrecMinimal.fromTexts([reader.readString()]).single;

  @override
  void write(BinaryWriter writer, RecurrenceRule obj) =>
      writer.writeString(GrecMinimal.toTexts([obj]).single);
}

// Type ids.
class TypeId {
  static const typeRoot = 42;
  static const typeId = 40;
  static const typeCollection = 70;
  static const typeColor = 48;
  static const typeChildren = 49;
  static const typeInstant = 61;
  static const typeRecurrenceRule = 62;

  static const typeUser = 51;
  static const typeRole = 65;

  static const typeAssignment = 54;
  static const typeSubmission = 55;

  static const typeEvent = 64;

  static const typeContentType = 46;
  static const typeContent = 57;
  static const typeCourse = 58;
  static const typeLesson = 59;

  static const typeArticle = 56;

  static const typeFile = 53;
}

Future<void> initializeHive() async {
  await Hive.initFlutter();

  Hive
    // General:
    ..registerAdapter(AdapterForId())
    ..registerAdapter(AdapterForIdCollection())
    ..registerAdapter(ColorAdapter())
    ..registerAdapter(InstantAdapter())
    ..registerAdapter(RecurrenceRuleAdapter())
    // App module:
    ..registerAdapter(UserAdapter())
    ..registerAdapter(RoleAdapter())
    // Assignments module:
    ..registerAdapter(AssignmentAdapter())
    ..registerAdapter(SubmissionAdapter())
    // Calendar module:
    ..registerAdapter(EventAdapter())
    // Courses module:
    ..registerAdapter(ContentTypeAdapter())
    ..registerAdapter(ContentAdapter())
    ..registerAdapter(CourseAdapter())
    ..registerAdapter(LessonAdapter())
    // News module:
    ..registerAdapter(ArticleAdapter())
    // Files module:
    ..registerAdapter(FileAdapter());

  HiveCache
    ..registerEntityType(TypeId.typeUser, User.fetch)
    ..registerEntityType<Role>(
        TypeId.typeRole,
        (id) =>
            throw UnsupportedError('Roles cannot be fetched by their id yet.'))
    ..registerEntityType(TypeId.typeAssignment, Assignment.fetch)
    ..registerEntityType(TypeId.typeSubmission, Submission.fetch)
    ..registerEntityType(TypeId.typeEvent, Event.fetch)
    ..registerEntityType(TypeId.typeCourse, Course.fetch)
    ..registerEntityType(TypeId.typeLesson, Lesson.fetch)
    ..registerEntityType<Content>(
      TypeId.typeContent,
      (id) => throw UnsupportedError('Contents cannot be fetched by their id.'),
    )
    ..registerEntityType<File>(
        TypeId.typeFile,
        (id) => throw UnsupportedError('File need to know the type of their '
            'owner, so they cannot be fetched by their id.'))
    ..registerEntityType(TypeId.typeArticle, Article.fetch);
  await HiveCache.initialize();
}
