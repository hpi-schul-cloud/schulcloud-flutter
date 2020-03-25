import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uni_links/uni_links.dart';

import '../logger.dart';

/// A service that handles incoming deep links.
class DeepLinkingService {
  DeepLinkingService._(Uri initial)
      : _subject = BehaviorSubject<Uri>.seeded(initial) {
    Observable(getUriLinksStream())
        .doOnData((uri) => logger.i('Received deep link: $uri'))
        // We can't use pipe as we're also adding items manually
        .listen(_subject.add);
  }

  static Future<DeepLinkingService> create() async {
    logger.d('Retrieving initial deep link…');
    final initialUri = await getInitialUri();
    logger.i('Initial deep link: $initialUri');

    return DeepLinkingService._(initialUri);
  }

  final BehaviorSubject<Uri> _subject;
  Stream<Uri> get stream => _subject.stream;

  void onUriHandled() {
    _subject.add(null);
  }
}

extension DeepLinkingServiceGetIt on GetIt {
  DeepLinkingService get deepLinking => get<DeepLinkingService>();
}
