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

/// An object in the business logic, like a [Course] or a [User].
@immutable
abstract class Entity<E extends Entity<E>> {
  const Entity._();

  Id<E> get id;
}

extension SaveableEntity<E extends Entity<E>> on Entity<E> {
  void saveToCache() => HiveCache.put(this);
}

/// An [Id] that identifies an [Entity] among all other [Entity]s, even of
/// different types.
@immutable
class Id<E extends Entity<E>> {
  const Id(this.value) : assert(value != null);

  factory Id.orNull(String value) => value == null ? null : Id<E>(value);

  final String value;

  Type get type => E;
  int get typeId => HiveCache.typeIdByType<E>();

  CacheController<E> get controller {
    return SimpleCacheController<E>(
      saveToCache: HiveCache.put,
      loadFromCache: () => HiveCache.get(this) ?? (throw NotInCacheException()),
      fetcher: () => HiveCache.fetch(this),
    );
  }

  Id<S> cast<S extends Entity<S>>() => Id<S>(value);

  @override
  bool operator ==(other) => other is Id<E> && other.value == value;
  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class _AdapterForId extends TypeAdapter<Id<dynamic>> {
  @override
  int get typeId => TypeId.id;

  @override
  void write(BinaryWriter writer, Id<dynamic> id) => writer
    ..writeInt(id.typeId)
    ..writeString(id.value);

  @override
  Id<dynamic> read(BinaryReader reader) =>
      HiveCache._createIdOfTypeId(reader.readInt(), reader.readString());
}

/// A wrapper around multiple [Id]s.
class IdCollection<E extends Entity<E>> implements Entity<IdCollection<E>> {
  const IdCollection({
    @required this.id,
    this.childrenIds = const [],
  })  : assert(id != null),
        assert(childrenIds != null);

  @override
  final Id<IdCollection<E>> id;
  final List<Id<E>> childrenIds;

  int get typeId => HiveCache.typeIdByType<E>();
}

class _AdapterForIdCollection extends TypeAdapter<IdCollection<dynamic>> {
  @override
  int get typeId => TypeId.collection;

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
class LazyIds<E extends Entity<E>> {
  LazyIds({@required this.collectionId, @required this.fetcher});

  final String collectionId;
  Id<IdCollection<E>> get _id => Id<IdCollection<E>>(collectionId);

  final FutureOr<List<E>> Function() fetcher;

  CacheController<List<E>> get controller {
    return SimpleCacheController<List<E>>(
      fetcher: fetcher,
      loadFromCache: () async {
        final ids = HiveCache.get(_id) ?? (throw NotInCacheException());
        return [
          for (final itemId in ids.childrenIds)
            HiveCache.get(itemId) ?? (throw NotInCacheException()),
        ];
      },
      saveToCache: (items) {
        final collection = IdCollection<E>(
          id: _id,
          childrenIds: items.map((item) => item.id).toList(),
        );
        HiveCache.put<IdCollection<E>>(collection);
        items.forEach(HiveCache.put);
      },
    );
  }
}

extension ListOfIds<E extends Entity<E>> on List<Id<E>> {
  CacheController<List<E>> get controller {
    return CacheController.combiningControllers(
      map((id) => id.controller).toList(),
    );
  }
}

extension IdParsingList on List<dynamic> {
  List<Id<E>> castIds<E extends Entity<E>>() {
    return map((id) => Id<E>(id as String)).toList();
  }
}

// ignore: non_constant_identifier_names
final HiveCache = HiveCacheImpl();

typedef FetchFunction<E extends Entity<E>> = Future<E> Function(Id<E> id);

@immutable
class Fetcher<E extends Entity<E>> {
  const Fetcher(this.fetch) : assert(fetch != null);

  final FetchFunction<E> fetch;

  Id<E> _createId(String id) => Id<E>(id);
  IdCollection<E> _createCollection(String id, List<String> childrenIds) {
    return IdCollection<E>(
      id: Id<IdCollection<E>>(id),
      childrenIds: childrenIds.map((child) => Id<E>(child)).toList(),
    );
  }
}

class HiveCacheImpl {
  final _fetchers = <int, Fetcher>{};
  Box<dynamic> _box;

  Future<E> fetch<E extends Entity<E>>(Id<E> id) {
    for (final fetcher in _fetchers.values) {
      if (fetcher is Fetcher<E>) {
        return fetcher.fetch(id);
      }
    }
    throw UnsupportedError("We don't know how to fetch $E. Are you sure you "
        'registered the type $E?');
  }

  Future<void> initialize() async {
    assert(_box == null, 'initialize was already called');
    _box = await Hive.openBox('cache');
  }

  void registerEntityType<E extends Entity<E>>(
    int typeId,
    FetchFunction<E> fetch,
  ) {
    assert(_fetchers[typeId] == null,
        'A fetcher with typeId $typeId is already registered');
    _fetchers[typeId] = Fetcher<E>(fetch);
  }

