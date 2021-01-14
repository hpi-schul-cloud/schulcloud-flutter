import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../data.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage(this.articleId) : assert(articleId != null);

  final Id<Article> articleId;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return EntityBuilder<Article>(
      id: articleId,
      builder: handleLoadingError((context, article, isFetching) {
        return FancyScaffold(
          appBar: FancyAppBar(title: Text(article.title)),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                Text(
                  s.news_article_published(
                      article.publishedAt.longDateTimeString),
                  style: context.textTheme.bodyText2,
                ),
                UserPreview(
                  article.authorId,
                  builder: (displayName) {
                    return FancyText(
                      s.news_article_author(displayName),
                      style: context.textTheme.bodyText2,
                    );
                  },
                ),
                if (article.imageUrl != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Image.network(article.imageUrl),
                  ),
                FancyText.rich(article.content),
              ],
            ),
          ),
        );
      }),
    );
  }
}
