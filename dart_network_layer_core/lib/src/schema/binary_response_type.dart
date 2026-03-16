/// Represents how a binary/file response should be handled.
///
/// Use [InMemoryBinaryResponse] to receive raw bytes in memory, or
/// [FileBinaryResponse] to save the response directly to a file at the
/// specified path.
sealed class BinaryResponseType {
  /// const constructor to allow subclasses to be const.
  const BinaryResponseType();
}

/// The response bytes will be returned in-memory as a `Uint8List`.
///
/// Use this when you want to process the binary data directly in your
/// application without saving it to disk.
final class InMemoryBinaryResponse extends BinaryResponseType {
  /// Creates a const instance of [InMemoryBinaryResponse].
  const InMemoryBinaryResponse();
}

/// The response bytes will be returned as a stream of byte chunks.
final class StreamBinaryResponse extends BinaryResponseType {
  /// Creates a const instance of [StreamBinaryResponse].
  const StreamBinaryResponse();
}

/// The response will be returned as a raw string.
///
/// Use this when the binary endpoint returns text-based content (e.g.,
/// base64-encoded data or CSV) and you want to receive it as a string rather
/// than bytes.
final class RawStringBinaryResponse extends BinaryResponseType {
  /// Creates an instance of [RawStringBinaryResponse].
  const RawStringBinaryResponse(this.data);

  /// The raw string response data.
  final String data;
}

/// The response will be saved to a file at [savePath].
///
/// Use this when you want to download the response directly to a file on disk.
/// The [savePath] must be a valid writable path on the target platform.
final class FileBinaryResponse extends BinaryResponseType {
  /// Creates a [FileBinaryResponse] with the given [savePath].
  const FileBinaryResponse(this.savePath);

  /// The local file path where the downloaded file should be saved.
  final String savePath;
}
