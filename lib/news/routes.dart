import 'package:flutter/material.dart' hide Route;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/news/widgets/article_screen.dart';

import 'data.dart';
import 'widgets/news_screen.dart';

final newsRoutes = Route.path(
  'news',
  builder: (_) => MaterialPageRoute(
    builder: (_) => NewsScreen(),
  ),
  routes: [
    Route.path(
      '{newsId}',
      builder: (result) => MaterialPageRoute(
        builder: (_) => ArticleScreen(Id<Article>(result['newsId'])),
      ),
    ),
  ],
);
