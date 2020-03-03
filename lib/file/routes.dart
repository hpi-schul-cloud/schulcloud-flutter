import 'package:flutter/material.dart' hide Route;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/file/file.dart';

Route _buildSubdirRoute(Id<Entity> Function(RouteResult result) ownerGetter) {
  return Route.path(
    '{parentId}',
    builder: (result) => FileBrowserPageRoute(
      builder: (_) =>
          FileBrowser(ownerGetter(result), Id<File>(result['parentId'])),
    ),
  );
}

final fileRoutes = Route.path(
  'files',
  builder: (_) => MaterialPageRoute(builder: (_) => FilesScreen()),
  routes: [
    Route.path(
      'my',
      builder: (_) => FileBrowserPageRoute(
        builder: (_) => FileBrowser(services.storage.userId, null),
      ),
      routes: [
        _buildSubdirRoute((_) => services.storage.userId),
      ],
    ),
    Route.path(
      'courses',
      builder: (_) => MaterialPageRoute(builder: (_) => FilesScreen()),
      routes: [
        Route.path(
          '{courseId}',
          builder: (result) => FileBrowserPageRoute(
            builder: (_) => FileBrowser(Id<Course>(result['courseId']), null),
          ),
          routes: [
            _buildSubdirRoute((result) => Id<Course>(result['courseId'])),
          ],
        ),
      ],
    ),
  ],
);
