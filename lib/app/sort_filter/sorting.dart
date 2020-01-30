import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
}

@immutable
class SortOption<T> {
  const SortOption({@required this.title, @required this.comparator})
      : assert(title != null),
        assert(comparator != null);

  final String title;
  final Comparator<T> comparator;
}
