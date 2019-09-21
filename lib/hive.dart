import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:repository/repository.dart';
import 'package:schulcloud/app/app.dart';
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
    ..registerAdapter(IdAdapter<StorageData>(), 47)
    ..registerAdapter(IdAdapter<ContentType>(), 41)
    ..registerAdapter(IdAdapter<Content>(), 42)
    ..registerAdapter(IdAdapter<Course>(), 43)
    ..registerAdapter(IdAdapter<Lesson>(), 44)
    ..registerAdapter(IdAdapter<Article>(), 45)
    ..registerAdapter(IdAdapter<Author>(), 46)
    // App module
    ..registerAdapter(UserAdapter(), 51)
    ..registerAdapter(StorageDataAdapter(), 52)
    // Courses module
    ..registerAdapter(ContentTypeAdapter(), 60)
    ..registerAdapter(ContentAdapter(), 61)
    ..registerAdapter(CourseAdapter(), 62)
    ..registerAdapter(LessonAdapter(), 63)
    // News module
    ..registerAdapter(ArticleAdapter(), 70)
    ..registerAdapter(AuthorAdapter(), 71);
}

class IdAdapter<T> extends TypeAdapter<Id<T>> {
  @override
  Id<T> read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Id<T>(fields[0] as String);
  }

  @override
  void write(BinaryWriter writer, Id<T> obj) {
    writer.writeByte(1);
    writer.writeByte(0);
    writer.write(obj.id);
  }
}
