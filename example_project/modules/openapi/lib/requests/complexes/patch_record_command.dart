//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../../base/base_request.dart';



/// Request schema for [PatchRecordCommand].
class PatchRecordRequestSchema extends JsonRequestSchema {
  const PatchRecordRequestSchema({required this.data});

  final Object data;

  @override
  dynamic toJsonPayload() => data;
}

/// Partial Update (PATCH)
/// Accepts a flexible payload to test how the client drops nulls or omits fields.
///
/// PATCH /api/v1/complex-json/records/{id}
class PatchRecordCommand extends OpenapiDefinitionBaseRequest<AnyDataSchema> {
  PatchRecordCommand({
    required this.id,
    required Object body,
  }) : _payload = PatchRecordRequestSchema(data: body);

  final String id;

  final PatchRecordRequestSchema _payload;

  @override
  String get path {
    var p = r'/api/v1/complex-json/records/{id}';
    p = p.replaceAll('{id}', id);
    return p;
  }

  @override
  HttpRequestMethod get method => HttpRequestMethod.patch;

  @override
  SchemaFactory<AnyDataSchema> get defaultResponseFactory => AnyDataSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => AnyDataSchema.factory;

  @override
  Map<int, SchemaFactory> get responseFactories => {
    200: AnyDataSchema.factory,
  };

  @override
  RequestSchema get payload =>
      _payload;
}
