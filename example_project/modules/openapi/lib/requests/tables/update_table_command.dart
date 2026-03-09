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


/// Request schema for [UpdateTableCommand].
class UpdateTableRequestSchema extends JsonRequestSchema {
  const UpdateTableRequestSchema({required this.data});

  final Map<String, Object> data;

  @override
  dynamic toJsonPayload() => data;
}

/// Update: Update an existing entity
/// Updates an existing entity with the provided field values. Implements ra-spring-data-provider's update operation with support for partial updates. Only the fields provided in the request body will be updated. 
///
/// PUT /api/v1/tables/{id}
class UpdateTableCommand extends OpenapiDefinitionBaseRequest<TableDTO> {
  UpdateTableCommand({
    required this.id,
    required Map<String, Object> requestBody,
  }) : _payload = UpdateTableRequestSchema(data: requestBody);

  /// Unique identifier of the entity to update
  final int id;

  final UpdateTableRequestSchema _payload;


  @override
  String get path {
    var p = r'/api/v1/tables/{id}';
    p = p.replaceAll('{id}', id.toString());
    return p;
  }


  @override
  HttpRequestMethod get method => HttpRequestMethod.put;

  @override
  SchemaFactory<TableDTO> get defaultResponseFactory => TableDTO.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;

  @override
  RequestSchema get payload =>
      _payload;

}
