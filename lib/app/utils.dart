import 'dart:convert';
import 'dart:ui';

import 'package:repository/repository.dart';
import 'package:rxdart/rxdart.dart';

import 'services.dart';

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

Color hexStringToColor(String hex) =>
    Color(int.parse('ff' + hex.substring(1), radix: 16));

Future<User> fetchUser(NetworkService network, Id<User> id) async {
  var response = await network.get('users/$id');
  var data = json.decode(response.body);

  // For now, the [avatarBackgroundColor] and [avatarInitials] are not saved.
  // Not sure if we'll need it.
  return User(
    id: Id<User>(data['_id']),
    firstName: data['firstName'],
    lastName: data['lastName'],
    email: data['email'],
    schoolToken: data['schoolId'],
    displayName: data['displayName'],
  );
}
