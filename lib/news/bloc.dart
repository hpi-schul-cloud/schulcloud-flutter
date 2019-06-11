import 'package:schulcloud/core/data.dart';

import 'data.dart';

class Bloc {
  static final _articles = CachedRepository<Article>(
    source: ArticleDownloader(),
    cache: ObjectToJsonTransformer(
      serializer: ArticleSerializer(),
      source: JsonToStringTransformer(
        source: SharedPreferencesStorage(keyPrefix: 'articles'),
      ),
    ),
  );

  Stream<Article> getArticleAtIndex(int index) =>
      _articles.fetch(Id('article_$index'));

  void refresh() => _articles.clearCache();
}
