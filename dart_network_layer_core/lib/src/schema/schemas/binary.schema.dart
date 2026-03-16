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
final class InMemoryBinarySchema extends BinarySchema {
  /// Creates an instance of [InMemoryBinarySchema] with the given [bytes].
  const InMemoryBinarySchema({required this.bytes});

  /// The raw response bytes.
  final Uint8List bytes;

  /// The factory instance for creating [InMemoryBinarySchema] instances.
  static const BinarySchemaFactory<InMemoryBinarySchema> factory =
      BinarySchemaFactory<InMemoryBinarySchema>();
}

/// Binary response data received as a stream of bytes.
final class StreamBinarySchema extends BinarySchema {
  /// Creates an instance of [StreamBinarySchema] with the given [stream].
  const StreamBinarySchema({required this.stream});

  /// The stream of response bytes.
  final Stream<Uint8List> stream;

  /// The factory instance for creating [StreamBinarySchema] instances.
  static const BinarySchemaFactory<StreamBinarySchema> factory =
      BinarySchemaFactory<StreamBinarySchema>();
}

/// Binary response data saved to a file on disk.
///
/// This is used when [FileBinaryResponse] is set on the request command.
final class FileBinarySchema extends BinarySchema {
  /// Creates an instance of [FileBinarySchema] with the given [filePath].
  const FileBinarySchema({required this.filePath});

  /// The path where the file was saved.
  final String filePath;

  /// The factory instance for creating [FileBinarySchema] instances.
  static const BinarySchemaFactory<FileBinarySchema> factory =
      BinarySchemaFactory<FileBinarySchema>();
}

/// Binary response data received as a raw string.
///
/// This can be used when the binary endpoint returns text-based content
/// (e.g., base64-encoded data or CSV).
final class RawStringBinarySchema extends BinarySchema {
  /// Creates an instance of [RawStringBinarySchema] with the given [data].
  const RawStringBinarySchema({required this.data});

  /// The raw string response data.
  final String data;

  /// The factory instance for creating [RawStringBinarySchema] instances.
  static const BinarySchemaFactory<RawStringBinarySchema> factory =
      BinarySchemaFactory<RawStringBinarySchema>();
}
