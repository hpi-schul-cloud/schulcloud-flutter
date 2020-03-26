import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';

import 'data.dart';
import 'widgets/file_browser.dart';
import 'widgets/files_screen.dart';

Route _buildSubdirRoute(Id<Entity> Function(RouteResult result) ownerGetter) {
  return FancyRoute(
    matcher: Matcher.path('{parentId}'),
    builder: (_, result) => FileBrowser(FilePath(
      ownerGetter(result),
      Id<File>(result['parentId']),
    )),
  );
}

final fileRoutes = FancyRoute(
  matcher: Matcher.path('files'),
  builder: (_, __) => FilesScreen(),
  routes: [
    FancyRoute(
      matcher: Matcher.path('my'),
      builder: (_, result) => FileBrowser(FilePath(services.storage.userId)),
      routes: [
        _buildSubdirRoute((_) => services.storage.userId),
      ],
    ),
    FancyRoute(
      matcher: Matcher.path('courses'),
      builder: (_, __) => FilesScreen(),
      routes: [
        FancyRoute(
          matcher: Matcher.path('{courseId}'),
          builder: (_, result) =>
              FileBrowser(FilePath(Id<Course>(result['courseId']))),
          routes: [
            _buildSubdirRoute((result) => Id<Course>(result['courseId'])),
          ],
        ),
      ],
    ),
  ],
);
