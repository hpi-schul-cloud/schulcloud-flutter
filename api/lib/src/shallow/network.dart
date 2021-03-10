import 'dart:io';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:oxidized/oxidized.dart';

@immutable
abstract class ShallowError implements Exception {
  const ShallowError(this.message);

  final String message;
}

class NoConnectionToServerError extends ShallowError {
  const NoConnectionToServerError() : super('NoConnectionToServer');
}

class UnauthorizedError extends ShallowError {
  const UnauthorizedError() : super('Unauthorized');
}

class NotFoundError extends ShallowError {
  const NotFoundError() : super('Not Found');
}

class InternalServerError extends ShallowError {
  const InternalServerError() : super('Internal Server Error');
}

extension FancyDio on Dio {
  Future<Result<Response<T>, ShallowError>> makeRequest<T>(
    Future<Response<T>> Function(Dio) requester,
  ) async {
    try {
      return Result.ok(await requester(this));
    } on DioError catch (e) {
      if (e.response == null) return Result.err(NoConnectionToServerError());
      switch (e.response!.statusCode) {
        case HttpStatus.unauthorized:
          return Result.err(UnauthorizedError());
        case HttpStatus.notFound:
          return Result.err(NotFoundError());
      }
      rethrow;
    }
  }
}
