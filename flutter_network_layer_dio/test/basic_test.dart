import 'dart:io';

import 'package:flutter_network_layer_dio/flutter_network_layer_dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'data/request/request_test_not_found.dart';
import 'data/request/request_test_user.dart';
import 'data/response/response_test_user.dart';
import 'data/test_paths.dart';

void main() {
  group('DioNetworkInvoker GET test', () {
    test('request success', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (request) async => '{"id": "1", "name": "test", "age": 20}',
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final response = await RequestTestUser().invoke(networkManager);

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

    test('request not found', () async {
      final server = await TestServer.createHttpServer(events: const []);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final response = await networkManager.request(RequestTestNotFound());

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
