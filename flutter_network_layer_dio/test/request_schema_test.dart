import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart' show ListFormat, ListParam;
import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'data/response/response_test_user.dart';
import 'data/test_paths.dart';

void main() {
  group('DioNetworkInvoker - Request Schema Tests', () {
    late TestServer server;
    late DioNetworkInvoker networkInvoker;

    tearDown(() async {
      await server.close();
    });

    group('JsonRequestSchema', () {
      test('POST request with JSON payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/users'],
              method: 'POST',
            ),
            handler: (request) async => '{"id": "123", "success": true}',
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final request = CreateUserRequest(
          name: 'John Doe',
          email: 'john@example.com',
          age: 30,
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<JsonResponse>>());
        if (response is SuccessResponseResult<JsonResponse>) {
          expect(response.data.id, '123');
          expect(response.data.success, true);
          expect(response.statusCode, 200);
        }
      });

      test('PUT request with JSON payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/users/123'],
              method: 'PUT',
            ),
            handler: (request) async => '{"id": "123", "success": true}',
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final request = UpdateUserRequest(
          userId: '123',
          name: 'Jane Doe',
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<JsonResponse>>());
        if (response is SuccessResponseResult<JsonResponse>) {
          expect(response.data.id, '123');
          expect(response.data.success, true);
        }
      });
    });

    group('FormDataRequestSchema', () {
      test('POST request with form data (text fields only)', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/upload'],
              method: 'POST',
            ),
            handler: (request) async => '{"id": "upload-123", "success": true}',
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final request = FormDataTextRequest(
          title: 'Test Upload',
          description: 'This is a test',
          category: 'general',
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<JsonResponse>>());
        if (response is SuccessResponseResult<JsonResponse>) {
          expect(response.data.id, 'upload-123');
          expect(response.data.success, true);
        }
      });

      test(
          'POST request with form data including file'
          ' (ByteMultipartFileSchema)', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/upload-file'],
              method: 'POST',
            ),
            handler: (request) async {
              return '{"id": "file-456", "success": true}';
            },
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final fileBytes = Uint8List.fromList('Hello, World!'.codeUnits);
        final request = FormDataFileRequest(
          file: ByteMultipartFileSchema(
            filename: 'test.txt',
            data: fileBytes,
            contentType: 'text/plain',
          ),
          description: 'Test file upload',
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<JsonResponse>>());
        if (response is SuccessResponseResult<JsonResponse>) {
          expect(response.data.id, 'file-456');
          expect(response.data.success, true);
        }
      });

      test('POST request with multiple files (List<MultipartFileSchema>)',
          () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/upload-multiple'],
              method: 'POST',
            ),
            handler: (request) async {
              return '{"id": "multi-789", "success": true, "count": 3}';
            },
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final files = [
          ByteMultipartFileSchema(
            filename: 'file1.txt',
            data: Uint8List.fromList('File 1'.codeUnits),
          ),
          ByteMultipartFileSchema(
            filename: 'file2.txt',
            data: Uint8List.fromList('File 2'.codeUnits),
          ),
          ByteMultipartFileSchema(
            filename: 'file3.txt',
            data: Uint8List.fromList('File 3'.codeUnits),
          ),
        ];

        final request = FormDataMultipleFilesRequest(
          files: files,
          description: 'Multiple files upload',
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<JsonResponseWithCount>>());
        if (response is SuccessResponseResult<JsonResponseWithCount>) {
          expect(response.data.id, 'multi-789');
          expect(response.data.success, true);
          expect(response.data.count, 3);
        }
      });
    });

    group('StringRequestSchema', () {
      test('POST request with plain text payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/text'],
              method: 'POST',
            ),
            handler: (request) async => 'Text received successfully',
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final request = PlainTextRequest(
          text: 'This is a plain text message',
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<StringResponse>>());
        if (response is SuccessResponseResult<StringResponse>) {
          expect(response.data.message, 'Text received successfully');
        }
      });

      test('POST request with XML payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/xml'],
              method: 'POST',
            ),
            handler: (request) async => 'XML processed',
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        const xmlData = '<?xml version="1.0"?><root><item>test</item></root>';
        final request = XmlRequest(xml: xmlData);

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<StringResponse>>());
        if (response is SuccessResponseResult<StringResponse>) {
          expect(response.data.message, 'XML processed');
        }
      });
    });

    group('BinaryRequestSchema', () {
      test('POST request with binary data payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/binary'],
              method: 'POST',
            ),
            handler: (request) async {
              return '{"id": "binary-001", "success": true}';
            },
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final binaryData = Uint8List.fromList([
          0x89,
          0x50,
          0x4E,
          0x47,
          0x0D,
          0x0A,
          0x1A,
          0x0A, // PNG header
        ]);

        final request = BinaryDataRequest(data: binaryData);

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<JsonResponse>>());
        if (response is SuccessResponseResult<JsonResponse>) {
          expect(response.data.id, 'binary-001');
          expect(response.data.success, true);
        }
      });

      test('POST request with image bytes', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/image'],
              method: 'POST',
            ),
            handler: (request) async {
              return '{"id": "img-002", "success": true}';
            },
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        // Simulate image bytes
        final imageBytes = Uint8List.fromList(
          List.generate(100, (i) => i % 256),
        );

        final request = ImageUploadRequest(imageBytes: imageBytes);

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<JsonResponse>>());
      });
    });

    group('StreamRequestSchema', () {
      test('POST request with stream payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/stream'],
              method: 'POST',
            ),
            handler: (request) async {
              await request.drain<dynamic>();
              return '{"id": "stream-001", "success": true}';
            },
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        // Create a stream of data
        final dataChunks = [
          [1, 2, 3, 4, 5],
          [6, 7, 8, 9, 10],
          [11, 12, 13, 14, 15],
        ];

        final request = StreamDataRequest(
          dataStream: Stream.fromIterable(dataChunks),
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<JsonResponse>>());
        if (response is SuccessResponseResult<JsonResponse>) {
          expect(response.data.id, 'stream-001');
          expect(response.data.success, true);
        }
      });

      test('POST request with large stream payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/large-stream'],
              method: 'POST',
            ),
            handler: (request) async {
              return '{"id": "large-stream-002", "success": true}';
            },
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        // Create a large stream
        Stream<List<int>> largeStream() async* {
          for (var i = 0; i < 10; i++) {
            yield List.generate(1024, (index) => index % 256);
          }
        }

        final request = LargeStreamRequest(
          dataStream: largeStream(),
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<JsonResponse>>());
      });
    });

    group('DynamicRequestSchema', () {
      test('POST request with dynamic JSON payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/dynamic'],
              method: 'POST',
            ),
            handler: (request) async {
              return '{"id": "dynamic-001", "success": true}';
            },
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final request = DynamicJsonRequest(
          payload: {
            'type': 'notification',
            'data': {'message': 'Hello', 'priority': 'high'},
            'timestamp': DateTime.now().toIso8601String(),
          },
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<JsonResponse>>());
      });

      test('POST request with dynamic list payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/dynamic-list'],
              method: 'POST',
            ),
            handler: (request) async {
              return '{"id": "list-001", "success": true}';
            },
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final request = DynamicListRequest(
          payload: [
            {'id': 1, 'name': 'Item 1'},
            {'id': 2, 'name': 'Item 2'},
            {'id': 3, 'name': 'Item 3'},
          ],
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<JsonResponse>>());
      });

      test('POST request with dynamic string payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/dynamic-string'],
              method: 'POST',
            ),
            handler: (request) async {
              return 'Dynamic string processed';
            },
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final request = DynamicStringRequest(
          payload: 'This is a dynamic string',
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<StringResponse>>());
      });
    });

    group('EmptyRequestSchema', () {
      test('GET request with no payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: [TestPaths.testUser],
              method: 'GET',
            ),
            handler: (request) async =>
                '{"id": "1", "name": "test", "age": 20}',
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final request = EmptyPayloadRequest();

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<UserResponse>>());
        if (response is SuccessResponseResult<UserResponse>) {
          expect(response.data.id, '1');
          expect(response.data.name, 'test');
          expect(response.data.age, 20);
        }
      });

      test('DELETE request with no payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/users/123'],
              method: 'DELETE',
            ),
            handler: (request) async => '{"success": true}',
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final request = DeleteUserRequest(userId: '123');

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<DeleteResponse>>());
        if (response is SuccessResponseResult<DeleteResponse>) {
          expect(response.data.success, true);
        }
      });
    });

    group('Mixed Scenarios', () {
      test('Request with headers and JSON payload', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/auth'],
              method: 'POST',
            ),
            handler: (request) async => '{"token": "abc123", "success": true}',
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final request = AuthenticatedRequest(
          username: 'testuser',
          password: 'password123',
        );

        final response = await networkInvoker.request(request);

        expect(response, isA<SuccessResponseResult<AuthResponse>>());
        if (response is SuccessResponseResult<AuthResponse>) {
          expect(response.data.token, 'abc123');
          expect(response.data.success, true);
        }
      });

      test('POST request returns non-200 status with error factory', () async {
        server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(
              paths: ['/api/validate'],
              method: 'POST',
            ),
            handler: (request) async {
              return '{"error": "Invalid data", "code": "VALIDATION_ERROR"}';
            },
            responseStatusCode: 400,
          ),
        ]);

        networkInvoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );

        final request = ValidationRequest(data: 'invalid');

        final response = await networkInvoker.request(request);

        expect(response, isA<SpecifiedResponseResult<JsonResponse>>());
        if (response is SpecifiedResponseResult<JsonResponse>) {
          expect(response.statusCode, 400);
          expect(response.data, isA<ErrorResponse>());
          final error = response.data as ErrorResponse;
          expect(error.error, 'Invalid data');
          expect(error.code, 'VALIDATION_ERROR');
        }
      });
    });
  });

  _queryParamTests();
}

