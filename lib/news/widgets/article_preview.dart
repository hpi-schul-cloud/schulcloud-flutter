import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/app/theming/utils.dart';

import '../data.dart';
import 'article_image.dart';
import 'article_screen.dart';
import 'section.dart';
import 'theme.dart';

class ArticlePreview extends StatelessWidget {
  const ArticlePreview({
    @required this.article,
    this.showPicture = true,
    this.showDetailedDate = false,
  })  : assert(article != null),
        assert(showPicture != null),
        assert(showDetailedDate != null);

  factory ArticlePreview.placeholder() {
    return ArticlePreview(article: null, showPicture: false);
  }

  final Article article;
  final bool showPicture;
  final bool showDetailedDate;

  bool get _isPlaceholder => article == null;

  void _openArticle(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ArticleScreen(article: article),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Provider<ArticleTheme>(
      builder: (_) => ArticleTheme(darkColor: Colors.purple, padding: 16),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        color: theme.cardColor,
        child: InkWell(
          onTap: _isPlaceholder ? null : () => _openArticle(context),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Section(
                  child: TextOrPlaceholder(
                    'Section',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                _buildImage(),
                SizedBox(height: 8),
                CachedRawBuilder(
                  controller: UserFetcherService.of(context)
                      .fetchUser(article.author, article.id),
                  builder: (_, update) {
                    return TextOrPlaceholder(
                      _isPlaceholder
                          ? null
                          : 'vor 3 Tagen von ${update.data?.displayName ?? 'unbekannt'}',
                      style: TextStyle(
                        color: mediumEmphasisOn(theme.cardColor),
                      ),
                    );
                  },
                ),
                TextOrPlaceholder(
                  article?.title,
                  style: theme.textTheme.display2,
                ),
                TextOrPlaceholder(
                  _isPlaceholder ? null : limitString(article.content, 200),
                  style: theme.textTheme.body2,
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
