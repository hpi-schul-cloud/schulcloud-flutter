import 'dart:io';

import 'package:api/shallow.dart';
import 'package:oxidized/oxidized.dart';
import 'package:test/test.dart';

Shallow? _shallow;
Shallow get shallow => _shallow!;

Future<void> setUpCommon() async {
  await Future<void>.delayed(Duration(seconds: 1));

  _shallow = Shallow(apiRoot: 'https://api.test.hpi-schul-cloud.org');
}

void tearDownCommon() {
  _shallow = null;
}

const schoolId = Id<School>('0000d186816abba584714c5f');
const teacherUserId = Id<User>('5ee1085380ec38002b79390a');
final teacherEmail = Platform.environment['SC_AT_TEACHER_EMAIL']!;
final teacherPassword = Platform.environment['SC_AT_TEACHER_PASSWORD']!;

const studentUserId = Id<User>('5ee109db80ec38002b793c60');
final studentEmail = Platform.environment['SC_AT_STUDENT_EMAIL']!;
final studentPassword = Platform.environment['SC_AT_STUDENT_PASSWORD']!;

Future<void> signIn() async {
  final authResult = await shallow.authentication.signIn(
    AuthenticationBody.local(
      emailAddress: teacherEmail,
      password: teacherPassword,
    ),
  );
  expect(authResult, isA<Ok<void, ShallowError>>());

  expect(shallow.authentication.isSignedIn, isTrue);
  expect(shallow.authentication.currentUserId, teacherUserId);
}

Future<void> signOut() async {
  await shallow.authentication.signOut();
}
