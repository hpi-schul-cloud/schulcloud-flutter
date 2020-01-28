import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/l10n/l10n.dart';

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
    context.navigator.push(MaterialPageRoute(
      builder: (_) => ArticleScreen(article: article),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Provider<ArticleTheme>(
      create: (_) => ArticleTheme(darkColor: Colors.purple, padding: 16),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(16),
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
                CachedRawBuilder<User>(
                  controller: services
                      .get<UserFetcherService>()
                      .fetchUser(article.author, article.id),
                  builder: (_, update) {
                    final author = update.data;
                    final authorName = author?.displayName ??
                        (update.hasError
                            ? context.s.general_user_unknown
                            : context.s.general_placeholder);

                    return TextOrPlaceholder(
                      _isPlaceholder
                          ? null
                          : context.s.news_articlePreview_subtitle(
                              article.publishedAt.shortDateString, authorName),
                      style: TextStyle(
                        color: theme.cardColor.mediumEmphasisColor,
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
