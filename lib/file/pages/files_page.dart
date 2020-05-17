import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import '../data.dart';
import '../widgets/file_browser.dart';
import '../widgets/upload_fab.dart';

class FilesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FancyScaffold(
      appBar: FancyAppBar(title: Text(context.s.file)),
      floatingActionButton: UploadFab(
        path: FilePath(services.storage.userId),
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _CoursesList(),
          SizedBox(height: 16),
          _UserFiles(),
        ]),
      ),
    );
  }
}

class _CoursesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FancyCard(
      title: context.s.file_files_course,
      child: CollectionBuilder.populated<Course>(
        collection: services.storage.root.courses,
        builder: handleLoadingError((context, courses, _) {
          return GridView.extent(
            primary: false,
            shrinkWrap: true,
            maxCrossAxisExtent: 300,
            childAspectRatio: 2.8,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: <Widget>[
              for (var course in courses) _CourseCard(course: course),
            ],
          );
        }),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({Key key, this.course}) : super(key: key);

  final Course course;

  @override
  Widget build(BuildContext context) {
    return FlatMaterial(
      onTap: () => context.navigator.pushNamed('/files/courses/${course.id}'),
      child: SizedBox(
        height: 48,
        child: Row(
          children: <Widget>[
            Icon(Icons.folder, color: course.color),
            SizedBox(width: 8),
            Expanded(child: Text(course.name)),
          ],
        ),
      ),
    );
  }
}

class _UserFiles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FancyCard(
      title: context.s.file_files_my,
      omitHorizontalPadding: true,
      child: FileBrowser.myFiles(),
    );
  }
}

class FlatMaterial extends StatelessWidget {
  const FlatMaterial({
    Key key,
    @required this.onTap,
    @required this.child,
  }) : super(key: key);

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.cardColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ),
    );
  }
}
