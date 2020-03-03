import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/dashboard/dashboard.dart';

import '../data.dart';
import '../news.dart';
import 'article_screen.dart';

class NewsDashboardCard extends StatelessWidget {
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
            return Center(
              child: update.hasError
                  ? ErrorBanner(update.error, update.stackTrace)
                  : CircularProgressIndicator(),
            );
          }

          return Column(
            children: <Widget>[
              for (final article in update.data)
                ListTile(
                  title: Text(article.title),
                  subtitle: Html(data: limitString(article.content, 100)),
                  trailing: Text(article.publishedAt.shortDateString),
                  onTap: () => context.navigator.push(MaterialPageRoute(
                    builder: (context) => ArticleScreen(article: article),
                  )),
                ),
            ],
          );
        },
      ),
    );
  }
}
