import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

class PermanentJsonStorage extends MutableRepository<Map<String, dynamic>> {
  final String id;

  const PermanentJsonStorage(this.id);

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Stream<Map<String, dynamic>> fetch(Id id) {
    return Stream.fromFuture(() async {
      return json.decode((await _prefs).getString(this.id))['$id'];
    }());
  }

  @override
  Stream<List<Map<String, dynamic>>> fetchAll() {
    return Stream.fromFuture(() async {
      return json.decode((await _prefs).getString(this.id));
    }())
        .cast<Map<String, dynamic>>()
        .map((jsonData) => jsonData.values);
  }

  @override
  Future<void> update(Id id, Map<String, dynamic> value) async {
    Map<String, dynamic> jsonData =
        json.decode((await _prefs).getString(this.id));
    jsonData['$id'] = value;
    (await _prefs).setString(this.id, json.encode(jsonData));
  }
}

/*class PermanentStorage<T extends Dto<T>> extends MutableRepository<T> {
  const PermanentStorage(String id);

  static const _storage = const PermanentJsonStorage('news_authors');

  @override
  Stream<T> fetch(Id<T> id) {
    
    return _storage.fetch(id).map((data) => T.fromJson(data));
  }

  @override
  Stream<Iterable<T>> fetchAll() {
    return _storage
        .fetchAll()
        .map((dataList) => dataList.map((data) => T.fromJson(data)));
  }

  @override
  Future<void> update(Id<T> id, T value) async {
    _storage.update(id, value.toJson());
    value.;
  }
}*/
