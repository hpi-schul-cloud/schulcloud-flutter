import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../data.dart';
import 'article_preview.dart';

/// A screen that displays a list of articles.
class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CollectionBuilder.populated<Article>(
        collection: services.storage.root.news,
        builder: handleLoadingErrorRefreshEmpty(
          appBar: FancyAppBar(title: Text(context.s.news)),
          emptyStateBuilder: (context) =>
              EmptyStatePage(text: context.s.news_empty),
          builder: (context, unsortedArticles, isFetching) {
            final articles = unsortedArticles.toList()
              ..sort((a1, a2) => a2.publishedAt.compareTo(a1.publishedAt));

            return ListView.builder(
              padding: EdgeInsets.only(top: 8),
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
      ),
    );
  }
}
