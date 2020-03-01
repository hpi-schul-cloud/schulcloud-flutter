import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import '../data.dart';
import '../news.dart';
import 'article_screen.dart';

class NewsDashboardCard extends StatelessWidget {
  static const articleCount = 3;

  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return FancyCard(
      omitHorizontalPadding: true,
      title: s.news_dashboardCard,
      child: CachedRawBuilder<List<Article>>(
        controller: services.get<NewsBloc>().fetchArticles(),
        builder: (context, update) {
          if (!update.hasData) {
            return Center(
              child: update.hasError
                  ? Text(update.error.toString())
                  : CircularProgressIndicator(),
            );
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
                ListTile(
                  title: Text(article.title),
                  subtitle: Html(data: limitString(article.content, 100)),
                  trailing: Text(article.publishedAt.shortDateString),
                  onTap: () => context.navigator.push(MaterialPageRoute(
                    builder: (context) => ArticleScreen(article: article),
                  )),
                ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: OutlineButton(
                    onPressed: () => context.navigator.push(MaterialPageRoute(
                      builder: (context) => NewsScreen(),
                    )),
                    child: Text(s.news_dashboardCard_all),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
