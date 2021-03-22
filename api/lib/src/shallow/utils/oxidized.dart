import 'dart:async';

import 'package:oxidized/oxidized.dart';

extension FancyFutureOfResult<T, E> on Future<Result<T, E>> {
  Future<Result<U, E>> map<U>(FutureOr<U> Function(T) mapper) =>
      fold((it) => mapper(it), (it) => it);
  Future<Result<T, F>> mapError<F>(FutureOr<F> Function(E) mapper) =>
      fold((it) => it, (it) => mapper(it));

  Future<Result<U, F>> fold<U, F>(
    FutureOr<U> Function(T) mapper,
    FutureOr<F> Function(E) errorMapper,
  ) {
    return expand(
      (it) async => Result.ok(await mapper(it)),
      (it) async => Result.err(await errorMapper(it)),
    );
  }

  Future<Result<U, F>> expand<U, F>(
    FutureOr<Result<U, F>> Function(T) mapper,
    FutureOr<Result<U, F>> Function(E) errorMapper,
  ) async {
    final result = await this;
    if (result is Ok) {
      return await mapper(result.unwrap());
    } else {
      return await errorMapper(result.unwrapErr());
    }
  }

  Future<Result<T, E>> orElse(FutureOr<Result<T, E>> Function(E) mapper) =>
      expand((it) async => Result.ok(it), (it) => mapper(it));

  Future<T> unwrap() async => (await this).unwrap();
}
