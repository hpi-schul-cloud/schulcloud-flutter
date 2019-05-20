import 'package:flutter/material.dart';

import '../model.dart';
import 'article.dart';

class ArticleScreen extends StatelessWidget {
  ArticleScreen({
    @required this.article,
    this.showPicture = true,
    this.showDetailedDate = false,
  })  : assert(article != null),
        assert(showPicture != null),
        assert(showDetailedDate != null);

  final Article article;
  final bool showPicture;
  final bool showDetailedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: <Widget>[
          SizedBox(height: 16),
          ArticleView(article: article),
        ],
      ),
    );
  }
}
