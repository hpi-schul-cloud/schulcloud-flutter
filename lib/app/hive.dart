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

bool _isHiveInitialized = false;

class Id<T extends Entity<T>> {
  Id(this.id) {
    _box = HiveCache._boxForType<T>(T);
  }

  final String id;
  CacheBox<T> _box;

  Type get type => T;

  CacheController<T> get controller {
    return SimpleCacheController<T>(
      saveToCache: HiveCache.put,
      loadFromCache: () => HiveCache.get(this) ?? (throw NotInCacheException()),
      fetcher: () => _box.fetcher(this),
    );
  }

  Id<S> cast<S extends Entity<S>>() => Id<S>(id);

  @override
  bool operator ==(other) => other is Id<T> && other.id == id;
  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => id;
}

class AdapterForId extends TypeAdapter<Id<dynamic>> {
  @override
  int get typeId => TypeId.typeId;

  @override
  void write(BinaryWriter writer, Id<dynamic> id) {
    final type = id.type;
    final typeId = HiveCache._untypedBoxForType(type).typeId;
    writer
      ..writeInt(typeId)
      ..writeString(id.id);
  }

  @override
  Id read(BinaryReader reader) {
    final typeId = reader.readInt();
    final box = HiveCache._boxForTypeId(typeId);
    return box._createId(reader.readString());
  }
}

class Collection<T extends Entity<T>> implements Entity<Collection<T>> {
  Collection({@required this.id, @required this.childrenIds});

  @override
  final Id<Collection<T>> id;
  final List<Id<T>> childrenIds;
}

class Ids<T extends Entity<T>> implements Entity<Collection<T>> {
  Ids({@required this.id, @required this.fetcher});

  @override
  final Id<Collection<T>> id;

  List<Id<T>> childrenIds;
  final FutureOr<List<T>> Function() fetcher;

  CacheController<List<T>> get controller {
    return SimpleCacheController<List<T>>(
      fetcher: fetcher,
      loadFromCache: () async {
        final ids = HiveCache.get(id) ?? (throw NotInCacheException());
        return [
          for (final itemId in ids.childrenIds)
            HiveCache.get(itemId) ?? (throw NotInCacheException()),
        ];
      },
      saveToCache: (items) {
        final collection = Collection<T>(
          id: id,
          childrenIds: items.map((item) => item.id),
        );
        HiveCache.put<Collection<T>>(collection);
        items.forEach(HiveCache.put);
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

abstract class Entity<T extends Entity<T>> {
  const Entity();

  Id<T> get id;
}

class CacheBox<T extends Entity<T>> {
  CacheBox({@required this.typeId, @required this.box, @required this.fetcher});

  final int typeId;
  final Box box;
  final FutureOr<T> Function(Id<T> id) fetcher;

  Type get type => T;

  Id<T> _createId(String id) => Id<T>(id);
}

class HiveCacheImpl {
  final _boxes = <Type, CacheBox<dynamic>>{};

  CacheBox<dynamic> _untypedBoxForType(Type type) {
    final box = _boxes[type];
    if (box == null) {
      throw Exception('Unknown type $type. Did you forget to register a box?');
    }
    return box;
  }

  CacheBox<T> _boxForType<T extends Entity<T>>(Type type) {
    return _untypedBoxForType(type) as CacheBox<T>;
  }

  CacheBox<dynamic> _boxForTypeId(int typeId) {
    return _boxes.values.singleWhere((box) => box.typeId == typeId);
  }

  void initialize(Iterable<CacheBox> boxes) {
    for (final box in boxes) {
      _boxes[box.type] = box;
    }
  }

  void put<T extends Entity<T>>(T entity) {
    final box = _boxForType<T>(entity.runtimeType);
    box.box.put(entity.id.id, entity);
  }

  T get<T extends Entity<T>>(Id<T> id) {
    final box = _boxForType<T>(T);
    return box.box.get(id.id) as T;
  }
}

// ignore: non_constant_identifier_names
final HiveCache = HiveCacheImpl();

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
  static const typeCollection = 41;
  static const typeColor = 48;
  static const typeChildren = 49;
  static const typeInstant = 61;
  static const typeRecurrenceRule = 62;

  static const typeUser = 51;

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
  if (_isHiveInitialized) {
    return;
  }
  _isHiveInitialized = true;

  await Hive.initFlutter();

  Hive
    // General:
    ..registerAdapter(AdapterForId())
    ..registerAdapter(ColorAdapter())
    ..registerAdapter(InstantAdapter())
    ..registerAdapter(RecurrenceRuleAdapter())
    // App module:
    ..registerAdapter(UserAdapter())
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

  HiveCache.initialize({
    CacheBox<User>(
      typeId: TypeId.typeUser,
      box: await Hive.openBox('users'),
      fetcher: User.fetch,
    ),
  });
}
