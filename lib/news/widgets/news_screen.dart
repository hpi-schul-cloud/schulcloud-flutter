import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'article_preview.dart';

/// A screen that displays a list of articles.
class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CachedBuilder<List<Article>>(
        controller: services.get<StorageService>().root.news.controller,
        errorBannerBuilder: (_, error, st) => ErrorBanner(error, st),
        errorScreenBuilder: (_, error, st) => ErrorScreen(error, st),
        builder: (_, articles) {
          articles.sort((a1, a2) => a2.publishedAt.compareTo(a1.publishedAt));

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ArticlePreview(article: articles[index]),
              );
            },
          );
        },
      ),
    );
  }
}
