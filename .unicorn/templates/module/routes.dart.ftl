import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';

import 'data.dart';
import 'widgets/${module}_detail_screen.dart';
import 'widgets/${module}s_screen.dart';

final ${module}Routes = Route(
  matcher: Matcher.path('${module}s'),
  materialBuilder: (_, __) => ${entity}sScreen(),
  routes: [
    Route(
      matcher: Matcher.path('{${module}Id}'),
      materialBuilder: (_, result) => ${entity}DetailsScreen(
        Id<${entity}>(result['${module}Id']),
      ),
    ),
  ],
);
