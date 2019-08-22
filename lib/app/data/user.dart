import 'package:entity/entity.dart';

@Entity()
class _User {
  String firstName;
  String lastName;
  String email;
  String schoolToken;
  String displayName;

  String get name => '$firstName $lastName';
  String get shortName => '${firstName[0]}. $lastName';
}
