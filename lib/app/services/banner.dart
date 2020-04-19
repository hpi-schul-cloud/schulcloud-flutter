import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

class Banner {
  const Banner();
}

abstract class Banners {
  static const demo = Banner();
  static const offline = Banner();
}

/// A service that offers storing app-wide state that should be shown to the
/// user.
class BannerService extends ValueNotifier<Set<Banner>> {
  BannerService() : super(<Banner>{});

  void add(Banner banner) => value = Set.from(value)..add(banner);
  void remove(Banner banner) => value = Set.from(value)..remove(banner);
}

extension BannerServiceGetIt on GetIt {
  BannerService get banners => get<BannerService>();
}
