import 'package:dart_network_layer_core/dart_network_layer_core.dart';

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

/// Factory for creating [IgnoredSchema] instances from string data.
///
/// The string input is ignored and a const [IgnoredSchema] instance is
/// returned.
class _Factory extends StringSchemaFactory<IgnoredSchema> {
  /// Creates a const instance of [_Factory].
  const _Factory();

  @override
  IgnoredSchema fromString(String plainString) {
    return const IgnoredSchema();
  }
}
