import 'package:flutter/material.dart' hide Route;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';
import 'widgets/assignment_details_screen.dart';
import 'widgets/assignments_screen.dart';

const _activeTabPrefix = 'activetabid=';
final assignmentRoutes = Route.path(
  'homework',
  builder: (_) => MaterialPageRoute(builder: (_) => AssignmentsScreen()),
  routes: [
    Route.path(
      '{assignmentId}',
      builder: (result) {
        var tab = result.uri.fragment;
        tab = tab.isNotEmpty && tab.startsWith(_activeTabPrefix)
            ? tab.substring(_activeTabPrefix.length)
            : null;

        return MaterialPageRoute(
          builder: (_) => AssignmentDetailsScreen(
            Id<Assignment>(result['assignmentId']),
            initialTab: tab,
          ),
        );
      },
    ),
  ],
);
