import 'package:flutter/material.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

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

    return FancyCard(
      onTap: _isPlaceholder ? null : () => _openArticle(context),
      child: Provider<ArticleTheme>(
        create: (_) => ArticleTheme(darkColor: Colors.purple, padding: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Section(
              child: Text(
                'Section',
                style: TextStyle(color: Colors.white),
              ),
            ),
            _buildImage(),
            FancyText(
              article?.title,
              style: theme.textTheme.display2,
            ),
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

                return FancyText(
                  _isPlaceholder
                      ? null
                      : context.s.news_articlePreview_subtitle(
                          article.publishedAt.shortDateString, authorName),
                  emphasis: TextEmphasis.medium,
                  style: theme.textTheme.subtitle,
                );
              },
            ),
            SizedBox(height: 4),
            FancyText.preview(
              article?.content,
              maxLines: 3,
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
