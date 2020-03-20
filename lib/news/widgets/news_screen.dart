import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'article_preview.dart';

/// A screen that displays a list of articles.
class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FancyCachedBuilder.list<Article>(
        appBar: FancyAppBar(title: Text(context.s.news)),
        controller: services.storage.root.news.controller,
        emptyStateBuilder: (context, __) => EmptyStateScreen(
          text: context.s.news_empty,
        ),
        builder: (context, articles, isFetching) {
          articles.sort((a1, a2) => a2.publishedAt.compareTo(a1.publishedAt));

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ArticlePreview(article: articles[index]),
              );
            },
          );
        },
      ),
    );
  }
}
