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
class GetManyTablesResponseSchema extends Schema {
  const GetManyTablesResponseSchema({required this.items});

  final List<TableDTO> items;

  static const factory = _GetManyTablesResponseSchemaFactory();
}

class _GetManyTablesResponseSchemaFactory extends JsonSchemaFactory<GetManyTablesResponseSchema> {
  const _GetManyTablesResponseSchemaFactory();

  @override
  GetManyTablesResponseSchema fromJson(dynamic json) {
    return GetManyTablesResponseSchema(
      items: TableDTO.listFromJson(json),
    );
  }
}

/// GetMany: Get multiple entities by IDs
/// Retrieves multiple specific entities by their unique identifiers. Implements ra-spring-data-provider's getMany operation.  Unlike getList, this operation does not use pagination. It simply returns all entities with the specified IDs. This is commonly used when the client needs to fetch multiple specific records, such as when displaying relationships or selected items.  If an ID doesn't exist, it is typically omitted from the response rather than returning an error. The order of returned entities may not match the order of requested IDs.  Example: GET /api/posts/many?id=1&id=5&id=12 
///
/// GET /api/v1/tables/many
class GetManyTablesCommand extends OpenapiDefinitionBaseRequest<GetManyTablesResponseSchema> {
  GetManyTablesCommand({
    required this.id,
  });

  /// List of entity IDs to retrieve
  final List<int> id;



  @override
  String get path {
    var p = r'/api/v1/tables/many';
    return p;
  }

  @override
  List<QueryParameter> get queryParameters => [
    QueryParameter(key: r'id', value: id),
  ];

  @override
  HttpRequestMethod get method => HttpRequestMethod.get;

  @override
  SchemaFactory<GetManyTablesResponseSchema> get defaultResponseFactory => GetManyTablesResponseSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;

  @override
  RequestSchema get payload =>
      const EmptyRequestSchema();

}