// ============================================================================
// Request Schema Implementations
// ============================================================================

// JSON Request Schemas
class CreateUserSchema extends JsonRequestSchema {
  const CreateUserSchema({
    required this.name,
    required this.email,
    required this.age,
  });

  final String name;
  final String email;
  final int age;

  @override
  Map<String, dynamic> toJsonPayload() {
    return {
      'name': name,
      'email': email,
      'age': age,
    };
  }
}

class UpdateUserSchema extends JsonRequestSchema {
  const UpdateUserSchema({required this.name});

  final String name;

  @override
  Map<String, dynamic> toJsonPayload() {
    return {'name': name};
  }
}

class AuthSchema extends JsonRequestSchema {
  const AuthSchema({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;

  @override
  Map<String, dynamic> toJsonPayload() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class ValidationSchema extends JsonRequestSchema {
  const ValidationSchema({required this.data});

  final String data;

  @override
  Map<String, dynamic> toJsonPayload() {
    return {'data': data};
  }
}

// FormData Request Schemas
class FormDataTextSchema extends FormDataRequestSchema {
  const FormDataTextSchema({
    required this.title,
    required this.description,
    required this.category,
  });

  final String title;
  final String description;
  final String category;

  @override
  Map<String, dynamic> toFormDataMapPayload() {
    return {
      'title': title,
      'description': description,
      'category': category,
    };
  }
}

class FormDataFileSchema extends FormDataRequestSchema {
  const FormDataFileSchema({
    required this.file,
    required this.description,
  });

  final MultipartFileSchema file;
  final String description;

  @override
  Map<String, dynamic> toFormDataMapPayload() {
    return {
      'file': file,
      'description': description,
    };
  }
}

class FormDataMultipleFilesSchema extends FormDataRequestSchema {
  const FormDataMultipleFilesSchema({
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

// String Request Schemas
class PlainTextSchema extends StringRequestSchema {
  const PlainTextSchema({required this.text});

  final String text;

  @override
  String toStringPayload() => text;
}

class XmlSchema extends StringRequestSchema {
  const XmlSchema({required this.xml});

  final String xml;

  @override
  String toStringPayload() => xml;
}

// Binary Request Schemas
class BinaryDataSchema extends BinaryRequestSchema {
  const BinaryDataSchema({required this.data});

  final List<int> data;

  @override
  List<int> toBinaryPayload() => data;
}

class ImageUploadSchema extends BinaryRequestSchema {
  const ImageUploadSchema({required this.imageBytes});

  final List<int> imageBytes;

  @override
  List<int> toBinaryPayload() => imageBytes;
}

// Stream Request Schemas
class StreamDataSchema extends StreamRequestSchema {
  const StreamDataSchema({required this.dataStream});

  final Stream<List<int>> dataStream;

  @override
  Stream<List<int>> toStreamPayload() => dataStream;
}

class LargeStreamSchema extends StreamRequestSchema {
  const LargeStreamSchema({required this.dataStream});

  final Stream<List<int>> dataStream;

  @override
  Stream<List<int>> toStreamPayload() => dataStream;
}

// Dynamic Request Schemas
class DynamicJsonSchema extends DynamicRequestSchema {
  const DynamicJsonSchema({required this.payload});

  final Map<String, dynamic> payload;

  @override
  dynamic toPayload() => payload;
}

class DynamicListSchema extends DynamicRequestSchema {
  const DynamicListSchema({required this.payload});

  final List<Map<String, dynamic>> payload;

  @override
  dynamic toPayload() => payload;
}

class DynamicStringSchema extends DynamicRequestSchema {
  const DynamicStringSchema({required this.payload});

  final String payload;

  @override
  dynamic toPayload() => payload;
}

// ============================================================================
// Request Command Implementations
// ============================================================================

class CreateUserRequest extends RequestCommand<JsonResponse> {
  CreateUserRequest({
    required String name,
    required String email,
    required int age,
  }) : _schema = CreateUserSchema(name: name, email: email, age: age);

  final CreateUserSchema _schema;

  @override
  String get path => '/api/users';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponse> get defaultResponseFactory =>
      JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class UpdateUserRequest extends RequestCommand<JsonResponse> {
  UpdateUserRequest({
    required this.userId,
    required String name,
  }) : _schema = UpdateUserSchema(name: name);

  final String userId;
  final UpdateUserSchema _schema;

  @override
  String get path => '/api/users/$userId';

  @override
  HttpRequestMethod get method => HttpRequestMethod.put;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponse> get defaultResponseFactory =>
      JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class FormDataTextRequest extends RequestCommand<JsonResponse> {
  FormDataTextRequest({
    required String title,
    required String description,
    required String category,
  }) : _schema = FormDataTextSchema(
          title: title,
          description: description,
          category: category,
        );

  final FormDataTextSchema _schema;

  @override
  String get path => '/api/upload';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponse> get defaultResponseFactory =>
      JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class FormDataFileRequest extends RequestCommand<JsonResponse> {
  FormDataFileRequest({
    required MultipartFileSchema file,
    required String description,
  }) : _schema = FormDataFileSchema(file: file, description: description);

  final FormDataFileSchema _schema;

  @override
  String get path => '/api/upload-file';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponse> get defaultResponseFactory =>
      JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class FormDataMultipleFilesRequest
    extends RequestCommand<JsonResponseWithCount> {
  FormDataMultipleFilesRequest({
    required List<MultipartFileSchema> files,
    required String description,
  }) : _schema = FormDataMultipleFilesSchema(
          files: files,
          description: description,
        );

  final FormDataMultipleFilesSchema _schema;

  @override
  String get path => '/api/upload-multiple';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponseWithCount> get defaultResponseFactory =>
      JsonResponseWithCountFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class PlainTextRequest extends RequestCommand<StringResponse> {
  PlainTextRequest({required String text})
      : _schema = PlainTextSchema(text: text);

  final PlainTextSchema _schema;

  @override
  String get path => '/api/text';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<StringResponse> get defaultResponseFactory =>
      StringResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class XmlRequest extends RequestCommand<StringResponse> {
  XmlRequest({required String xml}) : _schema = XmlSchema(xml: xml);

  final XmlSchema _schema;

  @override
  String get path => '/api/xml';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<StringResponse> get defaultResponseFactory =>
      StringResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class BinaryDataRequest extends RequestCommand<JsonResponse> {
  BinaryDataRequest({required List<int> data})
      : _schema = BinaryDataSchema(data: data);

  final BinaryDataSchema _schema;

  @override
  String get path => '/api/binary';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponse> get defaultResponseFactory =>
      JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class ImageUploadRequest extends RequestCommand<JsonResponse> {
  ImageUploadRequest({required List<int> imageBytes})
      : _schema = ImageUploadSchema(imageBytes: imageBytes);

  final ImageUploadSchema _schema;

  @override
  String get path => '/api/image';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponse> get defaultResponseFactory =>
      JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class StreamDataRequest extends RequestCommand<JsonResponse> {
  StreamDataRequest({required Stream<List<int>> dataStream})
      : _schema = StreamDataSchema(dataStream: dataStream);

  final StreamDataSchema _schema;

  @override
  String get path => '/api/stream';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponse> get defaultResponseFactory =>
      JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class LargeStreamRequest extends RequestCommand<JsonResponse> {
  LargeStreamRequest({required Stream<List<int>> dataStream})
      : _schema = LargeStreamSchema(dataStream: dataStream);

  final LargeStreamSchema _schema;

  @override
  String get path => '/api/large-stream';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponse> get defaultResponseFactory =>
      JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class DynamicJsonRequest extends RequestCommand<JsonResponse> {
  DynamicJsonRequest({required Map<String, dynamic> payload})
      : _schema = DynamicJsonSchema(payload: payload);

  final DynamicJsonSchema _schema;

  @override
  String get path => '/api/dynamic';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponse> get defaultResponseFactory =>
      JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class DynamicListRequest extends RequestCommand<JsonResponse> {
  DynamicListRequest({required List<Map<String, dynamic>> payload})
      : _schema = DynamicListSchema(payload: payload);

  final DynamicListSchema _schema;

  @override
  String get path => '/api/dynamic-list';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponse> get defaultResponseFactory =>
      JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class DynamicStringRequest extends RequestCommand<StringResponse> {
  DynamicStringRequest({required String payload})
      : _schema = DynamicStringSchema(payload: payload);

  final DynamicStringSchema _schema;

  @override
  String get path => '/api/dynamic-string';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<StringResponse> get defaultResponseFactory =>
      StringResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class EmptyPayloadRequest extends RequestCommand<UserResponse> {
  @override
  String get path => TestPaths.testUser;

  @override
  HttpRequestMethod get method => HttpRequestMethod.get;

  @override
  RequestSchema get payload => const EmptyRequestSchema();

  @override
  SchemaFactory<UserResponse> get defaultResponseFactory =>
      UserResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class DeleteUserRequest extends RequestCommand<DeleteResponse> {
  DeleteUserRequest({required this.userId});

  final String userId;

  @override
  String get path => '/api/users/$userId';

  @override
  HttpRequestMethod get method => HttpRequestMethod.delete;

  @override
  RequestSchema get payload => const EmptyRequestSchema();

  @override
  SchemaFactory<DeleteResponse> get defaultResponseFactory =>
      DeleteResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class AuthenticatedRequest extends RequestCommand<AuthResponse> {
  AuthenticatedRequest({
    required String username,
    required String password,
  }) : _schema = AuthSchema(username: username, password: password);

  final AuthSchema _schema;

  @override
  String get path => '/api/auth';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  Map<String, dynamic> get headers => {
        'Authorization': 'Bearer test-token',
        'X-API-Key': 'test-api-key',
      };

  @override
  SchemaFactory<AuthResponse> get defaultResponseFactory =>
      AuthResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class ValidationRequest extends RequestCommand<JsonResponse> {
  ValidationRequest({required String data})
      : _schema = ValidationSchema(data: data);

  final ValidationSchema _schema;

  @override
  String get path => '/api/validate';

  @override
  HttpRequestMethod get method => HttpRequestMethod.post;

  @override
  RequestSchema get payload => _schema;

  @override
  SchemaFactory<JsonResponse> get defaultResponseFactory =>
      JsonResponseFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => ErrorResponseFactory();

  @override
  Map<int, SchemaFactory> get responseFactories => {
        400: ErrorResponseFactory(),
      };
}

// ============================================================================
// Response Schema Implementations
// ============================================================================

class JsonResponse extends Schema {
  const JsonResponse({
    required this.id,
    required this.success,
  });

  final String id;
  final bool success;
}

class JsonResponseFactory extends JsonSchemaFactory<JsonResponse> {
  @override
  JsonResponse fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return JsonResponse(
      id: map['id'] as String,
      success: map['success'] as bool,
    );
  }
}

class JsonResponseWithCount extends Schema {
  const JsonResponseWithCount({
    required this.id,
    required this.success,
    required this.count,
  });

  final String id;
  final bool success;
  final int count;
}

class JsonResponseWithCountFactory
    extends JsonSchemaFactory<JsonResponseWithCount> {
  @override
  JsonResponseWithCount fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return JsonResponseWithCount(
      id: map['id'] as String,
      success: map['success'] as bool,
      count: map['count'] as int,
    );
  }
}

class StringResponse extends Schema {
  const StringResponse({required this.message});

  final String message;
}

class StringResponseFactory extends StringSchemaFactory<StringResponse> {
  @override
  StringResponse fromString(String plainString) {
    return StringResponse(message: plainString);
  }
}

class UserResponse extends Schema {
  const UserResponse({
    required this.id,
    required this.name,
    required this.age,
  });

  final String id;
  final String name;
  final int age;
}

class UserResponseFactory extends JsonSchemaFactory<UserResponse> {
  @override
  UserResponse fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return UserResponse(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
    );
  }
}

class DeleteResponse extends Schema {
  const DeleteResponse({required this.success});

  final bool success;
}

class DeleteResponseFactory extends JsonSchemaFactory<DeleteResponse> {
  @override
  DeleteResponse fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return DeleteResponse(
      success: map['success'] as bool,
    );
  }
}

class AuthResponse extends Schema {
  const AuthResponse({
    required this.token,
    required this.success,
  });

  final String token;
  final bool success;
}

class AuthResponseFactory extends JsonSchemaFactory<AuthResponse> {
  @override
  AuthResponse fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return AuthResponse(
      token: map['token'] as String,
      success: map['success'] as bool,
    );
  }
}

// ignore_for_file: avoid-importing-entrypoint-exports

// ---------------------------------------------------------------------------
// Query parameter tests
// ---------------------------------------------------------------------------

void _queryParamTests() {
  group('Query parameters', () {
    late TestServer server;
    late DioNetworkInvoker networkInvoker;

    tearDown(() async {
      await server.close();
    });

    test('single query parameter is forwarded in the URL', () async {
      server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: (req) => req.method == 'GET' && req.uri.path == '/test/user',
          handler: (req) async {
            expect(
              req.uri.queryParameters['filter'],
              'active',
              reason: 'filter query param should be "active"',
            );
            req.response
              ..statusCode = 200
              ..write('{"id":"1","name":"test","age":20}');
            return req.response;
          },
        ),
      ]);

      networkInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await networkInvoker.request(
        _RequestWithQueryParams(params: const [
          QueryParameter(key: 'filter', value: 'active'),
        ]),
      );

      expect(result, isA<SuccessResponseResult>());
    });

    test('multiple query parameters are all forwarded', () async {
      server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: (req) => req.method == 'GET' && req.uri.path == '/test/user',
          handler: (req) async {
            expect(req.uri.queryParameters['page'], '2');
            expect(req.uri.queryParameters['size'], '10');
            expect(req.uri.queryParameters['sort'], 'name');
            req.response
              ..statusCode = 200
              ..write('{"id":"1","name":"test","age":20}');
            return req.response;
          },
        ),
      ]);

      networkInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await networkInvoker.request(
        _RequestWithQueryParams(params: const [
          QueryParameter(key: 'page', value: 2),
          QueryParameter(key: 'size', value: 10),
          QueryParameter(key: 'sort', value: 'name'),
        ]),
      );

      expect(result, isA<SuccessResponseResult>());
    });

    test('no query parameters produces a clean URL', () async {
      server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: (req) => req.method == 'GET' && req.uri.path == '/test/user',
          handler: (req) async {
            expect(
              req.uri.queryParameters,
              isEmpty,
              reason: 'No query parameters should be appended',
            );
            req.response
              ..statusCode = 200
              ..write('{"id":"1","name":"test","age":20}');
            return req.response;
          },
        ),
      ]);

      networkInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await networkInvoker.request(
        _RequestWithQueryParams(params: const []),
      );

      expect(result, isA<SuccessResponseResult>());
    });

    test('null query parameter value is sent as empty string', () async {
      server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: (req) => req.method == 'GET' && req.uri.path == '/test/user',
          handler: (req) async {
            expect(
              req.uri.queryParameters.containsKey('optional'),
              isTrue,
              reason: 'key with null value should still appear in query string',
            );
            req.response
              ..statusCode = 200
              ..write('{"id":"1","name":"test","age":20}');
            return req.response;
          },
        ),
      ]);

      networkInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await networkInvoker.request(
        _RequestWithQueryParams(params: const [
          QueryParameter(key: 'optional', value: null),
        ]),
      );

      expect(result, isA<SuccessResponseResult>());
    });

    // -----------------------------------------------------------------------
    // List query parameter tests
    // -----------------------------------------------------------------------

    test('list value sends repeated keys (multi format)', () async {
      server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: (req) => req.method == 'GET' && req.uri.path == '/test/user',
          handler: (req) async {
            final tags = req.uri.queryParametersAll['tags'];
            expect(
              tags,
              containsAll(['dart', 'flutter', 'test']),
              reason: 'list value should send each element as a repeated key',
            );
            expect(tags!.length, 3);
            req.response
              ..statusCode = 200
              ..write('{"id":"1","name":"test","age":20}');
            return req.response;
          },
        ),
      ]);

      networkInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await networkInvoker.request(
        _RequestWithQueryParams(params: const [
          QueryParameter(key: 'tags', value: ['dart', 'flutter', 'test']),
        ]),
      );

      expect(result, isA<SuccessResponseResult>());
    });

    test('ListParam with multi format sends repeated keys', () async {
      server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: (req) => req.method == 'GET' && req.uri.path == '/test/user',
          handler: (req) async {
            final ids = req.uri.queryParametersAll['ids'];
            expect(
              ids,
              containsAll(['1', '2', '3']),
              reason: 'ListParam(multi) should produce repeated keys',
            );
            expect(ids!.length, 3);
            req.response
              ..statusCode = 200
              ..write('{"id":"1","name":"test","age":20}');
            return req.response;
          },
        ),
      ]);

      networkInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await networkInvoker.request(
        _RequestWithQueryParams(params: [
          QueryParameter(
            key: 'ids',
            value: ListParam<int>([1, 2, 3], ListFormat.multi),
          ),
        ]),
      );

      expect(result, isA<SuccessResponseResult>());
    });

    test('ListParam with csv format sends comma-separated values', () async {
      server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: (req) => req.method == 'GET' && req.uri.path == '/test/user',
          handler: (req) async {
            final raw = req.uri.queryParameters['roles'];
            expect(
              raw,
              'admin,user,moderator',
              reason: 'ListParam(csv) should produce a '
                  'single comma-separated value',
            );
            req.response
              ..statusCode = 200
              ..write('{"id":"1","name":"test","age":20}');
            return req.response;
          },
        ),
      ]);

      networkInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await networkInvoker.request(
        _RequestWithQueryParams(params: [
          QueryParameter(
            key: 'roles',
            value: ListParam<String>(
              ['admin', 'user', 'moderator'],
              ListFormat.csv,
            ),
          ),
        ]),
      );

      expect(result, isA<SuccessResponseResult>());
    });

    test('duplicate keys are merged into repeated query params', () async {
      server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: (req) => req.method == 'GET' && req.uri.path == '/test/user',
          handler: (req) async {
            final status = req.uri.queryParametersAll['status'];
            expect(
              status,
              containsAll(['active', 'pending']),
              reason: 'duplicate keys should be merged into repeated params',
            );
            expect(status!.length, 2);
            req.response
              ..statusCode = 200
              ..write('{"id":"1","name":"test","age":20}');
            return req.response;
          },
        ),
      ]);

      networkInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await networkInvoker.request(
        _RequestWithQueryParams(params: const [
          QueryParameter(key: 'status', value: 'active'),
          QueryParameter(key: 'status', value: 'pending'),
        ]),
      );

      expect(result, isA<SuccessResponseResult>());
    });

    test('list param mixed with scalar query parameters', () async {
      server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: (req) => req.method == 'GET' && req.uri.path == '/test/user',
          handler: (req) async {
            expect(req.uri.queryParameters['page'], '1');
            final statuses = req.uri.queryParametersAll['status'];
            expect(statuses, containsAll(['active', 'pending']));
            req.response
              ..statusCode = 200
              ..write('{"id":"1","name":"test","age":20}');
            return req.response;
          },
        ),
      ]);

      networkInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await networkInvoker.request(
        _RequestWithQueryParams(params: const [
          QueryParameter(key: 'page', value: 1),
          QueryParameter(key: 'status', value: ['active', 'pending']),
        ]),
      );

      expect(result, isA<SuccessResponseResult>());
    });

    test('empty list value does not append key to URL', () async {
      server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: (req) => req.method == 'GET' && req.uri.path == '/test/user',
          handler: (req) async {
            expect(
              req.uri.queryParametersAll.containsKey('tags'),
              isFalse,
              reason: 'empty list should not append the key to the URL',
            );
            req.response
              ..statusCode = 200
              ..write('{"id":"1","name":"test","age":20}');
            return req.response;
          },
        ),
      ]);

      networkInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final result = await networkInvoker.request(
        _RequestWithQueryParams(params: const [
          QueryParameter(key: 'tags', value: <String>[]),
        ]),
      );

      expect(result, isA<SuccessResponseResult>());
    });
  });
}

class _RequestWithQueryParams extends RequestCommand<ResponseTestUser> {
  _RequestWithQueryParams({required this.params});

  final List<QueryParameter> params;

  @override
  String get path => '/test/user';

  @override
  List<QueryParameter> get queryParameters => params;

  @override
  SchemaFactory<ResponseTestUser> get defaultResponseFactory =>
      ResponseTestUserFactory();

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}

class ErrorResponse extends Schema {
  const ErrorResponse({
    required this.error,
    required this.code,
  });

  final String error;
  final String code;
}

class ErrorResponseFactory extends JsonSchemaFactory<ErrorResponse> {
  @override
  ErrorResponse fromJson(dynamic json) {
    final map = json as Map<String, dynamic>;
    return ErrorResponse(
      error: map['error'] as String,
      code: map['code'] as String,
    );
  }
}
