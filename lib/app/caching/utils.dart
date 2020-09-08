import 'package:flutter/material.dart';
import 'package:hive_cache/hive_cache.dart';
import 'package:rxdart/rxdart.dart';

import '../logger.dart';
import '../sort_filter/sort_filter.dart';
import '../widgets/app_bar.dart';
import 'exception.dart';
import 'widgets/error.dart';

// Error
FetchableBuilder<CacheSnapshot<T>> handleError<T>(FetchableBuilder<T> builder) {
  return (context, snapshot, fetch) {
    return _buildError(snapshot) ?? builder(context, snapshot?.data, fetch);
  };
}

FetchableBuilder<CacheSnapshot<T>> handleErrorSliver<T>(
  FetchableBuilder<T> builder,
) {
  return (context, snapshot, fetch) {
    return _wrapInFillRemaining(_buildError(snapshot)) ??
        builder(context, snapshot?.data, fetch);
  };
}

Widget _buildError<T>(CacheSnapshot<T> snapshot) {
  // There is no error.
  if (snapshot == null || snapshot.hasNoError) {
    return null;
  }

  // An error occurred.
  assert(snapshot.hasError);
  final error = snapshot.error;

  // Code inside the stream should only throw [FancyException]s to
  // trigger behavior in other parts of the app. Other exceptions should
  // be handled locally. If they can't handle them, they should catch
  // them nevertheless and then throw descriptive [FancyException]s
  // instead.
  final correctlyHandled = error is FancyException ||
      error is ErrorAndStacktrace && error.error is FancyException;
  if (!correctlyHandled) {
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

  final fancyError = error is FancyException
      ? error
      : (error as ErrorAndStacktrace).error as FancyException;

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
    return null;
  }

  // TODO(marcelgarus): Display both the error and the cached content.
  return PinkStripedErrorWidget(error, null);
}

// Loading
FetchableBuilder<CacheSnapshot<T>> handleLoading<T>(
  FetchableBuilder<CacheSnapshot<T>> builder,
) {
  return (context, snapshot, fetch) {
    return _buildLoading(snapshot) ?? builder(context, snapshot, fetch);
  };
}

FetchableBuilder<CacheSnapshot<T>> handleLoadingSliver<T>(
  FetchableBuilder<CacheSnapshot<T>> builder,
) {
  return (context, snapshot, fetch) {
    return _wrapInFillRemaining(_buildLoading(snapshot)) ??
        builder(context, snapshot, fetch);
  };
}

Widget _buildLoading<T>(CacheSnapshot<T> snapshot) {
  if (snapshot.hasData || snapshot.hasError) {
    return null;
  }
  return Center(child: CircularProgressIndicator());
}

// Refresh
FetchableBuilder<T> handleRefresh<T>({
  NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
  FancyAppBar appBar,
  @required FetchableBuilder<T> builder,
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
        onRefresh: () => fetch(force: true),
        child: data == null
            ? Center(child: CircularProgressIndicator())
            : builder(context, data, fetch),
      ),
    );
  };
}

// Empty
FetchableBuilder<List<T>> handleEmpty<T>({
  @required WidgetBuilder emptyStateBuilder,
  @required FetchableBuilder<List<T>> builder,
}) {
  return (context, items, fetch) {
    return items.isEmpty
        ? emptyStateBuilder(context)
        : builder(context, items, fetch);
  };
}

// Filter
FetchableBuilder<List<T>> handleFilter<T>({
  @required SortFilterSelection<T> sortFilterSelection,
  @required WidgetBuilder filteredEmptyStateBuilder,
  @required FetchableBuilder<List<T>> builder,
}) {
  return (context, items, fetch) {
    final filtered = sortFilterSelection.apply(items);
    return filtered.isEmpty
        ? filteredEmptyStateBuilder(context)
        : builder(context, filtered, fetch);
  };
}

// Utils
Widget _wrapInFillRemaining(Widget child) {
  if (child == null) {
    return null;
  }

  return SliverFillRemaining(child: child);
}

// Compositional shortcuts

FetchableBuilder<CacheSnapshot<T>> handleLoadingError<T>(
  FetchableBuilder<T> builder,
) =>
    handleLoading(handleError(builder));
FetchableBuilder<CacheSnapshot<T>> handleLoadingErrorSliver<T>(
  FetchableBuilder<T> builder,
) =>
    handleLoadingSliver(handleErrorSliver(builder));

FetchableBuilder<CacheSnapshot<List<T>>> handleLoadingErrorEmpty<T>({
  @required WidgetBuilder emptyStateBuilder,
  @required FetchableBuilder<List<T>> builder,
}) {
  return handleLoadingError(handleEmpty(
    emptyStateBuilder: emptyStateBuilder,
    builder: builder,
  ));
}

FetchableBuilder<CacheSnapshot<List<T>>> handleLoadingErrorEmptySliver<T>({
  WidgetBuilder emptyStateBuilder,
  WidgetBuilder sliverEmptyStateBuilder,
  @required FetchableBuilder<List<T>> builder,
}) {
  assert((emptyStateBuilder == null) != (sliverEmptyStateBuilder == null));

  return handleLoadingErrorSliver(handleEmpty(
    emptyStateBuilder: sliverEmptyStateBuilder ??
        (context) {
          return SliverFillViewport(
            delegate:
                SliverChildListDelegate.fixed([emptyStateBuilder(context)]),
          );
        },
    builder: builder,
  ));
}

FetchableBuilder<CacheSnapshot<List<T>>> handleLoadingErrorRefreshEmpty<T>({
  bool isSliver = false,
  NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
  FancyAppBar appBar,
  @required WidgetBuilder emptyStateBuilder,
  @required FetchableBuilder<List<T>> builder,
}) {
  return handleLoadingError(handleRefresh(
    headerSliverBuilder: headerSliverBuilder,
    appBar: appBar,
    builder: handleEmpty(
      emptyStateBuilder: emptyStateBuilder,
      builder: builder,
    ),
  ));
}

FetchableBuilder<CacheSnapshot<List<T>>>
    handleLoadingErrorRefreshEmptyFilter<T>({
  NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
  FancyAppBar appBar,
  @required WidgetBuilder emptyStateBuilder,
  @required SortFilterSelection<T> sortFilterSelection,
  @required WidgetBuilder filteredEmptyStateBuilder,
  @required FetchableBuilder<List<T>> builder,
}) {
  return handleLoadingErrorRefreshEmpty<T>(
    headerSliverBuilder: headerSliverBuilder,
    appBar: appBar,
    emptyStateBuilder: emptyStateBuilder,
    builder: handleFilter(
      sortFilterSelection: sortFilterSelection,
      filteredEmptyStateBuilder: filteredEmptyStateBuilder,
      builder: builder,
    ),
  );
}
