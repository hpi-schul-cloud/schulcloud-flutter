import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model.dart';
import 'article_screen.dart';
import 'article_image.dart';
import 'author.dart';
import 'section.dart';
import 'theme.dart';

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
    return Provider<ArticleTheme>(
      builder: (_) => ArticleTheme(darkColor: Colors.purple, padding: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ArticleScreen(article: article),
            ));
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Section(content: article.section),
                GradientArticleImageView(image: article.image),
                Text(article.title),
                Transform.translate(
                  offset: Offset(28, -13),
                  child: AuthorView(author: article.author),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
