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


/// Bulk Download Data
/// Downloads a generated bulk dataset. Tests binary octet-stream responses.
///
/// GET /api/v1/bulk/download/{datasetId}
class BulkDownloadCommand extends OpenapiDefinitionBaseRequest<BinarySchema> {
  BulkDownloadCommand({
    required this.datasetId,
    this.binaryResponseType = const InMemoryBinaryResponse(),
  });

  /// ID of the dataset to download
  final String datasetId;

  @override
  final BinaryResponseType binaryResponseType;

  @override
  String get path {
    var p = r'/api/v1/bulk/download/{datasetId}';
    p = p.replaceAll('{datasetId}', datasetId);
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
    404: ErrorResponse.factory,
  };

  @override
  RequestSchema get payload =>
      const EmptyRequestSchema();
}
