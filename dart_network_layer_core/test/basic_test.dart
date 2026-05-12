import 'package:dart_network_layer_core/dart_network_layer_core.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'utils/test_network_invoker.dart';
import 'utils/test_request_samples.dart';
import 'utils/test_response_samples.dart';

void main() async {
  group('basic tests', () {
    test('Error Response', () async {
      // run the server
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/basic_test_error']),
          handler: (request) async =>
              '{"message": "Bad Request", "errorField": "error_value"}',
          responseStatusCode: 400,
        ),
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/basic_test']),
          handler: (request) async => '{"field1": "pong"}',
        ),
      ]);

      final invoker = TestNetworkInvoker(port: server.port);
      await invoker.init('http://${server.server.address.address}');

      // error response test
      {
        final request = RequestTest1Error(field1: 'trigger_error');
        final result = await invoker.send(request);

        expect(result, isA<SpecifiedResponseResult>());

        // result type check and cast
        if (result is SpecifiedResponseResult<ResponseTest1>) {
          expect(result.statusCode, 400);
          final errorData = result.data;
          expect(errorData, isA<ResponseTestError>());
          if (errorData is ResponseTestError) {
            expect(errorData.errorField, 'error_value');
            expect(errorData.message, 'Bad Request');
          } else {
            fail('Expected ResponseTestError but got ${errorData.runtimeType}');
          }
        } else {
          fail(
              'Expected SpecifiedResponseResult but got ${result.runtimeType}');
        }
      }

      // success response test
      {
        final request = RequestTest1(field1: 'ping');
        final result = await invoker.send(request);

        expect(result, isA<SuccessResponseResult>());

        // result type check
        if (result is SuccessResponseResult<ResponseTest1>) {
          expect(result.data.field1, 'pong');
          expect(result.statusCode, 200);
        } else {
          fail('Expected SuccessResponseResult but got ${result.runtimeType}');
        }
      }
    });
  });

  group('invoker of request object', () {
    test('Request with invoker', () async {
      // run the server
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/test_with_invoker']),
          handler: (request) async => '{"field1": "pong"}',
        ),
      ]);

      final request = RequestTestWithInvoker(
          field1: 'ping',
          port: server.port,
          host: 'http://${server.server.address.address}');
      final result = await request.send();

      expect(result, isA<SuccessResponseResult>());

      // result type check
      if (result is SuccessResponseResult<ResponseTest1>) {
        expect(result.data.field1, 'pong');
        expect(result.statusCode, 200);
      } else {
        fail('Expected SuccessResponseResult but got ${result.runtimeType}');
      }
    });
  });
}
