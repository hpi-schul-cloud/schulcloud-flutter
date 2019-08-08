import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/services/files.dart';
import 'package:schulcloud/app/data/file.dart';

class FilesView extends StatelessWidget {
  final String owner;
  final String ownerType;

  FilesView({this.owner, this.ownerType});

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<ApiService, FilesService>(
      builder: (_, api, __) => FilesService(
        api: api,
        owner: owner,
        ownerType: ownerType,
      ),
      child: StreamBuilder<List<File>>(
        stream: Provider.of<FilesService>(context).getFiles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return ListView(
            children: snapshot.data
                .map((file) => ListTile(
                      title: Text(file.name),
                      subtitle: Text(file.ownerType),
                      leading: Icon(
                        file.isDirectory ? Icons.folder : Icons.note,
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
