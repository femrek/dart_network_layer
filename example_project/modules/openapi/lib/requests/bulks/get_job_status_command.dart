//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../../base/base_request.dart';



/// Get Job Status
/// Retrieves the status of a bulk job. Tests untyped maps and Enum parameters.
///
/// GET /api/v1/dummy/status/{jobId}
class GetJobStatusCommand extends OpenapiDefinitionBaseRequest<AnyDataSchema> {
  GetJobStatusCommand({
    required this.jobId,
    this.level,
  });

  final String jobId;

  /// Detail level required
  final String? level;



  @override
  String get path {
    var p = r'/api/v1/dummy/status/{jobId}';
    p = p.replaceAll('{jobId}', jobId);
    return p;
  }

  @override
  List<QueryParameter> get queryParameters => [
    if (level != null) QueryParameter(key: r'level', value: level),
  ];

  @override
  HttpRequestMethod get method => HttpRequestMethod.get;

  @override
  SchemaFactory<AnyDataSchema> get defaultResponseFactory => AnyDataSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;

  @override
  RequestSchema get payload =>
      const EmptyRequestSchema();

}
