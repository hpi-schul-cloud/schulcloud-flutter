import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:schulcloud/core/data.dart';

part 'user.g.dart';

@JsonSerializable()
class User extends Entity<User> {
  final String firstName;
  final String lastName;
  final String email;
  final String schoolToken;
  final String displayName;

  String get name => '$firstName $lastName';
  String get shortName => '${firstName[0]}. $lastName';

  User({
    @required Id<User> id,
    @required this.firstName,
    @required this.lastName,
    @required this.email,
    @required this.schoolToken,
    @required this.displayName,
  }) : super(id);

  factory User.fromJson(Map<String, dynamic> data) => User(
          id: Id(data['id'] as String),
          firstName: data['firstName'] as String,
          lastName: data['lastName'] as String,
          email: data['email'] as String,
          schoolToken: data['schoolToken'] as String,
          displayName: data['displayName'] as String);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id.toString(),
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'schoolToken': schoolToken,
        'displayName': displayName
  };
}