  int typeIdByType<E extends Entity<E>>() {
    try {
      return _fetchers.entries
          .singleWhere((entry) => entry.value is Fetcher<E>)
          .key;
      // Unlike Exceptions, Errors indicate that the programmer did something
      // wrong. Generally, they should not be caught during runtime. In this
      // case, however, we throw another Error with more information, so it's
      // okay to catch the error here.
      // ignore: avoid_catching_errors
    } on StateError {
      throw UnsupportedError('No id for type $E found. Did you forget to '
          'register the type $E?');
    }
  }

  Fetcher<dynamic> _getFetcherOfTypeId(int id) =>
      _fetchers[id] ?? (throw UnsupportedError('Unknown type id $id.'));
  Id<dynamic> _createIdOfTypeId(int typeId, String id) =>
      _getFetcherOfTypeId(typeId)._createId(id);
  IdCollection<dynamic> _createCollectionOfTypeId(
          int typeId, String id, List<String> children) =>
      _getFetcherOfTypeId(typeId)._createCollection(id, children);

  void put<E extends Entity<E>>(E entity) {
    logger.v('Hive: put ${entity.id} ($entity)');

    _box.put(entity.id.value, entity);
  }

  E get<E extends Entity<E>>(Id<E> id) => _box.get(id.value) as E;
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = TypeId.color;

  @override
  Color read(BinaryReader reader) => Color(reader.readInt());

  @override
  void write(BinaryWriter writer, Color color) => writer.writeInt(color.value);
}

class InstantAdapter extends TypeAdapter<Instant> {
  @override
  final int typeId = TypeId.instant;

  @override
  Instant read(BinaryReader reader) =>
      Instant.fromEpochMilliseconds(reader.readInt());

  @override
  void write(BinaryWriter writer, Instant obj) =>
      writer.writeInt(obj.epochMilliseconds);
}

class RecurrenceRuleAdapter extends TypeAdapter<RecurrenceRule> {
  @override
  final int typeId = TypeId.recurrenceRule;

  @override
  RecurrenceRule read(BinaryReader reader) =>
      GrecMinimal.fromTexts([reader.readString()]).single;

  @override
  void write(BinaryWriter writer, RecurrenceRule obj) =>
      writer.writeString(GrecMinimal.toTexts([obj]).single);
}

// Type ids.
// Used before: 46
class TypeId {
  static const entity = 71;
  static const id = 40;
  static const root = 42;
  static const collection = 70;
  static const color = 48;
  static const children = 49;
  static const instant = 61;
  static const recurrenceRule = 62;

  static const user = 51;
  static const role = 65;

  static const assignment = 54;
  static const submission = 55;

  static const event = 64;

  static const course = 58;
  static const lesson = 59;
  static const content = 57;
  static const unsupportedComponent = 73;
  static const textComponent = 72;
  static const etherpadComponent = 74;
  static const nexboardComponent = 75;

  static const article = 56;

  static const file = 53;
  static const filePath = 78;
  static const localFile = 79;
}

Future<void> initializeHive() async {
  await Hive.initFlutter();

  Hive
    // General:
    ..registerAdapter(_AdapterForId())
    ..registerAdapter(_AdapterForIdCollection())
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
    ..registerAdapter(CourseAdapter())
    ..registerAdapter(LessonAdapter())
    ..registerAdapter(ContentAdapter())
    ..registerAdapter(UnsupportedComponentAdapter())
    ..registerAdapter(TextComponentAdapter())
    ..registerAdapter(EtherpadComponentAdapter())
    ..registerAdapter(NexboardComponentAdapter())
    // News module:
    ..registerAdapter(ArticleAdapter())
    // Files module:
    ..registerAdapter(FileAdapter())
    ..registerAdapter(FilePathAdapter());

  HiveCache
    ..registerEntityType(TypeId.user, User.fetch)
    ..registerEntityType<Role>(
        TypeId.role,
        (id) =>
            throw UnsupportedError('Roles cannot be fetched by their id yet.'))
    ..registerEntityType(TypeId.assignment, Assignment.fetch)
    ..registerEntityType(TypeId.submission, Submission.fetch)
    ..registerEntityType(TypeId.event, Event.fetch)
    ..registerEntityType(TypeId.course, Course.fetch)
    ..registerEntityType(TypeId.lesson, Lesson.fetch)
    ..registerEntityType<Content>(
      TypeId.content,
      (id) => throw UnsupportedError('Contents cannot be fetched by their id.'),
    )
    ..registerEntityType<File>(
        TypeId.file,
        (id) => throw UnsupportedError('Files need to know the type of their '
            'owner, so they cannot be fetched by their id alone.'))
    ..registerEntityType(TypeId.article, Article.fetch);
  await HiveCache.initialize();
}
