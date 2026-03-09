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
import '../../model/table_create_dto.dart';


/// Request schema for [CreateTableCommand].
class CreateTableRequestSchema extends JsonRequestSchema {
  const CreateTableRequestSchema({required this.data});

  final TableCreateDTO data;

  @override
  dynamic toJsonPayload() => data.toJson();
}

/// Create: Create a new entity
/// Creates a new entity with the provided data. Implements ra-spring-data-provider's create operation. Returns the created entity with generated ID and server-side defaults. 
///
/// POST /api/v1/tables
class CreateTableCommand extends OpenapiDefinitionBaseRequest<TableDTO> {
  CreateTableCommand({
    required TableCreateDTO tableCreateDTO,
  }) : _payload = CreateTableRequestSchema(data: tableCreateDTO);

  final CreateTableRequestSchema _payload;


  @override
  String get path {
    var p = r'/api/v1/tables';
    return p;
  }


  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  SchemaFactory<TableDTO> get defaultResponseFactory => TableDTO.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;

  @override
  RequestSchema get payload =>
      _payload;

}
