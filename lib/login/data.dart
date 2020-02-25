import 'package:meta/meta.dart';

@immutable
class LoginRequest {
  const LoginRequest({
    @required this.email,
    @required this.password,
  })  : assert(email != null),
        assert(password != null);

  Map<String, dynamic> toJson() => {
        'strategy': strategy,
        'username': email,
        'password': password,
      };

  static const strategy = 'local';
  final String email;
  final String password;
}

@immutable
class LoginResponse {
  const LoginResponse({
    @required this.accessToken,
    @required this.userId,
  })  : assert(accessToken != null),
        assert(userId != null);

  LoginResponse.fromJson(Map<String, dynamic> data)
      : this(
          accessToken: data['accessToken'],
          userId: data['account']['userId'],
        );

  final String accessToken;
  final String userId;
}
