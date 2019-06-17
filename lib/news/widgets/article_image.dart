import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

/// Displays an article image, which is faded in as its loaded.
///
/// If the [image] is [null], a placeholder is displayed.
class ArticleImageView extends StatelessWidget {
  const ArticleImageView({
    @required this.imageUrl,
    this.placeholderColor = Colors.black12,
  }) : assert(placeholderColor != null);

  final String imageUrl;
  final Color placeholderColor;

  bool get _showPlaceholder => imageUrl == null;

  @override
  Widget build(BuildContext context) {
    if (_showPlaceholder) {
      return AspectRatio(
        aspectRatio: 2,
        child: Container(color: placeholderColor),
      );
    }

    return Container(
      color: placeholderColor,
      child: FadeInImage.memoryNetwork(
        fadeInDuration: Duration(milliseconds: 500),
        fadeInCurve: Curves.easeInOutCubic,
        placeholder: kTransparentImage,
        image: imageUrl,
      ),
    );
  }
}

/// Displays an article image overlayed with a colored gradient.
///
/// If the [image] is [null], a placeholder is displayed.
class GradientArticleImageView extends StatelessWidget {
  GradientArticleImageView({
    @required this.imageUrl,
    this.color = Colors.purple,
  });

  final String imageUrl;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(8),
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      child: Stack(
        children: <Widget>[
          ArticleImageView(imageUrl: imageUrl, placeholderColor: color),
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
