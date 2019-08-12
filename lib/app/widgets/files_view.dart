import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/services/files.dart';
import 'package:schulcloud/app/data/file.dart';
import 'package:schulcloud/app/widgets/app_bar.dart';

class FilesView extends StatefulWidget {
  final String owner;
  final String ownerType;
  final String parent;

  FilesView({this.owner, this.ownerType, this.parent});

  @override
  _FilesViewState createState() => _FilesViewState();
}

class _FilesViewState extends State<FilesView> {
  String parent;

  @override
  Widget build(BuildContext context) {
    return ProxyProvider<ApiService, FilesService>(
      key: UniqueKey(),
      builder: (_, api, __) => FilesService(
        api: api,
        owner: widget.owner,
        ownerType: widget.ownerType,
        parent: parent,
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
                      subtitle: Text((file.parent != null) ? file.parent : ''),
                      leading: Icon(
                        file.isDirectory ? Icons.folder : Icons.note,
                      ),
                      onTap: () {
                        if (file.isDirectory) {
                          setState(() {
                            parent = file.id.toString();
                          });
                        } else {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Opened file ${file.name}'),
                          ));
                          Provider.of<FilesService>(context)
                              .downloadFile(file.id, fileName: file.name);
                        }
                      },
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
