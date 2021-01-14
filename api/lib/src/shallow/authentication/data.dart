import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:time_machine/time_machine.dart';

import '../entity.dart';
import '../user.dart';
import '../utils.dart';

part 'data.freezed.dart';
part 'data.g.dart';

@Freezed(unionKey: 'strategy')
abstract class AuthenticationBody implements _$AuthenticationBody {
  const factory AuthenticationBody.local({
    @required @JsonKey(name: 'username') String emailAddress,
    @required String password,

    /// When this is set, the user will remain logged in for longer when
    /// inactive.
    @Default(false) @JsonKey(name: 'privateDevice') bool isPrivateDevice,
  }) = _LocalAuthenticationBody;

  /// Not yet supported.
  @experimental
  const factory AuthenticationBody.ldap() = _LdapAuthenticationBody;

  factory AuthenticationBody.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationBodyFromJson(json);
  const AuthenticationBody._();
}

@freezed
abstract class AuthenticationResponse implements _$AuthenticationResponse {
  const factory AuthenticationResponse({
    @required String accessToken,
    @required Account account,
  }) = _AuthenticationResponse;
  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationResponseFromJson(json);
  const AuthenticationResponse._();
}

@freezed
abstract class Account implements ShallowEntity<Account>, _$Account {
  const factory Account({
    @required @JsonKey(name: '_id') Id<Account> id,
    @InstantConverter() Instant createdAt,
    @InstantConverter() Instant updatedAt,
    @JsonKey(name: 'isActivated') bool isActivated,
    @InstantConverter() Instant lasttriedFailedLogin,
    Id<User> userId,
    String username,
  }) = _Account;
  factory Account.fromJson(Map<String, dynamic> json) =>
      _$AccountFromJson(json);
  const Account._();
}
