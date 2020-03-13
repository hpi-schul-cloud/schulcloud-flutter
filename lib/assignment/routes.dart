import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';
import 'package:schulcloud/assignment/widgets/edit_submittion_screen.dart';

import 'data.dart';
import 'widgets/assignment_details_screen.dart';
import 'widgets/assignments_screen.dart';

const _activeTabPrefix = 'activetabid=';
final assignmentRoutes = Route(
  matcher: Matcher.path('homework'),
  materialBuilder: (_, result) {
    // Query string is stored inside the fragment, e.g.:
    // https://schul-cloud.org/homework/#?dueDateFrom=2020-03-09&dueDateTo=2020-03-27&private=true&publicSubmissions=false&sort=updatedAt&sortorder=1&teamSubmissions=true
    final query = Uri.parse(result.uri.fragment).queryParameters;
    final selection =
        AssignmentsScreen.sortFilterConfig.tryParseWebQuery(query);
    return AssignmentsScreen(sortFilterSelection: selection);
  },
  routes: [
    Route(
      matcher: Matcher.path('{assignmentId}'),
      materialBuilder: (_, result) {
        var tab = result.uri.fragment;
        tab = tab.isNotEmpty && tab.startsWith(_activeTabPrefix)
            ? tab.substring(_activeTabPrefix.length)
            : null;

        return AssignmentDetailsScreen(
          Id<Assignment>(result['assignmentId']),
          initialTab: tab,
        );
      },
      routes: [
        Route(
          matcher: Matcher.path('submission'),
          materialBuilder: (_, result) =>
              EditSubmissionScreen(Id<Assignment>(result['assignmentId'])),
        ),
      ],
    ),
  ],
);
