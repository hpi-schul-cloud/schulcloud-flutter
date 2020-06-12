import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/main_sc_test.dart';
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
    ..registerSingleton(scTestAppConfig)
    ..registerSingleton(BannerService())
    ..registerSingleton(NetworkService())
    ..registerSingleton(api);
}

void tearDownCommon() {
  services.reset();
}

class MockStorageService extends Mock implements StorageService {}

const schoolId = '0000d186816abba584714c5f';
const teacherUserId = Id<User>('5ee1085380ec38002b79390a');
final teacherEmail = Platform.environment['SC_AT_TEACHER_EMAIL'];
final teacherPassword = Platform.environment['SC_AT_TEACHER_PASSWORD'];
final teacher = User(
  id: teacherUserId,
  firstName: 'Flutter AT',
  lastName: 'Teacher',
  email: teacherEmail,
  schoolId: schoolId,
  displayName: 'Flutter AT Teacher',
  avatarInitials: 'FT',
  avatarBackgroundColor: Color(0x00fe8a71),
  permissions: [],
  roleIds: [],
);

const studentUserId = Id<User>('5eba35def505d6002a79a77f');
final studentEmail = Platform.environment['SC_AT_STUDENT_EMAIL'];
final studentPassword = Platform.environment['SC_AT_STUDENT_PASSWORD'];
final student = User(
  id: studentUserId,
  firstName: 'Flutter AT',
  lastName: 'Student',
  email: studentEmail,
  schoolId: schoolId,
  displayName: 'Flutter AT Student',
  avatarInitials: 'FT',
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
