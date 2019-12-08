import 'package:flutter/widgets.dart';
import 'package:flutter_cached/flutter_cached.dart';
import 'package:meta/meta.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';

class Bloc {
  Bloc({
    @required this.storage,
    @required this.network,
    @required this.userFetcher,
  })  : assert(storage != null),
        assert(network != null),
        assert(userFetcher != null);

  final StorageService storage;
  final NetworkService network;
  final UserFetcherService userFetcher;

  static Bloc of(BuildContext context) => Provider.of<Bloc>(context);

  CacheController<List<Article>> fetchArticles() => fetchList(
        storage: storage,
        makeNetworkCall: () => network.get('news'),
        parser: (data) => Article.fromJson(data),
      );
}
