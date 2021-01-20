import 'package:dio/dio.dart';

import 'authentication/module.dart';
import 'services/course.dart';
import 'services/news.dart';
import 'services/school.dart';
import 'services/user.dart';

class Shallow {
  Shallow({
    Dio dio,
    this.apiRoot = 'https://api.hpi-schul-cloud.de',
  })  : dio = dio ?? Dio(),
        assert(apiRoot != null) {
    this.dio.options.baseUrl = apiRoot;
    _authentication = ShallowAuthentication(this);
    this.dio.interceptors.add(authentication.dioInterceptor);

    _courses = CourseCollection(this);
    _news = ArticleCollection(this);
    _users = UserCollection(this);
    _schools = SchoolCollection(this);
  }

  final Dio dio;
  final String apiRoot;

  ShallowAuthentication _authentication;
  ShallowAuthentication get authentication => _authentication;

  CourseCollection _courses;
  CourseCollection get courses => _courses;

  ArticleCollection _news;
  ArticleCollection get news => _news;

  UserCollection _users;
  UserCollection get users => _users;

  SchoolCollection _schools;
  SchoolCollection get schools => _schools;
}
