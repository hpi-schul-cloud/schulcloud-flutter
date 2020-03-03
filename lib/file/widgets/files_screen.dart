import 'package:flutter_cached/flutter_cached.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import '../bloc.dart';
import 'file_browser.dart';
import 'page_route.dart';

class FilesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FancyScaffold(
      appBar: FancyAppBar(title: Text(context.s.file)),
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
      child: CachedRawBuilder(
        controller: services.get<FileBloc>().fetchCourses()..fetch(),
        builder: (context, update) {
          return GridView.extent(
            primary: false,
            shrinkWrap: true,
            maxCrossAxisExtent: 300,
            childAspectRatio: 2.8,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: <Widget>[
              for (var course in update.data ?? []) _CourseCard(course: course),
            ],
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({Key key, this.course}) : super(key: key);

  final Course course;

  void _showCourseFiles(BuildContext context) {
    context.navigator.push(FileBrowserPageRoute(
      builder: (context) => FileBrowser(owner: course),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return FlatMaterial(
      onTap: () => _showCourseFiles(context),
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
      child: CachedRawBuilder(
        controller: services.get<UserFetcherService>().fetchCurrentUser(),
        builder: (context, update) {
          return update.hasData
              ? FileBrowser(owner: update.data, isEmbedded: true)
              : Container();
        },
      ),
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
          padding: const EdgeInsets.all(8),
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
