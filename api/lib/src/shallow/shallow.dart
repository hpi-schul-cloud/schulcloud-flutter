import 'dart:convert';

import 'package:dio/dio.dart';

import 'authentication/module.dart';
import 'entity.dart';
import 'user.dart';

class Shallow {
  Shallow({
    Dio dio,
    this.apiRoot = 'https://api.hpi-schul-cloud.de',
  })  : dio = dio ?? Dio(),
        assert(apiRoot != null) {
    this.dio.options.baseUrl = apiRoot;
    _authentication = ShallowAuthentication(this);
  }

  final Dio dio;
  final String apiRoot;

  ShallowAuthentication _authentication;
  ShallowAuthentication get authentication => _authentication;
}

abstract class ShallowCollection<E> {
  ShallowCollection(Shallow shallow) : _shallow = shallow;

  final Shallow _shallow;
}

void main(List<String> args) {
  // final api = …;

  // api.currentUser

  // api.courses
  // .where()
  // .fetch()
  // with pagination

  // await api.courses.get(Id<Course>(''));

  // await api.courses.set(Course(''));
  // await api.courses.add(Course(''));
}

// shallow
// Schul-cloud of the Hpi's Api whose Level is LOW
