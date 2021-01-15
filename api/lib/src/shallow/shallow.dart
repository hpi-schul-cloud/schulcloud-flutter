import 'package:dio/dio.dart';

import 'authentication/module.dart';
import 'collection.dart';
import 'course.dart';

class Shallow {
  Shallow({
    Dio dio,
    this.apiRoot = 'https://api.hpi-schul-cloud.de',
  })  : dio = dio ?? Dio(),
        assert(apiRoot != null) {
    this.dio.options.baseUrl = apiRoot;
    _authentication = ShallowAuthentication(this);
    this.dio.interceptors.add(authentication.dioInterceptor);

    _courses = ShallowCollection(
      shallow: this,
      path: '/courses',
      entityFromJson: (it) => Course.fromJson(it),
    );
  }

  final Dio dio;
  final String apiRoot;

  ShallowAuthentication _authentication;
  ShallowAuthentication get authentication => _authentication;

  ShallowCollection<Course> _courses;
  ShallowCollection<Course> get courses => _courses;
}
