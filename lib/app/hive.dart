import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/news/news.dart';

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
        data = await Hive.openBox(name,
            lazy: true, compactionStrategy: (a, b) => false);
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
  @override
  Id<T> read(BinaryReader reader) => Id<T>(reader.readString());

  @override
  void write(BinaryWriter writer, Id obj) => writer.writeString(obj.id);
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  Color read(BinaryReader reader) => Color(reader.readInt());

  @override
  void write(BinaryWriter writer, Color color) => writer.writeInt(color.value);
}

Future<void> initializeHive() async {
  if (_isHiveInitialized) {
    return;
  }
  _isHiveInitialized = true;

  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();

  Hive
    ..init(dir.path)
    // General:
    ..registerAdapter(IdAdapter<User>(), 40)
    ..registerAdapter(ColorAdapter(), 48)
    ..registerAdapter(ChildrenAdapter(), 49)
    // App module:
    ..registerAdapter(UserAdapter(), 51)
    // Assignments module:
    ..registerAdapter(IdAdapter<Assignment>(), 47)
    ..registerAdapter(IdAdapter<Submission>(), 60)
    ..registerAdapter(AssignmentAdapter(), 54)
    ..registerAdapter(SubmissionAdapter(), 55)
    // Courses module:
    ..registerAdapter(IdAdapter<ContentType>(), 41)
    ..registerAdapter(IdAdapter<Content>(), 42)
    ..registerAdapter(IdAdapter<Course>(), 43)
    ..registerAdapter(IdAdapter<Lesson>(), 44)
    ..registerAdapter(ContentTypeAdapter(), 46)
    ..registerAdapter(ContentAdapter(), 57)
    ..registerAdapter(CourseAdapter(), 58)
    ..registerAdapter(LessonAdapter(), 59)
    // News module:
    ..registerAdapter(IdAdapter<Article>(), 45)
    ..registerAdapter(ArticleAdapter(), 56)
    // Files module:
    ..registerAdapter(IdAdapter<File>(), 50)
    ..registerAdapter(FileAdapter(), 53);
}
