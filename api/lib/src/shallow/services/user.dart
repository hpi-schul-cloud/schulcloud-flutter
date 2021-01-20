import 'package:freezed_annotation/freezed_annotation.dart';

import '../collection/filtering.dart';
import '../collection/module.dart';
import '../entity.dart';
import '../shallow.dart';
import '../utils.dart';
import 'school.dart';

part 'user.freezed.dart';

class UserCollection
    extends ShallowCollection<User, UserFilterProperties, void> {
  const UserCollection(Shallow shallow) : super(shallow);

  @override
  String get path => '/users';
  @override
  User entityFromJson(Map<String, dynamic> json) => User.fromJson(json);
  @override
  UserFilterProperties createFilterProperty() => UserFilterProperties();
}

@freezed
abstract class User implements ShallowEntity<User>, _$User {
  const factory User({
    @required PartialEntityMetadata<User> metadata,
    @required Id<School> schoolId,
    @required String firstName,
    @required String lastName,
    @required String fullName,
    @required String displayName,
    @required String avatarInitials,
    @required Color avatarBackgroundColor,
    // TODO(JonasWanke): roles
  }) = _User;
  const User._();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      metadata: EntityMetadata.partialFromJson(json),
      schoolId: Id<School>.fromJson(json['schoolId'] as String),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String,
      displayName: json['displayName'] as String,
      avatarInitials: json['avatarInitials'] as String,
      avatarBackgroundColor:
          Color.fromJson(json['avatarBackgroundColor'] as String),
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...metadata.toJson(),
      'schoolId': schoolId.toJson(),
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'displayName': displayName,
      'avatarInitials': avatarInitials,
      'avatarBackgroundColor': avatarBackgroundColor.toJson(),
    };
  }
}

@immutable
class UserFilterProperties {
  const UserFilterProperties();

  ComparableFilterProperty<User, String> get firstName =>
      ComparableFilterProperty('firstName');
  ComparableFilterProperty<User, String> get lastName =>
      ComparableFilterProperty('lastName');
}

enum UserField { id, firstName, lastName }
