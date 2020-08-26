import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';

import '../data.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard(this.articleId) : assert(articleId != null);

  final Id<Article> articleId;

  @override
  Widget build(BuildContext context) {
    return FancyCard(
      onTap: () => context.navigator.pushNamed('/news/$articleId'),
      omitTopPadding: true,
      omitHorizontalPadding: true,
      child: EntityBuilder<Article>(
        id: articleId,
        builder: handleLoadingError((context, article, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (article.hasImage) Image.network(article.imageUrl),
              SizedBox(height: article.hasImage ? 8 : 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _buildContent(context, article),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Article article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FancyText(article.title, style: context.textTheme.headline5),
        SizedBox(height: 4),
        Wrap(
          children: [
            UserPreview(
              article.authorId,
              builder: (displayName) {
                return SeparatedIconText([
                  IconText(
                    icon: Icons.calendar_today,
                    text: article.publishedAt.longDateTimeString,
                  ),
                  IconText(icon: Icons.person, text: displayName),
                ]);
              },
            ),
          ],
        ),
        SizedBox(height: 4),
        FancyText.preview(article.content, maxLines: 3),
      ],
    );
  }
}
