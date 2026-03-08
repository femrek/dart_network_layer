//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../../base/base_request.dart';

import '../../model/table.dart';


/// GetOne: Get single entity by ID
/// Retrieves a single entity by its unique identifier. Implements ra-spring-data-provider's getOne operation. 
///
/// GET /api/v1/tables/{id}
class GetTableCommand extends OpenapiDefinitionBaseRequest<Table> {
  GetTableCommand({
    required this.id,
  });

  /// Unique identifier of the entity to retrieve
  final int id;



  @override
  String get path {
    var p = r'/api/v1/tables/{id}';
    p = p.replaceAll('{id}', id.toString());
    return p;
  }


  @override
  HttpRequestMethod get method => HttpRequestMethod.get;

  @override
  SchemaFactory<Table> get defaultResponseFactory => Table.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;

  @override
  RequestSchema get payload =>
      const EmptyRequestSchema();

}
