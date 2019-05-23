import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:provider/provider.dart';

import '../model.dart';
import 'theme.dart';

/// Displays an article image, which is faded in as its loaded.
///
/// If the [image] is [null], a placeholder is displayed.
class ArticleImageView extends StatelessWidget {
  const ArticleImageView({
    @required this.image,
    this.placeholderColor = Colors.black12,
  }) : assert(placeholderColor != null);

  final ArticleImage image;
  final Color placeholderColor;

  bool get _showPlaceholder => image == null;

  @override
  Widget build(BuildContext context) {
    if (_showPlaceholder) {
      return AspectRatio(
        aspectRatio: 2,
        child: Container(color: placeholderColor),
      );
    }

    return AspectRatio(
      aspectRatio: image.size.aspectRatio,
      child: Container(
        color: placeholderColor,
        child: FadeInImage.memoryNetwork(
          fadeInDuration: Duration(milliseconds: 500),
          fadeInCurve: Curves.easeInOutCubic,
          placeholder: kTransparentImage,
          image: image.url,
        ),
      ),
    );
  }
}

/// Displays an article image overlayed with a colored gradient.
///
/// If the [image] is [null], a placeholder is displayed.
/// The color comes from the enclosing [ArticleTheme].
class GradientArticleImageView extends StatelessWidget {
  GradientArticleImageView({@required this.image});

  final ArticleImage image;

  @override
  Widget build(BuildContext context) {
    var color = Provider.of<ArticleTheme>(context).darkColor;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(8),
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      child: Stack(
        children: <Widget>[
          ArticleImageView(image: image, placeholderColor: color),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color,
                    color.withOpacity(0.9),
                    color.withOpacity(0),
                    color.withOpacity(0),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
