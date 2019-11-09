import 'dart:ui';

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
const _rootCacheKey = Id<dynamic>('_root_');

class HiveCache {
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
        children = await Hive.openBox('_children_${name}_');
        children.values.forEach((child) => child.retainTypes(types));
      }(),
      () async {
        data = await Hive.openBox(name, lazy: true);
      }(),
    ]);

    final cache = HiveCache._(name, children, data);
    await cache._collectGarbage();
    return cache;
  }

  HiveCache._(this.name, this._children, this._data);

  Future<void> _collectGarbage() async {
    final Set<Id<dynamic>> usefulIds = {};

    void markAsUseful(Id<dynamic> id) {
      if (usefulIds.contains(id)) return;
      usefulIds.add(id);
      for (final child in _children.get(id.id)?.getAllChildren() ?? []) {
        markAsUseful(child);
      }
    }

    markAsUseful(_rootCacheKey);

    // Remove all the non-useful entries.
    final nonUsefulIds = _data.keys.toSet().difference(usefulIds);
    _children.deleteAll(nonUsefulIds);
    _data.deleteAll(nonUsefulIds);
  }

  Future<void> putChildrenOfType<T extends Entity>(
      Id<dynamic> parent, List<T> children) async {
    Children theChildren;
    String key = parent?.id ?? _rootCacheKey;
    theChildren = _children.get(key);
    if (children == null) {
      _children.put(key, Children());
      theChildren = _children.get(key);
    }
    theChildren.setChildrenOfType<T>(children.map((child) => child.id));
    await Future.wait(children.map((child) => _data.put(child.id.id, child)));
  }

  Future<dynamic> get(Id<dynamic> id) async {
    return await _data.get(id.id);
  }

  Future<List<T>> getChildrenOfType<T>(Id<dynamic> parent) async {
    final childrenIds =
        _children.get(parent?.id ?? _rootCacheKey)?.getChildrenOfType<T>() ??
            (throw NotInCacheException());
    return [for (final id in childrenIds) await _data.get(id)];
  }

  Future<void> clear() => Future.wait([_data.clear(), _children.clear()]);
}

class Children extends HiveObject {
  /// Map from stringified runtime types to lists of ids.
  final Map<String, List<String>> _children = const {};

  void setChildrenOfType<T>(Iterable<Id<T>> children) {
    _children[T.toString()] = children.map((id) => id.id).toList();
    save();
  }

  List<Id<T>> getChildrenOfType<T>() {
    return _children[T.toString()]?.map((id) => Id<T>(id)) ??
        (throw NotInCacheException());
  }

  Set<Id<dynamic>> getAllChildren() {
    return _children.values
        .reduce((a, b) => [...a, ...b])
        .map((id) => Id<dynamic>(id))
        .toSet();
  }

  void retainTypes(Set<Type> types) {
    final typesAsStrings = types.map((type) => type.toString()).toSet();
    _children.removeWhere((key, _) => !typesAsStrings.contains(key));
    if (_children.isEmpty) {
      delete();
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
  if (_isHiveInitialized) return;
  _isHiveInitialized = true;

  var dir = await getApplicationDocumentsDirectory();

  Hive
    ..init(dir.path)
    // General:
    ..registerAdapter(IdAdapter<User>(), 40)
    ..registerAdapter(IdAdapter<Entity>(), 52)
    ..registerAdapter(ColorAdapter(), 48)
    ..registerAdapter(ChildrenAdapter(), 49)
    // App module:
    ..registerAdapter(UserAdapter(), 51)
    // Assignments module:
    ..registerAdapter(IdAdapter<Assignment>(), 47)
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
