import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_network_layer_core/flutter_network_layer_core.dart';
import 'package:test/test.dart';

import 'utils/test_response_samples.dart';

void main() {
  group('ByteMultipartFileSchema Tests', () {
    test('ByteMultipartFileSchema creation with byte data', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final fileSchema = ByteMultipartFileSchema(
        filename: 'test.bin',
        data: bytes,
      );

      expect(fileSchema.data, equals(bytes));
      expect(fileSchema.data.length, equals(5));
      expect(fileSchema.filename, equals('test.bin'));
    });

    test('ByteMultipartFileSchema with text content', () {
      final textBytes = Uint8List.fromList('Hello World'.codeUnits);
      final fileSchema = ByteMultipartFileSchema(
        filename: 'hello.txt',
        data: textBytes,
      );

      expect(fileSchema.data, equals(textBytes));
      expect(String.fromCharCodes(fileSchema.data), equals('Hello World'));
      expect(fileSchema.filename, equals('hello.txt'));
    });

    test('ByteMultipartFileSchema with image-like binary data', () {
      // Simulating JPEG header bytes
      final imageBytes = Uint8List.fromList(
          [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46]);
      final fileSchema = ByteMultipartFileSchema(
        filename: 'image.jpg',
        data: imageBytes,
      );

      expect(fileSchema.data, equals(imageBytes));
      expect(fileSchema.data[0], equals(0xFF));
      expect(fileSchema.data[1], equals(0xD8));
      expect(fileSchema.filename, equals('image.jpg'));
    });

    test('ByteMultipartFileSchema with empty data', () {
      final emptyBytes = Uint8List(0);
      final fileSchema = ByteMultipartFileSchema(
        filename: 'empty.txt',
        data: emptyBytes,
      );

      expect(fileSchema.data, equals(emptyBytes));
      expect(fileSchema.data.length, equals(0));
      expect(fileSchema.filename, equals('empty.txt'));
    });

    test('ByteMultipartFileSchema immutability', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final fileSchema = ByteMultipartFileSchema(
        filename: 'test.bin',
        data: bytes,
      );

      // FileSchema should be const, so this tests that the data is stored
      // correctly
      expect(fileSchema.data, same(bytes));
    });

    test('Large byte file handling', () {
      // Create a large byte array (1MB)
      final largeBytes = Uint8List(1024 * 1024);
      for (var i = 0; i < largeBytes.length; i++) {
        largeBytes[i] = i % 256;
      }

      final fileSchema = ByteMultipartFileSchema(
        filename: 'large.bin',
        data: largeBytes,
      );

      expect(fileSchema.data.length, equals(1024 * 1024));
      expect(fileSchema.data[0], equals(0));
      expect(fileSchema.data[1024], equals(0));
      expect(fileSchema.filename, equals('large.bin'));
    });
  });

  group('FileMultipartFileSchema Tests', () {
    test('FileMultipartFileSchema creation with file path', () {
      const fileSchema = FileMultipartFileSchema(
        filename: 'document.pdf',
        filePath: '/path/to/document.pdf',
        length: 1024,
      );

      expect(fileSchema.filePath, equals('/path/to/document.pdf'));
      expect(fileSchema.filename, equals('document.pdf'));
      expect(fileSchema.length, equals(1024));
    });

    test('FileMultipartFileSchema with relative path', () {
      const fileSchema = FileMultipartFileSchema(
        filename: 'image.png',
        filePath: './images/image.png',
        length: 2048,
      );

      expect(fileSchema.filePath, equals('./images/image.png'));
      expect(fileSchema.filename, equals('image.png'));
      expect(fileSchema.length, equals(2048));
    });

    test('FileMultipartFileSchema with absolute path', () {
      const fileSchema = FileMultipartFileSchema(
        filename: 'video.mp4',
        filePath: '/home/user/videos/video.mp4',
        length: 1024000,
      );

      expect(fileSchema.filePath, equals('/home/user/videos/video.mp4'));
      expect(fileSchema.filename, equals('video.mp4'));
      expect(fileSchema.length, equals(1024000));
    });

    test('FileMultipartFileSchema with Windows path', () {
      const fileSchema = FileMultipartFileSchema(
        filename: 'data.csv',
        filePath: r'\Users\test\data.csv',
        length: 512,
      );

      expect(fileSchema.filePath, equals(r'\Users\test\data.csv'));
      expect(fileSchema.filename, equals('data.csv'));
      expect(fileSchema.length, equals(512));
    });
  });

  group('StreamMultipartFileSchema Tests', () {
    test('StreamMultipartFileSchema creation with stream builder', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final fileSchema = StreamMultipartFileSchema(
        filename: 'stream.dat',
        streamBuilder: () => Stream.value(bytes),
      );

      expect(fileSchema.filename, equals('stream.dat'));
      expect(fileSchema.streamBuilder, isA<Function>());
    });

    test('StreamMultipartFileSchema stream emits data correctly', () async {
      final bytes = Uint8List.fromList([10, 20, 30, 40, 50]);
      final fileSchema = StreamMultipartFileSchema(
        filename: 'stream_test.bin',
        streamBuilder: () => Stream.value(bytes),
      );

      final stream = fileSchema.streamBuilder();
      final emittedData = await stream.first;

      expect(emittedData, equals(bytes));
      expect(fileSchema.filename, equals('stream_test.bin'));
    });

    test('StreamMultipartFileSchema with multiple chunks', () async {
      final chunk1 = Uint8List.fromList([1, 2, 3]);
      final chunk2 = Uint8List.fromList([4, 5, 6]);
      final chunk3 = Uint8List.fromList([7, 8, 9]);

      final fileSchema = StreamMultipartFileSchema(
        filename: 'chunked.dat',
        streamBuilder: () => Stream.fromIterable([chunk1, chunk2, chunk3]),
      );

      final stream = fileSchema.streamBuilder();
      final allChunks = await stream.toList();

      expect(allChunks.length, equals(3));
      expect(allChunks[0], equals(chunk1));
      expect(allChunks[1], equals(chunk2));
      expect(allChunks[2], equals(chunk3));
      expect(fileSchema.filename, equals('chunked.dat'));
    });

    test('StreamMultipartFileSchema can be called multiple times', () async {
      final bytes = Uint8List.fromList([100, 101, 102]);
      final fileSchema = StreamMultipartFileSchema(
        filename: 'reusable.dat',
        streamBuilder: () => Stream.value(bytes),
      );

      // Call stream builder multiple times
      final stream1 = fileSchema.streamBuilder();
      final data1 = await stream1.first;

      final stream2 = fileSchema.streamBuilder();
      final data2 = await stream2.first;

      expect(data1, equals(bytes));
      expect(data2, equals(bytes));
    });

    test('StreamMultipartFileSchema with large data stream', () async {
      // Create chunks of 1KB each
      final chunks = List.generate(
        10,
        (i) => Uint8List.fromList(
          List.generate(1024, (j) => (i * 1024 + j) % 256),
        ),
      );

      final fileSchema = StreamMultipartFileSchema(
        filename: 'large_stream.dat',
        streamBuilder: () => Stream.fromIterable(chunks),
      );

      final stream = fileSchema.streamBuilder();
      final allChunks = await stream.toList();

      expect(allChunks.length, equals(10));
      expect(allChunks[0].length, equals(1024));
      expect(fileSchema.filename, equals('large_stream.dat'));
    });
  });

  group('RequestCommand with Multipart Files', () {
    test('RequestCommand with ByteMultipartFileSchema payload', () {
      final textBytes = Uint8List.fromList('test file content'.codeUnits);
      final fileSchema = ByteMultipartFileSchema(
        filename: 'document.txt',
        data: textBytes,
      );

      final request = ByteFileUploadRequest(
        file: fileSchema,
        additionalField: 'metadata',
      );

      expect(request.payload, isA<FormDataRequestSchema>());
      final payload =
          (request.payload as FormDataRequestSchema).toFormDataMapPayload();
      expect(payload['file'], equals(fileSchema));
      expect(payload['additionalField'], equals('metadata'));
    });

    test('RequestCommand with FileMultipartFileSchema payload', () {
      const fileSchema = FileMultipartFileSchema(
        filename: 'video.mp4',
        filePath: '/path/to/video.mp4',
        length: 1024000,
      );

      const requestSchema = PathFileUploadRequestSchema(
        file: fileSchema,
        description: 'Video upload',
      );

      final request = PathFileUploadRequest(
        payload: requestSchema,
      );

      expect(request.payload, isA<FormDataRequestSchema>());
      final payload =
          (request.payload as FormDataRequestSchema).toFormDataMapPayload();
      expect(payload['file'], equals(fileSchema));
      expect(payload['description'], equals('Video upload'));
    });

    test('RequestCommand with StreamMultipartFileSchema payload', () {
      final bytes = Uint8List.fromList('stream content'.codeUnits);
      final fileSchema = StreamMultipartFileSchema(
        filename: 'stream.dat',
        streamBuilder: () => Stream.value(bytes),
      );

      final request = StreamFileUploadRequest(
        file: fileSchema,
        uploadId: 'upload-123',
      );

      expect(request.payload, isA<FormDataRequestSchema>());
      final payload =
          (request.payload as FormDataRequestSchema).toFormDataMapPayload();
      expect(payload['file'], equals(fileSchema));
      expect(payload['uploadId'], equals('upload-123'));
    });

    test('Multiple files of different types in form data payload', () {
      final byteFile = ByteMultipartFileSchema(
        filename: 'byte_file.txt',
        data: Uint8List.fromList('byte content'.codeUnits),
      );
      const pathFile = FileMultipartFileSchema(
        filename: 'path_file.pdf',
        filePath: '/path/to/file.pdf',
        length: 2048,
      );
      final streamFile = StreamMultipartFileSchema(
        filename: 'stream_file.dat',
        streamBuilder: () => Stream.value(Uint8List.fromList([1, 2, 3])),
      );

      final request = MixedFilesUploadRequest(
        files: [byteFile, pathFile, streamFile],
        description: 'Mixed files upload',
      );

      expect(request.payload, isA<FormDataRequestSchema>());
      final payload =
          (request.payload as FormDataRequestSchema).toFormDataMapPayload();

      expect(payload['files'], isA<List<MultipartFileSchema>>());
      expect((payload['files'] as List<MultipartFileSchema>).length, equals(3));
      expect(payload['description'], equals('Mixed files upload'));

      final files = payload['files'] as List<MultipartFileSchema>;
      expect(files[0], isA<ByteMultipartFileSchema>());
      expect(files[1], isA<FileMultipartFileSchema>());
      expect(files[2], isA<StreamMultipartFileSchema>());
    });

    test('Form data with mixed content types and ByteMultipartFileSchema', () {
      final fileBytes = Uint8List.fromList('document.pdf content'.codeUnits);
      final fileSchema = ByteMultipartFileSchema(
        filename: 'document.pdf',
        data: fileBytes,
      );

      final request = MixedContentRequest(
        file: fileSchema,
        textField: 'Some text',
        numberField: 42,
        boolField: true,
      );

      expect(request.payload, isA<FormDataRequestSchema>());

      final payload =
          (request.payload as FormDataRequestSchema).toFormDataMapPayload();
      expect(payload['file'], equals(fileSchema));
      expect(payload['textField'], equals('Some text'));
      expect(payload['numberField'], equals(42));
      expect(payload['boolField'], equals(true));
    });
  });

  group('Sealed Class Hierarchy', () {
    test('MultipartFileSchema is sealed', () {
      final byteFile = ByteMultipartFileSchema(
        filename: 'test.bin',
        data: Uint8List.fromList([1, 2, 3]),
      );
      const pathFile = FileMultipartFileSchema(
        filename: 'test.pdf',
        filePath: '/test.pdf',
        length: 1024,
      );
      final streamFile = StreamMultipartFileSchema(
        filename: 'test.dat',
        streamBuilder: () => Stream.value(Uint8List.fromList([4, 5, 6])),
      );

      // All should be instances of MultipartFileSchema
      expect(byteFile, isA<MultipartFileSchema>());
      expect(pathFile, isA<MultipartFileSchema>());
      expect(streamFile, isA<MultipartFileSchema>());

      // But each should be their specific type
      expect(byteFile, isA<ByteMultipartFileSchema>());
      expect(pathFile, isA<FileMultipartFileSchema>());
      expect(streamFile, isA<StreamMultipartFileSchema>());
    });

    test('Pattern matching on MultipartFileSchema', () {
      final files = <MultipartFileSchema>[
        ByteMultipartFileSchema(
          filename: 'byte.bin',
          data: Uint8List.fromList([1, 2]),
        ),
        const FileMultipartFileSchema(
          filename: 'path.pdf',
          filePath: '/path.pdf',
          length: 512,
        ),
        StreamMultipartFileSchema(
          filename: 'stream.dat',
          streamBuilder: () => Stream.value(Uint8List.fromList([3, 4])),
        ),
      ];

      var byteCount = 0;
      var pathCount = 0;
      var streamCount = 0;

      for (final file in files) {
        switch (file) {
          case ByteMultipartFileSchema():
            byteCount++;
          case FileMultipartFileSchema():
            pathCount++;
          case StreamMultipartFileSchema():
            streamCount++;
        }
      }

      expect(byteCount, equals(1));
      expect(pathCount, equals(1));
      expect(streamCount, equals(1));
    });
  });
}

