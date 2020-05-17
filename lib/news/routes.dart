import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';
import 'widgets/article_screen.dart';
import 'widgets/news_screen.dart';

final newsRoutes = FancyRoute(
  matcher: Matcher.path('news'),
  builder: (_, __) => NewsScreen(),
  routes: [
    FancyRoute(
      matcher: Matcher.path('{newsId}'),
      builder: (_, result) => ArticleScreen(Id<Article>(result['newsId'])),
    ),
  ],
);
