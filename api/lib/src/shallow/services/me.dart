import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/locale.dart';

import '../entity.dart';
import '../utils.dart';
import 'account.dart';
import 'role.dart';
import 'school.dart';

part 'me.freezed.dart';

@freezed
abstract class Me implements ShallowEntity<Me>, _$Me {
  const factory Me({
    @required EntityMetadata<Me> metadata,
    @required Id<School> schoolId,
    @required String firstName,
    @required String lastName,
    @required String fullName,
    @required String displayName,
    @required String avatarInitials,
    @required Color avatarBackgroundColor,
    // Additional properties compared to [User]:
    @required Id<Account> accountId,
    @required String emailAddress,
    @required Locale locale,
    @required List<Role> roles, // `/users` only contains their IDs
    @required List<Permission> permissions,
    @required bool isExternallyManaged,
    // TODO(JonasWanke): consent, forcePasswordChange, children, parents, features, preferences
  }) = _Me;
  const Me._();

  factory Me.fromJson(Map<String, dynamic> json) {
    return Me(
      metadata: EntityMetadata.fromJson(json),
      schoolId: Id<School>.fromJson(json['schoolId'] as String),
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String,
      displayName: json['displayName'] as String,
      avatarInitials: json['avatarInitials'] as String,
      avatarBackgroundColor:
          Color.fromJson(json['avatarBackgroundColor'] as String),
      // Additional properties compared to [User]:
      accountId: Id<Account>.fromJson(json['accountId'] as String),
      emailAddress: json['email'] as String,
      locale: Locale.parse(json['language'] as String),
      roles: (json['roles'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map((it) => Role.fromJson(it))
          .toList(),
      permissions: (json['permissions'] as List<dynamic>)
          .cast<String>()
          .map((it) => Permission.fromJson(it))
          .toList(),
      isExternallyManaged: json['externallyManaged'] as bool,
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
      // Additional properties compared to [User]:
      'accountId': accountId.toJson(),
      'email': emailAddress,
      'language': locale.toLanguageTag(),
      'roles': roles.map((it) => it.toJson()).toList(),
      'permissions': permissions.map((it) => it.toJson()).toList(),
      'externallyManaged': isExternallyManaged,
    };
  }
}
