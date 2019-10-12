import 'package:flutter/painting.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repository/repository.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';
import 'package:schulcloud/homework/homework.dart';
import 'package:schulcloud/news/news.dart';

bool _isHiveInitialized = false;

Future<void> initializeHive() async {
  if (_isHiveInitialized) return;
  _isHiveInitialized = true;

  var dir = await getApplicationDocumentsDirectory();

  Hive
    ..init(dir.path)
    ..registerAdapter(IdAdapter(), 40)
    ..registerAdapter(ColorAdapter(), 48)
    // App module
    ..registerAdapter(UserAdapter(), 51)
    ..registerAdapter(StorageDataAdapter(), 52)
    // Courses module
    ..registerAdapter(ContentTypeAdapter(), 60)
    ..registerAdapter(ContentAdapter(), 61)
    ..registerAdapter(CourseAdapter(), 62)
    ..registerAdapter(LessonAdapter(), 63)
    // Homework module
    ..registerAdapter(HomeworkAdapter(), 80)
    ..registerAdapter(SubmissionAdapter(), 81)
    // News module
    ..registerAdapter(ArticleAdapter(), 70)
    ..registerAdapter(AuthorAdapter(), 71);
}

class IdAdapter extends TypeAdapter<Id> {
  @override
  Id read(BinaryReader reader) => Id(reader.readString());

  @override
  void write(BinaryWriter writer, Id obj) => writer.writeString(obj.id);
}

class ColorAdapter extends TypeAdapter<Color> {
  @override
  Color read(BinaryReader reader) => Color(reader.readInt());

  @override
  void write(BinaryWriter writer, Color color) => writer.writeInt(color.value);
}
