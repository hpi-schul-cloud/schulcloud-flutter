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

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

class UserSerializer extends Serializer<User> {
  const UserSerializer()
      : super(fromJson: _$UserFromJson, toJson: _$UserToJson);
}
