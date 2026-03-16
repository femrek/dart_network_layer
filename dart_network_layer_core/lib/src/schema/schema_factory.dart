import 'dart:typed_data';

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

/// A factory that creates instances of [BinarySchema] from binary response
/// data.
final class BinarySchemaFactory<T extends BinarySchema>
    extends SchemaFactory<T> {
  /// const constructor to allow subclasses to be const.
  const BinarySchemaFactory();

  /// Converts the dynamic response to an instance of [BinarySchema].
  T from(dynamic response) {
    if (T == InMemoryBinarySchema) {
      return fromBytes(response) as T;
    }

    if (T == StreamBinarySchema) {
      if (response is Stream<Uint8List>) {
        return fromStream(response) as T;
      }
      throw ArgumentError(
        'StreamBinarySchema expects a Stream<Uint8List>, '
        'but got ${response.runtimeType}',
      );
    }

    if (T == FileBinarySchema) {
      if (response is String) {
        return fromFilePath(response) as T;
      }
      throw ArgumentError(
        'FileBinarySchema expects a file path as a string, '
        'but got ${response.runtimeType}',
      );
    }

    if (T == RawStringBinarySchema) {
      if (response is String) {
        return fromString(response) as T;
      }
      throw ArgumentError(
        'RawStringBinarySchema expects a plain string, '
        'but got ${response.runtimeType}',
      );
    }

    throw UnsupportedError('BinarySchemaFactory does not support type $T');
  }

  /// Creates an [InMemoryBinarySchema] from dynamic response data.
  InMemoryBinarySchema fromBytes(dynamic response) {
    if (response is Uint8List) {
      return InMemoryBinarySchema(bytes: response);
    }
    if (response is List<int>) {
      return InMemoryBinarySchema(bytes: Uint8List.fromList(response));
    }
    throw ArgumentError(
      'InMemoryBinarySchemaFactory expects Uint8List or List<int>, '
      'but got ${response.runtimeType}',
    );
  }

  /// Creates a [StreamBinarySchema] from a stream of bytes.
  StreamBinarySchema fromStream(Stream<Uint8List> response) {
    return StreamBinarySchema(stream: response);
  }

  /// Creates a [FileBinarySchema] from the file.
  FileBinarySchema fromFilePath(String fileName) {
    return FileBinarySchema(filePath: fileName);
  }

  /// Creates a [RawStringBinarySchema] from a raw string response.
  RawStringBinarySchema fromString(String plainString) {
    return RawStringBinarySchema(data: plainString);
  }
}
