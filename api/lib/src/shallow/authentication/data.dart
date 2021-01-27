import 'package:freezed_annotation/freezed_annotation.dart';

import '../services/account.dart';

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
