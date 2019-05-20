import 'package:flutter/material.dart';
import 'package:schulcloud/news/widgets/article_screen.dart';

import '../model.dart';
import 'article.dart';

class ArticlePreview extends StatelessWidget {
  ArticlePreview({
    @required this.article,
    this.showPicture = true,
    this.showDetailedDate = false,
  })  : assert(article != null),
        assert(showPicture != null),
        assert(showDetailedDate != null);

  final Article article;
  final bool showPicture;
  final bool showDetailedDate;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: Colors.black12,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ArticleScreen(article: article),
          ));
        },
        child: Container(
          height: 300,
          child: ArticleView(article: article, isPreview: true),
        ),
      ),
    );
  }
}
