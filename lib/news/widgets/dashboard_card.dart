import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/dashboard/dashboard.dart';

import '../data.dart';
import '../news.dart';
import 'article_screen.dart';

class NewsDashboardCard extends StatelessWidget {
  static const articleCount = 3;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return DashboardCard(
      title: s.news_dashboardCard,
      footerButtonText: s.news_dashboardCard_all,
      onFooterButtonPressed: () => context.navigator
          .push(MaterialPageRoute(builder: (context) => NewsScreen())),
      child: CachedRawBuilder<List<Article>>(
        controller: services.storage.root.news.controller,
        builder: (context, update) {
          if (!update.hasData) {
            return update.hasError
                ? ErrorBanner(update.error, update.stackTrace)
                : Center(child: CircularProgressIndicator());
          }

          Iterable<Article> articles = update.data;
          if (articles.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(s.news_dashboardCard_empty),
            );
          }

          articles = update.data
            ..sort((a1, a2) => -a1.publishedAt.compareTo(a2.publishedAt));
          articles = articles.take(articleCount);

          return Column(
            children: <Widget>[
              for (final article in articles)
                _buildArticlePreview(context, article),
            ],
          );
        },
      ),
    );
  }

  Widget _buildArticlePreview(BuildContext context, Article article) {
    return InkWell(
      onTap: () => context.navigator.push(MaterialPageRoute(
        builder: (context) => ArticleScreen(article: article),
      )),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Expanded(
                  child: Text(article.title, style: context.textTheme.subhead),
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
