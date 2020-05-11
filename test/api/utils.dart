import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/main.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';
import 'package:test/test.dart';

ApiNetworkService api;
StorageService storage;

Future<void> setUpCommon() async {
  await Future.delayed(Duration(seconds: 1));

  api = ApiNetworkService();
  storage = MockStorageService();

  services
    ..registerSingleton(storage)
    ..registerSingleton(schulCloudAppConfig)
    ..registerSingleton(BannerService())
    ..registerSingleton(NetworkService())
    ..registerSingleton(api);
}

class MockStorageService extends Mock implements StorageService {}

const teacherUserId = Id<User>('5eb9597d33f2e600294b1ac5');
final teacherEmail = Platform.environment['SC_AT_TEACHER_EMAIL'];
final teacherPassword = Platform.environment['SC_AT_TEACHER_PASSWORD'];
final teacher = User(
  id: teacherUserId,
  firstName: 'AT',
  lastName: 'Teacher',
  email: teacherEmail,
  schoolId: '5da021397f7b3700339a8906',
  displayName: 'AT Teacher',
  avatarInitials: 'AT',
  avatarBackgroundColor: Color(0xfffe8a71),
  permissions: [],
  roleIds: [],
);

Future<void> signIn() async {
  when(storage.hasToken).thenReturn(false);

  final response = await services.api.post(
    'authentication',
    body: {
      'strategy': 'local',
      'username': teacherEmail,
      'password': teacherPassword,
    },
  ).json;

  final token = response['accessToken'];
  expect(token, isNotEmpty);
  expect(response['account']['userId'], equals(teacherUserId.value));

  when(storage.hasToken).thenReturn(true);

  final tokenPreference = _MockPreference<String>();
  when(tokenPreference.getValue()).thenReturn(token);
  when(storage.token).thenAnswer((_) => tokenPreference);
  when(storage.userFromCache).thenAnswer((_) async => teacher);
}

// ignore: avoid_implementing_value_types
class _MockPreference<T> extends Mock implements Preference<T> {}

Future<void> signOut() async {
  await api.delete('authentication');
}
