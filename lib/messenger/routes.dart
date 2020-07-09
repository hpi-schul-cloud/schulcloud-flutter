import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:schulcloud/app/app.dart';

import 'pages/messenger_page.dart';

final messengerRoutes = FancyRoute(
  matcher: Matcher.path('messenger'),
  builder: (_, __) => MessengerPage(),
);
