Future<List<File>> listFiles(
    {String owner, String ownerType, String parent}) async {
  Map<String, String> queries = Map();
  if (owner != null) queries['owner'] = owner;
  if (parent != null) queries['parent'] = parent;
  var response = await network.get('fileStorage', parameters: queries);

  var body = json.decode(response.body);
  return (body as List<dynamic>).where((f) => f['name'] != null).map((data) {
    return File(
      id: Id<File>(data['_id']),
      name: data['name'] ?? data['_id'],
      ownerType: data['refOwnerModel'],
      ownerId: data['owner'],
      isDirectory: data['isDirectory'],
      parent: data['parent'],
      size: data['size'],
    );
  }).toList();
}
