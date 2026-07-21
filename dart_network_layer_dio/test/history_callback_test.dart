import 'dart:async';
import 'dart:io';

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'data/request/request_test_user.dart';
import 'data/test_paths.dart';

void main() {
  group('onHistoryUpdate callback', () {
    group('unit (no HTTP)', () {
      test('onHistoryUpdate is null by default', () {
        final invoker = DioNetworkInvoker.fromBaseUrl('http://localhost:8080');
        expect(invoker.onHistoryUpdate, isNull);
      });

      test('Setting onHistoryUpdate stores the callback', () {
        final invoker = DioNetworkInvoker.fromBaseUrl('http://localhost:8080');
        void cb(RequestHistoryEntry? e) {}
        invoker.onHistoryUpdate = cb;
        expect(invoker.onHistoryUpdate, equals(cb));
      });

      test(
          'Setting maxHistoryLength triggers '
          'onHistoryUpdate with null argument', () {
        final invoker = DioNetworkInvoker.fromBaseUrl('http://localhost:8080');
        var nullCalled = false;
        invoker
          ..onHistoryUpdate = (entry) {
            if (entry == null) nullCalled = true;
          }
          ..maxHistoryLength = 10;
        expect(nullCalled, isTrue);
      });
    });

    group('integration', () {
      test('fires when successful request completes', () async {
        final server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
            handler: (_) async => '{"id":"1","name":"t","age":1}',
          ),
        ]);

        final invoker =
            DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
        RequestHistoryEntry? captured;
        invoker.onHistoryUpdate = (entry) => captured = entry;

        await invoker.send(RequestTestUser());

        expect(captured, isNotNull);
        expect(captured!.status, ProgressStatus.success);

        await server.close();
      });

      test('fires when failed request (non-200) completes', () async {
        final server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
            handler: (_) async => '{"error":"not found"}',
            responseStatusCode: 404,
          ),
        ]);

        final invoker =
            DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
        RequestHistoryEntry? captured;
        invoker.onHistoryUpdate = (entry) => captured = entry;

        await invoker.send(RequestTestUser());

        expect(captured, isNotNull);
        expect(captured!.status, ProgressStatus.unsuccessful);

        await server.close();
      });

      test('fires when cancelled request completes; entry has cancelled status',
          () async {
        final completer = Completer<void>();
        final server = await TestServer.createHttpServer(events: [
          RawServerEvent(
            matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
            handler: (req) async {
              await completer.future
                  .timeout(const Duration(seconds: 5), onTimeout: () {});
              req.response
                ..statusCode = HttpStatus.ok
                ..write('{"id":"1","name":"t","age":1}');
              return req.response;
            },
          ),
        ]);

        final invoker =
            DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
        RequestHistoryEntry? captured;
        invoker.onHistoryUpdate = (entry) => captured = entry;

        final request = RequestTestUser();
        final future = invoker.send(request);
        await Future<void>.delayed(const Duration(milliseconds: 50));
        invoker.cancelRequest(request);
        await future;

        expect(captured, isNotNull);
        expect(captured!.status, ProgressStatus.cancelled);

        completer.complete();
        await server.close();
      });

      test('can be cleared by setting to null', () async {
        final server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
            handler: (_) async => '{"id":"1","name":"t","age":1}',
          ),
        ]);

        final invoker =
            DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
        var callCount = 0;
        invoker.onHistoryUpdate = (entry) => callCount++;

        await invoker.send(RequestTestUser());
        expect(callCount, 1);

        invoker.onHistoryUpdate = null;
        await invoker.send(RequestTestUser());
        expect(callCount, 1); // should not increment

        await server.close();
      });

      test('accumulates calls: 3 requests -> 3 callback invocations', () async {
        final server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
            handler: (_) async => '{"id":"1","name":"t","age":1}',
          ),
        ]);

        final invoker =
            DioNetworkInvoker.fromBaseUrl('http://localhost:${server.port}');
        var callCount = 0;
        invoker.onHistoryUpdate = (entry) => callCount++;

        await invoker.send(RequestTestUser());
        await invoker.send(RequestTestUser());
        await invoker.send(RequestTestUser());

        expect(callCount, 3);

        await server.close();
      });
    });
  });
}
