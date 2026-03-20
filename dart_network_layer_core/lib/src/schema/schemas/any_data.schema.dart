import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// [Schema] implementation to be used when the response is not important or
/// when the response data can be of any type.
///
/// See also [IgnoredSchema] for cases where the response data is not needed at
/// all.
class AnyDataSchema extends Schema {
  /// Creates an instance of [AnyDataSchema].
  const AnyDataSchema({required this.data});

  /// The data of any type. This can be used when the response data is not
  /// important or when the response data can be of any type.
  final dynamic data;

  /// The factory instance for creating [AnyDataSchema] instances.
  static const factory = _Factory();

  @override
  String toLogString() {
    return 'AnyDataSchema('
        'data type: ${data.runtimeType}, '
        'data length: ${data.toString().length} chars)';
  }
}

class _Factory extends DynamicSchemaFactory<AnyDataSchema> {
  const _Factory();

  @override
  AnyDataSchema from(dynamic data) => AnyDataSchema(data: data);
}
