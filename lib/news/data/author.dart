import 'package:flutter/foundation.dart';
import 'package:schulcloud/core/data.dart';

class Author extends Entity<Author> {
  final String name;
  final String photoUrl;

  const Author({
    @required Id<Author> id,
    @required this.name,
    this.photoUrl,
  })  : assert(name != null),
        super(id);

  factory Author.fromJson(Map<String, dynamic> data) => Author(
      id: Id(data['id']),
      name: data['name'] as String,
      photoUrl: data['photoUrl'] as String);

  Map<String, dynamic> toJson() => <String, dynamic> {''
      'id': id.id,
      'name': name,
      'photoUrl': photoUrl
  };
}
