import 'package:flutter/material.dart';
import 'package:hive_cache/hive_cache.dart';

import '../exception.dart';
import '../logger.dart';
import '../sort_filter/sort_filter.dart';
import 'app_bar.dart';
import 'error_widgets.dart';

FetchableBuilder<CacheSnapshot<T>> handleError<T>(FetchableBuilder<T> builder) {
  return (context, snapshot, fetch) {
    if (snapshot == null) {
      builder(context, null, fetch);
    }

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

FetchableBuilder<CacheSnapshot<T>> handleLoading<T>(
    FetchableBuilder<CacheSnapshot<T>> builder) {
  return (context, snapshot, fetch) {
    return (!snapshot.hasData && !snapshot.hasError)
        ? Center(child: CircularProgressIndicator())
        : builder(context, snapshot, fetch);
  };
}

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

// Compositional shortcuts.

FetchableBuilder<CacheSnapshot<T>> handleLoadingError<T>(
        FetchableBuilder<T> builder) =>
    handleLoading(handleError(builder));

FetchableBuilder<CacheSnapshot<List<T>>> handleLoadingErrorEmpty<T>({
  @required WidgetBuilder emptyStateBuilder,
  @required FetchableBuilder<List<T>> builder,
}) =>
    handleLoadingError(handleEmpty(
      emptyStateBuilder: emptyStateBuilder,
      builder: builder,
    ));

FetchableBuilder<CacheSnapshot<List<T>>> handleLoadingErrorRefreshEmpty<T>({
  NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
  FancyAppBar appBar,
  @required WidgetBuilder emptyStateBuilder,
  @required FetchableBuilder<List<T>> builder,
}) =>
    handleLoadingError(handleRefresh(
      headerSliverBuilder: headerSliverBuilder,
      appBar: appBar,
      builder: handleEmpty(
        emptyStateBuilder: emptyStateBuilder,
        builder: builder,
      ),
    ));

FetchableBuilder<CacheSnapshot<List<T>>>
    handleLoadingErrorRefreshEmptyFiltered<T>({
  NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
  FancyAppBar appBar,
  @required WidgetBuilder emptyStateBuilder,
  @required SortFilterSelection<T> sortFilterSelection,
  @required WidgetBuilder filteredEmptyStateBuilder,
  @required FetchableBuilder<List<T>> builder,
}) =>
        handleLoadingErrorRefreshEmpty<T>(
          headerSliverBuilder: headerSliverBuilder,
          appBar: appBar,
          emptyStateBuilder: emptyStateBuilder,
          builder: handleFilter(
            sortFilterSelection: sortFilterSelection,
            filteredEmptyStateBuilder: filteredEmptyStateBuilder,
            builder: builder,
          ),
        );
