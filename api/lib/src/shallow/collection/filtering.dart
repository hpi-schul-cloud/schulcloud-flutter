import 'package:dartx/dartx.dart';
import 'package:meta/meta.dart';

import '../entity.dart';

// filters

@immutable
abstract class Filter {
  const Filter();

  List<BuiltFilter> build();
}

abstract class SimpleOrAndFilter extends Filter {
  const SimpleOrAndFilter();

  AndFilter operator &(SimpleOrAndFilter other) => AndFilter([this, other]);
}

abstract class SimpleOrOrFilter extends Filter {
  const SimpleOrOrFilter();
  OrFilter operator |(SimpleOrOrFilter other) => OrFilter([this, other]);
}

abstract class SimpleFilter extends Filter
    implements SimpleOrAndFilter, SimpleOrOrFilter {
  const SimpleFilter(this.propertyName);

  final String propertyName;

  @override
  AndFilter operator &(SimpleOrAndFilter other) => AndFilter([this, other]);
  @override
  OrFilter operator |(SimpleOrOrFilter other) => OrFilter([this, other]);
}

class ComparisonFilter extends SimpleFilter {
  const ComparisonFilter(String propertyName, this.operatorString, this.value)
      : super(propertyName);

  final String? operatorString;
  final dynamic value;

  @override
  List<BuiltFilter> build() {
    return [
      BuiltFilter(
        propertyName,
        [if (operatorString != null) '\$$operatorString'],
        value,
      ),
    ];
  }
}

class InFilter extends SimpleFilter {
  const InFilter(String propertyName, this.operatorString, this.values)
      : super(propertyName);

  final String operatorString;
  final List<dynamic> values;

  @override
  List<BuiltFilter> build() {
    return [
      for (final value in values)
        BuiltFilter(propertyName, ['\$$operatorString', ''], value),
    ];
  }
}

class AndFilter extends SimpleOrAndFilter {
  AndFilter(List<SimpleOrAndFilter> filters)
      : filters = _flattenFilters(filters);

  static List<SimpleFilter> _flattenFilters(List<SimpleOrAndFilter> filters) {
    return filters
        .expand((it) => it is AndFilter
            ? _flattenFilters(it.filters)
            : [it as SimpleFilter])
        .toList();
  }

  final List<SimpleFilter> filters;

  @override
  List<BuiltFilter> build() => filters.expand((it) => it.build()).toList();
}

class OrFilter extends SimpleOrOrFilter {
  OrFilter(List<SimpleOrOrFilter> filters) : filters = _flattenFilters(filters);

  static List<SimpleFilter> _flattenFilters(List<SimpleOrOrFilter> filters) {
    return filters
        .expand((it) =>
            it is OrFilter ? _flattenFilters(it.filters) : [it as SimpleFilter])
        .toList();
  }

  final List<SimpleFilter> filters;

  @override
  List<BuiltFilter> build() {
    List<BuiltFilter> buildFilter(int index) {
      return [
        for (final built in filters[index].build())
          BuiltFilter(
            r'$or',
            ['$index', built.propertyName, ...built.operators],
            built.value,
          ),
      ];
    }

    return filters.indices.expand(buildFilter).toList();
  }
}

@immutable
class BuiltFilter {
  const BuiltFilter(this.propertyName, this.operators, this.value);

  final String propertyName;
  final List<String> operators;
  final dynamic value;

  String get queryKey {
    final key = StringBuffer(propertyName);
    for (final operator in operators) key.write('[$operator]');
    return key.toString();
  }

  String get queryValue => '$value';
}

// properties

@immutable
abstract class FilterProperty<E extends ShallowEntity<E>> {
  const FilterProperty(this.name);

  final String name;
}

class PrimitiveFilterProperty<E extends ShallowEntity<E>, T>
    extends FilterProperty<E> {
  const PrimitiveFilterProperty(String name) : super(name);

  ComparisonFilter equals(T value) => ComparisonFilter(name, null, value);
  ComparisonFilter notEquals(T value) => ComparisonFilter(name, 'ne', value);
  InFilter isIn(List<T> values) => InFilter(name, 'in', values);
  InFilter isNotIn(List<T> values) => InFilter(name, 'nin', values);
}

class ComparableFilterProperty<E extends ShallowEntity<E>, T>
    extends PrimitiveFilterProperty<E, T> {
  const ComparableFilterProperty(String name) : super(name);

  ComparisonFilter operator <(T value) => ComparisonFilter(name, 'lt', value);
  ComparisonFilter operator <=(T value) => ComparisonFilter(name, 'lte', value);
  ComparisonFilter operator >(T value) => ComparisonFilter(name, 'gt', value);
  ComparisonFilter operator >=(T value) => ComparisonFilter(name, 'gte', value);
}
