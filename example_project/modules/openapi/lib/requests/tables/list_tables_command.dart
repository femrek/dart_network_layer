//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../../base/base_request.dart';

import '../../model/table_dto.dart';


/// Response schema wrapping a list of [TableDTO].
class ListTablesResponseSchema extends Schema {
  const ListTablesResponseSchema({required this.items});

  final List<TableDTO> items;

  static const factory = _ListTablesResponseSchemaFactory();
}

class _ListTablesResponseSchemaFactory extends JsonSchemaFactory<ListTablesResponseSchema> {
  const _ListTablesResponseSchemaFactory();

  @override
  ListTablesResponseSchema fromJson(dynamic json) {
    return ListTablesResponseSchema(
      items: TableDTO.listFromJson(json),
    );
  }
}

/// GetList: Get paginated list of entities with filtering
/// Retrieves a paginated list of entities with support for sorting and filtering. Implements ra-spring-data-provider's getList operation.  This method returns a subset of entities based on the pagination parameters (_start and _end). The results can be sorted by any field in ascending or descending order. Custom filters can be applied through additional query parameters passed in allParams.  The response includes an X-Total-Count header containing the total number of entities matching the filter criteria (not just the current page). This header is essential for ra-spring-data-provider to calculate pagination correctly.  Example: GET /api/posts?_start=0&_end=10&_sort=title&_order=ASC&status=published 
///
/// GET /api/v1/tables
class ListTablesCommand extends OpenapiDefinitionBaseRequest<ListTablesResponseSchema> {
  ListTablesCommand({
    required this.start,
    required this.end,
    required this.allParams,
    this.sort,
    this.order,
    this.embed,
  });

  /// Starting index for pagination (0-based, inclusive)
  final int start;

  /// Ending index for pagination (0-based, exclusive)
  final int end;

  /// Additional query parameters for filtering by entity fields
  final Map<String, String> allParams;

  /// Field name to sort by
  final String? sort;

  /// Sort direction (ASC or DESC)
  final String? order;

  /// Optional parameter to embed related resources (implementation-specific)
  final String? embed;



  @override
  String get path {
    var p = r'/api/v1/tables';
    return p;
  }

  @override
  List<QueryParameter> get queryParameters => [
    QueryParameter(key: r'_start', value: start),
    QueryParameter(key: r'_end', value: end),
    if (sort != null) QueryParameter(key: r'_sort', value: sort),
    if (order != null) QueryParameter(key: r'_order', value: order),
    if (embed != null) QueryParameter(key: r'_embed', value: embed),
    QueryParameter(key: r'allParams', value: allParams),
  ];

  @override
  HttpRequestMethod get method => HttpRequestMethod.get;

  @override
  SchemaFactory<ListTablesResponseSchema> get defaultResponseFactory => ListTablesResponseSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;

  @override
  RequestSchema get payload =>
      const EmptyRequestSchema();

}
