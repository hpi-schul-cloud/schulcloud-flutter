import 'package:rxdart/rxdart.dart';

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
