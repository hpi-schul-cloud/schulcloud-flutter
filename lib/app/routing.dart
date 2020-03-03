import 'package:flutter/material.dart' hide Route;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/dashboard/dashboard.dart';
import 'package:schulcloud/file/file.dart';
import 'package:schulcloud/news/news.dart';
import 'package:schulcloud/settings/settings.dart';

final router = Router(
  routes: [
    Route.webHosts(
      ['schul-cloud.org', 'www.schul-cloud.org'],
      isOptional: true,
      routes: [
        assignmentRoutes,
        courseRoutes,
        dashboardRoutes,
        fileRoutes,
        newsRoutes,
        settingsRoutes,
      ],
    ),
    Route.any(
      builder: (result) => MaterialPageRoute(
        builder: (_) => Center(
          child: Text('Page ${result.uri} not found'),
        ),
      ),
    ),
  ],
);
