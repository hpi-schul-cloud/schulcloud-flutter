import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'file_tile.dart';

class FileList extends StatelessWidget {
  const FileList(this.fileIds) : assert(fileIds != null);

  final List<Id<File>> fileIds;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      primary: false,
      shrinkWrap: true,
      slivers: <Widget>[
        SliverFileList(fileIds),
      ],
    );
  }
}

class SliverFileList extends StatelessWidget {
  const SliverFileList(this.fileIds) : assert(fileIds != null);

  final List<Id<File>> fileIds;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == fileIds.length) {
            return Container(
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                context.s.file_fileBrowser_totalCount(fileIds.length),
                style: context.textTheme.caption,
              ),
            );
          }

          final file = fileIds[index];
          return FileTile(file);
        },
        childCount: fileIds.length + 1,
      ),
    );
  }
}
