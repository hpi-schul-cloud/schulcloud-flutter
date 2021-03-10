import 'package:api/shallow.dart';
import 'package:oxidized/oxidized.dart';
import 'package:test/test.dart';

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

  group('users', () {
    group('get single', () {
      test('teacher', () async {
        _expectUser(
          await shallow.users.get(teacherUserId),
          id: teacherUserId,
          schoolId: schoolId,
          firstName: 'Flutter AT',
          lastName: 'Teacher',
          fullName: 'Flutter AT Teacher',
          displayName: 'Flutter AT Teacher',
          avatarInitials: 'FT',
          avatarBackgroundColor: Color(0xfffe8a71),
          roleIds: [Role.teacherId],
        );
      });

      test('student', () async {
        _expectUser(
          await shallow.users.get(studentUserId),
          id: studentUserId,
          schoolId: schoolId,
          firstName: 'Flutter AT',
          lastName: 'Student',
          fullName: 'Flutter AT Student',
          displayName: 'Flutter AT Student',
          avatarInitials: 'FS',
          avatarBackgroundColor: Color(0xfff6cd61),
          roleIds: [Role.studentId],
        );
      });
    });
  });
}

void _expectUser(
  Result<User, ShallowError> result, {
  required Id<User> id,
  required Id<School> schoolId,
  required String firstName,
  required String lastName,
  required String fullName,
  required String displayName,
  required String avatarInitials,
  required Color avatarBackgroundColor,
  required List<Id<Role>> roleIds,
}) {
  expect(result, isA<Ok<User, ShallowError>>());

  final user = result.unwrap();
  expect(user, isNotNull);
  expect(user.metadata.id, id);
  expect(user.schoolId, schoolId);
  expect(user.firstName, firstName);
  expect(user.lastName, lastName);
  expect(user.fullName, fullName);
  expect(user.displayName, displayName);
  expect(user.avatarInitials, avatarInitials);
  expect(user.avatarBackgroundColor, avatarBackgroundColor);
  expect(user.roleIds, containsAll(roleIds));
}
