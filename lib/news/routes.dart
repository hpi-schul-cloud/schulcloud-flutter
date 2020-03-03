import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/news/widgets/article_screen.dart';

import 'data.dart';
import 'widgets/news_screen.dart';

final newsRoutes = Route(
  matcher: Matcher.path('news'),
  materialPageRouteBuilder: (_, __) => NewsScreen(),
  routes: [
    Route(
      matcher: Matcher.path('{newsId}'),
      materialPageRouteBuilder: (_, result) =>
          ArticleScreen(Id<Article>(result['newsId'])),
    ),
  ],
);
