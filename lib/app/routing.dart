import 'package:flutter/widgets.dart' hide Route, RouteBuilder;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/brand/brand.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/dashboard/dashboard.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/news/module.dart';
import 'package:schulcloud/settings/settings.dart';
import 'package:schulcloud/sign_in/sign_in.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import 'schulcloud_app.dart';
import 'services.dart';
import 'top_level_route/page_route.dart';
import 'widgets/not_found_screen.dart';

final _hostRegExp = RegExp('(?:www\.)?${RegExp.escape(services.config.host)}');

String appSchemeLink(String path) =>
    'app://${services.packageInfo.packageName}/$path';

typedef FancyRouteBuilder = Widget Function(
    BuildContext context, RouteResult result);

class FancyRoute extends Route {
  FancyRoute({
    Matcher matcher = const Matcher.any(),
    bool onlySwipeFromEdge = false,
    FancyRouteBuilder builder,
    FancyRouteBuilder topLevelBuilder,
    List<FancyRoute> routes = const [],
  })  : assert(!(builder != null && topLevelBuilder != null)),
        super(
          matcher: matcher,
          builder: _buildFancyRouteBuilder(builder, onlySwipeFromEdge) ??
              _buildTopLevelRouteBuilder(topLevelBuilder),
          routes: routes,
        );

  static RouteBuilder _buildFancyRouteBuilder(
      FancyRouteBuilder builder, bool onlySwipeFromEdge) {
    if (builder == null) {
      return null;
    }

    return (result) {
      return SwipeablePageRoute(
        onlySwipeFromEdge: onlySwipeFromEdge,
        builder: (context) => builder(context, result),
        settings: result.settings,
      );
    };
  }

  static RouteBuilder _buildTopLevelRouteBuilder(FancyRouteBuilder builder) {
    if (builder == null) {
      return null;
    }

    return (result) {
      return TopLevelPageRoute(
        builder: (context) => builder(context, result),
        settings: result.settings,
      );
    };
  }
}

final router = Router(
  routes: [
    FancyRoute(
      matcher: Matcher.scheme('app') &
          Matcher.host(services.packageInfo.packageName),
      routes: [
        FancyRoute(
          matcher: Matcher.path('signedInScreen'),
          topLevelBuilder: (_, result) => SignedInScreen(),
        ),
      ],
    ),
    FancyRoute(
      matcher: Matcher.webHost(_hostRegExp, isOptional: true),
      routes: [
        assignmentRoutes,
        courseRoutes,
        dashboardRoutes,
        fileRoutes,
        signInRoutes,
        newsRoutes,
        settingsRoutes,
      ],
    ),
    FancyRoute(builder: (_, result) => NotFoundScreen(result.uri)),
  ],
);
