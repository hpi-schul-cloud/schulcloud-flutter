import 'package:meta/meta.dart';

@immutable
class SignInRequest {
  const SignInRequest({
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
class SignInResponse {
  const SignInResponse({
    @required this.accessToken,
    @required this.userId,
  })  : assert(accessToken != null),
        assert(userId != null);

  SignInResponse.fromJson(Map<String, dynamic> data)
      : this(
          accessToken: data['accessToken'],
          userId: data['account']['userId'],
        );

  final String accessToken;
  final String userId;
}

@immutable
class UserResponse {
  const UserResponse({
    @required this.userId,
    @required this.email,
  })  : assert(userId != null),
        assert(email != null);

  UserResponse.fromJson(Map<String, dynamic> data)
      : this(
          userId: data['_id'],
          email: data['email'],
        );

  final String userId;
  final String email;
}
