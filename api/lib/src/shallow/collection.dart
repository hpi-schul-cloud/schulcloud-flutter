import 'dart:io';

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxidized/oxidized.dart';

import 'entity.dart';
import 'errors.dart';
import 'shallow.dart';

part 'collection.freezed.dart';

typedef EntityFromJson<E extends ShallowEntity<E>> = E Function(
  Map<String, dynamic> json,
);

class ShallowCollection<E extends ShallowEntity<E>> {
  ShallowCollection({
    @required this.shallow,
    @required this.path,
    @required this.entityFromJson,
  })  : assert(shallow != null),
        assert(path != null),
        assert(entityFromJson != null);

  final Shallow shallow;
  final String path;
  final EntityFromJson<E> entityFromJson;

  Future<Result<E, ShallowError>> get(Id<E> id) async {
    assert(id != null);

    Response<Map<String, dynamic>> rawResponse;
    try {
      rawResponse =
          await shallow.dio.get<Map<String, dynamic>>('$path/${id.value}');
    } on DioError catch (e) {
      switch (e.response.statusCode) {
        case HttpStatus.unauthorized:
          return Result.err(UnauthorizedError());
        case HttpStatus.notFound:
          return Result.err(NotFoundError());
      }
      rethrow;
    }

    final entity = entityFromJson(rawResponse.data);
    return Result.ok(entity);
  }

  Future<Result<PaginatedResponse<E>, ShallowError>> list() async {
    Response<Map<String, dynamic>> rawResponse;
    try {
      rawResponse = await shallow.dio.get<Map<String, dynamic>>(path);
    } on DioError catch (e) {
      switch (e.response.statusCode) {
        case HttpStatus.unauthorized:
          return Result.err(UnauthorizedError());
        case HttpStatus.notFound:
          return Result.err(NotFoundError());
      }
      rethrow;
    }

    final paginatedResponse = PaginatedResponse(
      total: rawResponse.data['total'] as int,
      limit: rawResponse.data['limit'] as int,
      skip: rawResponse.data['skip'] as int,
      items: (rawResponse.data['data'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(entityFromJson)
          .toList(),
    );
    return Result.ok(paginatedResponse);
  }
}

@freezed
abstract class PaginatedResponse<T> implements _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    @required int total,
    @required int limit,
    @required int skip,
    @required List<T> items,
  }) = _PaginatedResponse<T>;
}
