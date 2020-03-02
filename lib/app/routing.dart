import 'package:flutter/material.dart' hide Route;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/assignment/assignment.dart';
import 'package:schulcloud/course/course.dart';
import 'package:schulcloud/dashboard/dashboard.dart';

final router = Router(
  routes: [
    Route.webHosts(
      ['schul-cloud.org', 'www.schul-cloud.org'],
      isOptional: true,
      routes: [
        dashboardRoutes,
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
