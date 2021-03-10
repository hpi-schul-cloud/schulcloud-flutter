import 'package:freezed_annotation/freezed_annotation.dart';

import '../entity.dart';
import '../services/user.dart';
import '../utils.dart';

part 'account.freezed.dart';

@freezed
class Account with _$Account implements ShallowEntity<Account> {
  @Assert(
    'lastTriedFailedLogin == null || lastTriedFailedLogin.isValidDateTime',
  )
  const factory Account({
    required EntityMetadata<Account> metadata,
    required bool isActivated,
    DateTime? lastTriedFailedLogin,
    required Id<User> userId,
    required String username,
  }) = _Account;
  const Account._();

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      metadata: EntityMetadata.fromJson(json),
      isActivated: json['activated'] as bool,
      lastTriedFailedLogin: FancyDateTime.parseApiDateTime(
          json['lasttriedFailedLogin'] as String),
      userId: Id<User>.fromJson(json['userId'] as String),
      username: json['username'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      ...metadata.toJson(),
      'activated': isActivated,
      'lasttriedFailedLogin': lastTriedFailedLogin?.toIso8601String(),
      'userId': userId.toJson(),
      'username': username,
    };
  }
}
