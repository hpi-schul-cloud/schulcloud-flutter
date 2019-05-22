import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model.dart';
import 'author.dart';
import 'article_image.dart';
import 'headline.dart';
import 'section.dart';
import 'theme.dart';

/// Displays an article for the user to read. If there's no image, none is
/// displayed. If it's a landscape image, it's displayed above the headline, if
/// it's portrait, below the headline.
class ArticleScreen extends StatelessWidget {
  ArticleScreen({@required this.article}) : assert(article != null);

  final Article article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          var width = constraints.maxWidth;
          double margin = width < 500 ? 0 : width * 0.08;
          double padding = (width * 0.06).clamp(32.0, 64.0);

          return Provider<ArticleTheme>(
            builder: (_) =>
                ArticleTheme(darkColor: Colors.purple, padding: padding),
            child: ListView(
              padding: MediaQuery.of(context).padding +
                  EdgeInsets.symmetric(horizontal: margin) +
                  const EdgeInsets.symmetric(vertical: 16),
              children: <Widget>[ArticleView(article: article)],
            ),
          );
        },
      ),
    );
  }
}

class ArticleView extends StatelessWidget {
  const ArticleView({@required this.article}) : assert(article != null);

  final Article article;

  @override
  Widget build(BuildContext context) {
    if (article.image.size.aspectRatio >= 1) {
      return _buildWithLargeImage(context);
    } else {
      return _buildWithSmallImage(context);
    }
  }

  Widget _buildWithLargeImage(BuildContext context) {
    var padding = Provider.of<ArticleTheme>(context).padding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Section(content: article.section),
        ArticleImageView(image: article.image),
        Transform.translate(
          offset: Offset(0, -48),
          child: HeadlineBox(
            title: article.title,
            published: article.published,
          ),
        ),
        Transform.translate(
          offset: Offset(padding, -61),
          child: AuthorView(author: article.author),
        ),
        _buildText(context),
      ],
    );
  }

  Widget _buildWithSmallImage(BuildContext context) {
    var padding = Provider.of<ArticleTheme>(context).padding;

    return Stack(
      children: <Widget>[
        Positioned(
          top: 180,
          right: 0,
          width: 220,
          child: ArticleImageView(image: article.image),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Section(content: article.section),
            HeadlineBox(title: article.title, published: article.published),
            Transform.translate(
              offset: Offset(padding, -13.5),
              child: AuthorView(author: article.author),
            ),
            SizedBox(height: 8),
            _buildText(context),
          ],
        ),
      ],
    );
  }

  Widget _buildText(BuildContext context) {
    var padding = Provider.of<ArticleTheme>(context).padding;

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
