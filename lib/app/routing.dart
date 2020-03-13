import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/dashboard/dashboard.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/login/login.dart';
import 'package:schulcloud/news/news.dart';
import 'package:schulcloud/settings/settings.dart';

import 'app_config.dart';
import 'utils.dart';
import 'widgets/not_found_screen.dart';
import 'widgets/page_route.dart';
import 'widgets/schulcloud_app.dart';

final hostRegExp =
    RegExp('(?:www\.)?${RegExp.escape(services.get<AppConfig>().host)}');

String appSchemeLink(String path) => 'app://org.schulcloud.android/$path';

final router = Router(
  routes: [
    Route(
      matcher: Matcher.scheme('app') & Matcher.host('org.schulcloud.android'),
      routes: [
        Route(
          matcher: Matcher.path('signedInScreen'),
          builder: (result) => TopLevelPageRoute(
            builder: (_) => LoggedInScreen(),
            settings: result.settings,
          ),
        ),
      ],
    ),
    Route(
      matcher: Matcher.webHost(hostRegExp, isOptional: true),
      routes: [
        Route(
          routes: [
            assignmentRoutes,
            courseRoutes,
            dashboardRoutes,
            fileRoutes,
            loginRoutes,
            newsRoutes,
            settingsRoutes,
          ],
        ),
      ],
    ),
    Route(materialBuilder: (_, result) => NotFoundScreen(result.uri)),
  ],
);
