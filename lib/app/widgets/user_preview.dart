import 'package:flutter/widgets.dart';
import 'package:hive_cache/hive_cache.dart';
import 'package:rxdart/rxdart.dart';

import '../data.dart';
import '../services/network.dart';
import '../utils.dart';

typedef UserPreviewWidgetBuilder = Widget Function(String displayName);

class UserPreview extends StatelessWidget {
  const UserPreview(
    this.userId, {
    this.builder = _defaultBuilder,
  })  : assert(userId != null),
        assert(builder != null);

  final Id<User> userId;
  final UserPreviewWidgetBuilder builder;

  static Widget _defaultBuilder(String displayName) => Text(displayName);

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return EntityBuilder<User>(
      id: userId,
      builder: (context, snapshot, fetch) {
        var text = s.general_loading;
        if (snapshot.hasData) {
          text = snapshot.data?.displayName;
        } else if (snapshot.hasError) {
          if (snapshot.error is ErrorAndStacktrace &&
              (snapshot.error.error is NotFoundError ||
                  snapshot.error.error is UnauthorizedError)) {
            text = s.general_user_unknown;
          } else {
            text = exceptionMessage(snapshot.error, context);
          }
        }

        return builder(text);
      },
    );
  }
}
