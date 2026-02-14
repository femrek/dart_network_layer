import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';

/// [Schema] implementation to ignore the response data.
///
/// This can be used when the response data is not needed. For example,
/// endpoints that return no content (204).
///
/// Also useful for error responses where the response body is not relevant.
class IgnoredSchema extends Schema {
  /// Creates an instance of [IgnoredSchema].
  const IgnoredSchema();

  /// The factory instance for creating [IgnoredSchema] instances.
  static const factory = _Factory();
}

class _Factory extends StringSchemaFactory<IgnoredSchema> {
  const _Factory();

  @override
  IgnoredSchema fromString(String plainString) {
    return const IgnoredSchema();
  }
}
