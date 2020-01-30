import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theming_utils.dart';
import 'filtering.dart';
import 'sorting.dart';

typedef DataChangeCallback<D> = void Function(D newData);
typedef SortFilterChangeCallback<T, S, F> = void Function(
    SortFilterSelection<T, S, F> newSortFilter);

@immutable
class SortFilterConfig<T, S, F> {
  const SortFilterConfig({
    this.sortOptions = const {},
    this.filters = const {},
  })  : assert(sortOptions != null),
        assert(filters != null);

  final Map<S, SortOption<T>> sortOptions;
  final Map<F, Filter> filters;
}

@immutable
class SortFilterSelection<T, S, F> {
  const SortFilterSelection({
    @required this.config,
    @required this.sortOptionKey,
    this.sortOrder = SortOrder.ascending,
    this.filterOptions = const {},
  })  : assert(config != null),
        assert(sortOptionKey != null),
        assert(sortOrder != null),
        assert(filterOptions != null);

  final SortFilterConfig<T, S, F> config;

  final S sortOptionKey;
  SortOption<T> get sortOption => config.sortOptions[sortOptionKey];
  final SortOrder sortOrder;

  final Map<F, dynamic> filterOptions;

  SortFilterSelection<T, S, F> withSortSelection(S selectedKey) {
    return SortFilterSelection(
      config: config,
      sortOptionKey: selectedKey,
      sortOrder: selectedKey == sortOptionKey
          ? sortOrder.inverse
          : SortOrder.ascending,
      filterOptions: filterOptions,
    );
  }

  SortFilterSelection<T, S, F> withFilterSelection(F key, dynamic data) {
    final filterOptions = Map.of(this.filterOptions);
    filterOptions[key] = data;

    return SortFilterSelection(
      config: config,
      sortOptionKey: sortOptionKey,
      sortOrder: sortOrder,
      filterOptions: filterOptions,
    );
  }

  List<T> apply(List<T> allItems) {
    Iterable<T> items = List<T>.from(allItems);
    for (final filterOption in filterOptions.entries) {
      final filter = config.filters[filterOption.key];
      items = filter.apply(items, filterOption.value);
    }
    return List<T>.from(items)
      ..sort(sortOption.comparator.withOrder(sortOrder));
  }
}

class SortFilterWidget<T, S, F> extends StatelessWidget {
  const SortFilterWidget({
    Key key,
    @required this.selection,
    @required this.onSelectionChange,
  })  : assert(selection != null),
        assert(onSelectionChange != null),
        super(key: key);

  final SortFilterSelection<T, S, F> selection;
  SortFilterConfig<T, S, F> get config => selection.config;

  final SortFilterChangeCallback<T, S, F> onSelectionChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSortSection(),
        for (final filterKey in config.filters.keys)
          _buildFilterSection(context, filterKey)
      ],
    );
  }

  Widget _buildSortSection() {
    return _Section(
      title: 'Order by',
      child: Wrap(
        spacing: 8,
        children: <Widget>[
          for (final sortOption in config.sortOptions.entries)
            ActionChip(
              avatar: sortOption.key != selection.sortOptionKey
                  ? null
                  : Icon(selection.sortOrder.icon),
              label: Text(sortOption.value.title),
              onPressed: () => onSelectionChange(
                  selection.withSortSelection(sortOption.key)),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context, F filterKey) {
    final filter = config.filters[filterKey];

    return _Section(
      title: filter.title,
      child: filter.buildWidget(
          context,
          selection.filterOptions[filterKey],
          (data) => onSelectionChange(
              selection.withFilterSelection(filterKey, data))),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({Key key, @required this.title, @required this.child})
      : assert(title != null),
        assert(child != null),
        super(key: key);

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            title,
            style: context.textTheme.overline,
          ),
          SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
