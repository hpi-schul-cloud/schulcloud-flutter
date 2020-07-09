import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';
import 'pages/assignment_detail_page/page.dart';
import 'pages/assignments_page.dart';
import 'pages/edit_submission_page.dart';

const _activeTabPrefix = 'activetabid=';
final assignmentRoutes = FancyRoute(
  matcher: Matcher.path('homework'),
  builder: (_, result) {
    // Query string is stored inside the fragment, e.g.:
    // https://schul-cloud.org/homework/#?dueDateFrom=2020-03-09&dueDateTo=2020-03-27&private=true&publicSubmissions=false&sort=updatedAt&sortorder=1&teamSubmissions=true
    final query = Uri.parse(result.uri.fragment).queryParameters;
    final selection = AssignmentsPage.sortFilterConfig.tryParseWebQuery(query);
    return AssignmentsPage(sortFilterSelection: selection);
  },
  routes: [
    FancyRoute(
      matcher: Matcher.path('{assignmentId}'),
      onlySwipeFromEdge: true,
      builder: (_, result) {
        var tab = result.uri.fragment;
        tab = tab.isNotEmpty && tab.startsWith(_activeTabPrefix)
            ? tab.substring(_activeTabPrefix.length)
            : null;

        return AssignmentDetailPage(
          Id<Assignment>(result['assignmentId']),
          initialTab: tab,
        );
      },
      routes: [
        FancyRoute(
          matcher: Matcher.path('submission'),
          builder: (_, result) =>
              EditSubmissionPage(Id<Assignment>(result['assignmentId'])),
        ),
      ],
    ),
  ],
);
