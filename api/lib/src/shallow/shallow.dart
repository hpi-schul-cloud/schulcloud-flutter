import 'package:dio/dio.dart';
import 'package:oxidized/oxidized.dart';

import 'authentication/module.dart';
import 'network.dart';
import 'services/course.dart';
import 'services/lesson.dart';
import 'services/me.dart';
import 'services/news.dart';
import 'services/school.dart';
import 'services/user.dart';

class Shallow {
  Shallow({
    Dio? dio,
    this.apiRoot = 'https://api.hpi-schul-cloud.de',
  }) : dio = dio ?? Dio() {
    this.dio.options.baseUrl = apiRoot;
    _authentication = ShallowAuthentication(this);
    this.dio.interceptors.add(authentication.dioInterceptor);

    _courses = CourseCollection(this);
    _lessons = LessonCollection(this);
    _news = ArticleCollection(this);
    _users = UserCollection(this);
    _schools = SchoolCollection(this);
  }

  final Dio dio;
  final String apiRoot;

  late final ShallowAuthentication _authentication;
  ShallowAuthentication get authentication => _authentication;

  late final CourseCollection _courses;
  CourseCollection get courses => _courses;

  Future<Result<Me, ShallowError>> me() async {
    final response =
        await dio.makeRequest<Map<String, dynamic>>((it) => it.get('/me'));
    return response.map((it) => Me.fromJson(it.data!));
  }

  late final LessonCollection _lessons;
  LessonCollection get lessons => _lessons;

  late final ArticleCollection _news;
  ArticleCollection get news => _news;

  late final UserCollection _users;
  UserCollection get users => _users;

  late final SchoolCollection _schools;
  SchoolCollection get schools => _schools;
}
