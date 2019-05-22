import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model.dart';
import 'article_screen.dart';
import 'article_image.dart';
import 'section.dart';
import 'theme.dart';

class ArticlePreview extends StatelessWidget {
  ArticlePreview({
    @required this.article,
    this.showPicture = true,
    this.showDetailedDate = false,
  })  : assert(showPicture != null),
        assert(showDetailedDate != null);

  factory ArticlePreview.placeholder() {
    return ArticlePreview(article: null, showPicture: false);
  }

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
          onTap: article == null
              ? null
              : () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ArticleScreen(article: article),
                  ));
                },
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Section(child: Text(article.section)),
                GradientArticleImageView(image: article.image),
                SizedBox(height: 8),
                Text(
                  'vor 3 Tagen von ${article.author.name}',
                  style: TextStyle(color: Colors.black54),
                ),
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.display2,
                ),
                Text(
                  '${article.content.substring(0, 200)}...',
                  style: Theme.of(context).textTheme.body2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
