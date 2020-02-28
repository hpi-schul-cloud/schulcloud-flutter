import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/news/news.dart';

part 'data.g.dart';

@immutable
@HiveType(typeId: TypeId.typeUser)
class User implements Entity<User> {
  User({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.schoolId,
    @required this.displayName,
  })  : assert(id != null),
        assert(firstName != null),
        assert(lastName != null),
        assert(email != null),
        assert(schoolId != null),
        assert(displayName != null),
        files = LazyIds<File>(
          collectionId: 'files of $id',
          fetcher: () => File.fetchByOwner(id),
        );

  User.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<User>(data['_id']),
          firstName: data['firstName'],
          lastName: data['lastName'],
          email: data['email'],
          schoolId: data['schoolId'],
          displayName: data['displayName'],
        );

  static Future<User> fetch(Id<User> id) async =>
      User.fromJson(await fetchJsonFrom('users/$id'));

  @override
  @HiveField(0)
  final Id<User> id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  String get name => '$firstName $lastName';
  String get shortName => '${firstName[0]}. $lastName';

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String schoolId;

  @HiveField(5)
  final String displayName;

  final LazyIds<File> files;
}

@immutable
@HiveType(typeId: TypeId.typeRoot)
class Root implements Entity<Root> {
  @override
  Id<Root> get id => Id<Root>('root');

  final courses = LazyIds<Course>(
    collectionId: 'courses',
    fetcher: () async => (await fetchJsonListFrom('courses'))
        .map((data) => Course.fromJson(data))
        .toList(),
  );

  final assignments = LazyIds<Assignment>(
    collectionId: 'assignments',
    fetcher: () async => (await fetchJsonListFrom('homework'))
        .map((data) => Assignment.fromJson(data))
        .toList(),
  );

  final submissions = LazyIds<Submission>(
    collectionId: 'submissions',
    fetcher: () async => (await fetchJsonListFrom('submissions'))
        .map((data) => Submission.fromJson(data))
        .toList(),
  );

  final events = LazyIds<Event>(
    collectionId: 'events',
    fetcher: () async {
      final jsonResponse = await fetchJsonListFrom(
        'calendar',
        wrappedInData: false,
        parameters: {
          // We have to set this query parameter because otherwise—you guessed
          // it—no events are being returned at all 😂
          'all': 'true',
        },
      );
      return jsonResponse.map((data) => Event.fromJson(data)).toList();
    },
  );

  final news = LazyIds<Article>(
    collectionId: 'articles',
    fetcher: () async => (await fetchJsonListFrom('news'))
        .map((data) => Article.fromJson(data))
        .toList(),
  );
}
