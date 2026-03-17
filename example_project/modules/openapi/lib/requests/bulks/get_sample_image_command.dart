//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../../base/base_request.dart';

import '../../model/error_response.dart';


/// Get Sample Image
/// Returns a static PNG image from server resources. Tests binary image responses.
///
/// GET /api/v1/bulk/image
class GetSampleImageCommand extends OpenapiDefinitionBaseRequest<BinarySchema> {
  GetSampleImageCommand({this.binaryResponseType = const InMemoryBinaryResponse()});


  @override
  final BinaryResponseType binaryResponseType;

  @override
  String get path {
    var p = r'/api/v1/bulk/image';
    return p;
  }

  @override
  HttpRequestMethod get method => HttpRequestMethod.get;

  @override
  SchemaFactory<BinarySchema> get defaultResponseFactory => BinarySchemaFactory(binaryResponseType: binaryResponseType);

  @override
  SchemaFactory get defaultErrorResponseFactory => AnyDataSchema.factory;

  @override
  Map<int, SchemaFactory> get responseFactories => {
    200: BinarySchemaFactory(binaryResponseType: binaryResponseType),
    500: ErrorResponse.factory,
  };

  @override
  RequestSchema get payload =>
      const EmptyRequestSchema();
}
