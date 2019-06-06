import 'package:schulcloud/core/data.dart';
import 'package:schulcloud/core/storage.dart';

import 'author.dart';

class AuthorCache extends MutableRepository<AuthorDto> {
  static const _storage = const PermanentJsonStorage('news_authors');

  @override
  Stream<AuthorDto> fetch(Id<AuthorDto> id) {
    return _storage.fetch(id).map((data) => AuthorDto.fromJson(data));
  }

  @override
  Stream<Iterable<AuthorDto>> fetchAll() {
    return _storage
        .fetchAll()
        .map((dataList) => dataList.map((data) => AuthorDto.fromJson(data)));
  }

  @override
  Future<void> update(Id<AuthorDto> id, AuthorDto value) async {
    _storage.update(id, value.toJson());
  }
}

class ArticleCache extends MutableRepository<AuthorDto> {
  static const _storage = const PermanentJsonStorage('news_authors');

  @override
  Stream<AuthorDto> fetch(Id<AuthorDto> id) {
    return _storage.fetch(id).map((data) => AuthorDto.fromJson(data));
  }

  @override
  Stream<Iterable<AuthorDto>> fetchAll() {
    return _storage
        .fetchAll()
        .map((dataList) => dataList.map((data) => AuthorDto.fromJson(data)));
  }

  @override
  Future<void> update(Id<AuthorDto> id, AuthorDto value) async {
    _storage.update(id, value.toJson());
  }
}
