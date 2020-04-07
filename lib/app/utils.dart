import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_deep_linking/flutter_deep_linking.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_cache/hive_cache.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';
import 'package:schulcloud/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_config.dart';
import 'exception.dart';
import 'logger.dart';
import 'services/api_network.dart';
import 'services/network.dart';

final services = GetIt.instance;

extension ContextWithLocalization on BuildContext {
  S get s => S.of(this);
}

extension ResponseToJson on Response {
  dynamic get json => jsonDecode(body);
}

extension FutureResponseToJson on Future<Response> {
  Future<dynamic> get json async => (await this).json;
  Future<List<Map<String, dynamic>>> parseJsonList({
    bool isServicePaginated = true,
  }) async {
    var jsonData = (await this).json;
    if (isServicePaginated) {
      jsonData = jsonData['data'];
    }
    return (jsonData as List).cast<Map<String, dynamic>>();
  }
}

/// Limits a string to a certain amount of characters.
@Deprecated('Rather than limiting Strings to a certain amount of characters, '
    'they should be clipped visually, for example after 3 lines')
String limitString(String string, int maxLength) =>
    string.length > maxLength ? '${string.substring(0, maxLength)}…' : string;

/// Prints a file size given in [bytes] as a [String].
String formatFileSize(int bytes) {
  const units = ['B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  var index = 0;
  var power = 1;
  while (bytes > 1000 * power && index < units.length - 1) {
    power *= 1000;
    index++;
  }

  return '${(bytes / power).toStringAsFixed(index == 0 ? 0 : 1)} ${units[index]}';
}

typedef L10nStringGetter = String Function(S);

extension LegenWaitForItDaryString on String {
  // ignore: unnecessary_this
  String get blankToNull => this?.isBlank != false ? null : this;

  String get withoutLinebreaks => replaceAll(RegExp('[\r\n]'), '');

  /// Removes html tags from a string.
  String get withoutHtmlTags => parse(this).documentElement.text;

  /// Removes HTML tags trying to preserve line breaks.
  String get simpleHtmlToPlain {
    return replaceAllMapped(RegExp('</p>(.*?)<p>'), (m) => '\n\n${m[1]}')
        .replaceAll(RegExp('</?p>'), '')
        .splitMapJoin('<br />', onMatch: (_) => '\n')
        .withoutHtmlTags;
  }

  /// Converts this to a simple HTML subset so line breaks are properly
  /// displayed on the web.
  String get plainToSimpleHtml {
    // Because the server is doing … stuff, we need to double encode‽
    return HtmlEscape(HtmlEscapeMode.unknown)
        .convert(HtmlEscape(HtmlEscapeMode.unknown).convert(this))
        .splitMapJoin(
          '\n\n',
          onMatch: (_) => '',
          onNonMatch: (s) => '<p>$s</p>',
        )
        .replaceAllMapped(RegExp('(.+)\n'), (m) => '${m[1]}<br />');
  }

  String get uriComponentEncoded => Uri.encodeComponent(this ?? '');

  /// Converts a hex string (like '#ffdd00' or '#12c0ffee') to a [Color].
  Color get hexToColor =>
      Color(int.parse(substring(1).padLeft(8, 'f'), radix: 16));
}

/// Tries launching a url.
Future<bool> tryLaunchingUrl(String url) async {
  logger.i("Trying to launch url '$url'…");
  final resolved = Uri.parse(services.config.baseWebUrl).resolve(url);
  if (resolved.host == services.config.host) {
    final result = Matcher.path('content/redirect/{id}')
        .evaluate(PartialUri.fromUri(resolved));
    if (result.isMatch) {
      final response = await services.api.head(
        'content/redirect/${result.parameters['id']}',
        followRedirects: false,
      );
      final redirect = response.headers['location'];
      logger.d("Resolved content redirect: '$redirect'");
      return tryLaunchingUrl(redirect);
    }
  }

  final string = resolved.toString();
  if (await canLaunch(string)) {
    await launch(string);
    return true;
  }
  return false;
}

// TODO(marcelgarus): remove
String exceptionMessage(dynamic error) {
  if (error is ServerError && error.body.message != null) {
    return error.body.message;
  }
  return error.toString();
}

extension ImmutableMap<K, V> on Map<K, V> {
  Map<K, V> clone() => Map.of(this);

  Map<K, V> copyWith(K key, V value) {
    final newMap = clone();
    newMap[key] = value;
    return newMap;
  }
}

/// An error indicating that a permission wasn't granted by the user.
class PermissionNotGranted<T> extends FancyException {
  PermissionNotGranted()
      : super(
          isGlobal: false,
          messageBuilder: (context) => context.s.app_error_noPermission,
        );
}

/// Converts the given dynamically typed list into a strongly typed [List] of
/// [Id]s for the entity type [E].
List<Id<E>> parseIds<E extends Entity<E>>(dynamic list) =>
    (list as List<dynamic>)?.cast<String>()?.toIds<E>() ?? [];

extension DeepEquality<T> on Iterable<T> {
  bool deeplyEquals(Iterable<T> other, {bool unordered = false}) => (unordered
          ? DeepCollectionEquality.unordered()
          : DeepCollectionEquality())
      .equals(this, other);
}
