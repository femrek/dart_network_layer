import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:dio/dio.dart';

/// Extension to convert [MultipartFileSchema] to Dio's [MultipartFile].
extension MultipartDioExtension on MultipartFileSchema {
  /// Converts the [MultipartFileSchema] to Dio's [MultipartFile].
  Future<MultipartFile> toDioMultipartFile() {
    final contentType = this.contentType;
    final mediaType =
        contentType != null ? DioMediaType.parse(contentType) : null;

    switch (this) {
      case final ByteMultipartFileSchema f:
        return Future.value(MultipartFile.fromBytes(
          f.data,
          contentType: mediaType,
          filename: f.filename,
        ));
      case final FileMultipartFileSchema f:
        return MultipartFile.fromFile(
          f.filePath,
          contentType: mediaType,
          filename: f.filename,
        );
      case final StreamMultipartFileSchema f:
        final len = f.length ?? -1;
        return Future.value(MultipartFile.fromStream(
          f.streamBuilder,
          len,
          contentType: mediaType,
          filename: f.filename,
        ));
    }
  }
}
