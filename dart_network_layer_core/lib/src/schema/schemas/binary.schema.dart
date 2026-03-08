import 'dart:typed_data';

import 'package:dart_network_layer_core/dart_network_layer_core.dart';

/// Sealed [Schema] for binary response data.
///
/// This schema supports three modes:
/// - [InMemoryBinarySchema]: The response bytes are stored in memory.
/// - [FileBinarySchema]: The response was saved to a file.
/// - [RawStringBinarySchema]: The response was received as a raw string.
sealed class BinarySchema extends Schema {
  /// const constructor to allow subclasses to be const.
  const BinarySchema();
}

/// Binary response data stored in-memory as raw bytes.
///
/// This is used when [InMemoryBinaryResponse] is set on the request command.
class InMemoryBinarySchema extends BinarySchema {
  /// Creates an instance of [InMemoryBinarySchema] with the given [bytes].
  const InMemoryBinarySchema({required this.bytes});

  /// The raw response bytes.
  final Uint8List bytes;

  /// The factory instance for creating [InMemoryBinarySchema] instances.
  static const factory = InMemoryBinarySchemaFactory();
}

/// Binary response data saved to a file on disk.
///
/// This is used when [FileBinaryResponse] is set on the request command.
class FileBinarySchema extends BinarySchema {
  /// Creates an instance of [FileBinarySchema] with the given [filePath].
  const FileBinarySchema({required this.filePath});

  /// The path where the file was saved.
  final String filePath;

  /// The factory instance for creating [FileBinarySchema] instances.
  static const factory = FileBinarySchemaFactory();
}

/// Binary response data received as a raw string.
///
/// This can be used when the binary endpoint returns text-based content
/// (e.g., base64-encoded data or CSV).
class RawStringBinarySchema extends BinarySchema {
  /// Creates an instance of [RawStringBinarySchema] with the given [data].
  const RawStringBinarySchema({required this.data});

  /// The raw string response data.
  final String data;

  /// The factory instance for creating [RawStringBinarySchema] instances.
  static const factory = RawStringBinarySchemaFactory();
}

/// Factory for creating [InMemoryBinarySchema] from dynamic response data.
class InMemoryBinarySchemaFactory
    extends DynamicSchemaFactory<InMemoryBinarySchema> {
  /// Creates a const instance of [InMemoryBinarySchemaFactory].
  const InMemoryBinarySchemaFactory();

  @override
  InMemoryBinarySchema from(dynamic response) {
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
}

/// Factory for creating [FileBinarySchema] from a file path string.
class FileBinarySchemaFactory extends StringSchemaFactory<FileBinarySchema> {
  /// Creates a const instance of [FileBinarySchemaFactory].
  const FileBinarySchemaFactory();

  @override
  FileBinarySchema fromString(String plainString) {
    return FileBinarySchema(filePath: plainString);
  }
}

/// Factory for creating [RawStringBinarySchema] from a raw string response.
class RawStringBinarySchemaFactory
    extends StringSchemaFactory<RawStringBinarySchema> {
  /// Creates a const instance of [RawStringBinarySchemaFactory].
  const RawStringBinarySchemaFactory();

  @override
  RawStringBinarySchema fromString(String plainString) {
    return RawStringBinarySchema(data: plainString);
  }
}
