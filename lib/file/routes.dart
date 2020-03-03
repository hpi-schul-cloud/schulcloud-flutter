import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/file/file.dart';

Route _buildSubdirRoute(Id<Entity> Function(RouteResult result) ownerGetter) {
  return Route(
    matcher: Matcher.path('{parentId}'),
    builder: (result) => FileBrowserPageRoute(
      builder: (_) =>
          FileBrowser(ownerGetter(result), Id<File>(result['parentId'])),
      settings: result.settings,
    ),
  );
}

final fileRoutes = Route(
  matcher: Matcher.path('files'),
  materialPageRouteBuilder: (_, __) => FilesScreen(),
  routes: [
    Route(
      matcher: Matcher.path('my'),
      builder: (result) => FileBrowserPageRoute(
        builder: (_) => FileBrowser(services.storage.userId, null),
        settings: result.settings,
      ),
      routes: [
        _buildSubdirRoute((_) => services.storage.userId),
      ],
    ),
    Route(
      matcher: Matcher.path('courses'),
      materialPageRouteBuilder: (_, __) => FilesScreen(),
      routes: [
        Route(
          matcher: Matcher.path('{courseId}'),
          builder: (result) => FileBrowserPageRoute(
            builder: (_) => FileBrowser(Id<Course>(result['courseId']), null),
            settings: result.settings,
          ),
          routes: [
            _buildSubdirRoute((result) => Id<Course>(result['courseId'])),
          ],
        ),
      ],
    ),
  ],
);
