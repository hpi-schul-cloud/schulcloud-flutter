import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repository/repository.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/courses/courses.dart';
import 'package:schulcloud/news/news.dart';

Future<void> initializeHive() async {
  var dir = await getApplicationDocumentsDirectory();

  Hive
    ..init(dir.path)
    // App module
    ..registerAdapter(IdAdapter(), 40)
    ..registerAdapter(UserAdapter(), 41)
    // Courses module
    ..registerAdapter(ContentTypeAdapter(), 50)
    ..registerAdapter(ContentAdapter(), 51)
    ..registerAdapter(CourseAdapter(), 52)
    ..registerAdapter(LessonAdapter(), 53)
    // News module
    ..registerAdapter(ArticleAdapter(), 60);
}

class IdAdapter extends TypeAdapter<Id> {
  @override
  Id read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Id(fields[0] as String);
  }

  @override
  void write(BinaryWriter writer, Id obj) {
    writer.writeByte(1);
    writer.writeByte(0);
    writer.write(obj.id);
  }
}
