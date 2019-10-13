import 'package:flutter/painting.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignments/assignments.dart';
import 'package:schulcloud/courses/courses.dart';
import 'package:schulcloud/news/news.dart';

bool _isHiveInitialized = false;

Future<void> initializeHive() async {
  if (_isHiveInitialized) return;
  _isHiveInitialized = true;

  var dir = await getApplicationDocumentsDirectory();

  Hive
    ..init(dir.path)
    ..registerAdapter(IdAdapter<User>(), 40)
    ..registerAdapter(IdAdapter<ContentType>(), 41)
    ..registerAdapter(IdAdapter<Content>(), 42)
    ..registerAdapter(IdAdapter<Course>(), 43)
    ..registerAdapter(IdAdapter<Lesson>(), 44)
    ..registerAdapter(IdAdapter<Article>(), 45)
    ..registerAdapter(IdAdapter<Author>(), 46)
    ..registerAdapter(IdAdapter<Assignment>(), 47)
    ..registerAdapter(ColorAdapter(), 48)
    // App module
    ..registerAdapter(UserAdapter(), 51)
    // Courses module
    ..registerAdapter(ContentTypeAdapter(), 60)
    ..registerAdapter(ContentAdapter(), 61)
    ..registerAdapter(CourseAdapter(), 62)
    ..registerAdapter(LessonAdapter(), 63)
    // Homework module
    ..registerAdapter(AssignmentAdapter(), 80)
    ..registerAdapter(SubmissionAdapter(), 81)
    // News module
    ..registerAdapter(ArticleAdapter(), 70)
    ..registerAdapter(AuthorAdapter(), 71);
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
