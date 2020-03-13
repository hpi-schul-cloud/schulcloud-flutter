import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:meta/meta.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';

@immutable
class NewsBloc {
  const NewsBloc();

  CacheController<Article> fetchArticle(Id<Article> id) => fetchSingle(
        makeNetworkCall: () => services.network.get('news/$id'),
        parser: (data) => Article.fromJson(data),
      );
  CacheController<List<Article>> fetchArticles() => fetchList(
        makeNetworkCall: () => services.api.get('news'),
        parser: (data) => Article.fromJson(data),
      );
}
