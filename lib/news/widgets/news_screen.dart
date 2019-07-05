import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/core/services.dart';
import 'package:schulcloud/core/widgets.dart';

import '../bloc.dart';
import 'article_preview.dart';

/// A screen that displays a list of articles.
class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProxyProvider<ApiService, Bloc>(
      builder: (_, api, __) => Bloc(api: api),
      child: Scaffold(
        body: ArticleList(),
        bottomNavigationBar: MyAppBar(),
      ),
    );
  }
}

class ArticleList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Article>>(
      stream: Provider.of<Bloc>(context).getArticles(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(color: Colors.red);
        }
        return ListView(
          children: snapshot.data.map((article) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ArticlePreview(article: article),
            );
          }).toList(),
        );
      },
    );
  }
}
