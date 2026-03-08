//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../../base/base_request.dart';



/// Request schema for [UpdateManyTablesCommand].
class UpdateManyTablesRequestSchema extends JsonRequestSchema {
  const UpdateManyTablesRequestSchema({required this.data});

  final Map<String, Object> data;

  @override
  dynamic toJsonPayload() => data;
}

/// UpdateMany: Update multiple entities
/// Updates multiple entities with the same field values in a single operation. Implements ra-spring-data-provider's updateMany operation for bulk updates. Returns a list of updated entity IDs. 
///
/// PUT /api/v1/tables
class UpdateManyTablesCommand extends OpenapiDefinitionBaseRequest<AnyDataSchema> {
  UpdateManyTablesCommand({
    this.id,
    required Map<String, Object> requestBody,
  }) : _payload = UpdateManyTablesRequestSchema(data: requestBody);

  /// List of entity IDs to update
  final List<int>? id;

  final UpdateManyTablesRequestSchema _payload;


  @override
  String get path {
    var p = r'/api/v1/tables';
    return p;
  }

  @override
  List<QueryParameter> get queryParameters => [
    if (id != null) QueryParameter(key: r'id', value: id),
  ];

  @override
  HttpRequestMethod get method => HttpRequestMethod.put;

  @override
  SchemaFactory<AnyDataSchema> get defaultResponseFactory => AnyDataSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;

  @override
  RequestSchema get payload =>
      _payload;

}
