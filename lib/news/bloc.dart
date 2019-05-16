import '../paginated_loader.dart';
import 'model.dart';

export 'model.dart';

class Bloc {
  final _loader = PaginatedLoader<Article>(
    itemsPerPage: 10,
    pageLoader: _loadPage,
  );

  static Future<List<Article>> _loadPage(int page) async {
    return List.generate(10, (i) {
      return Article(
        title: 'Headline lorem ipsum dolor',
        author: Author(
          name: 'Mona Weitzenberg',
          photoUrl:
              'https://avatars2.githubusercontent.com/u/8601189?s=460&v=4',
        ),
        published: DateTime.now().subtract(Duration(days: 3)),
        section: 'News Schultheater',
        photoUrl:
            'https://cdn.stockphotosecrets.com/wp-content/uploads/2018/09/stock-photo-meme.jpg',
        content: 'Lorem ipsum dolor sit amet, consetetur',
      );
    });
  }

  Future<Article> getArticleAtIndex(int index) => _loader.getItem(index);
  void refresh() => _loader.clearCache();
}
