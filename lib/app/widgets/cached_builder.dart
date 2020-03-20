import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';

typedef CachedBuilderContentBuilder<T> = Widget Function(
    BuildContext, T data, bool isFetching);
typedef EmptyStateBuilder = Widget Function(BuildContext, bool isFetching);

class FancyCachedBuilder<T> extends StatelessWidget {
  FancyCachedBuilder({@required this.controller, @required this.builder})
      : assert(controller != null),
        assert(builder != null),
        assert(T != dynamic);

  factory FancyCachedBuilder.handleLoading({
    @required CacheController<T> controller,
    @required CachedBuilderContentBuilder<T> builder,
  }) = _FancyCachedBuilderWithLoading<T>;

  // factory FancyCachedBuilder.handlePullToRefresh({
  //   NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
  //   FancyAppBar appBar,
  //   @required CacheController<T> controller,
  //   @required CachedBuilderContentBuilder<T> builder,
  // }) = _FancyCachedBuilderWithPullToRefresh<T>;

  static FancyCachedBuilder<List<T>> list<T>({
    NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
    FancyAppBar appBar,
    @required CacheController<List<T>> controller,
    @required EmptyStateBuilder emptyStateBuilder,
    @required CachedBuilderContentBuilder<List<T>> builder,
  }) =>
      _FancyCachedListBuilderWithPullToRefresh<T>(
        headerSliverBuilder: headerSliverBuilder,
        appBar: appBar,
        controller: controller,
        emptyStateBuilder: emptyStateBuilder,
        builder: builder,
      );

  final CacheController<T> controller;
  final CachedBuilderContentBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return CachedRawBuilder<T>(
      controller: controller,
      builder: (context, update) {
        // There is no error. We can just call the builder.
        if (update.hasNoError) {
          return builder(context, update.data, update.isFetching);
        }

        // An error occurred.
        assert(update.hasError);

        // Our code should only throw [FancyException]s to trigger behavior in
        // other parts of the app. Other exceptions should be handled by the
        // children of this widget. If they can't handle them, they should
        // catch them nevertheless and then throw [FancyException]s instead.
        if (update.error is! FancyException) {
          logger.e(
            'The following exception occurred: '
            '${update.error} '
            'If you want to display an exception to the user, instead create '
            'a custom exception by extending FancyException. This will be '
            'caught and display a beautiful error screen. '
            'To view the full stack trace, long-tap the pink striped area.',
            update.error,
            update.stackTrace,
          );
          return PinkStripedErrorWidget(update.error, update.stackTrace);
        }

        final error = update.error as FancyException;

        // If there is no data, then there's nothing we can display except the
        // error.
        if (update.hasNoData) {
          return ErrorScreen(update.error);
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

class _FancyCachedBuilderWithLoading<T> extends FancyCachedBuilder<T> {
  _FancyCachedBuilderWithLoading({
    @required CacheController<T> controller,
    @required CachedBuilderContentBuilder<T> builder,
  }) : super(
          controller: controller,
          builder: (context, data, isFetching) {
            return data == null
                ? Center(child: CircularProgressIndicator())
                : builder(context, data, isFetching);
          },
        );
}

class _FancyCachedBuilderWithPullToRefresh<T> extends FancyCachedBuilder<T> {
  _FancyCachedBuilderWithPullToRefresh({
    NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
    Widget appBar,
    @required CacheController<T> controller,
    @required CachedBuilderContentBuilder<T> builder,
  })  : assert(headerSliverBuilder == null || appBar == null),
        super(
          controller: controller,
          builder: (context, data, isFetching) {
            return NestedScrollView(
              headerSliverBuilder: headerSliverBuilder ??
                  (_, __) => [if (appBar != null) appBar],
              body: RefreshIndicator(
                onRefresh: controller.fetch,
                child: data == null
                    ? CircularProgressIndicator()
                    // : Container(width: 30, height: 30, color: Colors.amber),
                    : builder(context, data, isFetching),
              ),
            );
          },
        );
}

class _FancyCachedListBuilderWithPullToRefresh<T>
    extends _FancyCachedBuilderWithPullToRefresh<List<T>> {
  _FancyCachedListBuilderWithPullToRefresh({
    NestedScrollViewHeaderSliversBuilder headerSliverBuilder,
    FancyAppBar appBar,
    @required CacheController<List<T>> controller,
    @required EmptyStateBuilder emptyStateBuilder,
    @required CachedBuilderContentBuilder<List<T>> builder,
  }) : super(
          headerSliverBuilder: headerSliverBuilder,
          appBar: appBar,
          controller: controller,
          builder: (context, data, isFetching) {
            return data.isEmpty
                ? SliverFillRemaining(
                    child: emptyStateBuilder(context, isFetching),
                  )
                : builder(context, data, isFetching);
          },
        );
}
