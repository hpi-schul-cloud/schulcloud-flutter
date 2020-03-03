import 'package:flutter/material.dart' hide Route;
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignment/widgets/edit_submittion_screen.dart';

import 'data.dart';
import 'widgets/assignment_details_screen.dart';
import 'widgets/assignments_screen.dart';

const _activeTabPrefix = 'activetabid=';
final assignmentRoutes = Route.path(
  'homework',
  builder: (result) {
    // Query string is stored inside the fragment, e.g.:
    // https://schul-cloud.org/homework/#?dueDateFrom=2020-03-09&dueDateTo=2020-03-27&private=true&publicSubmissions=false&sort=updatedAt&sortorder=1&teamSubmissions=true
    final query = Uri.parse(result.uri.fragment).queryParameters;
    final selection =
        AssignmentsScreen.sortFilterConfig.tryParseWebQuery(query);
    return MaterialPageRoute(
      builder: (_) => AssignmentsScreen(sortFilterSelection: selection),
    );
  },
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
      routes: [
        Route.path(
          'submission',
          builder: (result) => MaterialPageRoute(
            builder: (_) =>
                EditSubmissionScreen(Id<Assignment>(result['assignmentId'])),
          ),
        ),
      ],
    ),
  ],
);
