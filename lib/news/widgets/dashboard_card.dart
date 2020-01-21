import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/dashboard/widgets/dashboard_card.dart';
import 'package:schulcloud/news/bloc.dart';
import 'package:schulcloud/news/data.dart';
import 'package:schulcloud/news/news.dart';
import 'package:schulcloud/news/widgets/article_screen.dart';

class NewsDashboardCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: Bloc(
        storage: Provider.of<StorageService>(context),
        network: Provider.of<NetworkService>(context),
        userFetcher: Provider.of<UserFetcherService>(context),
      ),
      child: DashboardCard(
        title: 'News',
        child: Consumer<Bloc>(
          builder: (context, bloc, _) => CachedRawBuilder<List<Article>>(
            controller: bloc.fetchArticles(),
            builder: (context, update) {
              if (!update.hasData) {
                return Center(
                    child: update.hasError
                        ? Text(update.error.toString())
                        : CircularProgressIndicator());
              }

              return Column(
                children: <Widget>[
                  ...ListTile.divideTiles(
                      context: context,
                      tiles: update.data.map(
                        (a) => ListTile(
                          title: Text(a.title),
                          subtitle: Html(data: limitString(a.content, 100)),
                          trailing: Text(dateTimeToString(a.published)),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ArticleScreen(article: a))),
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
                        child: Text('All articles'),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
