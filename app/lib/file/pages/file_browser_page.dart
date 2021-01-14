import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/module.dart';
import 'package:schulcloud/course/module.dart';

import '../data.dart';
import '../widgets/file_list.dart';
import '../widgets/upload_fab.dart';

class FileBrowserPage extends StatelessWidget {
  const FileBrowserPage(this.path) : assert(path != null);

  final FilePath path;

  @override
  Widget build(BuildContext context) {
    return FancyScaffold(
      appBar: PreferredSize(
        preferredSize: AppBar().preferredSize,
        child: _buildAppBar(context),
      ),
      floatingActionButton: UploadFab(path: path),
      omitHorizontalPadding: true,
      sliver: CollectionBuilder<File>(
        collection: path.files,
        builder: handleLoadingErrorEmptySliver(
          emptyStateBuilder: (context) => EmptyStatePage(
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
          ),
          builder: (context, fileIds, isFetching) => SliverFileList(fileIds),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    Widget build({String title, dynamic error, Color color}) {
      return FancyAppBar(
        title: FancyText(title ?? error?.toString()),
        backgroundColor: color,
      );
    }

    if (path.isOwnerCourse) {
      return EntityBuilder<Course>(
        id: path.ownerId,
        builder: (context, snapshot, _) {
          final course = snapshot.data;

          if (path.parentId == null) {
            return build(
              title: course?.name,
              error: snapshot.error,
              color: course?.color,
            );
          }

          return EntityBuilder<File>(
            id: path.parentId,
            builder: (context, snapshot, _) {
              return build(
                title: snapshot.data?.name,
                error: snapshot.error,
                color: course?.color,
              );
            },
          );
        },
      );
    } else if (path.parentId != null) {
      return EntityBuilder<File>(
        id: path.parentId,
        builder: (context, snapshot, _) {
          return build(
            title: snapshot.data?.name,
            error: snapshot.error,
          );
        },
      );
    } else if (path.isOwnerMe) {
      return build(title: context.s.file_files_my);
    } else {
      assert(false, 'Unsupported path owner: ${path.ownerId.runtimeType}');
      return null;
    }
  }
}
