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
