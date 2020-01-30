import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_machine/time_machine.dart';

import 'sort_filter.dart';

typedef Predicate<T, D> = bool Function(T item, D data);
typedef Selector<T, R> = R Function(T item);

abstract class Filter<T, D> {
  const Filter({@required this.title}) : assert(title != null);

  final String title;

  bool filter(T item, D data);
  Widget buildWidget(
    BuildContext context,
    D data,
    DataChangeCallback<D> updater,
  );

  Iterable<T> apply(Iterable<T> items, D data) {
    if (data == null) {
      return items;
    }
    return items.where((item) => filter(item, data));
  }
}

@immutable
class DateRangeFilter<T> extends Filter<T, DateRangeFilterData> {
  const DateRangeFilter({@required String title, @required this.selector})
      : assert(title != null),
        assert(selector != null),
        super(title: title);

  final Selector<T, LocalDate> selector;

  @override
  bool filter(T item, DateRangeFilterData data) {
    final date = selector(item);
    if (data.start != null && data.start > date) {
      return false;
    }
    if (data.end != null && data.end < date) {
      return false;
    }
    return true;
  }

  @override
  Widget buildWidget(
    BuildContext context,
    DateRangeFilterData data,
    DataChangeCallback<DateRangeFilterData> updater,
  ) {
    final setData = data ?? DateRangeFilterData();

    return Row(
      children: <Widget>[
        Expanded(
          child: _buildDateField(
            date: data?.start,
            hintText: 'from',
            onChanged: (newStart) => updater(setData.withStart(newStart)),
            lastDate: data?.end,
          ),
        ),
        SizedBox(width: 4),
        Text('–'),
        SizedBox(width: 4),
        Expanded(
          child: _buildDateField(
            date: data?.end,
            hintText: 'until',
            onChanged: (newEnd) => updater(setData.withEnd(newEnd)),
            firstDate: data?.start,
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
      onChanged: (newDate) {
        onChanged(newDate == null ? null : LocalDate.dateTime(newDate));
      },
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.calendar_today),
        hintText: hintText,
      ),
    );
  }
}

@immutable
class DateRangeFilterData {
  const DateRangeFilterData({this.start, this.end})
      : assert(start == null || end == null || start <= end,
            'start must be before end');

  final LocalDate start;
  final LocalDate end;

  DateRangeFilterData withStart(LocalDate start) =>
      DateRangeFilterData(start: start, end: end);
  DateRangeFilterData withEnd(LocalDate end) =>
      DateRangeFilterData(start: start, end: end);
}
