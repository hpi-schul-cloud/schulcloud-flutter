import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

@immutable
class Banner {
  const Banner(this.name) : assert(name != null);

  final String name;

  @override
  String toString() => name;
}

abstract class Banners {
  static const demo = Banner('demo');
  static const offline = Banner('offline');
  static const tokenExpired = Banner('token_expired');
}

/// A service that offers storing app-wide state that should be shown to the
/// user.
class BannerService extends ValueNotifier<Set<Banner>> {
  BannerService() : super(<Banner>{});

  void add(Banner banner) => value = Set.from(value)..add(banner);
  void remove(Banner banner) => value = Set.from(value)..remove(banner);

  bool operator [](Banner banner) => value.contains(banner);
  void operator []=(Banner banner, bool value) {
    if (value) {
      add(banner);
    } else {
      remove(banner);
    }
  }
}

extension BannerServiceGetIt on GetIt {
  BannerService get banners => get<BannerService>();
}
