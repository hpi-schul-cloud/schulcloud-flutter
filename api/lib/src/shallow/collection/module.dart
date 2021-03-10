import 'package:enum_to_string/enum_to_string.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oxidized/oxidized.dart';

import '../entity.dart';
import '../network.dart';
import '../shallow.dart';
import '../utils.dart';
import 'filtering.dart';

part 'module.freezed.dart';

abstract class ShallowCollection<E extends ShallowEntity<E>, FilterProperty,
    SortProperty> {
  const ShallowCollection(this.shallow);

  final Shallow shallow;
  String get path;
  E entityFromJson(Map<String, dynamic> json);
  FilterProperty createFilterProperty();

  Future<Result<E, ShallowError>> get(Id<E> id) async {
    return shallow.dio
        .makeRequest<Map<String, dynamic>>((it) => it.get('$path/${id.value}'))
        .map((it) => entityFromJson(it.data!));
  }

  Future<Result<PaginatedResponse<E>, ShallowError>> list({
    WhereBuilder<FilterProperty>? where,
    Map<SortProperty, SortOrder> sortedBy = const {},
    int? limit,
    int? skip = 0,
  }) {
    assert(limit == null || limit > 0);
    assert(skip == null || skip >= 0);

    final builtWhere = where?.call(createFilterProperty()).build() ?? [];

    final rawResponse = shallow.dio.makeRequest<Map<String, dynamic>>(
      (it) => it.get<Map<String, dynamic>>(
        path,
        queryParameters: <String, dynamic>{
          for (final filter in builtWhere) filter.queryKey: filter.queryValue,
          for (final entry in sortedBy.entries)
            '\$sort[${EnumToString.convertToString(entry.key)}]':
                entry.value.queryValue,
          if (limit != null) r'$limit': limit,
          if (skip != null) r'$skip': skip,
        },
      ),
    );
    return rawResponse.map((it) {
      return PaginatedResponse(
        limit: it.data!['limit'] as int,
        skip: it.data!['skip'] as int,
        items: (it.data!['data'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(entityFromJson)
            .toList(),
      );
    });
  }
}

typedef WhereBuilder<FilterProperty> = Filter Function(FilterProperty it);

enum SortOrder { ascending, descending }

extension on SortOrder {
  int get queryValue {
    switch (this) {
      case SortOrder.ascending:
        return 1;
      case SortOrder.descending:
        return -1;
    }
  }
}

@freezed
class PaginatedResponse<T> with _$PaginatedResponse<T> {
  @Assert('total >= 0')
  @Assert('skip >= 0')
  const factory PaginatedResponse({
    // The API provides a `total` field, but that doesn't always return the
    // correct number…
    // required int total,
    required int limit,
    required int skip,
    required List<T> items,
  }) = _PaginatedResponse<T>;
}
