import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/dashboard/dashboard.dart';
import 'package:schulcloud/generated/generated.dart';

import '../data.dart';
import '../news.dart';
import 'article_screen.dart';

class NewsDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return DashboardCard(
      title: s.news_dashboardCard,
      child: CachedRawBuilder<List<Article>>(
        controller: services.get<StorageService>().root.news.controller,
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
              ...ListTile.divideTiles(
                  context: context,
                  tiles: update.data.map(
                    (a) => ListTile(
                      title: Text(a.title),
                      subtitle: Html(data: limitString(a.content, 100)),
                      trailing: Text(a.publishedAt.shortDateString),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ArticleScreen(article: a))),
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: OutlineButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => NewsScreen()));
                    },
                    child: Text(s.news_dashboardCard_all),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
