import 'package:cached_listview/cached_listview.dart';
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
            return CachedListView(
              controller: bloc.articles,
              emptyStateBuilder: (_) => Center(child: Text('Nuffin here')),
              errorBannerBuilder: (_, error) =>
                  Container(height: 48, color: Colors.red),
              errorScreenBuilder: (_, error) => Container(color: Colors.red),
              itemBuilder: (_, article) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ArticlePreview(article: article),
              ),
            );
          },
        ),
      ),
    );
  }
}
