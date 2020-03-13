import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'article_preview.dart';

/// A screen that displays a list of articles.
class NewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO(marcelgarus): Allow pull-to-refresh.
      body: FancyCachedBuilder<List<Article>>.handleLoading(
        controller: services.storage.root.news.controller,
        builder: (context, articles, isFetching) {
          articles.sort((a1, a2) => a2.publishedAt.compareTo(a1.publishedAt));

          return CustomScrollView(
            slivers: <Widget>[
              FancyAppBar(title: Text(context.s.news)),
              SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ArticlePreview(article: articles[index]),
                    );
                  },
                  childCount: articles.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
