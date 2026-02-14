import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';

/// [Schema] implementation to be used when the response is not important or
/// when the response data can be of any type.
///
/// See also [IgnoredSchema] for cases where the response data is not needed at
/// all.
class AnyDataSchema extends Schema {
  /// Creates an instance of [AnyDataSchema].
  const AnyDataSchema();

  /// The factory instance for creating [AnyDataSchema] instances.
  static const factory = _Factory();
}

class _Factory extends StringSchemaFactory<AnyDataSchema> {
  const _Factory();

  @override
  AnyDataSchema fromString(String plainString) {
    return const AnyDataSchema();
  }
}
