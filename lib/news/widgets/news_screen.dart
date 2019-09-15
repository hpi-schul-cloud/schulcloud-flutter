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
    return ProxyProvider<NetworkService, Bloc>(
      builder: (_, network, __) => Bloc(network: network),
      child: Scaffold(
        body: _ArticleList(),
        bottomNavigationBar: MyAppBar(),
      ),
    );
  }
}

class _ArticleList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Article>>(
      stream: Provider.of<Bloc>(context).getArticles(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
        }
        return ListView(
          children: [
            for (var article in snapshot.data)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ArticlePreview(article: article),
              ),
          ],
        );
      },
    );
  }
}
