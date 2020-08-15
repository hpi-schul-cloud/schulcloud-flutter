import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/dashboard/module.dart';

import '../data.dart';
import '../news.dart';

class NewsDashboardCard extends StatelessWidget {
  static const articleCount = 3;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return DashboardCard(
      title: s.news_dashboardCard,
      footerButtonText: s.news_dashboardCard_all,
      onFooterButtonPressed: () => context.navigator.pushNamed('/news'),
      child: CollectionBuilder.populated<Article>(
        collection: services.storage.root.news,
        builder: handleLoadingErrorEmpty(
          emptyStateBuilder: (context) => Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(s.news_dashboardCard_empty),
          ),
          builder: (context, unorderedArticles, isFetching) {
            var articles = unorderedArticles.toList()
              ..sort((a1, a2) => -a1.publishedAt.compareTo(a2.publishedAt));
            articles = articles.take(articleCount).toList();

            return Column(
              children: <Widget>[
                for (final article in articles)
                  _buildArticlePreview(context, article),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildArticlePreview(BuildContext context, Article article) {
    return InkWell(
      onTap: () => context.navigator.pushNamed('/news/${article.id}'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Expanded(
                  child: Text(
                    article.title,
                    style: context.textTheme.subtitle1,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  article.publishedAt.shortDateString,
                  style: context.textTheme.caption,
                ),
              ],
            ),
            SizedBox(height: 4),
            FancyText.preview(
              article.content,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
