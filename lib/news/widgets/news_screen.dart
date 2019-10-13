import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import '../bloc.dart';
import 'article_preview.dart';

/// A screen that displays a list of articles.
class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<NetworkService, Bloc>(
      builder: (_, network, __) => Bloc(network: network),
      child: Scaffold(
        body: Consumer<Bloc>(
          builder: (context, bloc, _) {
            return CachedBuilder(
              controller: bloc.articles,
              errorBannerBuilder: (_, error) =>
                  Container(height: 48, color: Colors.red),
              errorScreenBuilder: (_, error) => Container(color: Colors.red),
              builder: (_, articles) {
                return ListView.builder(
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
