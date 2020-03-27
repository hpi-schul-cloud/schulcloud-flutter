import 'dart:ui';

import 'package:dartx/dartx.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/news/news.dart';

part 'data.g.dart';

@HiveType(typeId: TypeId.user)
class User implements Entity<User> {
  const User({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.schoolId,
    String displayName,
    @required this.avatarInitials,
    @required this.avatarBackgroundColor,
    @required this.permissions,
    @required this.roleIds,
  })  : assert(id != null),
        assert(firstName != null),
        assert(lastName != null),
        assert(email != null),
        assert(schoolId != null),
        displayName = displayName ?? '$firstName $lastName',
        assert(avatarInitials != null),
        assert(avatarBackgroundColor != null),
        assert(permissions != null),
        assert(roleIds != null);

  User.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<User>(data['_id']),
          firstName: data['firstName'],
          lastName: data['lastName'],
          email: data['email'],
          schoolId: data['schoolId'],
          displayName: data['displayName'],
          avatarInitials: data['avatarInitials'],
          avatarBackgroundColor:
              (data['avatarBackgroundColor'] as String).hexToColor,
          permissions: (data['permissions'] as List<dynamic>).cast<String>(),
          roleIds: (data['roles'] as List<dynamic>).castIds<Role>(),
        );

  static Future<User> fetch(Id<User> id) async =>
      User.fromJson(await services.api.get('users/$id').json);

  @override
  @HiveField(0)
  final Id<User> id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  String get shortName => '${firstName.chars.first}. $lastName';

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String schoolId;

  @HiveField(5)
  final String displayName;

  @HiveField(7)
  final String avatarInitials;
  @HiveField(8)
  final Color avatarBackgroundColor;

  @HiveField(6)
  final List<String> permissions;
  bool hasPermission(String permission) => permissions.contains(permission);

  @HiveField(9)
  final List<Id<Role>> roleIds;
  bool get isTeacher => hasRole(Role.teacherName);
  bool get isNotTeacher => !isTeacher;
  bool hasRole(String name) {
    // TODO(marcelgarus): Remove the hard-coded mapping and use runtime lookup when upgrading flutter_cached and flattening is supported.
    final id = {
      Role.teacherName: '0000d186816abba584714c98',
    }[name];
    return id != null && roleIds.contains(Id<Role>(id));
  }
}

class Root implements Entity<Root> {
  @override
  final id = Id<Root>('root');

  final courses = LazyIds<Course>(
    collectionId: 'courses',
    fetcher: () async => (await services.api.get('courses').parseJsonList())
        .map((data) => Course.fromJson(data))
        .toList(),
  );

  final assignments = LazyIds<Assignment>(
    collectionId: 'assignments',
    fetcher: () async => (await services.api.get('homework').parseJsonList())
        .map((data) => Assignment.fromJson(data))
        .toList(),
  );

  final submissions = LazyIds<Submission>(
    collectionId: 'submissions',
    fetcher: () async => (await services.api.get('submissions').parseJsonList())
        .map((data) => Submission.fromJson(data))
        .toList(),
  );

  final events = LazyIds<Event>(
    collectionId: 'events',
    fetcher: () async {
      // We have to set the "all" query parameter because otherwise — you
      // guessed it — no events are being returned at all 😂
      final jsonResponse = await services.api.get(
        'calendar',
        queryParameters: {'all': 'true'},
      ).parseJsonList(isServicePaginated: false);
      return jsonResponse.map((data) => Event.fromJson(data)).toList();
    },
  );

  final news = LazyIds<Article>(
    collectionId: 'articles',
    fetcher: () async => (await services.api.get('news').parseJsonList())
        .map((data) => Article.fromJson(data))
        .toList(),
  );
}

@HiveType(typeId: TypeId.role)
class Role implements Entity<Role> {
  const Role({
    @required this.id,
    @required this.name,
    @required this.displayName,
    @required this.roleIds,
  })  : assert(id != null),
        assert(name != null),
        assert(displayName != null),
        assert(roleIds != null);

  Role.fromJson(Map<String, dynamic> data)
      : this(
          id: Id<Role>(data['_id']),
          name: data['name'],
          displayName: data['displayName'],
          roleIds: (data['roles'] as List<dynamic>).castIds<Role>(),
        );

  static const teacherName = 'teacher';

  @override
  @HiveField(0)
  final Id<Role> id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String displayName;

  @HiveField(3)
  final List<Id<Role>> roleIds;
}

@immutable
class Permission {
  const Permission._();

  static const assignmentEdit = 'HOMEWORK_EDIT';
  static const fileStorageCreate = 'FILESTORAGE_CREATE';
  static const submissionsCreate = 'SUBMISSIONS_CREATE';
  static const submissionsEdit = 'SUBMISSIONS_EDIT';
}
