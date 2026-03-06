import 'dart:io';

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dio/dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'data/request/request_test_not_found.dart';
import 'data/request/request_test_user.dart';
import 'data/response/response_test_user.dart';
import 'data/test_paths.dart';

void main() async {
  group('DioNetworkInvoker interceptor test', () {
    test('onRequest and onResponse', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (request) async => '{"id": "1", "name": "test", "age": 20}',
        ),
      ]);

      var onRequestRun = false;
      var onResponseRun = false;

      final request = RequestTestUser();
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://localhost:${server.port}',
          responseType: ResponseType.plain,
        ),
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            onRequestRun = true;
            expect(
              options.path,
              request.path,
              reason: 'the request path should be ${request.path}',
            );
            handler.next(options);
          },
          onResponse: (response, handler) {
            onResponseRun = true;
            expect(
              response.data.toString(),
              contains('id'),
              reason: 'the response should contain id field',
            );
            expect(
              response.data.toString(),
              contains('name'),
              reason: 'the response should contain name field',
            );
            expect(
              response.data.toString(),
              contains('age'),
              reason: 'the response should contain age field',
            );
            handler.next(response);
          },
          onError: (error, handler) {
            fail('The request should result in success.');
          },
        ),
      );

      final networkManager = DioNetworkInvoker.fromDio(dio);

      final response = await networkManager.request(request);

      expect(onRequestRun, isTrue, reason: 'onRequest should run');
      expect(onResponseRun, isTrue, reason: 'onResponse should run');

      switch (response) {
        case SuccessResponseResult(:final data):
          expect(data, isA<ResponseTestUser>());
          expect(data.id, '1');
          expect(data.name, 'test');
          expect(data.age, 20);
        case SpecifiedResponseResult():
          fail('Expected success response, got specified response with status: '
              '${response.statusCode}');
        case NetworkErrorResult(:final error):
          fail('Expected success response, got error: ${error.message}');
      }

      await server.close();
    });

    test('onRequest and onError', () async {
      final server = await TestServer.createHttpServer(events: const []);

      var onRequestRun = false;
      var onErrorRun = false;

      final request = RequestTestNotFound();
      final dio = Dio(
        BaseOptions(
          baseUrl: 'http://localhost:${server.port}',
          responseType: ResponseType.plain,
        ),
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            onRequestRun = true;
            expect(
              options.path,
              request.path,
              reason: 'the request path should be ${request.path}',
            );
            handler.next(options);
          },
          onResponse: (response, handler) {
            fail('The request should result in error.');
          },
          onError: (error, handler) {
            onErrorRun = true;
            expect(
              error.response?.statusCode,
              HttpStatus.notFound,
              reason: 'the error should be 404',
            );
            handler.next(error);
          },
        ),
      );

      final networkManager = DioNetworkInvoker.fromDio(dio);

      final response = await networkManager.request(request);

      expect(onRequestRun, isTrue, reason: 'onRequest should run');
      expect(onErrorRun, isTrue, reason: 'onError should run');

      switch (response) {
        case SuccessResponseResult(:final data):
          fail('Expected error response, got success: $data');
        case SpecifiedResponseResult(:final statusCode):
          expect(
            statusCode,
            HttpStatus.notFound,
            reason: 'Expected 404 status code',
          );
        case NetworkErrorResult():
          // Also acceptable - network error for not found
          break;
      }

      await server.close();
    });
  });
}
