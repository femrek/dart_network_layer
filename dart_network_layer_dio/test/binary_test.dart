import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'data/request/request_test_binary.dart';
import 'data/test_paths.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns a list of bytes that represent a small fake PNG (8-byte signature).
final _fakePngBytes = Uint8List.fromList(
  [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
);

/// Simple binary payload (32 bytes of incrementing values).
final _genericBinaryBytes =
    Uint8List.fromList(List<int>.generate(32, (i) => i));

Future<Uint8List> _collectStreamBytes(Stream<Uint8List> stream) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in stream) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}

// ---------------------------------------------------------------------------
// BinarySchema unit tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  // BinarySchema – unit tests (no network)
  // =========================================================================
  group('BinarySchema unit tests', () {
    group('InMemoryBinarySchema', () {
      test('stores bytes correctly', () {
        final schema = InMemoryBinarySchema(bytes: _fakePngBytes);
        expect(schema.bytes, equals(_fakePngBytes));
      });

      test('two instances with identical bytes are value-equal in bytes', () {
        final a = InMemoryBinarySchema(bytes: Uint8List.fromList([1, 2, 3]));
        final b = InMemoryBinarySchema(bytes: Uint8List.fromList([1, 2, 3]));
        expect(a.bytes, equals(b.bytes));
      });

      test('factory builds from Uint8List', () {
        const factory = BinarySchemaFactory<InMemoryBinarySchema>(
          binaryResponseType: InMemoryBinaryResponse(),
        );
        final schema = factory.fromBytes(_fakePngBytes);
        expect(schema, isA<InMemoryBinarySchema>());
        expect(schema.bytes, equals(_fakePngBytes));
      });

      test('factory builds from List<int>', () {
        const factory = BinarySchemaFactory<InMemoryBinarySchema>(
          binaryResponseType: InMemoryBinaryResponse(),
        );
        final schema = factory.fromBytes([0x01, 0x02, 0x03]);
        expect(schema, isA<InMemoryBinarySchema>());
        expect(schema.bytes, hasLength(3));
      });

      test('factory throws on invalid type', () {
        const factory = BinarySchemaFactory<InMemoryBinarySchema>(
          binaryResponseType: InMemoryBinaryResponse(),
        );
        expect(
          () => factory.fromBytes('not bytes'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('empty bytes are stored correctly', () {
        final schema = InMemoryBinarySchema(bytes: Uint8List(0));
        expect(schema.bytes, isEmpty);
      });

      test('is a BinarySchema', () {
        final schema = InMemoryBinarySchema(bytes: _fakePngBytes);
        expect(schema, isA<BinarySchema>());
        expect(schema, isA<Schema>());
      });
    });

    group('FileBinarySchema', () {
      test('stores filePath correctly', () {
        const schema = FileBinarySchema(filePath: '/tmp/output.bin');
        expect(schema.filePath, '/tmp/output.bin');
      });

      test('factory builds from path string', () {
        const factory = BinarySchemaFactory<FileBinarySchema>(
          binaryResponseType: FileBinaryResponse('/tmp/test.bin'),
        );
        final schema = factory.fromFilePath('/tmp/test.bin');
        expect(schema, isA<FileBinarySchema>());
        expect(schema.filePath, '/tmp/test.bin');
      });

      test('is a BinarySchema', () {
        const schema = FileBinarySchema(filePath: '/tmp/file.bin');
        expect(schema, isA<BinarySchema>());
        expect(schema, isA<Schema>());
      });
    });

    group('StreamBinarySchema', () {
      test('stores stream correctly', () async {
        final schema = StreamBinarySchema(
          stream: Stream<Uint8List>.value(_fakePngBytes),
        );
        final data = await _collectStreamBytes(schema.stream);
        expect(data, equals(_fakePngBytes));
      });

      test('factory builds from Stream<Uint8List>', () {
        final stream = Stream<Uint8List>.value(_genericBinaryBytes);
        const factory = BinarySchemaFactory<StreamBinarySchema>(
          binaryResponseType: StreamBinaryResponse(),
        );
        final schema = factory.from(stream);
        expect(schema, isA<StreamBinarySchema>());
      });

      test('factory throws on invalid type', () {
        const factory = BinarySchemaFactory<StreamBinarySchema>(
          binaryResponseType: StreamBinaryResponse(),
        );
        expect(
          () => factory.from(_genericBinaryBytes),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('RawStringBinarySchema', () {
      test('stores raw string data correctly', () {
        const schema = RawStringBinarySchema(data: 'aGVsbG8=');
        expect(schema.data, 'aGVsbG8=');
      });

      test('factory builds from string', () {
        const factory = BinarySchemaFactory<RawStringBinarySchema>(
          binaryResponseType: RawStringBinaryResponse('raw'),
        );
        final schema = factory.fromString('hello');
        expect(schema, isA<RawStringBinarySchema>());
        expect(schema.data, 'hello');
      });

      test('is a BinarySchema', () {
        const schema = RawStringBinarySchema(data: 'data');
        expect(schema, isA<BinarySchema>());
        expect(schema, isA<Schema>());
      });
    });

    group('BinaryResponseType', () {
      test('InMemoryBinaryResponse is a BinaryResponseType', () {
        const t = InMemoryBinaryResponse();
        expect(t, isA<BinaryResponseType>());
      });

      test('FileBinaryResponse stores savePath', () {
        const t = FileBinaryResponse('/tmp/download.bin');
        expect(t, isA<BinaryResponseType>());
        expect(t.savePath, '/tmp/download.bin');
      });

      test('different FileBinaryResponse instances hold their own path', () {
        const a = FileBinaryResponse('/path/a');
        const b = FileBinaryResponse('/path/b');
        expect(a.savePath, isNot(equals(b.savePath)));
      });
    });
  });

  // =========================================================================
  // In-memory binary – integration tests
  // =========================================================================
  group('DioNetworkInvoker – InMemoryBinaryResponse', () {
    test('returns InMemoryBinarySchema with correct bytes on success',
        () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryInMemory],
          ),
          handler: (request) async {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(_fakePngBytes);
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await invoker.request(RequestTestInMemoryBinary());

      switch (result) {
        case SuccessResponseResult(:final data):
          expect(data, isA<InMemoryBinarySchema>());
          expect(data.bytes, equals(_fakePngBytes));
        case SpecifiedResponseResult():
          fail('Expected SuccessResponseResult, got SpecifiedResponseResult '
              'with status ${result.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected SuccessResponseResult, got error: ${error.message}\n'
              '${error.stackTrace}');
      }

      await server.close();
    });

    test('returns InMemoryBinarySchema with generic binary payload', () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryInMemory],
          ),
          handler: (request) async {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(_genericBinaryBytes);
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await invoker.request(RequestTestInMemoryBinary());

      switch (result) {
        case SuccessResponseResult(:final data):
          expect(data.bytes, hasLength(_genericBinaryBytes.length));
          expect(data.bytes, equals(_genericBinaryBytes));
        case SpecifiedResponseResult():
          fail('Expected SuccessResponseResult, got SpecifiedResponseResult '
              'with status ${result.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected SuccessResponseResult, got error: ${error.message}\n'
              '${error.stackTrace}');
      }

      await server.close();
    });

    test('returns InMemoryBinarySchema with empty body', () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryInMemory],
          ),
          handler: (request) async {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary;
            // no body written → empty bytes
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await invoker.request(RequestTestInMemoryBinary());

      switch (result) {
        case SuccessResponseResult(:final data):
          expect(data, isA<InMemoryBinarySchema>());
          expect(data.bytes, isEmpty);
        case SpecifiedResponseResult():
          fail('Expected SuccessResponseResult, got SpecifiedResponseResult '
              'with status ${result.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected SuccessResponseResult, got error: ${error.message}\n'
              '${error.stackTrace}');
      }

      await server.close();
    });

    test('result has correct HTTP status code (200)', () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryInMemory],
          ),
          handler: (request) async {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(_fakePngBytes);
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await invoker.request(RequestTestInMemoryBinary());

      expect(result, isA<SuccessResponseResult<InMemoryBinarySchema>>());
      expect(
        (result as SuccessResponseResult<InMemoryBinarySchema>).statusCode,
        HttpStatus.ok,
      );

      await server.close();
    });

    test('returns NetworkErrorResult when server is unreachable', () async {
      final invoker = DioNetworkInvoker.fromBaseUrl('http://localhost:19999');

      final result = await invoker.request(RequestTestInMemoryBinary());

      expect(result, isA<NetworkErrorResult<InMemoryBinarySchema>>());
    });

    test('receive-progress callbacks are fired during binary download',
        () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryInMemory],
          ),
          handler: (request) async {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(Uint8List(1024)); // 1 KB of zeros
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final snapshots = <AggregatedRequestState>[];
      invoker.onUpdateRequestProgress = snapshots.add;

      await invoker.request(RequestTestInMemoryBinary());

      expect(
        snapshots,
        isNotEmpty,
        reason: 'Receive-progress callbacks should have fired',
      );

      await server.close();
    });

    test(
        'cancel during in-memory binary download returns RequestCancelledError',
        () async {
      final completer = Completer<void>();

      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryInMemory],
          ),
          handler: (request) async {
            await completer.future.timeout(
              const Duration(seconds: 5),
              onTimeout: () {},
            );
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(_fakePngBytes);
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final request = RequestTestInMemoryBinary();
      final future = invoker.request(request);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      invoker.cancelRequest(request);

      final result = await future;

      expect(result, isA<NetworkErrorResult<InMemoryBinarySchema>>());
      expect(
        (result as NetworkErrorResult<InMemoryBinarySchema>).error,
        isA<RequestCancelledError>(),
      );

      completer.complete();
      await server.close();
    });
  });

  // =========================================================================
  // File download binary – integration tests
  // =========================================================================
  group('DioNetworkInvoker – FileBinaryResponse', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('binary_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) await tempDir.delete(recursive: true);
    });

    test('downloads response bytes and saves them to the given file path',
        () async {
      final savePath = '${tempDir.path}/download.bin';

      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryFile],
          ),
          handler: (request) async {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(_fakePngBytes);
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result =
          await invoker.request(RequestTestFileBinary(savePath: savePath));

      switch (result) {
        case SuccessResponseResult(:final data):
          expect(data, isA<FileBinarySchema>());
          expect(data.filePath, savePath);
          // Verify the file was actually written to disk.
          final file = File(savePath);
          expect(file.existsSync(), isTrue);
          expect(file.readAsBytesSync(), equals(_fakePngBytes));
        case SpecifiedResponseResult():
          fail('Expected SuccessResponseResult, got SpecifiedResponseResult '
              'with status ${result.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected SuccessResponseResult, got error: ${error.message}\n'
              '${error.stackTrace}');
      }

      await server.close();
    });

    test('FileBinarySchema carries the correct filePath', () async {
      final savePath = '${tempDir.path}/output.dat';

      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryFile],
          ),
          handler: (request) async {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(_genericBinaryBytes);
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result =
          await invoker.request(RequestTestFileBinary(savePath: savePath));

      expect(
        result,
        isA<SuccessResponseResult<FileBinarySchema>>(),
      );
      expect(
        (result as SuccessResponseResult<FileBinarySchema>).data.filePath,
        equals(savePath),
      );

      await server.close();
    });

    test('result has correct HTTP status code (200) for file download',
        () async {
      final savePath = '${tempDir.path}/status.bin';

      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryFile],
          ),
          handler: (request) async {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(_fakePngBytes);
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result =
          await invoker.request(RequestTestFileBinary(savePath: savePath));

      expect(result, isA<SuccessResponseResult<FileBinarySchema>>());
      expect(
        (result as SuccessResponseResult<FileBinarySchema>).statusCode,
        HttpStatus.ok,
      );

      await server.close();
    });

    test('returns NetworkErrorResult when server is unreachable', () async {
      final savePath = '${tempDir.path}/unreachable.bin';
      final invoker = DioNetworkInvoker.fromBaseUrl('http://localhost:19998');

      final result =
          await invoker.request(RequestTestFileBinary(savePath: savePath));

      expect(result, isA<NetworkErrorResult<FileBinarySchema>>());
    });

    test('downloads large binary payload to file correctly', () async {
      final largeBytes = Uint8List(64 * 1024); // 64 KB
      for (var i = 0; i < largeBytes.length; i++) {
        largeBytes[i] = i % 256;
      }
      final savePath = '${tempDir.path}/large.bin';

      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryFile],
          ),
          handler: (request) async {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(largeBytes);
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result =
          await invoker.request(RequestTestFileBinary(savePath: savePath));

      switch (result) {
        case SuccessResponseResult(:final data):
          final written = File(data.filePath).readAsBytesSync();
          expect(written, hasLength(largeBytes.length));
          expect(written, equals(largeBytes));
        case SpecifiedResponseResult():
          fail('Expected SuccessResponseResult, got SpecifiedResponseResult '
              'with status ${result.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected SuccessResponseResult, got error: ${error.message}\n'
              '${error.stackTrace}');
      }

      await server.close();
    });

    test('cancel during file download returns RequestCancelledError', () async {
      final completer = Completer<void>();
      final savePath = '${tempDir.path}/cancelled.bin';

      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryFile],
          ),
          handler: (request) async {
            await completer.future.timeout(
              const Duration(seconds: 5),
              onTimeout: () {},
            );
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(_fakePngBytes);
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final request = RequestTestFileBinary(savePath: savePath);
      final future = invoker.request(request);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      invoker.cancelRequest(request);

      final result = await future;

      expect(result, isA<NetworkErrorResult<FileBinarySchema>>());
      expect(
        (result as NetworkErrorResult<FileBinarySchema>).error,
        isA<RequestCancelledError>(),
      );

      completer.complete();
      await server.close();
    });
  });

  // =========================================================================
  // Stream binary – integration tests
  // =========================================================================
  group('DioNetworkInvoker – StreamBinaryResponse', () {
    test('returns StreamBinarySchema and yields all response bytes', () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryStream],
          ),
          handler: (request) async {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(_fakePngBytes.sublist(0, 4))
              ..add(_fakePngBytes.sublist(4));
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await invoker.request(RequestTestStreamBinary());

      switch (result) {
        case SuccessResponseResult(:final data):
          expect(data, isA<StreamBinarySchema>());
          final allBytes = await _collectStreamBytes(data.stream);
          expect(allBytes, equals(_fakePngBytes));
        case SpecifiedResponseResult():
          fail('Expected SuccessResponseResult, got SpecifiedResponseResult '
              'with status ${result.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected SuccessResponseResult, got error: ${error.message}\n'
              '${error.stackTrace}');
      }

      await server.close();
    });

    test('result has correct HTTP status code (200) for stream response',
        () async {
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryStream],
          ),
          handler: (request) async {
            request.response
              ..statusCode = HttpStatus.ok
              ..headers.contentType = ContentType.binary
              ..add(_genericBinaryBytes);
            return request.response;
          },
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await invoker.request(RequestTestStreamBinary());

      expect(result, isA<SuccessResponseResult<StreamBinarySchema>>());
      expect(
        (result as SuccessResponseResult<StreamBinarySchema>).statusCode,
        HttpStatus.ok,
      );

      await server.close();
    });
  });

  // =========================================================================
  // Raw string binary – integration tests
  // =========================================================================
  group('DioNetworkInvoker – RawStringBinaryResponse', () {
    test('returns RawStringBinarySchema with raw string payload', () async {
      const rawPayload = 'PNG_SIGNATURE';
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryRawString],
          ),
          handler: (request) async => rawPayload,
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await invoker.request(RequestTestRawStringBinary());

      switch (result) {
        case SuccessResponseResult(:final data):
          expect(data, isA<RawStringBinarySchema>());
          expect(data.data, rawPayload);
        case SpecifiedResponseResult():
          fail('Expected SuccessResponseResult, got SpecifiedResponseResult '
              'with status ${result.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected SuccessResponseResult, got error: ${error.message}\n'
              '${error.stackTrace}');
      }

      await server.close();
    });

    test('returns RawStringBinarySchema with empty string body', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(
            paths: [TestPaths.testBinaryRawString],
          ),
          handler: (request) async => '',
        ),
      ]);

      final invoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await invoker.request(RequestTestRawStringBinary());

      expect(result, isA<SuccessResponseResult<RawStringBinarySchema>>());
      expect(
        (result as SuccessResponseResult<RawStringBinarySchema>).data.data,
        isEmpty,
      );

      await server.close();
    });
  });

  // =========================================================================
  // RequestCommand configuration tests
  // =========================================================================
  group('RequestTestInMemoryBinary command configuration', () {
    test('default binaryResponseType is InMemoryBinaryResponse', () {
      final cmd = RequestTestInMemoryBinary();
      expect(cmd.binaryResponseType, isA<InMemoryBinaryResponse>());
    });

    test('path is set to testBinaryInMemory by default', () {
      final cmd = RequestTestInMemoryBinary();
      expect(cmd.path, TestPaths.testBinaryInMemory);
    });

    test('custom path overrides default', () {
      final cmd = RequestTestInMemoryBinary(path: '/custom/path');
      expect(cmd.path, '/custom/path');
    });

    test('defaultResponseFactory is InMemoryBinarySchemaFactory', () {
      final cmd = RequestTestInMemoryBinary();
      expect(cmd.defaultResponseFactory,
          isA<BinarySchemaFactory<InMemoryBinarySchema>>());
    });

    test('defaultErrorResponseFactory is IgnoredSchema factory', () {
      final cmd = RequestTestInMemoryBinary();
      expect(cmd.defaultErrorResponseFactory, isA<StringSchemaFactory>());
    });
  });

  group('RequestTestFileBinary command configuration', () {
    test('binaryResponseType is FileBinaryResponse with correct savePath', () {
      final cmd = RequestTestFileBinary(savePath: '/tmp/file.bin');
      expect(cmd.binaryResponseType, isA<FileBinaryResponse>());
      expect(
        (cmd.binaryResponseType as FileBinaryResponse).savePath,
        '/tmp/file.bin',
      );
    });

    test('path is set to testBinaryFile', () {
      final cmd = RequestTestFileBinary(savePath: '/tmp/x.bin');
      expect(cmd.path, TestPaths.testBinaryFile);
    });

    test('defaultResponseFactory is FileBinarySchemaFactory', () {
      final cmd = RequestTestFileBinary(savePath: '/tmp/x.bin');
      expect(cmd.defaultResponseFactory,
          isA<BinarySchemaFactory<FileBinarySchema>>());
    });
  });

  group('RequestTestStreamBinary command configuration', () {
    test('default binaryResponseType is StreamBinaryResponse', () {
      final cmd = RequestTestStreamBinary();
      expect(cmd.binaryResponseType, isA<StreamBinaryResponse>());
    });

    test('defaultResponseFactory is StreamBinarySchemaFactory', () {
      final cmd = RequestTestStreamBinary();
      expect(cmd.defaultResponseFactory,
          isA<BinarySchemaFactory<StreamBinarySchema>>());
    });
  });

  group('RequestTestRawStringBinary command configuration', () {
    test('default binaryResponseType is RawStringBinaryResponse', () {
      final cmd = RequestTestRawStringBinary();
      expect(cmd.binaryResponseType, isA<RawStringBinaryResponse>());
    });

    test('defaultResponseFactory is RawStringBinarySchemaFactory', () {
      final cmd = RequestTestRawStringBinary();
      expect(cmd.defaultResponseFactory,
          isA<BinarySchemaFactory<RawStringBinarySchema>>());
    });
  });
}
