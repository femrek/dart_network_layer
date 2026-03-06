// ignore_for_file: avoid_dynamic_calls any type test

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'data/request/request_test_any_data.dart';
import 'data/test_paths.dart';

void main() {
  group('DioNetworkInvoker AnyDataSchema tests', () {
    // Note: AnyDataSchema uses DynamicSchemaFactory which receives the raw
    // response data (as String from HTTP body), not JSON-decoded values.
    // This is intentional - AnyDataSchema accepts ANY data type.

    test('should handle JSON Map string response with AnyDataSchema', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testAnyData]),
          handler: (request) async=> '{"message": "success", "code": 200}',
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final response = await networkManager.request(RequestTestAnyData());

      switch (response) {
        case SuccessResponseResult(:final data):
          expect(data, isA<AnyDataSchema>());
          // Raw string response
          expect(data.data, isA<String>());
          expect(data.data, equals('{"message": "success", "code": 200}'));
        case SpecifiedResponseResult():
          fail('Expected success response, got specified response with status: '
              '${response.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected success response, got error: ${error.message}');
      }

      await server.close();
    });

    test('should handle JSON List string response with AnyDataSchema',
        () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher:
              ServerEvent.standardMatcher(paths: [TestPaths.testAnyDataList]),
          handler: (request) async=> '[{"id": 1}, {"id": 2}, {"id": 3}]',
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final response = await networkManager.request(RequestTestAnyDataList());

      switch (response) {
        case SuccessResponseResult(:final data):
          expect(data, isA<AnyDataSchema>());
          // Raw string response
          expect(data.data, isA<String>());
          expect(data.data, equals('[{"id": 1}, {"id": 2}, {"id": 3}]'));
        case SpecifiedResponseResult():
          fail('Expected success response, got specified response with status: '
              '${response.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected success response, got error: ${error.message}');
      }

      await server.close();
    });

    test('should handle nested JSON string response with AnyDataSchema',
        () async {
      const jsonResponse = '''{"user": {"name": "John", "age": 30}, "items": [1, 2, 3], "metadata": {"total": 100}}''';
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testAnyData]),
          handler: (request) async=> jsonResponse,
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final response = await networkManager.request(RequestTestAnyData());

      switch (response) {
        case SuccessResponseResult(:final data):
          expect(data, isA<AnyDataSchema>());
          // Raw string response
          expect(data.data, isA<String>());
          expect(data.data, equals(jsonResponse));
        case SpecifiedResponseResult():
          fail('Expected success response, got specified response with status: '
              '${response.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected success response, got error: ${error.message}');
      }

      await server.close();
    });

    test('should handle empty JSON object string with AnyDataSchema', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testAnyData]),
          handler: (request) async=> '{}',
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final response = await networkManager.request(RequestTestAnyData());

      switch (response) {
        case SuccessResponseResult(:final data):
          expect(data, isA<AnyDataSchema>());
          expect(data.data, isA<String>());
          expect(data.data, equals('{}'));
        case SpecifiedResponseResult():
          fail('Expected success response, got specified response with status: '
              '${response.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected success response, got error: ${error.message}');
      }

      await server.close();
    });

    test('should handle empty JSON array string with AnyDataSchema', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher:
              ServerEvent.standardMatcher(paths: [TestPaths.testAnyDataList]),
          handler: (request) async=> '[]',
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final response = await networkManager.request(RequestTestAnyDataList());

      switch (response) {
        case SuccessResponseResult(:final data):
          expect(data, isA<AnyDataSchema>());
          expect(data.data, isA<String>());
          expect(data.data, equals('[]'));
        case SpecifiedResponseResult():
          fail('Expected success response, got specified response with status: '
              '${response.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected success response, got error: ${error.message}');
      }

      await server.close();
    });

    test('should handle plain text response with AnyDataSchema', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testAnyData]),
          handler: (request) async=> 'plain text response',
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final response = await networkManager.request(RequestTestAnyData());

      switch (response) {
        case SuccessResponseResult(:final data):
          expect(data, isA<AnyDataSchema>());
          expect(data.data, equals('plain text response'));
          expect(data.data, isA<String>());
        case SpecifiedResponseResult():
          fail('Expected success response, got specified response with status: '
              '${response.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected success response, got error: ${error.message}');
      }

      await server.close();
    });

    test('should handle JSON number string with AnyDataSchema', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testAnyData]),
          handler: (request) async=> '42',
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final response = await networkManager.request(RequestTestAnyData());

      switch (response) {
        case SuccessResponseResult(:final data):
          expect(data, isA<AnyDataSchema>());
          expect(data.data, equals('42'));
          expect(data.data, isA<String>());
        case SpecifiedResponseResult():
          fail('Expected success response, got specified response with status: '
              '${response.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected success response, got error: ${error.message}');
      }

      await server.close();
    });

    test('should handle JSON boolean string with AnyDataSchema', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testAnyData]),
          handler: (request) async=> 'true',
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final response = await networkManager.request(RequestTestAnyData());

      switch (response) {
        case SuccessResponseResult(:final data):
          expect(data, isA<AnyDataSchema>());
          expect(data.data, equals('true'));
          expect(data.data, isA<String>());
        case SpecifiedResponseResult():
          fail('Expected success response, got specified response with status: '
              '${response.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected success response, got error: ${error.message}');
      }

      await server.close();
    });

    test('should handle JSON null string with AnyDataSchema', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testAnyData]),
          handler: (request) async=> 'null',
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final response = await networkManager.request(RequestTestAnyData());

      switch (response) {
        case SuccessResponseResult(:final data):
          expect(data, isA<AnyDataSchema>());
          expect(data.data, equals('null'));
          expect(data.data, isA<String>());
        case SpecifiedResponseResult():
          fail('Expected success response, got specified response with status: '
              '${response.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected success response, got error: ${error.message}');
      }

      await server.close();
    });
  });
}
