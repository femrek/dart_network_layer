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
class GetManyReferenceByTablesResponseSchema extends Schema {
  const GetManyReferenceByTablesResponseSchema({required this.items});

  final List<TableDTO> items;

  static const factory = _GetManyReferenceByTablesResponseSchemaFactory();
}

class _GetManyReferenceByTablesResponseSchemaFactory extends JsonSchemaFactory<GetManyReferenceByTablesResponseSchema> {
  const _GetManyReferenceByTablesResponseSchemaFactory();

  @override
  GetManyReferenceByTablesResponseSchema fromJson(dynamic json) {
    return GetManyReferenceByTablesResponseSchema(
      items: TableDTO.listFromJson(json),
    );
  }
}

/// GetManyReference: Get entities that reference another entity
/// Retrieves a paginated list of entities that reference another specific entity. Implements ra-spring-data-provider's getManyReference operation.  This operation is used to fetch entities related to a specific record. For example, retrieving all comments for a particular post, or all orders for a specific customer. Unlike getList, the filter is based on a reference relationship rather than arbitrary criteria.  The response includes an X-Total-Count header containing the total number of entities that reference the specified target entity. This is essential for pagination in React Admin.  Example: GET /api/comments/of/postId/123?_start=0&_end=10&_sort=createdAt&_order=DESC This retrieves comments where the postId field equals 123, paginated and sorted. 
///
/// GET /api/v1/tables/of/{target}/{targetId}
class GetManyReferenceByTablesCommand extends OpenapiDefinitionBaseRequest<GetManyReferenceByTablesResponseSchema> {
  GetManyReferenceByTablesCommand({
    required this.target,
    required this.targetId,
    required this.start,
    required this.end,
    required this.allParams,
    this.sort,
    this.order,
    this.embed,
  });

  /// Name of the field that references the target entity
  final String target;
  /// ID of the target entity being referenced
  final String targetId;
  /// Starting index for pagination (0-based, inclusive)
  final int start;
  /// Ending index for pagination (0-based, exclusive)
  final int end;
  /// Additional query parameters for filtering
  final Map<String, String> allParams;
  /// Field name to sort by
  final String? sort;
  /// Sort direction (ASC or DESC)
  final String? order;
  /// Optional parameter to embed related resources (implementation-specific)
  final String? embed;

  @override
  String get path {
    var p = r'/api/v1/tables/of/{target}/{targetId}';
    p = p.replaceAll('{target}', target);
    p = p.replaceAll('{targetId}', targetId);
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
  SchemaFactory<GetManyReferenceByTablesResponseSchema> get defaultResponseFactory => GetManyReferenceByTablesResponseSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => AnyDataSchema.factory;

  @override
  Map<int, SchemaFactory> get responseFactories => {
    200: GetManyReferenceByTablesResponseSchema.factory,
  };

  @override
  RequestSchema get payload =>
      const EmptyRequestSchema();
}
