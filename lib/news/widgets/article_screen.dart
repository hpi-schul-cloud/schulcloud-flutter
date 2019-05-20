import 'package:flutter/material.dart';

import '../model.dart';
import 'author.dart';
import 'headline.dart';
import 'section.dart';

class ArticleScreen extends StatelessWidget {
  ArticleScreen({
    @required this.article,
  }) : assert(article != null);

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          var width = constraints.maxWidth;
          var margin = width < 500 ? 0 : width * 0.08;
          var padding = (width * 0.06).clamp(32.0, 64.0);

          return ListView(
            padding: MediaQuery.of(context).padding +
                EdgeInsets.symmetric(horizontal: margin) +
                const EdgeInsets.symmetric(vertical: 16),
            children: <Widget>[
              ArticleView(article: article, padding: padding),
            ],
          );
        },
      ),
    );
  }
}

class ArticleView extends StatelessWidget {
  ArticleView({
    @required this.article,
    @required this.padding,
  })  : assert(article != null),
        assert(padding != null);

  final Article article;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Section(content: article.section, padding: padding),
        Image.network(article.photoUrl),
        Transform.translate(
          offset: Offset(0, -48),
          child: Headline(
            title: article.title,
            published: article.published,
            padding: padding,
          ),
        ),
        Transform.translate(
          offset: Offset(padding, -13),
          child: AuthorView(author: article.author),
        ),
        SizedBox(height: 8),
        _buildText(article.content),
      ],
    );
  }

  Widget _buildText(String text) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, 16),
      child: Text(
        article.content,
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
