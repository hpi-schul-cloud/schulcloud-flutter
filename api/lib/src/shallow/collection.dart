import 'dart:io';

import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxidized/oxidized.dart';

import 'entity.dart';
import 'errors.dart';
import 'shallow.dart';

part 'collection.freezed.dart';

abstract class ShallowCollection<E extends ShallowEntity<E>, F> {
  const ShallowCollection(this.shallow) : assert(shallow != null);

  final Shallow shallow;
  String get path;
  E entityFromJson(Map<String, dynamic> json);

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

  Future<Result<PaginatedResponse<E>, ShallowError>> list({
    Map<F, SortOrder> sortedBy = const {},
    int limit,
    int skip = 0,
  }) async {
    assert(sortedBy != null);
    assert(limit == null || limit > 0);
    assert(skip == null || skip >= 0);

    Response<Map<String, dynamic>> rawResponse;
    try {
      rawResponse = await shallow.dio.get<Map<String, dynamic>>(
        path,
        queryParameters: <String, dynamic>{
          for (final entry in sortedBy.entries)
            '\$sort[${EnumToString.convertToString(entry.key)}]':
                entry.value.queryValue,
          if (limit != null) r'$limit': limit,
          if (skip != null) r'$skip': skip,
        },
      );
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

enum SortOrder { ascending, descending }

extension on SortOrder {
  int get queryValue {
    return {
      SortOrder.ascending: 1,
      SortOrder.descending: -1,
    }[this];
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
