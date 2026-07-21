import 'package:dart_network_layer_dio/dart_network_layer_dio.dart';
import 'package:dart_network_layer_dio/src/strategy/impl/dio_payload_resolver.dart';
import 'package:dart_network_layer_dio/src/strategy/impl/dio_response_parser.dart';
import 'package:dio/dio.dart';
import 'package:http_test_server/http_test_server.dart';
import 'package:test/test.dart';

import 'data/request/request_test_user.dart';
import 'data/test_paths.dart';

class _TrackingLogger implements NetworkLoggerStrategy {
  int logRequestCount = 0;
  int logSuccessCount = 0;
  int logErrorCount = 0;
  int logUnsuccessfulCount = 0;

  @override
  void logRequest<T extends Schema>(RequestCommand<T> request) =>
      logRequestCount++;

  @override
  void logSuccess<T extends Schema>(
    RequestCommand<T> request,
    SpecifiedResponseResult<T> result,
  ) =>
      logSuccessCount++;

  @override
  void logError<T extends Schema>(
    RequestCommand<T> request,
    NetworkErrorResult<T> result,
  ) =>
      logErrorCount++;

  @override
  void logUnsuccessful<T extends Schema>(
    RequestCommand<T> request,
    SpecifiedResponseResult<T> result,
  ) =>
      logUnsuccessfulCount++;
}

class _TrackingPayloadResolver implements PayloadResolver {
  _TrackingPayloadResolver(this._delegate);

  int callCount = 0;
  final PayloadResolver _delegate;

  @override
  Future<Object?> resolve(RequestSchema payload) {
    callCount++;
    return _delegate.resolve(payload);
  }
}

class _TrackingResponseParser implements ResponseParser {
  _TrackingResponseParser(this._delegate);

  int parseCallCount = 0;
  final ResponseParser _delegate;

  @override
  Future<NetworkResult<T>> parse<T extends Schema>(
    Response<dynamic> response,
    RequestCommand<T> request, {
    String? downloadedFilePath,
  }) {
    parseCallCount++;
    return _delegate.parse(
      response,
      request,
      downloadedFilePath: downloadedFilePath,
    );
  }

  @override
  Future<NetworkResult<T>> handleDioException<T extends Schema>(
    DioException e,
    StackTrace s,
    RequestCommand<T> request,
  ) {
    return _delegate.handleDioException(e, s, request);
  }
}

void main() {
  group('Custom NetworkLoggerStrategy injection', () {
    test(
      'On successful request: logRequest called once, logSuccess called once',
      () async {
        final server = await TestServer.createHttpServer(events: [
          StandardServerEvent(
            matcher:
                ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
            handler: (_) async => '{"id":"1","name":"test","age":20}',
          ),
        ]);
        final logger = _TrackingLogger();
        final invoker = DioNetworkInvoker(
          dio: Dio(
            BaseOptions(baseUrl: 'http://localhost:${server.port}'),
          ),
          networkLoggerStrategy: logger,
        );

        await invoker.send(RequestTestUser());
        expect(logger.logRequestCount, 1);
        expect(logger.logSuccessCount, 1);
        expect(logger.logErrorCount, 0);
        expect(logger.logUnsuccessfulCount, 0);

        await server.close();
      },
    );

    test(
      'On network error: logRequest called once, logError called once',
      () async {
        final logger = _TrackingLogger();
        final invoker = DioNetworkInvoker(
          // invalid port — connection refused
          dio: Dio(BaseOptions(baseUrl: 'http://localhost:1')),
          networkLoggerStrategy: logger,
        );

        await invoker.send(RequestTestUser());
        expect(logger.logRequestCount, 1);
        expect(logger.logErrorCount, 1);
        expect(logger.logSuccessCount, 0);
        expect(logger.logUnsuccessfulCount, 0);
      },
    );

    test(
      'On cancelled request: logRequest called once, logError called once',
      () async {
        final logger = _TrackingLogger();
        final invoker = DioNetworkInvoker(
          dio: Dio(BaseOptions(baseUrl: 'http://localhost:1')),
          networkLoggerStrategy: logger,
        );

        final req = RequestTestUser();
        final future = invoker.send(req);
        invoker.cancelRequest(req);
        await future;

        expect(logger.logRequestCount, 1);
        expect(logger.logErrorCount, 1);
      },
    );
  });

  group('Custom PayloadResolver injection', () {
    test('resolve() called once during send()', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);
      final resolver =
          _TrackingPayloadResolver(const DioPayloadResolver());
      final invoker = DioNetworkInvoker(
        dio: Dio(
          BaseOptions(baseUrl: 'http://localhost:${server.port}'),
        ),
        payloadResolver: resolver,
      );

      await invoker.send(RequestTestUser());
      expect(resolver.callCount, 1);

      await server.close();
    });
  });

  group('Custom ResponseParser injection', () {
    test('parse() called once during successful send()', () async {
      final server = await TestServer.createHttpServer(events: [
        StandardServerEvent(
          matcher: ServerEvent.standardMatcher(paths: [TestPaths.testUser]),
          handler: (_) async => '{"id":"1","name":"test","age":20}',
        ),
      ]);
      final parser =
          _TrackingResponseParser(const DioResponseParser());
      final invoker = DioNetworkInvoker(
        dio: Dio(
          BaseOptions(baseUrl: 'http://localhost:${server.port}'),
        ),
        responseParser: parser,
      );

      await invoker.send(RequestTestUser());
      expect(parser.parseCallCount, 1);

      await server.close();
    });
  });
}
