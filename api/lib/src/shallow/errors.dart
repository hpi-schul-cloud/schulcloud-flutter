import 'package:meta/meta.dart';

@immutable
abstract class ShallowError implements Exception {
  const ShallowError(this.message) : assert(message != null);

  final String message;
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
