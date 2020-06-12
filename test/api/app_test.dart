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
        expect(
          await api.get('users/$teacherUserId').json,
          _isUser(
            teacherUserId,
            isCurrentUser: true,
            firstName: 'Flutter AT',
            lastName: 'Teacher',
            email: teacherEmail,
            displayName: 'Flutter AT Teacher',
            avatarInitials: 'FT',
            role: Role.teacher.value,
          ),
        );
      });

      test('student', () async {
        expect(
          await api.get('users/$studentUserId').json,
          _isUser(
            studentUserId,
            isCurrentUser: false,
            firstName: 'Flutter AT',
            lastName: 'Student',
            email: studentEmail,
            displayName: 'Flutter AT Student',
            avatarInitials: 'FS',
            role: Role.student.value,
          ),
        );
      }, skip: 'Student account is not yet migrated');
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
