import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/module.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../data.dart';
import 'article_image.dart';
import 'author.dart';
import 'headline.dart';
import 'section.dart';
import 'theme.dart';

/// Displays an article for the user to read.
///
/// If a landscape image is provided, it's displayed above the headline.
/// If a portrait image is provided, it's displayed below it.
class ArticleScreen extends StatelessWidget {
  const ArticleScreen(this.articleId) : assert(articleId != null);

  final Id<Article> articleId;

  @override
  Widget build(BuildContext context) {
    return EntityBuilder<Article>(
      id: articleId,
      builder: handleLoadingError((context, article, isFetching) {
        return Scaffold(
          appBar: _buildAppBar(context, article),
          body: LayoutBuilder(
            builder: (ctx, constraints) {
              final width = constraints.maxWidth;
              final margin = width < 500 ? 0.0 : width * 0.08;
              final padding = (width * 0.06).clamp(32.0, 64.0);

              return Provider<ArticleTheme>(
                create: (_) =>
                    ArticleTheme(darkColor: Colors.purple, padding: padding),
                child: ListView(
                  padding:
                      EdgeInsets.symmetric(horizontal: margin, vertical: 16),
                  children: <Widget>[
                    ArticleView(article),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildAppBar(BuildContext context, Article article) {
    return MorphingAppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      iconTheme: IconThemeData(color: context.theme.contrastColor),
      actions: <Widget>[
        SizedBox(width: 8),
        AccountButton(),
        SizedBox(width: 8),
      ],
    );
  }
}

class ArticleView extends StatefulWidget {
  const ArticleView(this.article) : assert(article != null);

  final Article article;

  @override
  _ArticleViewState createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  @override
  Widget build(BuildContext context) {
    if (widget.article.imageUrl == null) {
      return _buildWithoutImage();
    } else {
      return _buildWithLandscapeImage();
    }
  }

  Widget _buildWithoutImage() {
    final padding = Provider.of<ArticleTheme>(context).padding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Section(child: Text('Section')),
        HeadlineBox(
          title: Text(widget.article.title),
          smallText: Text(widget.article.publishedAt.longDateTimeString),
        ),
        Transform.translate(
          offset: Offset(padding, -12),
          child: AuthorView(widget.article.authorId),
        ),
        Transform.translate(
          offset: Offset(0, -20),
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildWithLandscapeImage() {
    final padding = Provider.of<ArticleTheme>(context).padding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Section(child: Text('Section')),
        Hero(
          tag: widget.article,
          child: ArticleImageView(imageUrl: widget.article.imageUrl),
        ),
        Transform.translate(
          offset: Offset(0, -48),
          child: HeadlineBox(
            title: Text(widget.article.title),
            smallText: Text(widget.article.publishedAt.longDateTimeString),
          ),
        ),
        Transform.translate(
          offset: Offset(padding, -61),
          child: AuthorView(widget.article.authorId),
        ),
        Transform.translate(
          offset: Offset(0, -48),
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final padding = Provider.of<ArticleTheme>(context).padding;

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, padding, 16),
      child: Text(widget.article.content, textAlign: TextAlign.justify),
    );
  }
}
