import 'package:schulcloud/core/data.dart';

import 'data/repository.dart';
import 'entities.dart';

export 'entities.dart';

class Bloc {
  static final _articles = CachedRepository<Article>(
    source: ArticleDownloader(),
    cache: ObjectToJsonTransformer(
      serializer: ArticleSerializer(),
      source: JsonToStringTransformer(
        source: SharedPreferences(keyPrefix: 'articles'),
      ),
    ),
  );

  Stream<Article> getArticleAtIndex(int index) =>
      _articles.fetch(Id('article_$index'));

  void refresh() => _articles.clearCache();
}
