//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../../base/base_request.dart';


class GetJobStatusLevelEnum {
  /// Instantiate a new enum with the provided [value].
  const GetJobStatusLevelEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const BASIC = GetJobStatusLevelEnum._(r'BASIC');
  static const FULL = GetJobStatusLevelEnum._(r'FULL');

  /// List of all possible values in this [enum][GetJobStatusLevelEnum].
  static const values = <GetJobStatusLevelEnum>[
    BASIC,
    FULL,
  ];

  static GetJobStatusLevelEnum? fromJson(dynamic value) => GetJobStatusLevelEnumTypeTransformer().decode(value);
}

/// Transformation class that can [encode] an instance of [GetJobStatusLevelEnum] to String,
/// and [decode] dynamic data back to [GetJobStatusLevelEnum].
class GetJobStatusLevelEnumTypeTransformer {
  factory GetJobStatusLevelEnumTypeTransformer() => _instance ??= const GetJobStatusLevelEnumTypeTransformer._();

  const GetJobStatusLevelEnumTypeTransformer._();

  String encode(GetJobStatusLevelEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a GetJobStatusLevelEnum.
  GetJobStatusLevelEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'BASIC': return GetJobStatusLevelEnum.BASIC;
        case r'FULL': return GetJobStatusLevelEnum.FULL;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [GetJobStatusLevelEnumTypeTransformer] instance.
  static GetJobStatusLevelEnumTypeTransformer? _instance;
}



/// Get Job Status
/// Retrieves the status of a bulk job. Tests untyped maps and Enum parameters.
///
/// GET /api/v1/bulk/status/{jobId}
class GetJobStatusCommand extends OpenapiDefinitionBaseRequest<AnyDataSchema> {
  GetJobStatusCommand({
    required this.jobId,
    this.level,
  });

  final String jobId;

  /// Detail level required
  final GetJobStatusLevelEnum? level;



  @override
  String get path {
    var p = r'/api/v1/bulk/status/{jobId}';
    p = p.replaceAll('{jobId}', jobId);
    return p;
  }

  @override
  List<QueryParameter> get queryParameters => [
    if (level != null) QueryParameter(key: r'level', value: level!.value),
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
