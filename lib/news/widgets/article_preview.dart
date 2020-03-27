import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
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
            EntityBuilder<User>(
              id: article.authorId,
              builder: handleEdgeCases((context, author, __) {
                final authorName =
                    author?.displayName ?? context.s.general_placeholder;

                return FancyText(
                  _isPlaceholder
                      ? null
                      : context.s.news_articlePreview_subtitle(
                          article.publishedAt.shortDateString, authorName),
                  emphasis: TextEmphasis.medium,
                  style: theme.textTheme.subtitle,
                );
              }),
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
