/// Datatype for file types. Especially useful for multipart/form-data requests
/// where files need to be
sealed class MultipartFileSchema {
  /// The const constructor for [MultipartFileSchema].
  const MultipartFileSchema({
    required this.filename,
    this.length,
    this.contentType,
  });

  /// The name of the file, which can be used as the filename in
  /// multipart/form-data requests.
  final String filename;

  /// The length of the file in bytes. This is required for multipart/form-data
  /// requests to set the content-length header for the file part. This must be
  /// known in advance, even if the file content is provided as a stream of
  /// bytes.
  final int? length;

  /// The content type of the file, which can be used as the content-type in
  /// multipart/form-data requests. This is optional and can be inferred from
  /// the filename in the future, but can be specified explicitly if needed.
  final String? contentType;
}

/// A [MultipartFileSchema] that represents a file using byte data. This is
/// useful for multipart/form-data requests where the file content is
/// represented as bytes.
class ByteMultipartFileSchema extends MultipartFileSchema {
  /// Creates an instance of [ByteMultipartFileSchema] with the given byte data.
  const ByteMultipartFileSchema({
    required super.filename,
    required this.data,
    super.length,
    super.contentType,
  });

  /// The byte data representing the file content.
  final List<int> data;
}

/// A [MultipartFileSchema] that represents a file using a file path.
///
/// This is useful for multipart/form-data requests where the file is located on
/// the device and can be accessed via its file path.
class FileMultipartFileSchema extends MultipartFileSchema {
  /// Creates an instance of [FileMultipartFileSchema] with the given file path.
  const FileMultipartFileSchema({
    required super.filename,
    required this.filePath,
    required super.length,
    super.contentType,
  });

  /// The file path representing the location of the file on the device.
  final String filePath;
}

/// A [MultipartFileSchema] that represents a file using a stream of byte data.
///
/// This is useful for multipart/form-data requests where the file content is
/// large and can be read as a stream of bytes, rather than loading the entire
/// file into memory at once.
class StreamMultipartFileSchema extends MultipartFileSchema {
  /// Creates an instance of [StreamMultipartFileSchema] with the given stream
  /// builder.
  const StreamMultipartFileSchema({
    required super.filename,
    required this.streamBuilder,
    super.length,
    super.contentType,
  });

  /// The stream builder that will emit the file's contents for every call.
  final Stream<List<int>> Function() streamBuilder;
}
