import 'package:test/test.dart';
import 'package:schulcloud/app/module.dart';

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
        await api.get('homework/5ee31c9580ec38002b79505d').json,
        matchesJsonMap({
          '_id': '5ee31c9580ec38002b79505d',
          'schoolId': schoolId,
          'createdAt': '2020-06-12T06:11:33.421Z',
          'updatedAt': '2020-06-12T06:11:33.421Z',
          'teacherId': teacherUserId.value,
          'name': 'Flutter AT assignment 1',
          'description': '<p>description…</p>\r\n',
          'availableDate': '2020-05-12T06:17:00.000Z',
          'dueDate': null,
          'courseId': allOf(
            isMap,
            matchesJsonMap({'_id': '5ee31bfd80ec38002b795029'}),
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
