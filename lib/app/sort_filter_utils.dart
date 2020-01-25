import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
class SortFilterConfig<T, F> {
  const SortFilterConfig({
    this.sortOptions = const {},
    this.filters = const [],
  })  : assert(sortOptions != null),
        assert(filters != null);

  final Map<F, SortOption<T>> sortOptions;
  final List<Filter> filters;
}

@immutable
class SortFilterSelection<T, F> {
  const SortFilterSelection({
    @required this.config,
    @required this.sortOptionKey,
    this.sortOrder = SortOrder.ascending,
    this.filters = const [],
  })  : assert(config != null),
        assert(sortOptionKey != null),
        assert(sortOrder != null),
        assert(filters != null);

  final SortFilterConfig<T, F> config;

  final F sortOptionKey;
  SortOption<T> get sortOption => config.sortOptions[sortOptionKey];
  final SortOrder sortOrder;

  final List<Filter> filters;

  SortFilterSelection<T, F> withSortSelection(F selectedKey) {
    return SortFilterSelection(
      config: config,
      sortOptionKey: selectedKey,
      sortOrder: selectedKey == sortOptionKey
          ? sortOrder.inverse
          : SortOrder.ascending,
      filters: filters,
    );
  }

  List<T> apply(List<T> allItems) {
    return List<T>.from(allItems)
      ..sort(sortOption.comparator.withOrder(sortOrder));
  }
}

typedef Comparator<T> = int Function(T a, T b);

extension ComparatorOrder<T> on Comparator<T> {
  Comparator<T> withOrder(SortOrder order) {
    return order == SortOrder.ascending ? this : (a, b) => -this(a, b);
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

abstract class Filter<F, T> {
  Filter({@required this.field, @required this.title})
      : assert(field != null),
        assert(title != null);

  final F field;
  final String title;
}

class NullableBoolFilter<F> extends Filter<F, bool> {}
