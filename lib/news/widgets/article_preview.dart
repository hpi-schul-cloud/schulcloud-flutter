import 'package:flutter/material.dart';

import '../model.dart';
import 'author.dart';
import 'headline.dart';
import 'section.dart';

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
      child: Container(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Section(content: article.section),
            Headline(title: article.title, published: article.published),
            Transform.translate(
              offset: Offset(28, -13),
              child: AuthorView(author: article.author),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
