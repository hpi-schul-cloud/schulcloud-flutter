import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

/// Turns any stream into a BehaviorSubject, which is a BroadcastStream and thus
/// can handle multiple subscribers.
BehaviorSubject<T> streamToBehaviorSubject<T>(Stream<T> stream) {
  BehaviorSubject<T> subject;
  subject = BehaviorSubject<T>(
    onListen: () => stream.listen(
      subject.add,
      onError: subject.addError,
      onDone: subject.close,
    ),
    onCancel: () => subject.hasListener ? null : subject.close(),
  );
  return subject;
}

/// Converts a hex string (like, '#ffdd00') to a [Color].
Color hexStringToColor(String hex) =>
    Color(int.parse('ff' + hex.substring(1), radix: 16));

/// Widget that waits for the given future and otherwise displays a loading
/// indicator.
class SplashScreenTask extends StatelessWidget {
  final Future<dynamic> Function() task;
  final WidgetBuilder builder;

  SplashScreenTask({
    @required this.task,
    @required this.builder,
  })  : assert(task != null),
        assert(builder != null);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: task(),
      builder: (context, snapshot) {
        return snapshot.connectionState == ConnectionState.done
            ? builder(context)
            : Container(
                color: Colors.white,
                alignment: Alignment.center,
                child: CircularProgressIndicator());
      },
    );
  }
}
