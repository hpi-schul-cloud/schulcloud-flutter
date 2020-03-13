import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';
import 'widgets/article_screen.dart';
import 'widgets/news_screen.dart';

final newsRoutes = Route(
  matcher: Matcher.path('news'),
  materialBuilder: (_, __) => NewsScreen(),
  routes: [
    Route(
      matcher: Matcher.path('{newsId}'),
      materialBuilder: (_, result) =>
          ArticleScreen(Id<Article>(result['newsId'])),
    ),
  ],
);
