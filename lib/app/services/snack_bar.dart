import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get_it/get_it.dart';

import '../logger.dart';

class SnackBarRequest {
  SnackBarRequest({@required this.completer, @required this.snackBar})
      : assert(completer != null),
        assert(snackBar != null);

  final Completer<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>>
      completer;
  final SnackBar snackBar;
}

typedef LoadingMessageBuilder<T> = String Function(T update);

/// A service that offers displaying app-wide [SnackBar]s at the bottom.
class SnackBarService {
  final _controller = StreamController<SnackBarRequest>.broadcast();
  Stream<SnackBarRequest> get requests => _controller.stream;

  void dispose() => _controller.close();

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> show(
    SnackBar snackBar,
  ) {
    final completer =
        Completer<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>>();
    _controller.add(SnackBarRequest(
      completer: completer,
      snackBar: snackBar,
    ));
    return completer.future;
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> showMessage(
    String message,
  ) =>
      show(SnackBar(content: Text(message)));

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>>
      showMessageBriefly(String message) {
    return show(SnackBar(
      duration: Duration(seconds: 2),
      content: Text(message),
    ));
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> showLoading(
      Stream<String> messages) async {
    ScaffoldFeatureController<SnackBar, SnackBarClosedReason> controller;
    return controller = await show(SnackBar(
      duration: Duration(days: 1),
      content: Row(
        children: <Widget>[
          Transform.scale(
            scale: 0.5,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: StreamBuilder<String>(
              stream: Observable(messages).doOnDone(() => controller.close()),
              builder: (_, snapshot) {
                return Text(snapshot.data ?? '');
              },
            ),
          ),
        ],
      ),
    ));
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>>
      showLoadingMessage(String message) {
    return showLoading(Stream.value(message));
  }

  Future<void> performAction({
    @required FutureOr<void> Function() action,
    @required String loadingMessage,
    @required String successMessage,
    @required String failureMessage,
  }) async {
    final controller = await showLoadingMessage(loadingMessage);
    try {
      await action();
      controller.close();
      await showMessageBriefly(successMessage);
    } catch (e, st) {
      logger.e("Simple action couldn't be performed.", e, st);
      controller.close();
      await showMessageBriefly(failureMessage);
    }
  }

  Future<void> performMultiAction<T>({
    @required Stream<T> action,
    @required LoadingMessageBuilder<T> loadingMessageBuilder,
    @required String successMessage,
    @required String failureMessage,
  }) async {
    final updateMessages = StreamController<String>();
    await showLoading(updateMessages.stream);

    var hasError = false;
    Observable(action)
        .doOnData((update) => updateMessages.add(loadingMessageBuilder(update)))
        .listen(
      (update) {},
      onError: (e, st) async {
        logger.e("Multi action couldn't be performed.", e, st);
        hasError = true;
        await updateMessages.close();
        await showMessageBriefly(failureMessage);
      },
      onDone: () {
        if (hasError) {
          // We already closed updateMessages and showed an error message.
          return;
        }

        updateMessages.close();
        showMessageBriefly(successMessage);
      },
      cancelOnError: true,
    );
  }
}

extension SnackBarServiceGetIt on GetIt {
  SnackBarService get snackBar => get<SnackBarService>();
}