// Test request classes for multipart file uploads

class ByteFileUploadRequestSchema extends FormDataRequestSchema {
  const ByteFileUploadRequestSchema({
    required this.file,
    required this.additionalField,
  });

  final ByteMultipartFileSchema file;
  final String additionalField;

  @override
  Map<String, dynamic> toFormDataMapPayload() {
    return {
      'file': file,
      'additionalField': additionalField,
    };
  }
}

class ByteFileUploadRequest extends RequestCommand<ResponseTest1> {
  ByteFileUploadRequest({
    required ByteMultipartFileSchema file,
    required String additionalField,
  }) : _schema = ByteFileUploadRequestSchema(
          file: file,
          additionalField: additionalField,
        );

  final ByteFileUploadRequestSchema _schema;

  @override
  String get path => '/upload-byte';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<ResponseTest1> get defaultResponseFactory =>
      ResponseTest1Factory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class PathFileUploadRequest extends RequestCommand<ResponseTest1> {
  PathFileUploadRequest({
    required this.payload,
  });

  @override
  final RequestSchema payload;

  @override
  String get path => '/upload-path';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  SchemaFactory<ResponseTest1> get defaultResponseFactory =>
      ResponseTest1Factory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class PathFileUploadRequestSchema extends FormDataRequestSchema {
  const PathFileUploadRequestSchema({
    required this.file,
    required this.description,
  });

  final FileMultipartFileSchema file;
  final String description;

  @override
  Map<String, dynamic> toFormDataMapPayload() {
    return {
      'file': file,
      'description': description,
    };
  }
}

class StreamFileUploadRequestSchema extends FormDataRequestSchema {
  const StreamFileUploadRequestSchema({
    required this.file,
    required this.uploadId,
  });

  final StreamMultipartFileSchema file;
  final String uploadId;

  @override
  Map<String, dynamic> toFormDataMapPayload() {
    return {
      'file': file,
      'uploadId': uploadId,
    };
  }
}

class StreamFileUploadRequest extends RequestCommand<ResponseTest1> {
  StreamFileUploadRequest({
    required StreamMultipartFileSchema file,
    required String uploadId,
  }) : _schema = StreamFileUploadRequestSchema(
          file: file,
          uploadId: uploadId,
        );

  final StreamFileUploadRequestSchema _schema;

  @override
  String get path => '/upload-stream';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<ResponseTest1> get defaultResponseFactory =>
      ResponseTest1Factory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class MixedFilesUploadRequestSchema extends FormDataRequestSchema {
  const MixedFilesUploadRequestSchema({
    required this.files,
    required this.description,
  });

  final List<MultipartFileSchema> files;
  final String description;

  @override
  Map<String, dynamic> toFormDataMapPayload() {
    return {
      'files': files,
      'description': description,
    };
  }
}

class MixedFilesUploadRequest extends RequestCommand<ResponseTest1> {
  MixedFilesUploadRequest({
    required List<MultipartFileSchema> files,
    required String description,
  }) : _schema = MixedFilesUploadRequestSchema(
          files: files,
          description: description,
        );

  final MixedFilesUploadRequestSchema _schema;

  @override
  String get path => '/upload-mixed';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<ResponseTest1> get defaultResponseFactory =>
      ResponseTest1Factory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class MixedContentRequestSchema extends FormDataRequestSchema {
  const MixedContentRequestSchema({
    required this.file,
    required this.textField,
    required this.numberField,
    required this.boolField,
  });

  final MultipartFileSchema file;
  final String textField;
  final int numberField;
  final bool boolField;

  @override
  Map<String, dynamic> toFormDataMapPayload() {
    return {
      'file': file,
      'textField': textField,
      'numberField': numberField,
      'boolField': boolField,
    };
  }
}

class MixedContentRequest extends RequestCommand<ResponseTest1> {
  MixedContentRequest({
    required MultipartFileSchema file,
    required String textField,
    required int numberField,
    required bool boolField,
  }) : _schema = MixedContentRequestSchema(
          file: file,
          textField: textField,
          numberField: numberField,
          boolField: boolField,
        );

  final MixedContentRequestSchema _schema;

  @override
  String get path => '/mixed-upload';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<ResponseTest1> get defaultResponseFactory =>
      ResponseTest1Factory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}
