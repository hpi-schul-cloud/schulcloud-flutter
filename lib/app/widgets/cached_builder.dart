import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:hive_cache/hive_cache.dart';
import 'package:rxdart/rxdart.dart';

import '../exception.dart';
import '../logger.dart';
import 'app_bar.dart';
import 'error_widgets.dart';

typedef FetchableDataBuilder<T> = Widget Function(
  BuildContext,
  T,
  FetchCallback,
);

// TODO(marcelgarus): remove
// I'm so looking forward to typedefs for non-function-types:
// https://github.com/dart-lang/language/issues/65
// Then this could just become a CachedFetchStream<T>.

FetchableBuilder<T> handleError<T>(FetchableDataBuilder<T> builder) {
  return (context, snapshot, fetch) {
    // There is no error. We can just call the builder.
    if (!snapshot.hasError) {
      return builder(context, snapshot.data, fetch);
    }

    // An error occurred.
    assert(snapshot.hasError);
    final error = snapshot.error;

    // Code inside the stream should only throw [FancyException]s to
    // trigger behavior in other parts of the app. Other exceptions should
    // be handled locally. If they can't handle them, they should catch
    // them nevertheless and then throw descriptive [FancyException]s
    // instead.
    if (error is! FancyException) {
      logger.e(
        'The following exception occurred: $error '
        'If you want to display an exception to the user, instead create '
        'a custom exception by extending FancyException. This will be '
        'caught and display a beautiful error screen. '
        'To view the full stack trace, long-tap the pink striped area.',
        error,
      );
      return PinkStripedErrorWidget(error, null);
    }

    final fancyError = error as FancyException;

    // If there is no data, then there's nothing we can display except the
    // error.
    if (!snapshot.hasData) {
      return ErrorScreen(fancyError);
    }

    // There is an error as well as cached data.

    // If the error is global, it's been handled elsewhere. More
    // specifically, the user is shown a message at a central error space.
    // That's why we don't need to display the error here.
    if (fancyError.isGlobal) {
      return builder(context, snapshot.data, fetch);
    }

    // TODO(marcelgarus): Display both the error and the cached content.
    return PinkStripedErrorWidget(error, null);
  };
}

FetchableDataBuilder<T> handleLoading<T>(FetchableDataBuilder<T> builder) {
  return (context, data, fetch) {
    return data == null
        ? Center(child: CircularProgressIndicator())
        : builder(context, data, fetch);
  };
}

FetchableDataBuilder<T> handleLoadingAndPullToRefresh<T>({
  NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
  FancyAppBar appBar,
  @required FetchableDataBuilder<T> builder,
}) {
  assert(
    headerSliverBuilder == null || appBar == null,
    'You cannot provide both a headerSliverBuilder and an appBar to '
    'handlePullToRefresh. If you want to display both, include the app bar in '
    'the result of the headerSliverBuilder.',
  );

  return (context, data, fetch) {
    return NestedScrollView(
      headerSliverBuilder:
          headerSliverBuilder ?? (_, __) => [if (appBar != null) appBar],
      body: RefreshIndicator(
        onRefresh: fetch,
        child: data == null
            ? Center(child: CircularProgressIndicator())
            : builder(context, data, fetch),
      ),
    );
  };
}

FetchableDataBuilder<List<T>> handleEmptyState<T>({
  @required WidgetBuilder emptyStateBuilder,
  @required FetchableDataBuilder<List<T>> builder,
}) {
  return (context, items, fetch) {
    return items.isEmpty
        ? emptyStateBuilder(context)
        : builder(context, items, fetch);
  };
}

// FetchableBuilder<T> handleErrorAndLoading<T>(FetchableDataBuilder<T> builder) {
//   return handleError((context, data, fetch) {});
// }

FetchableBuilder<T> handleErrorAndLoadingAndPullToRefreshAndEmptyState<T>({
  NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
  FancyAppBar appBar,
  @required StreamContentBuilder<T> builder,
  @required WidgetBuilder emptyStateBuilder,
}) {
  assert(
    headerSliverBuilder == null || appBar == null,
    'You cannot provide both a headerSliverBuilder and an appBar to '
    'handlePullToRefresh. If you want to display both, include the app bar in '
    'the result of the headerSliverBuilder.',
  );

  return handleError(handleLoadingAndPullToRefresh(
    builder: (context, data, fetch) {
      return NestedScrollView(
        headerSliverBuilder:
            headerSliverBuilder ?? (_, __) => [if (appBar != null) appBar],
        body: RefreshIndicator(
          onRefresh: fetch,
          child: data == null
              ? Center(child: CircularProgressIndicator())
              : builder(context, data),
        ),
      );
    },
  ));
}

