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

  group('/homework', () {
    test('GET /:id', () async {
      expect(
        await api.get('homework/5eba3f7b614d76002ab664a4').json,
        matchesJsonMap({
          '_id': '5eba3f7b614d76002ab664a4',
          'schoolId': schoolId,
          'createdAt': '2020-05-12T06:17:31.122Z',
          'updatedAt': '2020-05-12T06:17:31.122Z',
          'teacherId': teacherUserId.value,
          'name': 'AT assignment 1',
          'description': '<p>description…</p>\r\n',
          'availableDate': '2020-05-12T06:17:00.000Z',
          'dueDate': null,
          'courseId': allOf(
            isMap,
            matchesJsonMap({'_id': '5eba370d614d76002ab62905'}),
          ),
          'lessonId': null,
          'private': false,
          'publicSubmissions': true,
          'archived': allOf(isIdList, isEmpty),
          'teamSubmissions': false,
          'fileIds': allOf(isIdList, isEmpty),
        }),
      );
    });
  });
}
