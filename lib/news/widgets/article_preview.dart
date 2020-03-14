import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'article_image.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return FancyCard(
      onTap: _isPlaceholder
          ? null
          : () => context.navigator.pushNamed('/news/${article.id}'),
      child: Provider<ArticleTheme>(
        create: (_) => ArticleTheme(darkColor: Colors.purple, padding: 16),
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
              controller: article.authorId.controller,
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
                    color: theme.cardColor.mediumEmphasisOnColor,
                  ),
                );
              },
            ),
            TextOrPlaceholder(
              article?.title,
              style: theme.textTheme.display2,
            ),
            TextOrPlaceholder(
              // ignore: deprecated_member_use_from_same_package
              _isPlaceholder ? null : limitString(article.content, 200),
              style: theme.textTheme.body2,
            ),
          ],
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
