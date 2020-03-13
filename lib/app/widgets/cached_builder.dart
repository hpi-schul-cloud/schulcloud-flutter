import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';

class FancyCachedBuilder<T> extends StatelessWidget {
  const FancyCachedBuilder({@required this.controller, @required this.builder})
      : assert(controller != null),
        assert(builder != null);

  final CacheController<T> controller;
  final Widget Function(BuildContext, T data, bool isFetching) builder;

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder(
      controller: controller,
      builder: (context, update) {
        // There is no error. We can just call the builder.
        if (update.hasNoError) {
          return builder(context, update.data, update.isFetching);
        }

        // An error occurred.

        // Our code should only throw [FancyException]s to trigger behavior in
        // other parts of the app. Other exceptions should be handled by the
        // children of this widget. If they can't handle them, they should
        // catch them nevertheless and then throw [FancyException]s instead.
        if (update.error is! FancyException) {
          logger
            ..e('The following exception occurred. If you want to display an '
                'exception to the user, instead create a custom exception by '
                'extending FancyException. This will be caught and display a '
                'beautiful error screen.')
            ..e(update.error)
            ..e('To view the full stack trace, long-tap the pink striped '
                'area.');
          return PinkStripedErrorWidget(update.error, update.stackTrace);
        }

        final error = update.error as FancyException;

        // If there are no data, then there's nothing we can display except the
        // error.
        if (update.hasNoData) {
          return ErrorScreen(update.error, update.stackTrace);
        }

        // There is an error as well as cached data.

        // If the error is global, it's been handled elsewhere. More
        // specifically, the user is shown a message at a central error space.
        // That's why we don't need to display the error here.
        if (error.isGlobal) {
          return builder(context, update.data, update.isFetching);
        }

        // TODO(marcelgarus): Display both the error and the cached content.
        return PinkStripedErrorWidget(update.error, update.stackTrace);
      },
    );
  }
}
