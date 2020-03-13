import 'package:flutter/cupertino.dart';

typedef ErrorMessageBuilder = String Function(BuildContext context);

/// All the exceptions that are thrown in this repository and are expected to
/// be handled by other code in this repository should extend [FancyException].
class FancyException implements Exception {
  FancyException({
    @required this.isGlobal,
    @required this.stackTrace,
    @required this.messageBuilder,
  })  : assert(isGlobal != null),
        assert(messageBuilder != null);

  /// Whether the error applies to the whole app. Certain errors indicate that
  /// the whole app is in a certain exceptional state, for example when there's
  /// no connection to the server or the user's authentication token expired.
  final bool isGlobal;

  final StackTrace stackTrace;

  /// Creates a localized message describing this error.
  final ErrorMessageBuilder messageBuilder;

  String buildMessage(context) => messageBuilder(context);

  @Deprecated('To display FancyExceptions, use the messageBuilder instead of '
      'toString(). It takes a context and returns a localized error message.')
  @override
  String toString() => '$runtimeType';
}
