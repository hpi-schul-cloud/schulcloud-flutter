import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:repository/repository.dart';

import 'utils.dart';

part 'data.g.dart';

@immutable
@HiveType()
class User implements Entity {
  @HiveField(0)
  final Id<User> id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String schoolToken;

  @HiveField(5)
  final String displayName;

  String get name => '$firstName $lastName';
  String get shortName => '${firstName[0]}. $lastName';

  User({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.schoolToken,
    @required this.displayName,
  })  : assert(id != null),
        assert(firstName != null),
        assert(lastName != null),
        assert(email != null),
        assert(schoolToken != null),
        assert(displayName != null);
}