typedef StreamContentBuilder<T> = Widget Function(BuildContext, T data);
typedef EmptyStateBuilder = Widget Function(BuildContext);

class FancyStreamBuilder<T> extends StatelessWidget {
  FancyStreamBuilder({@required this.stream, @required this.builder})
      : assert(stream != null),
        assert(builder != null),
        assert(T != dynamic);

  FancyStreamBuilder.handlePullToRefresh({
    NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
    FancyAppBar appBar,
    // I'm so looking forward to typedefs for non-function-types:
    // https://github.com/dart-lang/language/issues/65#issuecomment-604637347
    // Then this could just become a FetchStream<T>.
    @required StreamAndData<T, FetchStreamData<dynamic>> stream,
    @required StreamContentBuilder<T> builder,
  }) : this(
          stream: stream,
          builder: (context, data) {},
        );

  static FancyStreamBuilder<List<T>> list<T>({
    NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
    FancyAppBar appBar,
    @required Stream<List<T>> stream,
    @required EmptyStateBuilder emptyStateBuilder,
    @required StreamContentBuilder<List<T>> builder,
  }) =>
      FancyStreamBuilder<List<T>>.handlePullToRefresh(
        headerSliverBuilder: headerSliverBuilder,
        appBar: appBar,
        stream: stream,
        builder: (context, data) {
          return data.isEmpty
              ? SliverFillRemaining(child: emptyStateBuilder(context))
              : builder(context, data);
        },
      );

  final Stream<T> stream;
  final StreamContentBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      // There are some quirks in Flutter I could rant about. This is one of
      // them. Of course, Dart Streams are really fancy and may contain both an
      // error and a StackTrace inside each event. But Flutter's dumbed-down
      // wannabe-Events called AsyncSnapshots don't offer saving StackTraces.
      // So here, we handle errors by rethrowing ErrorAndStacktraces, which —
      // you guessed it — is just a wrapper around both an error and a
      // StackTrace. Thankfully, the rxdart package dealt with the same problem
      // and therefore already created the ErrorAndStacktrace class for us.
      stream: stream.handleError((error, stackTrace) {
        // ignore: only_throw_errors
        throw ErrorAndStacktrace(error, stackTrace);
      }),
      builder: (context, snapshot) {
        // There is no error. We can just call the builder.
        if (!snapshot.hasError) {
          return builder(context, snapshot.data);
        }

        // An error occurred.
        assert(snapshot.hasError);
        assert(snapshot.error is ErrorAndStacktrace);
        final errorAndStacktrace = snapshot.error as ErrorAndStacktrace;
        final error = errorAndStacktrace.error;
        final stackTrace = errorAndStacktrace.stackTrace;

        // Code inside the stream should only throw [FancyException]s to
        // trigger behavior in other parts of the app. Other exceptions should
        // be handled locally. If they can't handle them, they should catch
        // them nevertheless and then throw descriptive [FancyException]s
        // instead.
        if (error is! FancyException) {
          logger.e(
            'The following exception occurred: $error '
            'If you want to display an exception to the user, instead create '
            'a custom exception by extending FancyException. This will be '
            'caught and display a beautiful error screen. '
            'To view the full stack trace, long-tap the pink striped area.',
            error,
            stackTrace,
          );
          return PinkStripedErrorWidget(error, stackTrace);
        }

        final fancyError = error as FancyException;

        // If there is no data, then there's nothing we can display except the
        // error.
        if (!snapshot.hasData) {
          return ErrorScreen(fancyError);
        }

        // There is an error as well as cached data.

        // If the error is global, it's been handled elsewhere. More
        // specifically, the user is shown a message at a central error space.
        // That's why we don't need to display the error here.
        if (error.isGlobal) {
          return builder(context, snapshot.data);
        }

        // TODO(marcelgarus): Display both the error and the cached content.
        return PinkStripedErrorWidget(error, stackTrace);
      },
    );
  }
}
