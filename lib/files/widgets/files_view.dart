import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/files/bloc.dart';

import '../entities.dart';

class FilesView extends StatelessWidget {
  final String owner;

  FilesView({this.owner});

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<ApiService, Bloc>(
      builder: (_, api, __) => Bloc(api: api),
      child: StreamBuilder<List<File>>(
        stream: Provider.of<Bloc>(context).getFiles(),
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
