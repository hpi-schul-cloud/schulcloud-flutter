import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../bloc.dart';
import 'article_preview.dart';

/// A screen that displays a list of articles.
class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<Bloc>.value(
      value: Bloc(),
      child: Scaffold(body: ArticleList()),
    );
  }
}

class ArticleList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return FutureBuilder<Article>(
          future: Provider.of<Bloc>(context).getArticleAtIndex(index),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: snapshot.hasData
                  ? ArticlePreview(article: snapshot.data)
                  : ArticlePreview.placeholder(),
            );
          },
        );
      },
    );
  }
}
