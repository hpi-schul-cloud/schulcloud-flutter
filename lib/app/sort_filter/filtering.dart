import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_machine/time_machine.dart';

import '../datetime_utils.dart';
import '../utils.dart';
import 'sort_filter.dart';

typedef Test<T, D> = bool Function(T item, D data);
typedef Selector<T, R> = R Function(T item);

abstract class Filter<T, S> {
  const Filter(this.title) : assert(title != null);

  S get defaultSelection;

  final String title;

  bool filter(T item, S selection);
  Widget buildWidget(
    BuildContext context,
    S selection,
    DataChangeCallback<S> updater,
  );

  Iterable<T> apply(Iterable<T> items, S selection) {
    if (selection == null) {
      return items;
    }
    return items.where((item) => filter(item, selection));
  }
}

@immutable
class DateRangeFilter<T> extends Filter<T, DateRangeFilterSelection> {
  const DateRangeFilter(String title, {@required this.selector})
      : assert(selector != null),
        super(title);

  @override
  DateRangeFilterSelection get defaultSelection => DateRangeFilterSelection();

  final Selector<T, LocalDate> selector;

  @override
  bool filter(T item, DateRangeFilterSelection selection) {
    final date = selector(item);
    final start = selection.start ?? LocalDate.minIsoValue;
    final end = selection.end ?? LocalDate.maxIsoValue;
    return date == null || (start <= date && date <= end);
  }

  @override
  Widget buildWidget(
    BuildContext context,
    DateRangeFilterSelection selection,
    DataChangeCallback<DateRangeFilterSelection> updater,
  ) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _buildDateField(
            date: selection.start,
            hintText: 'from',
            onChanged: (newStart) => updater(selection.withStart(newStart)),
            lastDate: selection.end,
          ),
        ),
        SizedBox(width: 4),
        Text('–'),
        SizedBox(width: 4),
        Expanded(
          child: _buildDateField(
            date: selection.end,
            hintText: 'until',
            onChanged: (newEnd) => updater(selection.withEnd(newEnd)),
            firstDate: selection.start,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    LocalDate date,
    @required String hintText,
    void Function(LocalDate) onChanged,
    LocalDate firstDate,
    LocalDate lastDate,
  }) {
    return DateTimeField(
      initialValue: date?.toDateTimeUnspecified(),
      format: DateFormat.yMd(),
      onShowPicker: (context, current) => showDatePicker(
        context: context,
        initialDate: date?.toDateTimeUnspecified() ?? DateTime.now(),
        firstDate: firstDate?.toDateTimeUnspecified() ?? DateTime(1900),
        lastDate: lastDate?.toDateTimeUnspecified() ?? DateTime(2100),
      ),
      onChanged: (newDate) => onChanged(newDate?.asLocalDate),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.calendar_today),
        hintText: hintText,
      ),
    );
  }
}

@immutable
class DateRangeFilterSelection {
  const DateRangeFilterSelection({this.start, this.end})
      : assert(start == null || end == null || start <= end,
            'start must be before end');

  final LocalDate start;
  final LocalDate end;

  DateRangeFilterSelection withStart(LocalDate start) =>
      DateRangeFilterSelection(start: start, end: end);
  DateRangeFilterSelection withEnd(LocalDate end) =>
      DateRangeFilterSelection(start: start, end: end);
}

@immutable
class FlagsFilter<T> extends Filter<T, Map<String, bool>> {
  const FlagsFilter(String title, {@required this.filters})
      : assert(filters != null),
        super(title);

  @override
  Map<String, bool> get defaultSelection => {};

  final Map<String, FlagFilter<T>> filters;

  @override
  Widget buildWidget(
    BuildContext context,
    Map<String, bool> selection,
    DataChangeCallback<Map<String, bool>> updater,
  ) {
    return ChipGroup(
      children: filters.entries.map((e) {
        final key = e.key;
        final filter = e.value;
        final filterData = selection[key];

        Widget avatar;
        if (filterData == true) {
          avatar = Icon(Icons.check);
        } else if (filterData == false) {
          avatar = Icon(Icons.close);
        }

        return FilterChip(
          avatar: avatar,
          label: Text(filter.title),
          onSelected: (value) {
            final newValue = {
              null: true,
              true: false,
              false: null,
            }[filterData];

            updater(selection.copyWith(key, newValue));
          },
        );
      }).toList(),
    );
  }

  @override
  bool filter(T item, Map<String, bool> selection) =>
      filters.keys.every((k) => filters[k].apply(item, selection[k]));
}

typedef SetFlagFilterCallback<T> = void Function(String key, bool value);

@immutable
class FlagFilter<T> {
  const FlagFilter(this.title, {@required this.selector})
      : assert(title != null),
        assert(selector != null);

  final String title;
  final Selector<T, bool> selector;

  // ignore: avoid_positional_boolean_parameters
  bool apply(T item, bool selection) {
    if (selection == null) {
      return true;
    }
    return selector(item) == selection;
  }
}

class FlagFilterPreviewChip<T> extends StatelessWidget {
  const FlagFilterPreviewChip({
    Key key,
    @required this.flag,
    @required this.callback,
    @required this.icon,
    @required this.label,
  })  : assert(flag != null),
        assert(callback != null),
        assert(icon != null),
        assert(label != null),
        super(key: key);

  final String flag;
  final SetFlagFilterCallback<T> callback;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon),
      label: Text(label),
      onPressed: () => callback(flag, true),
    );
  }
}
