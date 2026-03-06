import 'dart:async';
import 'dart:io';

import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'data/request/request_test_user.dart';
import 'data/test_paths.dart';

void main() {
  group('DioNetworkInvoker cancel tests', () {
    test('cancelRequest returns NetworkErrorResult with cancel message',
        () async {
      // Server delays response so the cancel has time to fire.
      final completer = Completer<void>();
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (request) async {
            // Wait until the test lets us respond (or forever — the request
            // will be cancelled before we ever reply).
            await completer.future.timeout(
              const Duration(seconds: 5),
              onTimeout: () {},
            );
            request.response
              ..statusCode = HttpStatus.ok
              ..write('{"id":"1","name":"test","age":20}');
            return request.response;
          },
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final request = RequestTestUser();
      final responseFuture = networkManager.request(request);

      // Give Dio a moment to actually send the request before cancelling.
      await Future<void>.delayed(const Duration(milliseconds: 50));

      networkManager.cancelRequest(request);

      final result = await responseFuture;

      expect(
        result,
        isA<NetworkErrorResult>(),
        reason: 'Cancelled request should return NetworkErrorResult',
      );
      final error = (result as NetworkErrorResult).error;
      expect(
        error,
        isA<RequestCancelledError>(),
        reason: 'Error should be a RequestCancelledError',
      );
      expect(
        error.message,
        contains('cancel'),
        reason: 'Error message should mention cancellation',
      );

      completer.complete();
      await server.close();
    });

    test('cancel() on RequestCommand cancels the in-flight request', () async {
      final completer = Completer<void>();
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (request) async {
            await completer.future.timeout(
              const Duration(seconds: 5),
              onTimeout: () {},
            );
            request.response
              ..statusCode = HttpStatus.ok
              ..write('{"id":"1","name":"test","age":20}');
            return request.response;
          },
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final request = RequestTestUser();
      final responseFuture = networkManager.request(request);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Cancel via the command itself, not via the invoker directly.
      request.cancel();

      final result = await responseFuture;

      expect(
        result,
        isA<NetworkErrorResult>(),
        reason: 'Cancelled request should return NetworkErrorResult',
      );
      expect(
        (result as NetworkErrorResult).error,
        isA<RequestCancelledError>(),
        reason: 'Error should be a RequestCancelledError',
      );

      completer.complete();
      await server.close();
    });

    test('cancelAll cancels every active request', () async {
      final completer = Completer<void>();

      // Two different paths that both delay.
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (request) async {
            await completer.future.timeout(
              const Duration(seconds: 5),
              onTimeout: () {},
            );
            request.response
              ..statusCode = HttpStatus.ok
              ..write('{"id":"1","name":"test","age":20}');
            return request.response;
          },
        ),
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testAnyData]),
          handler: (request) async {
            await completer.future.timeout(
              const Duration(seconds: 5),
              onTimeout: () {},
            );
            request.response
              ..statusCode = HttpStatus.ok
              ..write('"any data"');
            return request.response;
          },
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final request1 = RequestTestUser();
      final request2 = _RequestTestAnyData();

      final future1 = networkManager.request(request1);
      final future2 = networkManager.request(request2);

      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(
        networkManager.requestMap.length,
        2,
        reason: 'Both requests should be active before cancelAll',
      );

      networkManager.cancelAll();

      final result1 = await future1;
      final result2 = await future2;

      expect(
        result1,
        isA<NetworkErrorResult>(),
        reason: 'First request should be cancelled',
      );
      expect(
        (result1 as NetworkErrorResult).error,
        isA<RequestCancelledError>(),
        reason: 'First request error should be RequestCancelledError',
      );
      expect(
        result2,
        isA<NetworkErrorResult>(),
        reason: 'Second request should be cancelled',
      );
      expect(
        (result2 as NetworkErrorResult).error,
        isA<RequestCancelledError>(),
        reason: 'Second request error should be RequestCancelledError',
      );
      expect(
        networkManager.requestMap,
        isEmpty,
        reason: 'No active requests should remain after cancelAll',
      );

      completer.complete();
      await server.close();
    });

    test('activeRequests contains command while in-flight, removed after done',
        () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final request = RequestTestUser();

      expect(
        networkManager.requestMap,
        isEmpty,
        reason: 'No active requests before sending',
      );

      final responseFuture = networkManager.request(request);

      // The request is registered synchronously inside `request()` before the
      // first await, so it should already be active here.
      expect(
        networkManager.requestMap.keys,
        contains(request),
        reason: 'Request should be active while in-flight',
      );

      await responseFuture;

      expect(
        networkManager.requestMap.keys,
        isNot(contains(request)),
        reason: 'Request should be removed from active after completion',
      );

      await server.close();
    });

    test('cancelling an already-completed request throws NetworkError',
        () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);

      final networkManager = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );

      final request = RequestTestUser();
      await networkManager.request(request);

      // After the request completes the invoker replaces onCancel with a
      // callback that throws RequestAlreadyCancelledError (invalid state).
      expect(
        request.cancel,
        throwsA(isA<RequestAlreadyCancelledError>()),
        reason: 'Cancelling an already-completed request should throw '
            'RequestAlreadyCancelledError',
      );

      await server.close();
    });

    test(
        'cancelled request does not affect'
        ' a subsequent request on same command', () async {
      final completer = Completer<void>();
      final server = await TestServer.createHttpServer(events: [
        RawServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (request) async {
            await completer.future.timeout(
              const Duration(seconds: 5),
              onTimeout: () {},
            );
            request.response
              ..statusCode = HttpStatus.ok
              ..write('{"id":"1","name":"test","age":20}');
            return request.response;
          },
        ),
      ]);

      // A second server that responds immediately for the retry.
      final fastServer = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (_) async => '{"id":"2","name":"retry","age":30}',
        ),
      ]);

      final slowInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${server.port}',
      );
      final fastInvoker = DioNetworkInvoker.fromBaseUrl(
        'http://localhost:${fastServer.port}',
      );

      final request = RequestTestUser();
      final firstFuture = slowInvoker.request(request);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      slowInvoker.cancelRequest(request);

      final firstResult = await firstFuture;
      expect(firstResult, isA<NetworkErrorResult>());
      expect(
        (firstResult as NetworkErrorResult).error,
        isA<RequestCancelledError>(),
        reason: 'First request error should be RequestCancelledError',
      );

      // Re-use the same command object for a new request on a different
      // invoker.
      final secondResult = await fastInvoker.request(request);

      expect(
        secondResult,
        isA<SuccessResponseResult>(),
        reason: 'Subsequent request with the same command should succeed',
      );

      completer.complete();
      await server.close();
      await fastServer.close();
    });
  });
}

// ---------------------------------------------------------------------------
// Minimal helper request targeting /test/any-data
// ---------------------------------------------------------------------------

class _RequestTestAnyData extends RequestCommand<AnyDataSchema> {
  @override
  String get path => TestPaths.testAnyData;

  @override
  SchemaFactory<AnyDataSchema> get defaultResponseFactory =>
      AnyDataSchema.factory;

  @override
  SchemaFactory get defaultErrorResponseFactory => IgnoredSchema.factory;
}
