import 'package:flutter/cupertino.dart';

typedef ErrorMessageBuilder = String Function(BuildContext context);

/// All the exceptions that are thrown in this repository and are expected to
/// be handled by other code in this repository should extend [FancyException].
class FancyException implements Exception {
  FancyException({
    @required this.isGlobal,
    @required this.messageBuilder,
    this.originalException,
    this.stackTrace,
  })  : assert(isGlobal != null),
        assert(messageBuilder != null),
        assert((originalException == null) == (stackTrace == null));

  /// Whether the error applies to the whole app. Certain errors indicate that
  /// the whole app is in a certain exceptional state, for example when there's
  /// no connection to the server or the user's authentication token expired.
  final bool isGlobal;

  /// Creates a localized message describing this error.
  final ErrorMessageBuilder messageBuilder;

  String buildMessage(context) => messageBuilder(context);

  /// Some [FancyException] are thrown because other, non-fancy [Exception]s
  /// got thrown before and got caught.
  final dynamic originalException;
  final StackTrace stackTrace;
  bool get hasOriginalException => originalException != null;

  @Deprecated('To display FancyExceptions, use the messageBuilder instead of '
      'toString(). It takes a context and returns a localized error message.')
  @override
  String toString() => '$runtimeType';
}
