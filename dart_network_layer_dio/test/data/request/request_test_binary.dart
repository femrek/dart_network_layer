import 'package:dart_network_layer_core/dart_network_layer_core.dart';

import '../test_paths.dart';

/// Request that downloads binary data into memory as [InMemoryBinarySchema].
class RequestTestInMemoryBinary extends RequestCommand<InMemoryBinarySchema> {
  RequestTestInMemoryBinary({this.path = TestPaths.testBinaryInMemory});

  @override
  final String path;

  @override
  BinaryResponseType get binaryResponseType => const InMemoryBinaryResponse();

  @override
  SchemaFactory<InMemoryBinarySchema> get defaultResponseFactory =>
      InMemoryBinarySchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

/// Request that downloads binary data and saves it to a file as
/// [FileBinarySchema].
class RequestTestFileBinary extends RequestCommand<FileBinarySchema> {
  RequestTestFileBinary({required this.savePath});

  @override
  String get path => TestPaths.testBinaryFile;

  @override
  BinaryResponseType get binaryResponseType => FileBinaryResponse(savePath);

  /// The local path where the downloaded file will be saved.
  final String savePath;

  @override
  SchemaFactory<FileBinarySchema> get defaultResponseFactory =>
      FileBinarySchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

/// Request that receives binary data as a stream of chunks.
class RequestTestStreamBinary extends RequestCommand<StreamBinarySchema> {
  RequestTestStreamBinary({this.path = TestPaths.testBinaryStream});

  @override
  final String path;

  @override
  BinaryResponseType get binaryResponseType => const StreamBinaryResponse();

  @override
  SchemaFactory<StreamBinarySchema> get defaultResponseFactory =>
      StreamBinarySchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

/// Request that receives binary endpoint content as raw string.
class RequestTestRawStringBinary extends RequestCommand<RawStringBinarySchema> {
  RequestTestRawStringBinary({this.path = TestPaths.testBinaryRawString});

  @override
  final String path;

  @override
  BinaryResponseType get binaryResponseType =>
      const RawStringBinaryResponse('raw');

  @override
  SchemaFactory<RawStringBinarySchema> get defaultResponseFactory =>
      RawStringBinarySchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}
