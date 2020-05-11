import 'package:test/test.dart';
import 'package:schulcloud/app/app.dart';

import 'matchers.dart';
import 'utils.dart';

void main() {
  setUp(() async {
    await setUpCommon();
    await signIn();
  });

  tearDown(signOut);

  group('/users', () {
    test('GET /:id', () async {
      final response = await api.get('users/$teacherUserId').json;
      expect(
        response,
        matchesJsonMap({
          '_id': equals(teacherUserId.value),
          'firstName': equals('AT'),
          'lastName': equals('Teacher'),
          'email': equals(teacherEmail),
          'schoolId': equals(schoolId),
          'displayName': equals('AT Teacher'),
          'avatarInitials': equals('AT'),
          'avatarBackgroundColor': isColorString,
          'permissions': allOf(isList, everyElement(isA<String>())),
          'roles': isIdList,
        }),
      );
    });
  });
}
