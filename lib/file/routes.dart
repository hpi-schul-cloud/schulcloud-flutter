import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import 'data.dart';
import 'pages/file_browser_page.dart';
import 'pages/files_page.dart';

Route _buildSubdirRoute(Id<Entity> Function(RouteResult result) ownerGetter) {
  return FancyRoute(
    matcher: Matcher.path('{parentId}'),
    builder: (_, result) => FileBrowserPage(FilePath(
      ownerGetter(result),
      Id<File>(result['parentId']),
    )),
  );
}

final fileRoutes = FancyRoute(
  matcher: Matcher.path('files'),
  builder: (_, __) => FilesPage(),
  routes: [
    FancyRoute(
      matcher: Matcher.path('my'),
      builder: (_, result) => FileBrowserPage(
        FilePath(services.storage.userId),
      ),
      routes: [
        _buildSubdirRoute((_) => services.storage.userId),
      ],
    ),
    FancyRoute(
      matcher: Matcher.path('courses'),
      builder: (_, __) => FilesPage(),
      routes: [
        FancyRoute(
          matcher: Matcher.path('{courseId}'),
          builder: (_, result) =>
              FileBrowserPage(FilePath(Id<Course>(result['courseId']))),
          routes: [
            _buildSubdirRoute((result) => Id<Course>(result['courseId'])),
          ],
        ),
      ],
    ),
  ],
);
