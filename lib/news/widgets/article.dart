import 'package:flutter/material.dart';

import '../model.dart';
import 'author.dart';
import 'headline.dart';
import 'section.dart';

class ArticleView extends StatelessWidget {
  ArticleView({
    @required this.article,
    this.isPreview = false,
  })  : assert(article != null),
        assert(isPreview != null);

  final Article article;
  final bool isPreview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Section(content: article.section),
        Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Image.network(article.photoUrl),
            ),
            Positioned(
              bottom: 0,
              child:
                  Headline(title: article.title, published: article.published),
            ),
          ],
        ),
        Transform.translate(
          offset: Offset(28, -13),
          child: AuthorView(author: article.author),
        ),
        SizedBox(height: 8),
        if (!isPreview) _buildText(article.content),
      ],
    );
  }

  Widget _buildText(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
      child: Text(article.content, style: TextStyle(fontSize: 20)),
    );
  }
}
