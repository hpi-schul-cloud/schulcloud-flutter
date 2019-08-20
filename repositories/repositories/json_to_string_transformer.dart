import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../id.dart';
import '../repository.dart';

/// A repository that saves json structures into a [Repository<String>].
class JsonToStringTransformer
    extends RepositoryWithSource<Map<String, dynamic>, String> {
  JsonToStringTransformer({@required source}) : super(source);

  @override
  Stream<Map<String, dynamic>> fetch(Id<dynamic> id) =>
      source.fetch(id.cast<String>())?.map((s) => json.decode(s)) ??
      Stream.empty();

  @override
  Stream<Map<Id<Map<String, dynamic>>, Map<String, dynamic>>> fetchAll() =>
      fetchSourceEntriesAndMapItems(
          (data) => json.decode(data) as Map<String, dynamic>);

  @override
  Future<void> update(Id<dynamic> id, Map<String, dynamic> value) async {
    await source.update(id.cast<String>(), json.encode(value));
  }

  @override
  Future<void> remove(Id<dynamic> id) async {
    await source.remove(id.cast<String>());
  }
}
