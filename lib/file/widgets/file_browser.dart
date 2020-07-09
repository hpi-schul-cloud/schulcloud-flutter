import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import '../data.dart';
import 'file_list.dart';

class FileBrowser extends StatelessWidget {
  FileBrowser.myFiles() : path = FilePath(services.storage.userId);

  final FilePath path;

  @override
  Widget build(BuildContext context) {
    return CollectionBuilder<File>(
      collection: path.files,
      builder: handleLoadingErrorEmpty(
        emptyStateBuilder: _buildEmptyState,
        builder: (context, fileIds, _) {
          return FileList(fileIds);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyStatePage(
      text: context.s.file_fileBrowser_empty,
      child: SizedBox(
        width: 100,
        height: 100,
        child: FlareActor(
          'assets/empty_states/files.flr',
          alignment: Alignment.center,
          fit: BoxFit.contain,
          animation: 'idle',
        ),
      ),
    );
  }
}
