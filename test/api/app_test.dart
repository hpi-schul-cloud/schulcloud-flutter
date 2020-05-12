import 'package:test/test.dart';
import 'package:schulcloud/app/app.dart';

import 'matchers.dart';
import 'utils.dart';

void main() {
  setUp(() async {
    await setUpCommon();
    await signIn();
  });

  tearDown(() async {
    await signOut();
    tearDownCommon();
  });

  group('/users', () {
    group('GET /:id', () {
      test('teacher (me)', () async {
        final response = await api.get('users/$teacherUserId').json;
        expect(
          response,
          _isUser(
            teacherUserId,
            isCurrentUser: true,
            firstName: 'AT',
            lastName: 'Teacher',
            email: teacherEmail,
            displayName: 'AT Teacher',
            avatarInitials: 'AT',
            role: Role.teacher.value,
          ),
        );
      });

      test('student', () async {
        final response = await api.get('users/$studentUserId').json;
        expect(
          response,
          _isUser(
            studentUserId,
            isCurrentUser: false,
            firstName: 'AT',
            lastName: 'Student',
            email: studentEmail,
            displayName: 'AT Student',
            avatarInitials: 'AS',
            role: Role.student.value,
          ),
        );
      });
    });
  });
}

Matcher _isUser(
  Id<User> id, {
  @required bool isCurrentUser,
  @required String firstName,
  @required String lastName,
  @required String email,
  @required String displayName,
  @required String avatarInitials,
  @required String role,
}) {
  return matchesJsonMap({
    '_id': id.value,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'schoolId': schoolId,
    'displayName': displayName,
    'avatarInitials': avatarInitials,
    'avatarBackgroundColor': isColorString,
    if (isCurrentUser)
      'permissions': allOf(isList, everyElement(isA<String>())),
    'roles': allOf(isIdList, contains(role)),
  });
}
