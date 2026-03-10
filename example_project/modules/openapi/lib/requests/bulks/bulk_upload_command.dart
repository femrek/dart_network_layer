//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../../base/base_request.dart';

import '../../model/upload_response.dart';
import '../../model/upload_metadata.dart';
import '../../model/error_response.dart';


/// Request schema for [BulkUploadCommand] (multipart).
class BulkUploadRequestSchema extends FormDataRequestSchema {
  const BulkUploadRequestSchema({
    required this.file,
    this.metadata,
  });

  final MultipartFileSchema file;
  final UploadMetadata? metadata;

  @override
  Map<String, dynamic> toFormDataMapPayload() {
    return {
      r'file': file,
      if (metadata != null) r'metadata': metadata,
    };
  }
}

/// Bulk Upload Data
/// Uploads a bulk data file along with metadata. Tests multipart/form-data with mixed parts.
///
/// POST /api/v1/bulk/upload
class BulkUploadCommand extends OpenapiDefinitionBaseRequest<UploadResponse> {
  BulkUploadCommand({
    required MultipartFileSchema file,
    UploadMetadata? metadata,
  }) : _payload = BulkUploadRequestSchema(
          file: file,
          metadata: metadata,
        );


  final BulkUploadRequestSchema _payload;

  @override
  String get path {
    var p = r'/api/v1/bulk/upload';
    return p;
  }

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  SchemaFactory<UploadResponse> get defaultResponseFactory => UploadResponse.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => AnyDataSchema.factory;

  @override
  Map<int, SchemaFactory> get responseFactories => {
    202: UploadResponse.factory,
    400: ErrorResponse.factory,
  };

  @override
  RequestSchema get payload =>
      _payload;
}
