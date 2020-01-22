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
import 'utils.dart';

bool _isHiveInitialized = false;
const _rootCacheKey = '_root_';

class HiveCache {
  HiveCache._(this.name, this._children, this._data);

  final String name;

  final Box<Children> _children;
  final LazyBox _data;

  static Future<HiveCache> create({
    @required Set<Type> types,
    String name = 'cache',
  }) async {
    assert(types != null);
    assert(types.isNotEmpty);
    assert(name != null);

    Box<Children> children;
    LazyBox data;

    await Future.wait([
      () async {
        children = await Hive.openBox('_children_${name}_',
            compactionStrategy: (a, b) => false);
        for (final child in children.values) {
          child.retainTypes(types);
        }
      }(),
      () async {
        data = await Hive.openLazyBox(
          name,
          compactionStrategy: (a, b) => false,
        );
      }(),
    ]);

    final cache = HiveCache._(name, children, data);
    await cache._collectGarbage();
    return cache;
  }

  Future<void> _collectGarbage() async {
    final usefulKeys = <String>{};

    void markAsUseful(String key) {
      if (usefulKeys.contains(key)) {
        return;
      }
      usefulKeys.add(key);
      _children.get(key)?.getAllChildren()?.forEach(markAsUseful);
    }

    markAsUseful(_rootCacheKey);

    // Remove all the non-useful entries.
    final nonUsefulKeys = _data.keys.toSet().difference(usefulKeys);
    await Future.wait([
      _children.deleteAll(nonUsefulKeys),
      _data.deleteAll(nonUsefulKeys),
    ]);
  }

  Future<void> putChildrenOfType<T extends Entity>(
      Id<dynamic> parent, List<T> children) async {
    final key = parent?.id ?? _rootCacheKey;
    var theChildren = _children.get(key);
    if (theChildren == null) {
      await _children.put(key, Children());
      theChildren = _children.get(key);
    }

    await Future.wait(children.map((child) => _data.put(child.id.id, child)));
    theChildren.setChildrenOfType<T>(
        children.map((child) => child.id.toString()).toList());
  }

  Future<dynamic> get(Id<dynamic> id) => _data.get(id.id);

  Future<List<T>> getChildrenOfType<T>(Id<dynamic> parent) async {
    final key = parent?.id ?? _rootCacheKey;
    final childrenKeys = _children.get(key)?.getChildrenOfType<T>() ??
        (throw NotInCacheException());
    return [for (final key in childrenKeys) await _data.get(key)]
        .where((data) => data != null)
        .cast<T>()
        .toList();
  }

  Future<void> clear() => Future.wait([_data.clear(), _children.clear()]);
}

class Children extends HiveObject {
  /// Map from stringified runtime types to lists of ids.
  final Map<String, List<String>> _children = {};

  void setChildrenOfType<T>(List<String> children) {
    _children[T.toString()] = children;
    save();
  }

  List<String> getChildrenOfType<T>() =>
      _children[T.toString()] ?? (throw NotInCacheException());

  Set<String> getAllChildren() =>
      _children.values.reduce((a, b) => [...a, ...b]).toSet();

  void retainTypes(Set<Type> types) {
    final typesAsStrings = types.map((type) => type.toString()).toSet();
    _children.removeWhere((key, _) => !typesAsStrings.contains(key));
    if (_children.isEmpty) {
      delete();
    } else {
      save();
    }
  }
}

class ChildrenAdapter extends TypeAdapter<Children> {
  @override
  final int typeId = typeChildren;

  @override
  Children read(BinaryReader reader) {
    return Children()
      .._children.addAll({
        for (final entry in (reader.read() as Map)?.entries ?? [])
          entry.key: (entry.value as List).cast<String>(),
      });
  }

  @override
  void write(BinaryWriter writer, Children obj) {
    writer.write(obj._children);
  }
}

class IdAdapter<T> extends TypeAdapter<Id<T>> {
  IdAdapter(this.typeId);

  @override
  final int typeId;

  @override
  Id<T> read(BinaryReader reader) => Id<T>(reader.readString());

  @override
  void write(BinaryWriter writer, Id obj) => writer.writeString(obj.id);
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  final int typeId = typeColor;

  @override
  Color read(BinaryReader reader) => Color(reader.readInt());

  @override
  void write(BinaryWriter writer, Color color) => writer.writeInt(color.value);
}

class InstantAdapter extends TypeAdapter<Instant> {
  @override
  final int typeId = typeInstant;

  @override
  Instant read(BinaryReader reader) =>
      Instant.fromEpochMilliseconds(reader.readInt());

  @override
  void write(BinaryWriter writer, Instant obj) =>
      writer.writeInt(obj.epochMilliseconds);
}

class RecurrenceRuleAdapter extends TypeAdapter<RecurrenceRule> {
  @override
  final int typeId = typeRecurrenceRule;

  @override
  RecurrenceRule read(BinaryReader reader) =>
      GrecMinimal.fromTexts([reader.readString()]).single;

  @override
  void write(BinaryWriter writer, RecurrenceRule obj) =>
      writer.writeString(GrecMinimal.toTexts([obj]).single);
}

// Type ids.
const typeUserId = 40;
const typeColor = 48;
const typeChildren = 49;
const typeInstant = 61;
const typeRecurrenceRule = 62;

const typeUser = 51;

const typeAssignmentId = 47;
const typeSubmissionId = 60;
const typeAssignment = 54;
const typeSubmission = 55;

const typeEventId = 63;
const typeEvent = 64;

const typeContentTypeId = 41;
const typeContentId = 42;
const typeCourseId = 43;
const typeLessonId = 44;
const typeContentType = 46;
const typeContent = 57;
const typeCourse = 58;
const typeLesson = 59;

const typeArticleId = 45;
const typeArticle = 56;

const typeFileId = 50;
const typeFile = 53;

Future<void> initializeHive() async {
  if (_isHiveInitialized) {
    return;
  }
  _isHiveInitialized = true;

  await Hive.initFlutter();

  Hive
    // General:
    ..registerAdapter(IdAdapter<User>(40))
    ..registerAdapter(ColorAdapter())
    ..registerAdapter(ChildrenAdapter())
    ..registerAdapter(InstantAdapter())
    ..registerAdapter(RecurrenceRuleAdapter())
    // App module:
    ..registerAdapter(UserAdapter())
    // Assignments module:
    ..registerAdapter(IdAdapter<Assignment>(typeAssignmentId))
    ..registerAdapter(IdAdapter<Submission>(typeSubmissionId))
    ..registerAdapter(AssignmentAdapter())
    ..registerAdapter(SubmissionAdapter())
    // Calendar module:
    ..registerAdapter(IdAdapter<Event>(typeEventId))
    ..registerAdapter(EventAdapter())
    // Courses module:
    ..registerAdapter(IdAdapter<ContentType>(typeContentTypeId))
    ..registerAdapter(IdAdapter<Content>(typeContentId))
    ..registerAdapter(IdAdapter<Course>(typeCourseId))
    ..registerAdapter(IdAdapter<Lesson>(typeLessonId))
    ..registerAdapter(ContentTypeAdapter())
    ..registerAdapter(ContentAdapter())
    ..registerAdapter(CourseAdapter())
    ..registerAdapter(LessonAdapter())
    // News module:
    ..registerAdapter(IdAdapter<Article>(typeArticleId))
    ..registerAdapter(ArticleAdapter())
    // Files module:
    ..registerAdapter(IdAdapter<File>(typeFileId))
    ..registerAdapter(FileAdapter());
}
