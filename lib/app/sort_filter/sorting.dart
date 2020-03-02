import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/app.dart';

import 'filtering.dart';

typedef Comparator<T> = int Function(T a, T b);

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
    @required Selector<T, Comparable> selector,
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

  final L10nStringGetter title;
  final String webQueryKey;
  final Comparator<T> comparator;
}
