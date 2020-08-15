import 'dart:ui';

import 'package:characters/characters.dart';
import 'package:hive/hive.dart';
import 'package:hive_cache/hive_cache.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/calendar/calendar.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/news/news.dart';

import 'hive.dart';
import 'services.dart';
import 'services/api_network.dart';
import 'utils.dart';

part 'data.g.dart';

@HiveType(typeId: TypeId.user)
class User implements Entity<User> {
  // [email] & [permissions] are null for some users (but not for the current
  // one).
  const User({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    this.email,
    @required this.schoolId,
    String displayName,
    @required this.avatarInitials,
    @required this.avatarBackgroundColor,
    this.permissions,
    @required this.roleIds,
  })  : assert(id != null),
        assert(firstName != null),
        assert(lastName != null),
        assert(schoolId != null),
        displayName = displayName ?? '$firstName $lastName',
        assert(avatarInitials != null),
        assert(avatarBackgroundColor != null),
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
          permissions: (data['permissions'] as List<dynamic>)?.cast<String>(),
          roleIds: parseIds(data['roles']),
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

  String get shortName => '${firstName.characters.first}. $lastName';

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
  bool hasPermission(String permission) =>
      permissions?.contains(permission) ?? false;

  @HiveField(9)
  final List<Id<Role>> roleIds;
  bool get isTeacher => hasRole(Role.teacherName);
  bool get isNotTeacher => !isTeacher;
  bool hasRole(String name) {
    // TODO(marcelgarus): Remove the hard-coded mapping and use runtime lookup when upgrading flutter_cached and flattening is supported.
    final id = {
      Role.teacherName: Role.teacher,
    }[name];
    return id != null && roleIds.contains(id);
  }

  @override
  bool operator ==(Object other) =>
      other is User &&
      id == other.id &&
      firstName == other.firstName &&
      lastName == other.lastName &&
      email == other.email &&
      schoolId == other.schoolId &&
      displayName == other.displayName &&
      avatarInitials == other.avatarInitials &&
      avatarBackgroundColor == other.avatarBackgroundColor &&
      permissions.deeplyEquals(other.permissions, unordered: true) &&
      roleIds.deeplyEquals(other.roleIds, unordered: true);
  @override
  int get hashCode => hashList([
        id,
        firstName,
        lastName,
        email,
        schoolId,
        displayName,
        avatarInitials,
        avatarBackgroundColor,
      ]);
}

class Root implements Entity<Root> {
  @override
  final id = Id<Root>('root');

  final courses = Collection<Course>(
    id: 'courses',
    fetcher: () async => (await services.api.get('courses').parseJsonList())
        .map((data) => Course.fromJson(data))
        .toList(),
  );

  final assignments = Collection<Assignment>(
    id: 'assignments',
    fetcher: () async => (await services.api.get('homework').parseJsonList())
        .map((data) => Assignment.fromJson(data))
        .toList(),
  );

  final submissions = Collection<Submission>(
    id: 'submissions',
    fetcher: () async => (await services.api.get('submissions').parseJsonList())
        .map((data) => Submission.fromJson(data))
        .toList(),
  );

  final events = Collection<Event>(
    id: 'events',
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

  final news = Collection<Article>(
    id: 'articles',
    fetcher: () async => (await services.api.get('news').parseJsonList())
        .map((data) => Article.fromJson(data))
        .toList(),
  );

  @override
  bool operator ==(Object other) => other is Root;
  @override
  int get hashCode => 42;
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
          roleIds: parseIds(data['roles']),
        );

  static const teacher = Id<Role>('0000d186816abba584714c98');
  static const teacherName = 'teacher';
  static const student = Id<Role>('0000d186816abba584714c99');

  static const demoGeneral = Id<Role>('0000d186816abba584714d00');
  static const demoTeacher = Id<Role>('0000d186816abba584714d03');
  static const demoStudent = Id<Role>('0000d186816abba584714d02');
  // TODO(marcelgarus): Don't hardcode role id.
  static bool isDemo(Id<Role> roleId) =>
      [Role.demoGeneral, Role.demoTeacher, Role.demoStudent].contains(roleId);

  @override
  @HiveField(0)
  final Id<Role> id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String displayName;

  @HiveField(3)
  final List<Id<Role>> roleIds;

  @override
  bool operator ==(Object other) =>
      other is Role &&
      id == other.id &&
      name == other.name &&
      displayName == other.displayName &&
      roleIds.deeplyEquals(other.roleIds, unordered: true);
  @override
  int get hashCode => hashList([id, name, displayName, roleIds]);
}

@immutable
class Permission {
  const Permission._();

  static const assignmentEdit = 'HOMEWORK_EDIT';
  static const fileStorageCreate = 'FILESTORAGE_CREATE';
  static const submissionsCreate = 'SUBMISSIONS_CREATE';
  static const submissionsEdit = 'SUBMISSIONS_EDIT';
}
