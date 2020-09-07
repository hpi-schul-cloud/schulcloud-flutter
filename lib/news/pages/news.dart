import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../data.dart';
import '../widgets/article_card.dart';

/// A page that displays a list of articles.
class NewsPage extends StatelessWidget {
  const NewsPage({this.sortFilterSelection});

  static final sortFilterConfig = SortFilter<Article>(
    sorters: {
      'name': Sorter<Article>.name(
        (s) => s.general_entity_property_name,
        selector: (article) => article.title,
      ),
      'createdAt': Sorter<Article>.simple(
        (s) => s.general_entity_property_createdAt,
        selector: (article) => article.createdAt,
      ),
      'publishedAt': Sorter<Article>.simple(
        (s) => s.general_entity_property_publishedAt,
        selector: (article) => article.publishedAt,
      ),
    },
    defaultSorter: 'publishedAt',
    defaultSortOrder: SortOrder.descending,
  );
  final SortFilterSelection<Article> sortFilterSelection;

  @override
  Widget build(BuildContext context) {
    return SortFilterPage<Article>(
      config: sortFilterConfig,
      initialSelection: sortFilterSelection,
      collection: services.storage.root.news,
      appBarBuilder: (context, showSortFilterSheet) => FancyAppBar(
        title: Text(context.s.news),
        actions: <Widget>[SortFilterIconButton(showSortFilterSheet)],
      ),
      emptyStateTextGetter: (s) => s.news_newsPage_empty,
      filteredEmptyStateTextGetter: (s) => s.news_newsPage_emptyFiltered,
      builder: (_, article, __, ___) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ArticleCard(article.id),
        );
      },
    );
  }
}
