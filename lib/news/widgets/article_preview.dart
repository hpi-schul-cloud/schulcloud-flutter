import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'article_image.dart';
import 'article_screen.dart';
import 'section.dart';
import 'theme.dart';

class ArticlePreview extends StatelessWidget {
  final Article article;
  final bool showPicture;
  final bool showDetailedDate;

  ArticlePreview({
    @required this.article,
    this.showPicture = true,
    this.showDetailedDate = false,
  })  : assert(article != null),
        assert(showPicture != null),
        assert(showDetailedDate != null);

  factory ArticlePreview.placeholder() {
    return ArticlePreview(article: null, showPicture: false);
  }

  bool get _isPlaceholder => article == null;

  void _openArticle(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ArticleScreen(article: article),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Provider<ArticleTheme>(
      builder: (_) => ArticleTheme(darkColor: Colors.purple, padding: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        child: InkWell(
          onTap: _isPlaceholder ? null : () => _openArticle(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Section(
                  child: TextOrPlaceholder(
                    article?.section,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                _buildImage(),
                SizedBox(height: 8),
                TextOrPlaceholder(
                  _isPlaceholder
                      ? null
                      : 'vor 3 Tagen von ${article.author.name == 'unbekannt'}',
                  style: TextStyle(color: Colors.black54),
                ),
                TextOrPlaceholder(
                  article?.title,
                  style: Theme.of(context).textTheme.display2,
                ),
                TextOrPlaceholder(
                  _isPlaceholder ? null : limitString(article.content, 200),
                  style: Theme.of(context).textTheme.body2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_isPlaceholder) {
      return GradientArticleImageView(imageUrl: null);
    } else if (article.imageUrl == null) {
      return Container();
    } else {
      return Hero(
        tag: article,
        child: GradientArticleImageView(imageUrl: article?.imageUrl),
      );
    }
  }
}
