import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import '../data.dart';
import 'article_preview.dart';

/// A screen that displays a list of articles.
class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider2<StorageService, NetworkService, Bloc>(
      builder: (_, storage, network, __) =>
          Bloc(storage: storage, network: network),
      child: Scaffold(
        body: Consumer<Bloc>(
          builder: (context, bloc, _) {
            return CachedBuilder<List<Article>>(
              controller: bloc.articles,
              errorBannerBuilder: (_, error) => ErrorBanner(error),
              errorScreenBuilder: (_, error) => ErrorScreen(error),
              builder: (_, articles) {
                return ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    var article = articles[index];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: ArticlePreview(article: article),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
