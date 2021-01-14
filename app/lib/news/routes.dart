import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/module.dart';

import 'data.dart';
import 'pages/article.dart';
import 'pages/news.dart';

final newsRoutes = FancyRoute(
  matcher: Matcher.path('news'),
  builder: (_, __) => NewsPage(),
  routes: [
    FancyRoute(
      matcher: Matcher.path('{newsId}'),
      builder: (_, result) => ArticlePage(Id<Article>(result['newsId'])),
    ),
  ],
);
