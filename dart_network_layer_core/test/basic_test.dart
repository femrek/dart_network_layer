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

  group('RequestResultMixin integration', () {
    test('request.result is populated after send() completes', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/basic_test']),
          handler: (request) async => '{"field1": "pong"}',
        ),
      ]);
      final invoker = TestNetworkInvoker(port: server.port);
      await invoker.init('http://${server.server.address.address}');

      final request = RequestTest1(field1: 'ping');
      expect(request.result, isNull,
          reason: 'result should be null before send()');

      final result = await invoker.send(request);
      expect(request.result, isNotNull,
          reason: 'result should be set after send()');
      expect(request.result, same(result),
          reason: 'result should be identical to returned value');
    });

    test('responseFactories per-status-code routing', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: ['/basic_test_error']),
          handler: (request) async =>
              '{"message": "Bad Request", "errorField": "error_value"}',
          responseStatusCode: 400,
        ),
      ]);
      final invoker = TestNetworkInvoker(port: server.port);
      await invoker.init('http://${server.server.address.address}');

      final request = RequestTest1Error(field1: 'trigger_error');
      final result = await invoker.send(request);

      expect(result, isA<SpecifiedResponseResult>(),
          reason:
              'responseFactories[400] should produce SpecifiedResponseResult');
      if (result is SpecifiedResponseResult) {
        final specResult = result as SpecifiedResponseResult;
        expect(specResult.statusCode, 400);
        expect(specResult.data, isA<ResponseTestError>());
      }
    });
  });
}
