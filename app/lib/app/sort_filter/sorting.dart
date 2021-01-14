import 'package:characters/characters.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';

import '../utils.dart';
import 'filtering.dart';

extension ComparatorOrder<T> on Comparator<T> {
  Comparator<T> withOrder(SortOrder order) {
    return order == SortOrder.ascending ? this : (a, b) => -this(a, b);
  }
}

enum SortOrder { ascending, descending }

extension SortOrderUtils on SortOrder {
  SortOrder get inverse =>
      this == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending;

  IconData get icon {
    return {
      SortOrder.ascending: Icons.arrow_upward,
      SortOrder.descending: Icons.arrow_downward,
    }[this];
  }

  static SortOrder tryParseWebQuery(Map<String, String> query) {
    return {
      '1': SortOrder.ascending,
      '-1': SortOrder.descending,
    }[query['sortorder']];
  }
}

@immutable
class Sorter<T> {
  const Sorter(
    this.title, {
    this.webQueryKey,
    @required this.comparator,
  })  : assert(title != null),
        assert(comparator != null);

  Sorter.simple(
    L10nStringGetter titleGetter, {
    String webQueryKey,
    @required Selector<T, Comparable<dynamic>> selector,
  }) : this(
          titleGetter,
          webQueryKey: webQueryKey,
          comparator: (a, b) {
            final selectorA = selector(a);
            if (selectorA == null) {
              return 1;
            }
            final selectorB = selector(b);
            if (selectorB == null) {
              return -1;
            }
            return selectorA.compareTo(selectorB);
          },
        );

  /// A specialized [Sorter] for names.
  ///
  /// Unlike a normal [Sorter], it also performs case-insensitive comparison and
  /// tries to detect names with a single leading emoji (which is then ignored).
  Sorter.name(
    L10nStringGetter titleGetter, {
    String webQueryKey,
    @required Selector<T, String> selector,
  }) : this.simple(
          titleGetter,
          webQueryKey: webQueryKey,
          selector: (item) {
            var name = Characters(selector(item) ?? '');
            name = name.toLowerCase();
            // Try to detect names starting with a single emoji.
            if (name.length >= 2 &&
                name.first.length > 1 &&
                name.second.length == 1) {
              name = name.skip(1);
            }
            return name.toString().trim();
          },
        );

  final L10nStringGetter title;
  final String webQueryKey;
  final Comparator<T> comparator;
}
