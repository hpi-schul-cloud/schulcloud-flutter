import 'package:api/shallow.dart';
import 'package:dio/dio.dart';

// ignore_for_file: avoid_print

Future<void> main(List<String> args) async {
  final shallow = Shallow(
    apiRoot: 'https://api.nbc-audit.hpi-schul-cloud.org',
  );
  // shallow.dio.interceptors.add(
  //   LogInterceptor(
  //     requestHeader: true,
  //     requestBody: true,
  //     responseHeader: true,
  //     responseBody: true,
  //   ),
  // );

  await shallow.authentication.signIn(
    AuthenticationBody.local(
      emailAddress: 'your-email-address',
      password: r'your-password',
    ),
  );
  print('Signed in as:\n${shallow.authentication.currentUserId}\n');

  final courses = await shallow.courses.list(
      // where: (it) => it.id.equals(Id<Course>('5f86ea313ab6eb0036e5d34c')),
      // where: (it) => (it.color <= Color(0xFFFFFFFF)),
      // sortedBy: {CourseField.createdAt: SortOrder.ascending},
      );
  print('Courses:\n${courses.unwrap().items.join('\n')}\n');

  final lessonCourseId = courses.unwrap().items.first.metadata.id;
  final lessons = await shallow.lessons.list(
    where: (it) => it.courseId.equals(lessonCourseId),
  );
  print(
      'Lessons of course $lessonCourseId:\n${lessons.unwrap().items.join('\n')}\n');

  final me = await shallow.me();
  print('Me:\n${me.unwrap()}\n');

  final news = await shallow.news.list();
  print('News:\n${news.unwrap().items.join('\n')}\n');

  final users = await shallow.users.list();
  print('Users:\n${users.unwrap().items.join('\n')}\n');

  final schools = await shallow.schools.list();
  print('Schools:\n${schools.unwrap().items.join('\n')}\n');

  await shallow.authentication.signOut();
}
