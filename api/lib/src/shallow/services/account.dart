import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:time_machine/time_machine.dart';

import '../entity.dart';
import '../services/user.dart';
import '../utils.dart';

part 'account.freezed.dart';

@freezed
abstract class Account implements ShallowEntity<Account>, _$Account {
  const factory Account({
    @required EntityMetadata<Account> metadata,
    @required bool isActivated,
    Instant lasttriedFailedLogin,
    @required Id<User> userId,
    @required String username,
  }) = _Account;
  const Account._();

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      metadata: EntityMetadata.fromJson(json),
      isActivated: json['activated'] as bool,
      lasttriedFailedLogin:
          FancyInstant.fromJson(json['lasttriedFailedLogin'] as String),
      userId: Id<User>.fromJson(json['userId'] as String),
      username: json['username'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...metadata.toJson(),
      'activated': isActivated,
      'lasttriedFailedLogin': lasttriedFailedLogin?.toJson(),
      'userId': userId.toJson(),
      'username': username,
    };
  }
}
