import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/l10n/l10n.dart';

import '../bloc.dart';
import '../data.dart';
import '../news.dart';
import 'article_screen.dart';

class NewsDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.s;

    return Provider.value(
      value: Bloc(
        storage: Provider.of<StorageService>(context),
        network: Provider.of<NetworkService>(context),
        userFetcher: Provider.of<UserFetcherService>(context),
      ),
      child: FancyCard(
        omitHorizontalPadding: true,
        title: s.news_dashboardCard,
        child: Consumer<Bloc>(
          builder: (context, bloc, _) => CachedRawBuilder<List<Article>>(
            controller: bloc.fetchArticles(),
            builder: (context, update) {
              if (!update.hasData) {
                return Center(
                  child: update.hasError
                      ? Text(update.error.toString())
                      : CircularProgressIndicator(),
                );
              }

              return Column(
                children: <Widget>[
                  for (final article in update.data)
                    ListTile(
                      title: Text(article.title),
                      subtitle: Html(data: limitString(article.content, 100)),
                      trailing: Text(dateTimeToString(article.published)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleScreen(article: article),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: OutlineButton(
                        onPressed: () {
                          context.navigator.push(MaterialPageRoute(
                              builder: (context) => NewsScreen()));
                        },
                        child: Text(s.news_dashboardCard_all),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
