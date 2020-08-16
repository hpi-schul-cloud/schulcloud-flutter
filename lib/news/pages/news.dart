import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../data.dart';
import '../widgets/article_card.dart';

/// A page that displays a list of articles.
class NewsPage extends StatelessWidget {
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

            return CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ArticleCard(articles[index].id),
                      );
                    },
                    childCount: articles.length,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
