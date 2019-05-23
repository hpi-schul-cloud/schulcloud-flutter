import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:schulcloud/utils/placeholder.dart';

import '../model.dart';
import 'article_image.dart';
import 'article_screen.dart';
import 'section.dart';
import 'theme.dart';

class ArticlePreview extends StatefulWidget {
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
  _ArticlePreviewState createState() => _ArticlePreviewState();
}

class _ArticlePreviewState extends State<ArticlePreview> {
  Article get article => widget.article;

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
                _buildSection(),
                GradientArticleImageView(image: article?.image),
                SizedBox(height: 8),
                _buildSmallText(),
                _buildTitle(),
                _buildContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection() {
    if (article == null)
      return Section(child: PlaceholderText(color: Colors.white));
    else
      return Section(child: Text(article.section));
  }

  Widget _buildSmallText() {
    if (article == null)
      return PlaceholderText();
    else
      return Text(
        'vor 3 Tagen von ${article.author.name == 'unbekannt'}',
        style: TextStyle(color: Colors.black54),
      );
  }

  Widget _buildTitle() {
    final style = Theme.of(context).textTheme.display2;

    if (article == null)
      return PlaceholderText(style: style);
    else
      return Text(article.title, style: style);
  }

  Widget _buildContent() {
    final style = Theme.of(context).textTheme.body2;

    if (article == null)
      return PlaceholderText(style: style, numLines: 3);
    else
      return Text(
        '${article.content.substring(0, 200) ?? ''}...',
        style: style,
      );
  }
}
