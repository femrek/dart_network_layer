import 'dart:async';
import 'dart:io';

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'data/request/request_test_user.dart';
import 'data/test_paths.dart';

void main() {
  group('RequestResultMixin.result via DioNetworkInvoker', () {
    test('request.result is null before send() is called', () {
      final req = RequestTestUser();
      expect(req.result, isNull);
    });

    test(
      'After successful send(), request.result equals the returned result',
      () async {
        final server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher:
                ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
            handler: (_) async => '{"id":"1","name":"test","age":20}',
          ),
        ]);

        final invoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );
        final req = RequestTestUser();
        final res = await invoker.send(req);

        expect(req.result, isNotNull);
        expect(req.result, same(res));
        expect(req.result, isA<SuccessResponseResult>());

        await server.close();
      },
    );

    test(
      'After a cancelled send(), request.result is NetworkErrorResult '
      'with RequestCancelledError',
      () async {
        final completer = Completer<void>();
        final server = await TestServer.createHttpServer(events: [
          RawServerEvent(
            matcher:
                ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
            handler: (req) async {
              await completer.future.timeout(
                const Duration(seconds: 5),
                onTimeout: () {},
              );
              req.response
                ..statusCode = HttpStatus.ok
                ..write('{"id":"1","name":"t","age":1}');
              return req.response;
            },
          ),
        ]);

        final invoker = DioNetworkInvoker.fromBaseUrl(
          'http://localhost:${server.port}',
        );
        final req = RequestTestUser();
        final future = invoker.send(req);

        await Future<void>.delayed(const Duration(milliseconds: 50));
        invoker.cancelRequest(req);

        final res = await future;

        expect(req.result, isNotNull);
        expect(req.result, same(res));
        expect(req.result, isA<NetworkErrorResult>());
        expect(
          (req.result! as NetworkErrorResult).error,
          isA<RequestCancelledError>(),
        );

        completer.complete();
        await server.close();
      },
    );

    test(
      'request.result is set even when the request fails (network error)',
      () async {
        // invalid port — connection refused immediately
        final invoker = DioNetworkInvoker.fromBaseUrl('http://localhost:1');
        final req = RequestTestUser();
        final res = await invoker.send(req);

        expect(req.result, isNotNull);
        expect(req.result, same(res));
        expect(req.result, isA<NetworkErrorResult>());
        expect(
          (req.result! as NetworkErrorResult).error,
          isA<NetworkError>(),
        );
      },
    );
  });
}
