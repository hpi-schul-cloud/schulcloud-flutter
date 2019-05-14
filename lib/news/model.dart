import 'package:flutter/foundation.dart';

@immutable
class Article {
  final String title;
  final String author;
  final DateTime published;
  final String bannerText;
  final String photoUrl;
  final String content;

  Article({
    @required this.title,
    @required this.author,
    @required this.published,
    @required this.bannerText,
    @required this.photoUrl,
    @required this.content,
  });

  String get shortPublishedText => 'Published 3 days ago.';
  String get longPublishedText => '05.02.2019 um 18 Uhr';
}
