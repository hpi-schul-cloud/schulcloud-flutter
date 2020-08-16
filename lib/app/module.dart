import 'package:meta/meta.dart';
import 'package:schulcloud/brand/brand.dart';

import 'logger.dart';
import 'services.dart';
import 'services/deep_linking.dart';

export 'dart:async';
export 'dart:ui' show Color, hashList;

export 'package:black_hole_flutter/black_hole_flutter.dart';
export 'package:dartx/dartx.dart';
export 'package:dartx/dartx_io.dart';
export 'package:get_it/get_it.dart';
export 'package:hive/hive.dart'
    show HiveType, HiveField, TypeAdapter, BinaryReader, BinaryWriter;
export 'package:hive_cache/hive_cache.dart';
export 'package:meta/meta.dart';
export 'package:pedantic/pedantic.dart';
export 'package:rxdart/rxdart.dart';
export 'package:schulcloud/brand/brand.dart';
export 'package:time_machine/time_machine.dart' hide Offset;

export 'account/avatar.dart';
export 'banner/service.dart';
export 'caching/exception.dart';
export 'caching/pages/empty_state.dart';
export 'caching/utils.dart';
export 'caching/widgets/error.dart';
export 'data.dart';
export 'datetime_utils.dart';
export 'error_reporting.dart';
export 'hive.dart';
export 'logger.dart';
export 'routing.dart' show FancyRoute, FancyRouteBuilder, appSchemeLink;
export 'schulcloud_app.dart' show SchulCloudApp, SignedInScreen;
export 'services.dart' hide initServices;
export 'services/api_network.dart';
export 'services/deep_linking.dart';
export 'services/network.dart';
export 'services/snack_bar.dart';
export 'services/storage.dart';
export 'sort_filter/filtering.dart';
export 'sort_filter/sort_filter.dart';
export 'sort_filter/sorting.dart';
export 'top_level_route/page_route.dart';
export 'utils.dart';
export 'widgets/app_bar.dart';
export 'widgets/fade_in.dart';
export 'widgets/form.dart';
export 'widgets/scaffold.dart';
export 'widgets/text.dart';
export 'widgets/user_preview.dart';

Future<void> initAppStart({@required AppConfig appConfig}) async {
  logger.i('Initializing module app part Ⅰ/Ⅱ…');
  services.registerSingleton(appConfig);

  await initServices();
}

Future<void> initAppEnd() async {
  logger.i('Initializing module app part Ⅱ/Ⅱ…');

  services.registerSingletonAsync(DeepLinkingService.create);
}
