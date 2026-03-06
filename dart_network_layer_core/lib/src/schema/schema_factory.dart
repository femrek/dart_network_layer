import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// Base type of factory that creates instances of [Schema].
sealed class SchemaFactory<T extends Schema> {
  /// const constructor to allow subclasses to be const.
  const SchemaFactory();

  /// The type of the schema that this factory creates.
  Type get type => T;
}

/// A factory that creates instances of [Schema] from JSON data.
///
/// If the expected response is json, then [JsonSchemaFactory] should be
/// used.
///
/// The invoker uses this class to convert the response body to the expected
/// type.
abstract class JsonSchemaFactory<T extends Schema> extends SchemaFactory<T> {
  /// const constructor to allow subclasses to be const.
  const JsonSchemaFactory();

  /// Converts the map or list to an instance.
  ///
  /// The [json] parameter is the decoded json data, which can be a [Map] or a
  /// [List].
  T fromJson(dynamic json);
}

/// A factory that creates instances of [Schema] from raw data.
///
/// If the expected response is not json, then [StringSchemaFactory] should be
/// used.
abstract class StringSchemaFactory<T extends Schema> extends SchemaFactory<T> {
  /// const constructor to allow subclasses to be const.
  const StringSchemaFactory();

  /// Converts the plain string to an instance.
  ///
  /// The [plainString] parameter is the raw response body as a string.
  T fromString(String plainString);
}

/// A factory that creates instances of [Schema] from dynamic data.
///
/// This can be used when the response data can be of any type (e.g., String,
/// Map, List, etc.).
abstract class DynamicSchemaFactory<T extends Schema> extends SchemaFactory<T> {
  /// const constructor to allow subclasses to be const.
  const DynamicSchemaFactory();

  /// Converts the dynamic response to an instance.
  ///
  /// The [response] parameter is the raw response body, which can be of any
  /// type (e.g., String, Map, List, etc.).
  T from(dynamic response);
}
