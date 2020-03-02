import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schulcloud/app/chip.dart';

import '../theming_utils.dart';
import '../widgets/bottom_sheet.dart';
import 'filtering.dart';
import 'sorting.dart';

typedef DataChangeCallback<D> = void Function(D newData);
typedef SortFilterChangeCallback<T> = void Function(
    SortFilterSelection<T> newSortFilter);

@immutable
class SortFilter<T> {
  const SortFilter({
    this.sortOptions = const {},
    this.filters = const {},
  })  : assert(sortOptions != null),
        assert(filters != null);

  final Map<String, Sorter<T>> sortOptions;
  final Map<String, Filter> filters;
}

@immutable
class SortFilterSelection<T> {
  SortFilterSelection({
    @required this.config,
    @required this.sortSelectionKey,
    this.sortOrder = SortOrder.ascending,
    Map<String, dynamic> filterSelections = const {},
  })  : assert(config != null),
        assert(sortSelectionKey != null),
        assert(sortOrder != null),
        filterSelections = {
          for (final entry in config.filters.entries)
            entry.key: entry.value.defaultSelection,
          ...filterSelections,
        };

  final SortFilter<T> config;

  final String sortSelectionKey;
  Sorter<T> get sortSelection => config.sortOptions[sortSelectionKey];
  final SortOrder sortOrder;

  final Map<String, dynamic> filterSelections;

  SortFilterSelection<T> withSortSelection(String selectedKey) {
    return SortFilterSelection(
      config: config,
      sortSelectionKey: selectedKey,
      sortOrder: selectedKey == sortSelectionKey
          ? sortOrder.inverse
          : SortOrder.ascending,
      filterSelections: filterSelections,
    );
  }

  SortFilterSelection<T> withFilterSelection(String key, dynamic selection) {
    return SortFilterSelection(
      config: config,
      sortSelectionKey: sortSelectionKey,
      sortOrder: sortOrder,
      filterSelections: {
        ...filterSelections,
        key: selection,
      },
    );
  }

  SortFilterSelection<T> withFlagsFilterSelection(
    String flagsKey,
    String flag,
    // ignore: avoid_positional_boolean_parameters
    bool selection,
  ) {
    assert(config.filters[flagsKey] is FlagsFilter);

    return SortFilterSelection(
      config: config,
      sortSelectionKey: sortSelectionKey,
      sortOrder: sortOrder,
      filterSelections: {
        ...filterSelections,
        flagsKey: <String, bool>{
          ...filterSelections[flagsKey],
          flag: selection,
        }
      },
    );
  }

  List<T> apply(List<T> allItems) {
    Iterable<T> items = List<T>.from(allItems);
    for (final filterOption in filterSelections.entries) {
      final filter = config.filters[filterOption.key];
      items = filter.apply(items, filterOption.value);
    }
    return List<T>.from(items)
      ..sort(sortSelection.comparator.withOrder(sortOrder));
  }

  void showSheet({
    @required BuildContext context,
    @required SortFilterChangeCallback<T> callback,
  }) {
    assert(context != null);
    assert(callback != null);

    var currentSelection = this;
    context.showFancyBottomSheet(
      builder: (_) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: StatefulBuilder(
          builder: (_, setState) {
            return SortFilterWidget(
              selection: currentSelection,
              onSelectionChange: (selection) {
                setState(() => currentSelection = selection);
                callback(selection);
              },
            );
          },
        ),
      ),
    );
  }
}

class SortFilterWidget<T> extends StatelessWidget {
  const SortFilterWidget({
    Key key,
    @required this.selection,
    @required this.onSelectionChange,
  })  : assert(selection != null),
        assert(onSelectionChange != null),
        super(key: key);

  final SortFilterSelection<T> selection;
  SortFilter<T> get config => selection.config;

  final SortFilterChangeCallback<T> onSelectionChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSortSection(),
        for (final filterKey in config.filters.keys)
          _buildFilterSection(context, filterKey),
      ],
    );
  }

  Widget _buildSortSection() {
    return _Section(
      title: 'Order by',
      child: ChipGroup(
        children: <Widget>[
          for (final sortOption in config.sortOptions.entries)
            ActionChip(
              avatar: sortOption.key != selection.sortSelectionKey
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

  Widget _buildFilterSection(BuildContext context, String filterKey) {
    final filter = config.filters[filterKey];

    return _Section(
      title: filter.title,
      child: filter.buildWidget(
          context,
          selection.filterSelections[filterKey],
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
