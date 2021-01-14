import 'package:freezed_annotation/freezed_annotation.dart';

import 'entity.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User implements ShallowEntity<User>, _$User {
  const factory User({
    @required Id<User> id,
  }) = _User;
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  const User._();
}
