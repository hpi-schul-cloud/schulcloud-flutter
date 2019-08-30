import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:schulcloud/app/services.dart';
import 'package:schulcloud/app/services/files.dart';
import 'package:schulcloud/app/data/file.dart';
import 'package:schulcloud/app/widgets/app_bar.dart';

class FilesView extends StatefulWidget {
  final String owner;
  final String parent;
  final Color appBarColor;
  final String appBarTitle;

  FilesView({this.owner, this.parent, this.appBarColor, this.appBarTitle});

  @override
  _FilesViewState createState() => _FilesViewState();
}

class _FilesViewState extends State<FilesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: MyAppBar(),
      appBar: AppBar(
        backgroundColor: widget.appBarColor,
        title: Text(
          widget.appBarTitle ?? '',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<File>>(
        stream: Provider.of<FilesService>(context).getFiles(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          print(snapshot.data.map((f) => f.name));
          return ListView(
            children: [
              ...snapshot.data
                  .where((file) => file.isDirectory)
                  .map((file) => ListTile(
                        title: Text(file.name),
                        leading: Icon(Icons.folder),
                        onTap: () {
                          setState(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProxyProvider<ApiService, FilesService>(
                                    builder: (_, api, __) => FilesService(
                                        api: api,
                                        owner: widget.owner,
                                        parent: file.id.toString()),
                                    child: FilesView(
                                      owner: widget.owner,
                                      parent: file.id.toString(),
                                      appBarColor: widget.appBarColor,
                                      appBarTitle:
                                          '${widget.appBarTitle} > ${file.name}',
                                    ),
                                  ),
                                ));
                          });
                        },
                      )),
              Divider(),
              ...snapshot.data
                  .where((file) => !file.isDirectory)
                  .map((file) => ListTile(
                        title: Text(file.name),
                        subtitle: Text('${(file.size / 1000).round()}kB'),
                        leading: Icon(Icons.note),
                        onTap: () {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Downloading file ${file.name}'),
                          ));
                          Provider.of<FilesService>(context)
                              .downloadFile(file.id, fileName: file.name);
                        },
                      ))
            ],
          );
        },
      ),
    );
  }
}
