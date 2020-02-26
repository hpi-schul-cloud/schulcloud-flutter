import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';

part 'data.g.dart';

@immutable
@HiveType(typeId: typeUser)
class User implements Entity {
  const User({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.schoolId,
    @required this.displayName,
    @required this.avatarInitials,
    @required this.avatarBackgroundColor,
    @required this.permissions,
  })  : assert(id != null),
        assert(firstName != null),
        assert(lastName != null),
        assert(email != null),
        assert(schoolId != null),
        assert(displayName != null),
        assert(avatarInitials != null),
        assert(avatarBackgroundColor != null),
        assert(permissions != null);

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
        );

  @override
  @HiveField(0)
  final Id<User> id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String schoolId;

  @HiveField(5)
  final String displayName;

  String get name => '$firstName $lastName';
  String get shortName => '${firstName[0]}. $lastName';

  @HiveField(7)
  final String avatarInitials;
  @HiveField(8)
  final Color avatarBackgroundColor;

  @HiveField(6)
  final List<String> permissions;
  bool hasPermission(String permission) => permissions.contains(permission);
}

@immutable
class Permission {
  const Permission._();

  static const submissionsCreate = 'SUBMISSIONS_CREATE';
  static const submissionsEdit = 'SUBMISSIONS_EDIT';
}
